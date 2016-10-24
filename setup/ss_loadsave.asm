setscreen_loadsave:
  ld     a,(HWOK_EE)
  or     a
  jr     nz,+

  ld     de,text_nosaves
  ld     hl,$9800+(32*7)+1
  ld     b,TXT_NORMAL
  call   maptext
  ld     a,T_ERROR
  ld     hl,$9800+(32*6)+2
  ld     bc,$0303
  call   mapinc
  ld     hl,vbl_loadsaveerr
  call   setvblhandler
  jr     ++
+:

  ld     de,text_loadsave
  ld     hl,$9800+(32*0)+1
  ld     b,TXT_NORMAL
  call   maptext
  
  ld    a,(CURPATTERN)
  ld    (SAVECURPATTSLOT),a
  ld    a,(CURSONG)
  ld    (SAVECURSONGSLOT),a
  
  ;Very similar to write_pattinfo in draw.asm, difference is display location
  ld     a,(CURPATTERN)
  ld     hl,$9800+(32*4)+7
  ld     b,TXT_NORMAL
  call   writeAsmall
  ld     hl,$9800+(32*4)+9
  ld     a,':'-TXT_NORMAL
  di
  call   wait_write
  ld     (hl),a
  ei
  ld     de,PATTNAME
  ld     hl,$9800+(32*4)+10
  ld     b,0
  call   maptext

  ld     a,(CURSONG)
  ld     hl,$9800+(32*3)+7
  ld     b,TXT_NORMAL
  call   writeAsmall
  ld     hl,$9800+(32*3)+9
  ld     a,':'-TXT_NORMAL
  di
  call   wait_write
  ld     (hl),a
  ei
  ld     de,SONGNAME
  ld     hl,$9800+(32*3)+10
  ld     b,0
  call   maptext

  ld     b,TXT_NORMAL
  call   mem_updpattslot
  ld     b,TXT_NORMAL
  call   mem_updsongslot

  call   redrawcur_mem
  
  call   setdefaultpal

  ld     hl,vbl_loadsave
  call   setvblhandler

++:
  call   setdefaultpal
  call   intset

  ret
