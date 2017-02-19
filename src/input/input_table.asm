input_table:
  call   playstop

  ld     a,(JOYP_CURRENT)	;Select ?
  bit    2,a
  ret    nz

  ld     a,(JOYP_ACTIVE)	;Right
  bit    4,a
  jr     z,+
  ld     a,(JOYP_CURRENT)	;+A ?
  bit    0,a
  jr     z,++
  call   getsongpatt
  ld     a,(hl)
  cp     99
  jr     z,+
  cp     $FF
  jr     nz,+++
  xor    a
+++:
  inc    a
  ld     (hl),a
  call   updatesongpatt
  jr     +
++:
  ld     a,(SONG_CURX)		;Right only
  cp     4
  jr     nz,++
  ld     a,(SONGOFS)
  cp     80
  jr     z,+
  ld     a,80
  ld     (SONGOFS),a
  call   redraw_song
  jr     +
++:
  inc    a
  ld     (SONG_CURX),a
  call   redrawcur_song
+:

  ld     a,(JOYP_ACTIVE)	;Left
  bit    5,a
  jr     z,+
  ld     a,(JOYP_CURRENT)	;+A ?
  bit    0,a
  jr     z,++
  call   getsongpatt
  ld     a,(hl)
  or     a
  jr     z,+
  cp     $FF
  jr     nz,+++
  xor    a
+++:
  dec    a
  ld     (hl),a
  call   updatesongpatt
  jr     +
++:
  ld     a,(SONG_CURX) 		;Left only
  or     a
  jr     nz,++
  ld     a,(SONGOFS)
  or     a
  jr     z,+
  ld     a,0
  ld     (SONGOFS),a
  call   redraw_song
  jr     +
++:
  dec    a
  ld     (SONG_CURX),a
  call   redrawcur_song
+:

  ld     a,(JOYP_ACTIVE)	;Up
  bit    6,a
  jr     z,+
  ld     a,(JOYP_CURRENT)	;+A ?
  bit    0,a
  jr     z,++
  call   getsongpatt
  ld     a,(hl)
  cp     $FF
  jr     nz,+++
  xor    a
  jr     ++++
+++:
  add    10
  cp     99+1
  jr     c,++++
  ld     a,99
++++:
  ld     (hl),a
  call   updatesongpatt
  jr     +
++:
  ld     a,(SONG_CURY)		;Up only
  or     a
  jr     z,+
  dec    a
  ld     (SONG_CURY),a
  call   redrawcur_song
+:

  ld     a,(JOYP_ACTIVE)	;Down
  bit    7,a
  jr     z,+
  ld     a,(JOYP_CURRENT)	;+A ?
  bit    0,a
  jr     z,++
  call   getsongpatt
  ld     a,(hl)
  cp     $FF
  jr     nz,+++
  xor    a
  jr     ++++
+++:
  sub    10
  jr     nc,++++
  xor    a
++++:
  ld     (hl),a
  call   updatesongpatt
  jr     +
++:
  ld     a,(SONG_CURY)		;Down only
  cp     15
  jr     z,+
  inc    a
  ld     (SONG_CURY),a
  call   redrawcur_song
+:

  ld     a,(JOYP_ACTIVE)	;A
  bit    0,a
  jr     z,+
  ld     a,(JOYP_CURRENT)	;+B	End of song
  bit    1,a
  jr     z,+
  call   getsongpatt
  ld     a,$FF
  ld     (hl),a
  call   updatesongpatt
+:

  ret
  
  
redrawcur_song:
  ;Set previous cur to normal
  ld     a,(SONG_PREVX)
  ld     b,a
  sla    a
  add    b			;X*3
  inc    a
  inc    a
  ld     d,0
  ld     e,a
  ld     a,(SONG_PREVY)		;Y*32
  add    $C0+2			;Trick to get +$9800 in the end
  ld     h,4
  ld     l,a
  add    hl,hl
  add    hl,hl
  add    hl,hl
  add    hl,hl
  add    hl,hl
  add    hl,de
  ld     b,2
-:
  di
  call   wait_write
  ld     a,(hl)
  ei
  and    $3F
  di
  call   wait_write
  ldi    (hl),a
  ei
  dec    b
  jr     nz,-

  ;Set current cursor to inverted
  ld     a,(SONG_CURX)
  ld     b,a
  sla    a
  add    b			;X*3
  inc    a
  inc    a
  ld     d,0
  ld     e,a
  ld     a,(SONG_CURY)		;Y*32
  add    $C0+2			;Trick to get +$9800 in the end
  ld     h,4
  ld     l,a
  add    hl,hl
  add    hl,hl
  add    hl,hl
  add    hl,hl
  add    hl,hl
  add    hl,de
  ld     b,2
-:
  di
  call   wait_write
  ld     a,(hl)
  ei
  or     $40
  di
  call   wait_write
  ldi    (hl),a
  ei
  dec    b
  jr     nz,-

  ld     a,(SONG_CURX)
  ld     (SONG_PREVX),a
  ld     a,(SONG_CURY)
  ld     (SONG_PREVY),a
  ret
  
getsongpatt:
  ld     a,(SONG_CURX)
  swap   a                      ;*16
  and    $F0			;Security
  ld     b,a
  ld     a,(SONG_CURY)
  add    b
  ld     b,a
  ld     hl,SONG
  ld     d,0
  ld     a,(SONGOFS)
  ld     e,a
  add    hl,de
  ld     d,0
  ld     e,b
  add    hl,de
  ret

updatesongpatt:
  push   af
  ld     a,(SONG_PREVX)
  ld     b,a
  sla    a
  add    b			;X*3
  inc    a
  inc    a
  ld     d,0
  ld     e,a
  ld     a,(SONG_PREVY)		;Y*32
  add    $C0+2			;Trick to get +$9800 in the end
  ld     h,4
  ld     l,a
  add    hl,hl
  add    hl,hl
  add    hl,hl
  add    hl,hl
  add    hl,hl
  add    hl,de
  pop    af
  cp     $FF
  jr     nz,+
  ld     de,text_eos
  ld     b,TXT_INVERT
  call   maptext
  ret
+:
  ld     b,TXT_INVERT
  call   writeAsmall
  ret

