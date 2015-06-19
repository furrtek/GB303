vbl_table:
  call   RAMtoOAM

  ld     hl,FRAME
  inc    (hl)

  call   readinput

  call   input_table
  
  call   redraw_songptr

  ld     a,(HWOK_ADC)
  or     a
  call   nz,readpots

  ld     hl,OAMCOPY
  ld     bc,$40
  call   clear
  
  call   changescreen

  ret
