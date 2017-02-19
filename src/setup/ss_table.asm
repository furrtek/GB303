setscreen_table:
  ld     de,text_table
  ld     hl,$9800+(32*0)+1
  ld     b,TXT_NORMAL
  call   maptext

  call   redraw_song
  call   redraw_songptr_force

  call   write_songinfo

  call   setdefaultpal

  ;For debug: :) TODO TO REMOVE
  ;ld     hl,$9800+64+2
  ;ld     de,TEMPSECTOR
  ;ld     c,16
-:
  ;ld     a,(de)
  ;ld     b,TXT_NORMAL
  ;call   writeAhex
  ;push   de
  ;ld     de,32-1
  ;add    hl,de
  ;pop    de
  ;inc    de
  ;dec    c
  ;jr     nz,-

  ld     hl,vbl_table
  call   setvblhandler

  call   intset

  ret
  
  
redraw_songptr:
  ld     a,(SONGPTR)
  cp     80
  jr     c,+
  sub    80
+:
  ld     hl,PREVSONGPTR
  cp     (hl)
  ret    z

redraw_songptr_force:
  ld     a,(SONGPTR)
  cp     80
  jr     nc,+
  ;<80
  ld     a,(SONGOFS)
  or     a
  ret    nz
  jr     ++
+:
  ;>=80
  ld     a,(SONGOFS)
  or     a
  ret    z
++:

  ld     a,(PREVSONGPTR)
  call   songcurcommon
  xor    a
  di
  call   wait_write
  ld     (hl),a
  ei

  ld     a,(SONGPTR)
  cp     80
  jr     c,+
  sub    80
+:
  call   songcurcommon
  ld     a,$3B
  di
  call   wait_write
  ld     (hl),a
  ei
  
  ld     a,(SONGPTR)
  cp     80
  jr     c,+
  sub    80
+:
  ld     (PREVSONGPTR),a

  ret


songcurcommon:
  ld     hl,$9800+64+1
  ld     d,a
  ld     e,16
  xor    a
  call   div8_8         ;/5
  ld     b,a
  ld     a,d
  sla    a		;*3
  add    d
  ld     d,0
  ld     e,a
  add    hl,de
  push   hl
  ld     h,0
  ld     l,b
  add    hl,hl
  add    hl,hl
  add    hl,hl
  add    hl,hl
  add    hl,hl
  pop    de
  add    hl,de
  ret

redraw_song:
  ld     b,5
  ld     hl,SONG
  ld     d,0
  ld     a,(SONGOFS)
  ld     e,a
  add    hl,de
  ld     d,h
  ld     e,l
  ld     hl,$9800+64+1
--:
  push   hl
  ld     c,16
-:
  ld     a,(de)
  cp     $FF
  jr     nz,+
  inc    hl
  push   bc
  push   de
  ld     de,text_eos
  ld     b,TXT_NORMAL
  call   maptext
  pop    de
  pop    bc
  inc    hl
  jr     ++
+:
  push   af
  xor    a
  di
  call   wait_write
  ldi    (hl),a
  ei
  pop    af
  push   bc
  ld     b,TXT_NORMAL
  call   writeAsmall
  pop    bc
++:
  ld     a,32-2
  add    l
  jr     nc,+
  inc    h
+:
  ld     l,a
  inc    de
  dec    c
  jr     nz,-
  pop    hl
  ld     a,3
  add    l
  jr     nc,+
  inc    h
+:
  ld     l,a
  dec    b
  jr     nz,--

  ld     a,(SONGOFS)
  ld     b,'A'-TXT_NORMAL
  or     a
  jr     z,+
  ld     b,'B'-TXT_NORMAL
+:
  ld     a,b
  ld     hl,$9800+4
  di
  call   wait_write
  ldi    (hl),a
  ei

  jp     redrawcur_song
