setscreen_live:
  ld     de,text_live
  ld     hl,$9800+(32*0)+1
  ld     b,TXT_NORMAL
  call   maptext

  ld     a,T_DISTS
  ld     hl,$9800+(32*14)+2
  ld     bc,$0602
  call   mapinc
  
  ld     a,T_POT
  ld     hl,$9800+(32*2)+2
  ld     bc,$0202
  call   mapinc
  ld     a,T_POT
  ld     hl,$9800+(32*2)+8
  ld     bc,$0202
  call   mapinc
  ld     a,T_POT
  ld     hl,$9800+(32*2)+14
  ld     bc,$0202
  call   mapinc

  call   write_pattinfo
  
  call   redrawcur_liv
  call   liv_drawpotlinks
  call   drumsicon

  call   setdefaultpal

  ld     hl,vbl_live
  call   setvblhandler

  call   intset

  ret
