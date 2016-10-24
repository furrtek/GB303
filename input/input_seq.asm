input_seq:
  call   playstop
  
  ld     a,(JOYP_CURRENT)	;Select ?
  bit    2,a
  ret    nz
  
  ld     a,(JOYP_ACTIVE)	;Up:
  bit    6,a
  jr     z,+
  ld     a,(JOYP_CURRENT)	;Up+A
  bit    0,a
  jr     z,++
  ld     a,(SEQ_CURX)
  sla    a
  ld     hl,jt_seqinputup
  rst    0
  inc    hl
  ld     h,(hl)
  ld     l,a
  call   dojump
  jr     +
++:
  ld     a,(PLAYING)
  or     a
  jr     nz,+
  ld     a,(NOTEIDX)            ;Just up
  or     a
  jr     nz,++
  ld     a,15+1			;Wrap around
++:
  dec    a
  ld     (NOTEIDX),a
+:
  
  ld     a,(JOYP_ACTIVE)	;Down:
  bit    7,a
  jr     z,+
  ld     a,(JOYP_CURRENT)	;Down+A
  bit    0,a
  jr     z,++
  ld     a,(SEQ_CURX)
  sla    a
  ld     hl,jt_seqinputdown
  rst    0
  inc    hl
  ld     h,(hl)
  ld     l,a
  call   dojump
  jr     +
++:
  ld     a,(PLAYING)
  or     a
  jr     nz,+
  ld     a,(NOTEIDX)		;Just down
  cp     15
  jr     nz,++
  ld     a,-1			;Wrap around
++:
  inc    a
  ld     (NOTEIDX),a
+:

  ld     a,(JOYP_ACTIVE)	;Left:
  bit    5,a
  jr     z,+
  ld     a,(JOYP_CURRENT)       ;Left+A
  bit    0,a
  jr     z,++
  ld     a,(SEQ_CURX)
  sla    a
  ld     hl,jt_seqinputleft
  rst    0
  inc    hl
  ld     h,(hl)
  ld     l,a
  call   dojump
  jr     +
++:
  ld     a,(SEQ_CURX)		;Just left
  or     a
  jr     z,+
  dec    a
  ld     (SEQ_CURX),a
+:

  ld     a,(JOYP_ACTIVE)	;Right:
  bit    4,a
  jr     z,+
  ld     a,(JOYP_CURRENT)       ;Right+A
  bit    0,a
  jr     z,++
  ld     a,(SEQ_CURX)
  sla    a
  ld     hl,jt_seqinputright
  rst    0
  inc    hl
  ld     h,(hl)
  ld     l,a
  call   dojump
  jr     +
++:
  ld     a,(SEQ_CURX)		;Just right
  cp     5
  jr     z,+
  inc    a
  ld     (SEQ_CURX),a
+:

  ld     a,(JOYP_ACTIVE)	;A
  bit    0,a
  jr     z,+
  ld     a,(PLAYING)		;Nothing if playing
  or     a
  jr     nz,+

  ld     a,(JOYP_CURRENT)	;B
  bit    1,a
  jr     z,++
  ld     a,(SEQ_CURX)
  sla    a
  ld     hl,jt_seqinputB
  rst    0
  inc    hl
  ld     h,(hl)
  ld     l,a
  call   dojump
  jr     +
++:
  				;A only
  ld     a,(SEQ_CURX)		;On notes column
  or     a
  jr     nz,++
  ld     a,(NOTEIDX)
  call   getnotenumber          ;Insert last input note
  bit    7,a
  jr     z,+++			;See if note is empty
  ld     (LASTNOTEINPUT),a	;Copy
  jr     +
+++:
  ld     a,(LASTNOTEINPUT)
  bit    7,a
  jr     z,+
  ld     (hl),a 		;Paste
  call   redrawnote_seq
  jr     +
++:
  ld     a,(SEQ_CURX)		;On drums column
  cp     5
  jr     nz,+
  ld     a,(NOTEIDX)
  call   getnoteattrl		;See if drum is empty
  and    $F8
  cp     1+1
  jr     c,+++
  ld     (LASTDRUMINPUT),a	;Copy
  jr     +
+++:
  ld     a,(LASTDRUMINPUT)
  and    $F8			;Security
  ld     b,a
  ld     a,(NOTEIDX)
  call   getnoteattrl           ;Insert last input drum
  and    7
  or     b
  ld     (hl),a                 ;Paste
  call   redrawdrum_seq
+:

  ret


jt_seqinputup:
.dw seq_inc_octave
.dw seq_toggle_accent
.dw seq_toggle_slide
.dw seq_toggle_osc
.dw seq_inc_arph
.dw seq_inc_drumh

jt_seqinputdown:
.dw seq_dec_octave
.dw seq_toggle_accent
.dw seq_toggle_slide
.dw seq_toggle_osc
.dw seq_dec_arph
.dw seq_dec_drumh

jt_seqinputleft:
.dw seq_dec_note
.dw seq_toggle_accent
.dw seq_toggle_slide
.dw seq_toggle_osc
.dw seq_dec_arp
.dw seq_dec_drum

jt_seqinputright:
.dw seq_inc_note
.dw seq_toggle_accent
.dw seq_toggle_slide
.dw seq_toggle_osc
.dw seq_inc_arp
.dw seq_inc_drum
  
jt_seqinputB
.dw seq_disable_note
.dw seq_disable_accent
.dw seq_disable_slide
.dw seq_disable_osc
.dw seq_disable_arp
.dw seq_disable_drum



