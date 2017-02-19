setdefaultpal:
  ld     a,%11100100            ;Palette BG
  ldh    ($47),a
  ld     a,%11100100            ;Palette SPR0
  ldh    ($48),a
  ld     a,%00011011            ;Palette SPR1
  ldh    ($49),a
  ret

clearsprites:
  ld     hl,$FE00               ;Empties OAM
  ld     b,40*4
clspr:
  di
  call   wait_hblank
  ld     (hl),$00
  ei
  inc    l                      ;Avoids hardware bug
  dec    b
  jr     nz,clspr
  ld     hl,OAMCOPY
  ld     bc,$A0
  call   clear
  ret

;Sets to zero HL -> HL+BC in VRAM
clear_w:
  ldh    a,($FF)
  push   af
  xor    a
  ldh    ($FF),a
-:
  call   wait_write
  xor    a
  ldi    (hl),a
  dec    bc
  ld     a,c
  or     b
  jr     nz,-
  pop    af
  ldh    ($FF),a
  ret


;a=first tile
;bc=w/h
;hl=vram
mapinc:
  ld     d,a
mapinc_:
  ldh    a,($FF)
  push   af
  xor    a
  ldh    ($FF),a
  push   de
  push   hl
  ld     a,d
mapib:
  ld     d,b
mapia:
  ldi    (hl),a
  inc    a
  dec    d
  jr     nz,mapia
  pop    hl
  ld     de,32
  add    hl,de
  push   hl
  dec    c
  jr     nz,mapib
  pop    hl
  pop    de
  pop    af
  ldh    ($FF),a
  ret

;a=first tile
;bc=w/h
;hl=vram
mapinc_w:
  ld     d,a
  ldh    a,($40)
  bit    7,a
  jr     z,mapinc_
  ldh    a,($FF)
  push   af
  xor    a
  ldh    ($FF),a
  ld     a,d
  push   de
  push   hl
  ld     de,32
--:
  ld     d,b
-:

  push   af
---:
  ldh    a,($41)
  and    3
  cp     3
  jr     nz,---
---:
  ldh    a,($41)
  and    3
  cp     3
  jr     z,---
  pop    af

  ldi    (hl),a
  inc    a
  dec    d
  jr     nz,-
  pop    hl
  add    hl,de
  push   hl
  dec    c
  jr     nz,--
  pop    hl
  pop    de
  pop    af
  ldh    ($FF),a
  ret
  

screen_off:
  call   wait_vbl
  ld     a,%00010001
  ldh    ($40),a
  ret


;de=text
;hl=vram
;b=ascii offset
maptext:
  ldh    a,($FF)
  push   af
  xor    a
  ldh    ($FF),a
  push   hl
maptextlp:
  ld     a,(de)
  cp     $FF
  jr     nz,+
  pop    hl
  pop    af
  ldh    ($FF),a
  ret
+:
  cp     $FE
  jr     nz,+
  pop    hl
  push   de
  ld     de,32
  add    hl,de
  pop    de
  push   hl
  inc    de
  jr     maptextlp
+:
  sub    b
  
  push   af
  ldh    a,($40)
  bit    7,a
  jr     z,+
---:
  ldh    a,($41)
  and    3
  cp     3
  jr     nz,---
---:
  ldh    a,($41)
  and    3
  cp     3
  jr     z,---
+:
  pop    af

  ldi    (hl),a
  inc    de
  jr     maptextlp

;a=first tile
;hl=map
;de=vram
map:
  ld     (MAP_FIRST),a
  ldi    a,(hl)
  ld     (MAP_W),a
  ldi    a,(hl)
  ld     c,a
  push   de

mapb:
  ld     a,(MAP_W)
  ld     b,a
mapa:
  ldi    a,(hl)
  push   hl
  ld     hl,MAP_FIRST
  add    (hl)
  pop    hl
  call   wait_write
  ld     (de),a
  inc    de
  dec    b
  jr     nz,mapa

  pop    de
  ld     a,e
  add    32
  jr     nc,+
  inc    d
+:
  ld     e,a
  push   de

  dec    c
  jr     nz,mapb
  pop    de
  ret

wait_vbl:
  ;di
  ldh    a,($40)
  rlca
  jr     nc,+
wait_vbll:
  ldh    a,($44)
  cp     144
  jr     c,wait_vbll
+:
  ;ei
  ret

clearbkg:
  ld     de,18*32
  ld     hl,$9800
-:
  xor    a
  di
  call   wait_write
  ldi    (hl),a
  ei
  dec    de
  ld     a,e
  or     d
  jr     nz,-

  ld     de,18*32               ;Window
  ld     hl,$9C00
-:
  xor    a
  di
  call   wait_write
  ldi    (hl),a
  ei
  dec    de
  ld     a,e
  or     d
  jr     nz,-
  ret
  
writeDE:
  ld     a,d
  swap   a
  and    $F
  call   checkhex
  add    16
  di
  call   wait_write
  ldi    (hl),a
  ei
  ld     a,d
  and    $F
  call   checkhex
  add    16
  di
  call   wait_write
  ldi    (hl),a
  ei
  ld     a,e
  swap   a
  and    $F
  call   checkhex
  add    16
  di
  call   wait_write
  ldi    (hl),a
  ei
  ld     a,e
  and    $F
  call   checkhex
  add    16
  di
  call   wait_write
  ldi    (hl),a
  ei
  ret
 
writeAsmall:
  call   bin2bcd
  push   bc
  ld     c,a
  and    $F0
  swap   a
  add    $30
  sub    b
  di
  call   wait_hblank
  ldi    (hl),a
  ei
  ld     a,c
  and    $0F
  add    $30
  sub    b
  di
  call   wait_hblank
  ld     (hl),a
  ei
  pop    bc
  ret

writeAhex:
  push   bc
  ld     c,a
  and    $F0
  swap   a
  call   checkhex
  add    $30
  sub    b
  di
  call   wait_hblank
  ldi    (hl),a
  ei
  ld     a,c
  and    $0F
  call   checkhex
  add    $30
  sub    b
  di
  call   wait_hblank
  ld     (hl),a
  ei
  pop    bc
  ret

checkhex:
  cp     $0A
  ret    c
  add    7
  ret

wait_write:
  push   af
-:
  ldh    a,($41)
  bit    1,a
  jr     nz,-
  pop    af
  ret
  
wait_hblank:
  push   af
  ldh    a,($40)
  bit    7,a
  jr     nz,+
  pop    af
  ret
+:
-:
  ldh    a,($41)
  and    3
  cp     3
  jr     nz,-
-:
  ldh    a,($41)
  and    3
  jr     nz,-
  pop    af
  ret

RAMtoOAM:
  ;Now with 0% DMA !
  ld     hl,$DF00
  ld     de,$FE00
  ld     b,4*24		;24 sprites to copy
-:
  ldi    a,(hl)
  di
  call   wait_hblank
  ld     (de),a
  ei
  inc    e
  dec    b
  jr     nz,-
  ret

   .INCLUDE "common\loadtile.asm"
