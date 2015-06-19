changescreen:
  ld     a,(JOYP_ACTIVE)	;Select ?
  bit    2,a
  jr     z,+
  call   setscreenmap
  jr     ++
+:
  ld     a,(JOYP_CURRENT)
  bit    2,a
  jr     nz,++
  ld     a,(SCREENMAP)		;Is screenmap displayed ?
  or     a
  ret    z
  ld     hl,OAMCOPY+16*4	;Yes, remove it
  ld     bc,8*4
  call   clear
  xor    a
  ld     (SCREENMAP),a
  ret
++:

  ld     a,(JOYP_ACTIVE)	;Up:
  bit    6,a
  jr     z,+
  ld     a,(CURSCREEN)		;0 (top row, liv) ?
  or     a
  jr     z,+
  cp     6			;Bottom row ?
  jr     nz,++
  ld     a,(SCREENMID)		;Yes, retrieve middle screen index
  or     a
  jr     nz,+++			;Security
  inc    a
  jr     +++
++:
  xor    a			;No: forcibly in middle row
+++:
  ld     (CURSCREEN),a
  jr     setscreen
+:

  ld     a,(JOYP_ACTIVE)	;Down:
  bit    7,a
  jr     z,+
  ld     a,(CURSCREEN)
  cp     6			;Bottom row ?
  jr     z,+
  or     a                      ;0 (top row, liv) ?
  jr     nz,++
  ld     a,(SCREENMID)		;Yes, retrieve middle screen index
  or     a
  jr     nz,+++			;Security
  inc    a
  jr     +++
++:
  ld     a,(PLAYING)		;Can't go in MEM screen if playing
  or     a
  jr     nz,+
  ld     a,6			;No: forcibly in middle row
+++:
  ld     (CURSCREEN),a
  jr     setscreen
+:

  ld     a,(JOYP_ACTIVE)	;Right:
  bit    4,a
  jr     z,+
  ld     a,(CURSCREEN)		;0 (top row, liv) or 6 (bottom row, mem) ?
  or     a
  jr     z,+
  cp     6
  jr     z,+
  inc    a			;No: next screen in middle row
  cp     5+1
  jr     nz,++
  ld     a,1
++:
  ld     (CURSCREEN),a
  ld     (SCREENMID),a
  jr     setscreen
+:

  ld     a,(JOYP_ACTIVE)	;Left:
  bit    5,a
  ret    z
  ld     a,(CURSCREEN)		;0 (top row, liv) or 6 (bottom row, mem) ?
  or     a
  ret    z
  cp     6
  ret    z
  dec    a			;No: prev screen in middle row
  jr     nz,++
  ld     a,5
++:
  ld     (CURSCREEN),a
  ld     (SCREENMID),a
  jr     setscreen

setscreen:
  ld     a,(CURSCREEN)
  cp     7
  ret    nc			;Security
  call   ss_common
  ld     a,(CURSCREEN)
  ld     hl,lut_setupscr
  sla    a
  rst    0
  inc    hl
  ld     h,(hl)
  ld     l,a
  jp     hl

lut_setupscr:
  .dw    setscreen_live		;Top
  .dw    setscreen_table        ;Middle
  .dw    setscreen_seq          ;Middle
  .dw    setscreen_piano        ;Middle
  .dw    setscreen_xy           ;Middle
  .dw    setscreen_config       ;Middle
  .dw    setscreen_loadsave     ;Bottom

ss_common:
  call   clearsprites
  call   clearbkg
  call	 screen_off
  call   setscreenmap
  xor    a
  ld     (DRUMSMUTE),a
  ret

setscreenmap:
  ld     hl,OAMCOPY+4*16	;16 first sprites are for UI, next 8 are for screen map (7 used)
  
  ;Center line
  ld     b,0
-:
  ld     a,84			;Y
  ldi    (hl),a
  ld     a,b
  sla    a
  sla    a
  sla    a
  add    68
  ldi    (hl),a			;X
  ld     a,b
  add    T_SCREENMAP+1
  ldi    (hl),a			;Tile
  
  ld     a,(CURSCREEN)
  dec    a
  cp     b
  ld     a,0			;Inverted palette
  jr     z,+
  ld     a,1<<4
+:
  ldi    (hl),a			;Attr
  inc    b
  ld     a,b
  cp     5
  jr     nz,-
  
  ;Top sprite
  ld     b,1<<4
  ld     a,76
  ldi    (hl),a
  ld     a,(CURSCREEN)
  or     a
  jr     nz,+
  ld     a,(SCREENMID)
  ld     b,0
+:
  cp     6
  jr     nz,+
  ld     a,(SCREENMID)
+:
  dec    a
  sla    a
  sla    a
  sla    a
  add    68
  ldi    (hl),a			;X
  ld     a,T_SCREENMAP
  ldi    (hl),a			;Tile
  ld     a,b
  ldi    (hl),a

  ;Bottom sprite
  ld     a,(PLAYING)		;Don't show MEM screen if playing
  or     a
  jr     nz,++
  ld     b,1<<4
  ld     a,92
  ldi    (hl),a
  ld     a,(CURSCREEN)
  cp     6
  jr     nz,+
  ld     a,(SCREENMID)
  ld     b,0
+:
  or     a
  jr     nz,+
  ld     a,(SCREENMID)
+:
  dec    a
  sla    a
  sla    a
  sla    a
  add    68
  ldi    (hl),a			;X
  ld     a,T_SCREENMAP+6
  ldi    (hl),a			;Tile
  ld     a,b
  ldi    (hl),a
++:
  ld     a,1
  ld     (SCREENMAP),a
  ret
