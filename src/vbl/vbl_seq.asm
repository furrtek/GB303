vbl_seq:
  call   RAMtoOAM
  
  call   refresh_seq

  ld     hl,FRAME
  inc    (hl)

  call   readinput

  call   input_seq

  ld     a,(HWOK_ADC)
  or     a
  call   nz,readpots

  ld     hl,OAMCOPY
  ld     bc,$40
  call   clear
  
  call   changescreen           ;Always do this at end of VBL

  ret
  
  
redrawnote_seq:
  ld     a,(NOTEIDX)
  ld     b,TXT_INVERT
redrawnote_seq_a:
  push   bc
  push   af
  call   getnotename
  pop    af
  ld     hl,$9800+(32*1)+1
  ld     bc,32
  inc    a
-:
  add    hl,bc
  dec    a
  jr     nz,-
  pop    bc
  call   maptext
  ret
  
redrawaccent_seq:
  ld     a,(NOTEIDX)
  ld     b,TXT_INVERT
redrawaccent_seq_a:
  push   bc
  push   af
  ld     hl,$9800+(32*1)+5
  ld     bc,32
  inc    a
-:
  add    hl,bc
  dec    a
  jr     nz,-
  pop    af
  push   hl
  call   getnoteattrl
  pop    hl
  bit    0,a
  ld     a,'.'			;Checkmark
  jr     nz,+
  ld     a,'-'
+:
  pop    bc
  sub    b
  call   wait_write
  ld     (hl),a
  ret
  
redrawslide_seq:
  ld     a,(NOTEIDX)
  ld     b,TXT_INVERT
redrawslide_seq_a:
  push   bc
  push   af
  ld     hl,$9800+(32*1)+7
  call   getline
  pop    af
  push   hl
  call   getnoteattrl
  pop    hl
  bit    1,a
  ld     a,'.'			;Checkmark
  jr     nz,+
  ld     a,'-'
+:
  pop    bc
  sub    b
  call   wait_write
  ld     (hl),a
  ret
  
redrawosc_seq:
  ld     a,(NOTEIDX)
  ld     b,TXT_INVERT
redrawosc_seq_a:
  push   bc
  push   af
  ld     hl,$9800+(32*1)+9
  call   getline
  pop    af
  push   hl
  call   getnoteattrl
  pop    hl
  bit    2,a
  ld     a,'&'			;Oscillator icons
  jr     nz,+
  ld     a,'$'
+:
  pop    bc
  sub    b
  call   wait_write
  ld     (hl),a
  ret
  
redrawarp_seq:
  ld     a,(NOTEIDX)
  ld     b,TXT_INVERT
redrawarp_seq_a:
  push   bc
  push   af
  ld     hl,$9800+(32*1)+11
  call   getline
  pop    af
  push   hl
  call   getnoteattrh
  pop    hl
  pop    bc
  call   writeAhex
  ret

redrawdrum_seq:
  ld     a,(NOTEIDX)
  ld     b,TXT_INVERT
redrawdrum_seq_a:
  push   bc
  push   af
  ld     hl,$9800+(32*1)+14
  call   getline
  pop    af
  push   hl
  call   getnoteattrl
  srl    a
  srl    a
  srl    a
  and    $1F
  sla    a
  ld     b,a
  sla    a
  add    b			;*6
  ld     hl,text_drums
  ld     d,0
  ld     e,a
  add    hl,de
  ld     d,h
  ld     e,l
  pop    hl
  pop    bc
  call   maptext
  ret
  

refresh_seq:
  ld     hl,SEQ_CURX
  ld     a,(SEQ_PREVX)
  cp     (hl)
  jr     nz,+
  ld     hl,SEQ_PREVY		;VARIABLE MESS ! Bugged while playing
  ld     a,(NOTEIDX)
  cp     (hl)
  ret    z
+:
  ld     a,(SEQ_PREVX)
  jr     ++
+:
  ld     a,(SEQ_CURX)
++:
  ld     (SEQ_TOERASEX),a
  ld     a,(SEQ_CURX)
  ld     (SEQ_PREVX),a
  ld     a,(NOTEIDX)
  ld     a,(SEQ_PREVY)
  ld     b,a
  ld     a,(NOTEIDX)
  ld     (SEQ_PREVY),a
  ld     a,b

  ;Set previous as normal
  ld     hl,$9800+(32*1)

  call   getline
  push   hl
  ld     hl,lut_seqlayout
  ld     a,(SEQ_TOERASEX)
  sla    a
  ld     d,0
  ld     e,a
  add    hl,de
  ldi    a,(hl)
  ld     b,a
  ldi    a,(hl)
  ld     c,a
  pop    hl
  ld     a,l
  add    b
  jr     nc,+
  inc    h
+:
  ld     l,a
-:
  di
  call   wait_write
  ld     a,(hl)
  ei
  and    %10111111		;Clear inverted
  di
  call   wait_write
  ldi    (hl),a
  ei
  dec    c
  jr     nz,-

  ;Set current as inverted
showcur_seq:			;Called just here by seq init
  ld     a,(NOTEIDX)
  ld     hl,$9800+(32*1)
  call   getline
  push   hl
  ld     hl,lut_seqlayout
  ld     a,(SEQ_CURX)
  sla    a
  ld     d,0
  ld     e,a
  add    hl,de
  ldi    a,(hl)
  ld     b,a
  ldi    a,(hl)
  ld     c,a
  pop    hl
  ld     a,l
  add    b
  jr     nc,+
  inc    h
+:
  ld     l,a
-:
  di
  call   wait_write
  ld     a,(hl)
  ei
  or     %01000000		;Set inverted
  di
  call   wait_write
  ldi    (hl),a
  ei
  dec    c
  jr     nz,-
  ret
