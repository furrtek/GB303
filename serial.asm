serial:
  push    af
  push    bc
  push    de
  push    hl
  ld      hl,MIDIBUFFER
  ld      a,(MIDIBPUT)
  add     l
  jr      nc,+
  inc     h
+:
  ld      l,a
  ldh     a,($01)
  ld      (hl),a
  ld      a,(MIDIBPUT)
  inc     a
  and     $3F
  ld      (MIDIBPUT),a
  call    serialhnd

  ld      a,(SYNCMODE)
  cp      SYNC_LSDJMIDI
  jr      z,+
  cp      SYNC_NANO
  jr      z,+
  ld      a,$80         ;Slave
  ldh     ($02),a
+:

  pop     hl
  pop     de
  pop     bc
  pop     af
  reti


serialhnd:
  ld      a,(SYNCMODE)
  cp      SYNC_NONE
  ret     z
  cp      SYNC_LSDJS
  jr      z,synch_lsdjslave
  cp      SYNC_LSDJMIDI
  jr      z,sync_lsdjmidi
  cp      SYNC_NANO
  ret     z
  cp      SYNC_MIDI
  jr      z,synch_midi
  ret

sync_lsdjmidi:
  call    sy_common
  or      a
  ret     z
  cp      $80
  ret     c
  cp      $FD
  ret     z
  cp      $FE
  ret     z
  and     $7F
  jr      z,+
  ld      (MIDINOTENB),a
  ld      a,1			;Note on
  ld      (MIDINOTECMD),a
  ret
+:
  ld      a,2			;Note off
  ld      (MIDINOTECMD),a
  ret
  
sy_common:
  ld      a,(MIDIBPUT)
  ld      (MIDIBGET),a
  dec     a
  and     $3F
  ld      hl,MIDIBUFFER
  add     l
  jr      nc,+
  inc     h
+:
  ld      l,a
  ld      a,(hl)
  ret

synch_lsdjslave:
  call    sy_common
  or      a
  jr      nz,+
  xor     a
  ld      (SONGPTR),a
  ld      (LSDJTICK),a
  ld      a,2			;Start to play song from start
  ld      (PLAYING),a
  call    pscommon
  ret
+:
  ld      a,(LSDJTICK)
  inc     a
  cp      6
  jr      nz,+
  ld      a,1
  ld      (BEAT),a
  xor     a
+:
  ld      (LSDJTICK),a
  ret

synch_midi:
  ld      a,1
  ld      (PLAYING),a

  ;See if we got a valid command somewhere in the buffer
  ld      a,(MIDIBGET)
  ld      b,a
-:
  ld      a,b
  ld      hl,MIDIBPUT
  cp      (hl)
  jr      nz,+
  ld      a,b
  ld      (MIDIBGET),a		;Matched put pointer and didn't find anything
  ret
+:
  ld      hl,MIDIBUFFER
  add     l
  jr      nc,+
  inc     h
+:
  ld      l,a
  ld      a,(hl)
  and     $F0			;Ignore channel
  cp      $90			;Note on any channel
  jr      z,midi_noteon
  cp      $80
  jr      z,midi_noteoff
  ld      a,b
  inc     a
  and     $3F
  ld      b,a
  jr      -

midi_noteoff:
  call    MIDI3bytes
  ret     c

  inc     b
  ld      a,b
  and     $3F
  ld      (MIDIBGET),a

  call    getMIDIbyteinc 	;Note value (ignore)
  and     $7F
  ;ld      (MIDINOTENB),a

  call    getMIDIbyteinc        ;Velocity (ignore)
  and     $7F

noteoffvel:
  ld      a,2			;Note off
  ld      (MIDINOTECMD),a
  ret

midi_noteon:
  call    MIDI3bytes
  ret     c

  inc     b
  ld      a,b
  and     $3F
  ld      (MIDIBGET),a

  call    getMIDIbyteinc 	;Note value
  and     $7F
  ld      (MIDINOTENB),a

  call    getMIDIbyteinc        ;Velocity (ignore)
  and     $7F
  jr      z,noteoffvel

  ld      a,1			;Note on
  ld      (MIDINOTECMD),a
  ret


MIDI3bytes:
  push    bc
  ld      a,(MIDIBGET)		;See if we got at least 3 bytes in buffer
  ld      b,a
  ld      a,(MIDIBPUT)
  sub     b
  and     $3F
  pop     bc
  cp      3
  ret

getMIDIbyteinc:
  ld      hl,MIDIBUFFER
  ld      a,(MIDIBGET)
  ld      b,a
  add     l
  jr      nc,+
  inc     h
+:
  ld      l,a
  ld      a,b
  ld      b,(hl)
  inc     a
  and     $3F
  ld      (MIDIBGET),a
  ld      a,b
  ret


;serialhnd:
  ld      a,(LINK_RX)
  cp      $FF
  jr      z,+		;No LSDJ
  cp      $70
  jr      c,+           ;Invalid or no new message
  cp      $7F
  jr      z,+           ;Special
  cp      $7E
  jr      z,+
  cp      $7D
  jr      z,+

  sub     $70
  ld      b,a
  ld      a,(LASTSERIAL)
  cp      $80
  ld      a,b
  jr      nz,++
  cp      $10
  jr      nz,+++
  jr      ++
+++:
  ld      (TOPLAY),a
++:
  ld      (LASTSERIAL),a
+:
  ;ld      a,(LSDJTICK)
  ;inc     a
  ;cp      24
  ;jr      nz,+
  ;ld      a,1
  ;ld      (LSDJSTEP),a
  ;xor     a
+:
  ;ld      (LSDJTICK),a
  ;ld      a,$80
  ;ldh     ($02),a
  
  ;call    play
  
  xor    a
  ldh    ($01),a
  ldh    ($02),a
  ret

