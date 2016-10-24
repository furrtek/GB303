setscreen_xy:
  call   write_pattinfo

  ld     hl,$9800+(32*2)+2
  ld     b,15
-:
  ld     c,16
--:
  ld     a,T_GRID
  ldi    (hl),a
  dec    c
  jr     nz,--
  ld     a,l
  add    16
  ld     l,a
  jr     nc,+
  inc    h
+:
  dec    b
  jr     nz,-
  
  ld     de,text_xy
  ld     hl,$9800+(32*0)+1
  ld     b,TXT_NORMAL
  call   maptext
  
  call   setdefaultpal

  ld     hl,vbl_xy
  call   setvblhandler
  
  call   intset

  ret
