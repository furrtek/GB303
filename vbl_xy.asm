vbl_xy:
  call   RAMtoOAM

  ld     hl,FRAME
  inc    (hl)

  call   readinput

  call   input_xy
  
  ld     a,(HWOK_ADC)
  or     a
  call   nz,readpots

  ld     hl,OAMCOPY
  ld     bc,$40
  call   clear

  ;Render x/y cursor
  ld     hl,OAMCOPY
  ld     a,(RESON)
  sla    a
  sla    a
  sla    a
  cpl
  add    128+21
  ldi    (hl),a
  ld     a,(PREVCUT)		;255 = 96+96+(96/2)+(96/8)+(96/32)
  ld     b,a
  srl    b                      ;96/4
  srl    b
  add    b
  srl    b
  srl    b			;96/16
  add    b
  add    21
  ldi    (hl),a
  ld     a,T_GRIDCUR
  ldi    (hl),a
  xor    a
  ld     (hl),a

  call   changescreen           ;Always do this at end of VBL
  ret
