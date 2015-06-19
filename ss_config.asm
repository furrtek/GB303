setscreen_config:
  ld     de,text_config
  ld     hl,$9800+(32*0)+1
  ld     b,TXT_NORMAL
  call   maptext

  call   write_pattinfo

  call   setdefaultpal
  
  ld     b,TXT_NORMAL
  call   cfg_updbpm_a
  ld     b,TXT_NORMAL
  call   cfg_updsync_a
  ld     b,TXT_NORMAL
  call   cfg_updlforoute_a
  ld     b,TXT_NORMAL
  call   cfg_updlforeset_a
  ld     b,TXT_NORMAL
  call   cfg_updsynthlr_a
  ld     b,TXT_NORMAL
  call   cfg_upddrumslr_a
  ld     b,TXT_NORMAL
  call   cfg_updovr_a
  
  call   redrawcur_cfg

  ld     hl,vbl_config
  call   setvblhandler

  call   intset

  ret
