setscreen_piano:
  ld     de,text_piano
  ld     hl,$9800+(32*0)+1
  ld     b,TXT_NORMAL
  call   maptext

  ld     a,T_KEYB
  ld     hl,map_keyb
  ld     de,$9800+(32*4)+1
  call   map

  ld     a,T_LOGO
  ld     hl,$9800+(32*2)+11
  ld     bc,$0802
  call   mapinc
  
  call   write_pattinfo

  call   draw_notes

  call   setdefaultpal

  ld     hl,vbl_piano
  call   setvblhandler

  call   intset

  ret
