vbl_credits:
  di

  ld     hl,FRAME
  inc    (hl)

  ld     a,(COPPERFLIP)
  xor    1
  ld     (COPPERFLIP),a

  ;COPPERFLIP = 0: Draw in COPPERA, render from COPPERB
  ;COPPERFLIP = 1: Draw in COPPERB, render from COPPERA

  ld     hl,COPPERA
  ld     a,<COPPERB
  ld     (COPPERI),a
  ld     a,(COPPERFLIP)
  or     a
  jr     z,+
  ld     hl,COPPERB
  ld     a,<COPPERA
  ld     (COPPERI),a
+

  ei

  ld     de,lut_cos
  ld     a,(COPPERANIM)
  inc    a
  ld     (COPPERANIM),a
  add    e
  ld     e,a
  jr     nc,+
  inc    d
+:
  ld     a,(de)
  sra    a
  sra    a
  sra    a
  sra    a
  ld     b,a

  ld     a,(COPPEROA)
  add    b
  ld     (COPPEROA),a
  ld     a,(COPPEROB)
  add    b
  add    b
  add    b
  ld     (COPPEROB),a

  ld     b,72
-:
  ld     de,lut_cos
  ld     a,(COPPEROA)
  srl    a
  srl    a
  add    b
  sla    a
  sla    a
  add    e
  ld     e,a
  jr     nc,+
  inc    d
+:
  ld     a,(de)
  add    $80
  rlca
  rlca
  and    3
  cp     3
  jr     nz,+++
  ;Transparency :)
  ld     de,lut_cos
  ld     a,(COPPEROB)
  srl    a
  srl    a
  srl    a
  add    b
  sla    a
  sla    a
  sla    a
  sla    a
  add    e
  ld     e,a
  jr     nc,+
  inc    d
+:
  ld     a,(de)
  add    $80
  rlca
  and    1
  jr     nz,+
  ld     a,2
+:
  inc    a
+++:
  ld     de,lut_copper
  add    e
  jr     nc,+
  inc    d
+:
  ld     e,a
  ld     a,(de)
  ldi    (hl),a
  dec    b
  jr     nz,-

  call   RAMtoOAM

  call   readinput

  ld     a,(JOYP_ACTIVE)
  or     a
  jr     z,+
  ld     hl,hblank+1
  ld     a,<int_play
  ldi    (hl),a
  ld     a,>int_play
  ld     (hl),a
  call   setscreen
+:

  ld     a,(HWOK_ADC)
  or     a
  call   nz,readpots

  ld     hl,OAMCOPY
  ld     bc,$40
  call   clear

  ret
  
lut_copper:
  .db   %11100100
  .db   %10100101
  .db   %00011010
  .db   %00011011

hblank_copperline:
  push   af
  push   hl
  ldh    a,($44)
  bit    0,a
  jr     nz,+
  srl    a
  ld     l,a
  ld     a,(COPPERI)
  add    l
  ld     l,a
  ld     h,$DE
  ld     a,(hl)
  ldh    ($47),a
+:
  pop    hl
  pop    af
  reti
