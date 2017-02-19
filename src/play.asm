int_play:
  push   af
  push   bc
  push   de
  push   hl
  call   playv
  pop    hl
  pop    de
  pop    bc
  pop    af
  reti

playv:
  ld     a,(PLAYING)
  or     a
  ret    z

  ld     a,(SYNCMODE)
  cp     SYNC_NONE
  jr     z,play_internal
  cp     SYNC_MIDI
  jr     z,play_midi
  cp     SYNC_LSDJS
  jr     z,play_internal
  cp     SYNC_LSDJMIDI
  jr     z,play_midi
  cp     SYNC_NANO
  jr     z,play_nano

  ret


play_nano:
  ld     a,(BEAT)
  or     a
  ret    z
  ld     c,3
--:
  ld     a,$FF
  ldh    ($01),a
  ld     a,$81		;Master
  ldh    ($02),a
  ld     b,$FF
-:
  dec    b
  jr     nz,-
  ld     a,$00
  ldh    ($01),a
  ld     a,$81		;Master
  ldh    ($02),a
  ld     b,$FF
-:
  dec    b
  jr     nz,-
  dec    c
  jr     nz,--
  jp     play_internal

play_midi:
  ld     a,(MIDINOTECMD)
  bit    0,a
  jr     nz,+
  bit    1,a
  jr     z,++
  xor    a			;Note off
  ldh    ($1A),a
  inc    a
  ld     (WAVEMUTE),a
  ret
+
  xor    a
  ld     (MIDINOTECMD),a	;Note on
  ld     (CUTOFFI),a
  
  call   resetlfo

  ld     a,(MIDINOTENB)
  cp     48
  jr     c,++			;Low limit
  cp     84
  jr     nc,++			;High limit
  sub    48-1
  ld     (LASTNOTE),a
  sla    a
  ld     hl,notelut
  rst    0
  ld     (FLOW),a
  inc    hl
  ld     a,(hl)
  ld     (FHIGH),a
  xor    a
  ld     (WAVEMUTE),a
++:
  jp     play_common

  
  
play_internal:

  call   lfostep

  ld     a,(WAVEMUTE)
  or     a
  jr     nz,++
arp:
  ld     a,(ARPIDX)
  or     a
  jr     z,arpzero
  dec    a
  jr     z,arpone
  ;arptwo
  ld     a,(ARPWORD)
  call   arpcommon
  jr     ++
arpone:
  ld     a,(ARPWORD)
  swap   a
  call   arpcommon
  jr     ++
arpzero:
  xor    a
  call   arpcommon
  jr     ++
+:
  dec    a
++:


  ld     a,(BEAT)
  or     a
  jp     z,nonewnote
  xor    a
  ld     (BEAT),a
  ld     a,(NOTEIDX)
  inc    a
  cp     16
  jr     nz,+
  ld     a,(PLAYING)
  cp     1
  jr     z,++			;Just loop pattern
  ld     a,(SONGPTR)
  inc    a
  cp     160
  jr     nz,+++
  xor    a			;Loop at end of song if no $FF (stop) slot
+++:
  ld     (SONGPTR),a
  ld     hl,SONG
  rst    0
  cp     $FF
  jr     nz,+++
  call   stopp
  ret
+++:
  ld     (SAVECURPATTSLOT),a
  call   loadpattern
++:
  xor    a
+:
  ld     (NOTEIDX),a

  ;Play drum if there's one
  ld     a,(DRUMSMUTE)
  or     a
  jr     nz,++
  ld     a,(NOTEIDX)
  call   getnoteattrl
  srl    a
  srl    a
  srl    a
  and    $1F			;Max drums
  jr     nz,+
  xor    a			;Silence CH4 if drum off
  ldh    ($21),a
  jr     ++
+:
  ;Not drum note off
  dec    a
  jr     z,++			;Just no new drum
  ld     hl,lut_drumsounds
  dec    a
  sla    a			;*8
  sla    a
  sla    a
  ld     d,0
  ld     e,a
  add    hl,de
  ldi    a,(hl)
  ldh    ($10),a		;Set CH1 registers
  ldi    a,(hl)
  ldh    ($11),a
  ldi    a,(hl)
  ldh    ($12),a
  ldi    a,(hl)
  ldh    ($13),a
  ldi    a,(hl)
  and    $7
  or     $B8			;Play !
  ldh    ($14),a

  ldi    a,(hl)
  ldh    ($20),a		;Set CH4 registers
  ldi    a,(hl)
  ldh    ($21),a
  ld     a,(hl)
  ldh    ($22),a
  ld     a,$FF			;Play !
  ldh    ($23),a