seq_inc_note:
  ld     a,(NOTEIDX)
  call   getnotenumber
  cp     36+$80			;If note was off, set to on, C-2
  jr     nz,+
  xor    a			;C-2
  jr     ++
+:
  inc    a
  ld     b,a
  and    $7F
  cp     36
  ret    z
  ld     a,b
++:
  or     $80
  ld     (hl),a
  ld     (LASTNOTEINPUT),a
  call   redrawnote_seq
  ret

seq_inc_arp:
  ld     a,(NOTEIDX)
  call   getnoteattrh
  inc    a
  ld     (hl),a
  call   redrawarp_seq
  ret

seq_inc_drum:
  ld     a,(NOTEIDX)
  call   getnoteattrl
  and    7
  ld     b,a
  ld     a,(hl)
  add    8
  and    $F8
  ld     (LASTDRUMINPUT),a
  or     b
  ld     (hl),a
  call   redrawdrum_seq
  ret

seq_dec_note:
  ld     a,(NOTEIDX)
  call   getnotenumber
  dec    a
  ld     b,a
  and    $7F
  cp     $7F
  jr     nz,+
-:
  ld     a,36+$80		;Cap to note off
  jr     ++
+:
  cp     36-1			;Compensate for previous DEC A
  jr     z,-
  ld     a,b
  or     $80
++:
  ld     (hl),a
  ld     (LASTNOTEINPUT),a
  call   redrawnote_seq
  ret

seq_dec_arp:
  ld     a,(NOTEIDX)
  call   getnoteattrh
  dec    a
  ld     (hl),a
  call   redrawarp_seq
  ret
  
seq_dec_drum:
  ld     a,(NOTEIDX)
  call   getnoteattrl
  and    7
  ld     b,a
  ld     a,(hl)
  sub    8
  and    $F8
  ld     (LASTDRUMINPUT),a
  or     b
  ld     (hl),a
  call   redrawdrum_seq
  ret

seq_dec_octave:
  ld     a,(NOTEIDX)
  call   getnotenumber
  and    $7F
  cp     12
  jr     nc,+
-:
  ld     a,36+$80		;Cap to note off
  jr     ++
+:
  cp     36
  jr     z,-
  sub    12			;Sub octave
  or     $80
++:
  ld     (hl),a
  ld     (LASTNOTEINPUT),a
  call   redrawnote_seq
  ret

seq_dec_arph:
  ld     a,(NOTEIDX)
  call   getnoteattrh
  sub    $10
  ld     (hl),a
  call   redrawarp_seq
  ret
  
seq_dec_drumh:
  ld     a,(NOTEIDX)
  call   getnoteattrl
  and    7
  ld     b,a
  ld     a,(hl)
  sub    $20			;1<<5
  and    $F8
  ld     (LASTDRUMINPUT),a
  or     b
  ld     (hl),a
  call   redrawdrum_seq
  ret


seq_inc_octave:
  ld     a,(NOTEIDX)
  call   getnotenumber
  cp     36+$80			;If note was off, set to on, C-2
  jr     nz,+
  xor    a			;C-2
  jr     ++
+:
  and    $7F
  add    12                     ;Add octave
  cp     36			;3 octaves * 12 notes
  ret    nc
++:
  or     $80
  ld     (hl),a
  ld     (LASTNOTEINPUT),a
  call   redrawnote_seq
  ret

seq_inc_arph:
  ld     a,(NOTEIDX)
  call   getnoteattrh
  add    $10
  ld     (hl),a
  call   redrawarp_seq
  ret
  
seq_inc_drumh:
  ld     a,(NOTEIDX)
  call   getnoteattrl
  and    7
  ld     b,a
  ld     a,(hl)
  add    $20			;1<<5
  and    $F8
  ld     (LASTDRUMINPUT),a
  or     b
  ld     (hl),a
  call   redrawdrum_seq
  ret

seq_disable_note:
  ld     a,(NOTEIDX)            ;See if note is already empty
  call   getnotenumber
  bit    7,a
  jr     nz,+
  ld     a,36+$80		;Note off if empty
  jr     ++
+:
  and    $7F			;Disable note if note
  cp     36
  jr     nz,++
  xor    a
++:
  ld     (hl),a
  call   redrawnote_seq
  ret

seq_disable_accent:
  ld     a,(NOTEIDX)
  call   getnoteattrl
  and    $FE
  ld     (hl),a
  call   redrawaccent_seq
  ret

seq_disable_slide:
  ld     a,(NOTEIDX)
  call   getnoteattrl
  and    $FD
  ld     (hl),a
  call   redrawslide_seq
  ret

seq_disable_osc:
  ld     a,(NOTEIDX)
  call   getnoteattrl
  xor    $FB
  ld     (hl),a
  call   redrawosc_seq
  ret

seq_disable_arp:
  ld     a,(NOTEIDX)
  call   getnoteattrh
  xor    a			;Clear arp
  ld     (hl),a
  call   redrawarp_seq
  ret

seq_disable_drum:
  ld     a,(NOTEIDX)
  call   getnoteattrl
  and    7			;Clear drum #
  ld     (hl),a
  call   redrawdrum_seq
  ret


seq_toggle_accent:
  ld     a,(NOTEIDX)
  call   getnoteattrl
  xor    $01
  ld     (hl),a
  call   redrawaccent_seq
  ret

seq_toggle_slide:
  ld     a,(NOTEIDX)
  call   getnoteattrl
  xor    $02
  ld     (hl),a
  call   redrawslide_seq
  ret

seq_toggle_osc:
  ld     a,(NOTEIDX)
  call   getnoteattrl
  xor    $04
  ld     (hl),a
  call   redrawosc_seq
  ret
