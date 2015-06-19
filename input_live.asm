input_live:
  call   playstop
  
  ld     a,(JOYP_CURRENT)	;Select ?
  bit    2,a
  ret    nz
  
  ld     a,(JOYP_ACTIVE)	;A
  bit    1,a
  jr     z,+
  ld     a,(DRUMSMUTE)
  xor    1
  ld     (DRUMSMUTE),a
  call   drumsicon
+:
  
  ld     a,(JOYP_ACTIVE)	;A
  bit    0,a
  jr     z,+
  ld     a,(LIVE_CURY)		;In pot link matrix ?
  cp     6
  jr     z,+
  ld     a,(LIVE_CURX)
  or     a
  jr     nz,++
  call   liv_erasepotlinks	;Column 1
  ld     a,(POTLINK1)
  call   liv_resetlastlink
  ld     a,(LIVE_CURY)
  ld     (POTLINK1),a
  call   liv_drawpotlinks
  jr     +
++:
  dec    a
  jr     nz,++
  call   liv_erasepotlinks	;Column 2
  ld     a,(POTLINK2)
  call   liv_resetlastlink
  ld     a,(LIVE_CURY)
  ld     (POTLINK2),a
  call   liv_drawpotlinks
  jr     +
++:
  dec    a
  jr     nz,+
  call   liv_erasepotlinks	;Column 3
  ld     a,(POTLINK3)
  call   liv_resetlastlink
  ld     a,(LIVE_CURY)
  ld     (POTLINK3),a
  call   liv_drawpotlinks
+:

  ld     a,(JOYP_ACTIVE)	;Right
  bit    4,a
  jr     z,+
  ld     a,(JOYP_CURRENT)
  bit    0,a
  jr     z,++
  ld     a,(LIVE_CURY)		;A+Right
  cp     6
  jr     nz,+
  ld     a,(LIVE_CURX)		;In dist/osc line
  or     a
  jr     nz,+++
  ld     a,(DISTTYPE)		;In dist item
  cp     2
  jr     z,+
  inc    a
  ld     (DISTTYPE),a
  jr     +
+++:
  ld     a,(OSCTYPEOVD)		;In osc item
  cp     2
  jr     z,+
  inc    a
  ld     (OSCTYPEOVD),a
  jr     +
++:
  ld     a,(LIVE_CURY)		;Right only
  cp     6
  jr     z,++
  ld     a,(LIVE_CURX)		;In pot link matrix
  cp     2
  jr     z,+
  inc    a
  ld     (LIVE_CURX),a
  call   redrawcur_liv
  jr     +
++:
  ld     a,(LIVE_CURX)		;Dist/osc line
  or     a
  jr     nz,+
  inc    a
  ld     (LIVE_CURX),a
  call   redrawcur_liv
+:


  ld     a,(JOYP_ACTIVE)	;Left
  bit    5,a
  jr     z,+
  ld     a,(JOYP_CURRENT)
  bit    0,a
  jr     z,++
  ld     a,(LIVE_CURY)		;A+Left
  cp     6
  jr     nz,+
  ld     a,(LIVE_CURX)		;In dist/osc line
  or     a
  jr     nz,+++
  ld     a,(DISTTYPE)		;In dist item
  or     a
  jr     z,+
  dec    a
  ld     (DISTTYPE),a
  jr     +
+++:
  ld     a,(OSCTYPEOVD)		;In osc item
  or     a
  jr     z,+
  dec    a
  ld     (OSCTYPEOVD),a
  jr     +
++:
  ld     a,(LIVE_CURX)		;Left only
  or     a
  jr     z,+
  dec    a
  ld     (LIVE_CURX),a
  call   redrawcur_liv
+:


  ld     a,(JOYP_ACTIVE)	;Up
  bit    6,a
  jr     z,+
  ld     a,(LIVE_CURY)		;Up only
  or     a
  jr     z,+
  dec    a
  ld     (LIVE_CURY),a
  call   redrawcur_liv
+:


  ld     a,(JOYP_ACTIVE)	;Down
  bit    7,a
  jr     z,+
  ld     a,(LIVE_CURY)		;Down only
  cp     6
  jr     z,+
  inc    a
  ld     (LIVE_CURY),a
  cp     6
  jr     nz,++
  ld     a,(LIVE_CURX)		;Re-adjust CURX when going to last line (only 2 items instead of 3)
  cp     2
  jr     nz,++
  ld     a,1
  ld     (LIVE_CURX),a
++:
  call   redrawcur_liv
+:

  ret
  
drumsicon:
  ld     a,(DRUMSMUTE)
  ld     hl,$9800+5
  or     a
  ld     a,'B'-TXT_INVERT
  jr     z,++
  ld     a,'B'-TXT_NORMAL
++:
  di
  call   wait_write
  ld     (hl),a
  ei
  ret

redrawcur_liv:
  ;Set previous cur to normal
  ld     a,(LIVE_PREVX)
  ld     c,a
  sla    a
  ld     b,a
  sla    a
  add    b
  add    c			;X*7
  ld     b,a
  ld     a,(LIVE_PREVY)		;+Y
  add    b
  ld     hl,liv_curlist
  call   liv_curcommon
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
  ld     a,(LIVE_CURX)
  ld     c,a
  sla    a
  ld     b,a
  sla    a
  add    b
  add    c			;X*7
  ld     b,a
  ld     a,(LIVE_CURY)		;+Y
  add    b
  ld     hl,liv_curlist
  call   liv_curcommon
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

  ld     a,(LIVE_CURX)
  ld     (LIVE_PREVX),a
  ld     a,(LIVE_CURY)
  ld     (LIVE_PREVY),a
  ret
  
liv_curcommon:
  ld     b,a
  sla    a
  add    b
  rst    0
  inc    hl
  push   hl
  ld     hl,$9800
  call   getline
  pop    de
  ld     a,(de)
  inc    de
  ld     b,0
  ld     c,a
  add    hl,bc
  ld     a,(de)
  ld     b,a
  ret

liv_curlist:
      ;Line,start,len
  .db 4,2,4
  .db 5,2,4
  .db 6,2,4
  .db 7,2,4
  .db 8,2,4
  .db 9,2,4
  .db 11,2,4

  .db 4,8,4
  .db 5,8,4
  .db 6,8,4
  .db 7,8,4
  .db 8,8,4
  .db 9,8,4
  .db 11,12,3

  .db 4,14,4
  .db 5,14,4
  .db 6,14,4
  .db 7,14,4
  .db 8,14,4
  .db 9,14,4
  ;Last entry unused, handled in code

liv_resetlastlink:
  ld     hl,jt_rll
  rst    0
  ld     b,a
  inc    hl
  ldi    a,(hl)
  ld     h,(hl)
  ld     l,a
  ld     (hl),b
  ret

jt_rll:
  .dw    0,CUTOFF
  .dw    0,RESON
  .dw    0,BEND
  .dw    24,SLIDESPEED
  .dw    20,LFOSPEED
  .dw    12,LFOAMP