++:

  ld     a,(OSCTYPEOVD)
  or     a
  jr     nz,++
  ld     a,(NOTEIDX)		;Change oscillator type even if no note :)
  call   getnoteattrl
  bit    2,a
  ld     a,0
  jr     z,+
  ld     a,1
+:
  ld     (OSCTYPE),a
  jr     +
++:
  ld     a,(OSCTYPEOVD)
  dec    a
  ld     (OSCTYPE),a
+:

  ;Inc sequencer and get new note frequency
  ld     a,(NOTEIDX)
  call   getnotenumber
  bit    7,a
  jr     z,nonewnote	;Empty step, continue note
  and    $7F
  cp     36		;Note off code
  jr     nz,+
  xor    a
  ldh    ($1A),a
  inc    a
  ld     (WAVEMUTE),a
  ret			;Might be dangerous ?
+:
  ld     c,a
  
  ld     a,(NOTEIDX)
  call   getnoteattrl
  ld     b,a
  srl    a
  and    1			;Slide flag
  jr     nz,+
  ld     a,(DOSLIDE)		;Arm slide for next note
  and    $FD
  jr     ++
+:
  ld     a,(DOSLIDE)		;Arm slide for next note
  or     1
++:
  ld     (DOSLIDE),a
  ld     a,b
  and    1
  ld     (ACCENT),a		;Accent flag

  ld     a,(NOTEIDX)
  call   getnoteattrh
  ld     (ARPWORD),a
  
  ld     a,c
  ld     (LASTNOTE),a
  sla    a
  ld     b,a
  ld     hl,notelut
  ld     a,(DOSLIDE)
  bit    0,a
  jr     z,+
  ld     a,b
  rst    0
  ld     (FNLOW),a
  inc    hl
  ld     a,(hl)
  ld     (FNHIGH),a
  ld     a,2
  ld     (DOSLIDE),a
  jr     ++
+:
  ld     a,b
  rst    0
  ld     (FLOW),a
  inc    hl
  ld     a,(hl)
  ld     (FHIGH),a
  xor    a
  ld     (WAVEMUTE),a
++:

  xor    a
  ld     (ARPIDX),a
  ld     (CUTOFFI),a
  
  call   resetlfo
  
nonewnote:

  ld     a,(WAVEMUTE)
  or     a
  ret    nz

  ;Slider/pitch setter
  ld     a,(DOSLIDE)
  bit    1,a
  jp     z,noslide
  ld     a,(FLOW)
  ld     hl,FNLOW
  cp     (hl)
  jr     nz,+
  ld     a,(FHIGH)
  ld     hl,FNHIGH
  cp     (hl)
  jr     nz,+
  ld     a,(DOSLIDE)		;Sliding done !
  res    1,a
  ld     (DOSLIDE),a
  jp     noslide
+:
  ;Slide direction
  ld     a,(FHIGH)
  ld     hl,FNHIGH
  cp     (hl)
  jr     z,+
  jr     nc,slidedown
  jr     slideup
+:
  ld     a,(FLOW)
  ld     hl,FNLOW
  cp     (hl)
  jr     z,noslide
  jr     nc,slidedown
  jr     slideup
slidedown:
  ld     a,(FLOW)
  ld     hl,SLIDESPEED
  sub    (hl)
  ld     (FLOW),a
  jr     nc,+
  ld     a,(FHIGH)
  dec    a
  ld     (FHIGH),a
+:
  ;Check for undershoot
  ld     a,(FHIGH)
  ld     hl,FNHIGH
  cp     (hl)
  jr     z,+
  jr     nc,noslide
+:
  ld     a,(FLOW)
  ld     hl,FNLOW
  cp     (hl)
  jr     nc,noslide
  ld     a,(FNLOW)
  ld     (FLOW),a
  ld     a,(FNHIGH)
  ld     (FHIGH),a
  jr     noslide             
slideup:
  ld     a,(FLOW)
  ld     hl,SLIDESPEED
  add    (hl)
  ld     (FLOW),a
  jr     nc,+
  ld     a,(FHIGH)
  inc    a
  ld     (FHIGH),a
+:
  ;Check for overrshoot
  ld     a,(FHIGH)
  ld     hl,FNHIGH
  cp     (hl)
  jr     c,noslide
  ld     a,(FLOW)
  ld     hl,FNLOW
  cp     (hl)
  jr     c,noslide
  ld     a,(FNLOW)
  ld     (FLOW),a
  ld     a,(FNHIGH)
  ld     (FHIGH),a
  jr     noslide
