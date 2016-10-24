vbl_piano:
  call   RAMtoOAM

  ld     hl,FRAME
  inc    (hl)

  call   readinput

  call   input_piano

  ld     a,(HWOK_ADC)
  or     a
  call   nz,readpots

  ld     hl,OAMCOPY
  ld     bc,$40
  call   clear

  ;Sequence cursor
  ld     hl,OAMCOPY
  ld     a,39
  ldi    (hl),a		;Y
  ld     a,(NOTEIDX)
  sla    a
  sla    a
  sla    a
  add    32
  ld     d,a
  ldi    (hl),a		;X
  ld     a,T_CURSEQ
  ldi    (hl),a         ;#
  xor    a
  ldi    (hl),a         ;Attr
  ld     b,12
  ld     c,39+8
-:
  ld     a,c
  ldi    (hl),a		;Y
  add    8
  ld     c,a
  ld     a,d
  ldi    (hl),a		;X
  ld     a,T_CURSEQ2
  ldi    (hl),a         ;#
  xor    a
  ldi    (hl),a		;Attr
  dec    b
  jr     nz,-

  ld     a,(FRAME)
  bit    2,a
  jr     z,+++
  push   hl
  ;Keyboard cursor
  ld     a,(NOTECUR_X)
  call   getnotenumber
  pop    hl
  or     a
  ;jr     nz,+
  ;ld     a,128+16
  ;jr     ++
;+:
  call   getnoteypos
  sla    a
  sla    a
  sla    a
  add    64-16
++:
  ldi    (hl),a
  ld     a,(NOTECUR_X)
  sla    a
  sla    a
  sla    a
  add    32
  ldi    (hl),a
  ld     a,T_CURNOTE
  ldi    (hl),a
  xor    a
  ldi    (hl),a
+++:

  call   changescreen           ;Always do this at end of VBL

  ret