noslide:



play_common:
  ld     a,(FLOW)
  ld     hl,LFOPITCH		;Apply LFO pitch route
  add    (hl)
  ld     hl,BEND		;Apply pot bending
  add    (hl)
  ldh    ($1D),a		;CH3 Freq low
  ld     a,(FHIGH)
  adc    0
  ld     (FHIGHF),a
  ldh    ($1E),a		;CH3 Freq high


  ;Address generator

  ld     a,(ACCENT)		;Drive (file*16)
  and    1			;Sanitize
  swap   a			;*16
  ld     h,0
  ld     l,a

  ld     a,7
  ld     ($2000),a		;Bankswitch

  ld     d,0
  ld     a,(RESON)		;Resonnance (file)
  ld     b,a
  ld     a,(LFORESON)		;Apply LFO resonance route
  add    b
  cp     15+1
  jr     c,+
  ld     a,15
+:				;Sanitize
  ld     e,a
  add    hl,de

  ld     d,h
  ld     e,l			;*3
  add    hl,hl
  add    hl,de

  ld     a,(OSCTYPE)		;mmap address = 8*8*type*3 (32*3=96 64*2*3=384)
  ld     de,mmap
  or     a
  jr     z,+
  ld     de,mmap+96
+:
  add    hl,de

  ldi    a,(hl)
  ld     b,a
  nop
  nop				;Useless ?
  ldi    a,(hl)
  ld     e,a
  ld     d,(hl)
  ld     a,b
  ld     ($2000),a		;Bankswitch

  ld     hl,cutofflut
  ld     a,(CUTOFFI)
  inc    a
  inc    a
  cp     95			;Full envelope run is always 96 wavetables max
  jr     nc,+
  ld     (CUTOFFI),a
+:
  dec    a
  rst    0
  ld     b,a
  ld     a,(CUTOFFSET)
  add    b
  ld     b,a
  ld     a,(LFOCUTOFF)		;Apply LFO cutoff route
  add    b
  cp     95
  jr     c,+
  ld     a,95
+:
  ld     b,a
  ;ld     a,(PREVCUT)
  ;cp     b
  ;jp     z,samecutoff		;Same cutoff than last one ? No wavetable update
  ld     a,b
  ld     (PREVCUT),a

  swap   a			;0~5F      00000000 01011111
  and    $F0                    ;          00000000 11110000
  ld     l,a

  ld     a,b
  swap   a                      ;          00000000 11110101
  and    $07                    ;          00000000 00000101
  or     $40			;Slot 1    01000000 01000001
  ld     h,a
  
  add    hl,de
  ld     d,h
  ld     e,l

  ld     a,(DISTTYPE)
  or     a
  jp     z,direct
  dec    a
  jp     z,softdist
  dec    a
  jp     z,harddist
nodist:
  ld     de,WAVETABLE
  ;di
  call   loadwave
  ;ei
samecutoff:
  ret

direct:
  ld     de,WAVETABLE
.rept 16
  ldi    a,(hl)
  ld     (de),a
  inc    e
.endr
  jp     nodist

softdist:
  ld     b,h
  ld     c,l
  ld     de,WAVETABLE
.rept 16
  ld     a,(bc)
  inc    bc
  ld     hl,lut_softdist
  add    l
  jr     nc,+
  inc    h
+:
  ld     l,a
  ld     a,(hl)
  ld     (de),a
  inc    e
.endr
  jp     nodist

harddist:
  ld     b,h
  ld     c,l
  ld     de,WAVETABLE
.rept 16
  ld     a,(bc)
  inc    bc
  ld     hl,lut_harddist
  add    l
  jr     nc,+
  inc    h
+:
  ld     l,a
  ld     a,(hl)
  ld     (de),a
  inc    e
.endr
  jp     nodist


getnotenumber:
  ld     hl,SEQ
  ld     d,0
  sla    a	;*4
  sla    a
  ld     e,a
  add    hl,de
  ld     a,(hl)
  ret

getnoteattrl:
  ld     hl,SEQ
  ld     d,0
  sla    a	;*4
  sla    a
  ld     e,a
  inc    de
  add    hl,de
  ld     a,(hl)
  ret
  
getnoteattrh:
  ld     hl,SEQ
  ld     d,0
  sla    a	;*4
  sla    a
  ld     e,a
  inc    de
  inc    de
  add    hl,de
  ld     a,(hl)
  ret
