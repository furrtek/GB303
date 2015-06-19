input_config:
  call   playstop
  
  ld     a,(JOYP_CURRENT)	;Select ?
  bit    2,a
  ret    nz

  ld     a,(JOYP_ACTIVE)	;Right
  bit    4,a
  jr     z,+
  ld     a,(JOYP_CURRENT)	;A+Right
  bit    0,a
  jr     z,+
  ld     a,(CFG_CUR)
  dec    a
  jr     nz,++
  ld     a,(PLAYING)		;Don't allow changing sync mode during play
  or     a
  jr     nz,+
++:
  ld     hl,cfg_paramlist
  ld     a,(CFG_CUR)
  sla    a
  ld     b,a
  sla    a			;*6
  add    b
  rst    0
  inc    hl			;Skip minimum
  ldi    a,(hl)
  ld     b,a
  ldi    a,(hl)
  ld     d,h
  ld     e,l
  ld     h,(hl)
  ld     l,a
  ld     a,(hl)
  cp     b
  jr     z,+			;Check maximum
  inc    (hl)
  inc    de
  ld     a,(de)
  ld     l,a
  inc    de
  ld     a,(de)
  ld     h,a
  call   dojump
+:

  ld     a,(JOYP_ACTIVE)	;Left
  bit    5,a
  jr     z,+
  ld     a,(JOYP_CURRENT)	;A+Left
  bit    0,a
  jr     z,+
  ld     a,(CFG_CUR)
  dec    a
  jr     nz,++
  ld     a,(PLAYING)		;Don't allow changing sync mode during play
  or     a
  jr     nz,+
++:
  ld     hl,cfg_paramlist
  ld     a,(CFG_CUR)
  sla    a
  ld     b,a
  sla    a			;*6
  add    b
  rst    0
  ldi    a,(hl)
  inc    hl                     ;Skip maximum
  ld     b,a
  ldi    a,(hl)
  ld     d,h
  ld     e,l
  ld     h,(hl)
  ld     l,a
  ld     a,(hl)
  cp     b
  jr     z,+			;Check minimum
  dec    (hl)
  inc    de
  ld     a,(de)
  ld     l,a
  inc    de
  ld     a,(de)
  ld     h,a
  call   dojump
+:

  ld     a,(JOYP_ACTIVE)	;Down
  bit    7,a
  jr     z,+
  ld     a,(JOYP_CURRENT)	;A+Down
  bit    0,a
  jr     z,++
  ld     a,(CFG_CUR)		;BPM line
  or     a
  jr     nz,+
  ld     a,(BPM)
  sub    10
  jr     nc,+++
  ld     a,6
+++:
  ld     (BPM),a
  call   cfg_updbpm
  jr     +
++:
  ld     a,(CFG_CUR)		;Down only
  cp     6
  jr     z,+
  inc    a
  ld     (CFG_CUR),a
  call   redrawcur_cfg
+:

  ld     a,(JOYP_ACTIVE)	;Up
  bit    6,a
  jr     z,+
  ld     a,(JOYP_CURRENT)	;A+Up
  bit    0,a
  jr     z,++
  ld     a,(CFG_CUR)		;BPM line
  or     a
  jr     nz,+
  ld     a,(BPM)
  add    10
  jr     c,+
  ld     (BPM),a
  call   cfg_updbpm
  jr     +
++:
  ld     a,(CFG_CUR)		;Up only
  or     a
  jr     z,+
  dec    a
  ld     (CFG_CUR),a
  call   redrawcur_cfg
+:

selinputcfg:

  ret
  
  
redrawcur_cfg:

  ;Set previous cur to normal
  ld     a,(CFG_PREVCUR)
  ld     hl,cfg_curlist
  call   curcommon
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
  ld     a,(CFG_CUR)
  ld     hl,cfg_curlist
  call   curcommon
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

  ld     a,(CFG_CUR)
  ld     (CFG_PREVCUR),a
  ret

cfg_updbpm:
  ld     b,TXT_INVERT
cfg_updbpm_a:
  ld     a,(BPM)
  ld     hl,$9800+(32*2)+5
  cp     100
  ld     d,'0'
  jr     c,+
  sub    100
  ld     d,'1'		;Lazy 3-digit BCD
  cp     100
  jr     c,+
  sub    100
  ld     d,'2'
+:
  ld     c,a
  ld     a,d
  sub    b
  di
  call   wait_write
  ldi    (hl),a
  ei
  ld     a,c
  call   writeAsmall
  call   setbpm
  ret

cfg_updsync:
  ld     b,TXT_INVERT
cfg_updsync_a:
  ld     a,(SYNCMODE)
  cp     5+1
  ret    nc
  ld     hl,textptr_sync
  sla    a
  rst    0
  inc    hl
  ld     d,(hl)
  ld     e,a
  ld     hl,$9800+(32*4)+6
  call   maptext
  ret

cfg_updlforoute:
  ld     b,TXT_INVERT
cfg_updlforoute_a:
  ld     a,(LFOROUTE)
  cp     3+1
  ret    nc
  ld     hl,textptr_lfor
  sla    a
  rst    0
  inc    hl
  ld     d,(hl)
  ld     e,a
  ld     hl,$9800+(32*6)+8
  call   maptext
  ret
  
cfg_updlforeset:
  ld     b,TXT_INVERT
cfg_updlforeset_a:
  ld     a,(LFORESET)
  cp     1+1
  ret    nc
  ld     hl,textptr_yesno
  sla    a
  rst    0
  inc    hl
  ld     d,(hl)
  ld     e,a
  ld     hl,$9800+(32*7)+11
  call   maptext
  ret

cfg_updsynthlr:
  ld     b,TXT_INVERT
cfg_updsynthlr_a:
  ld     a,(SYNTHLR)
  cp     2+1
  ret    nc
  ld     hl,textptr_lr
  sla    a
  rst    0
  inc    hl
  ld     d,(hl)
  ld     e,a
  ld     hl,$9800+(32*9)+7
  call   maptext
  call   setstereo
  ret

cfg_upddrumslr:
  ld     b,TXT_INVERT
cfg_upddrumslr_a:
  ld     a,(DRUMSLR)
  cp     2+1
  ret    nc
  ld     hl,textptr_lr
  sla    a
  rst    0
  inc    hl
  ld     d,(hl)
  ld     e,a
  ld     hl,$9800+(32*10)+7
  call   maptext
  call   setstereo
  ret
  
cfg_updovr:
  ld     b,TXT_INVERT
cfg_updovr_a:
  ld     a,(POTPATTOVRD)
  cp     1+1
  ret    nc
  ld     hl,textptr_yesno
  sla    a
  rst    0
  inc    hl
  ld     d,(hl)
  ld     e,a
  ld     hl,$9800+(32*13)+11
  call   maptext
  ret
  
setstereo:
  ld     a,(DRUMSLR)
  ld     hl,lut_stereodrums
  rst    0
  ld     b,a
  ld     a,(SYNTHLR)
  ld     hl,lut_stereosynth
  rst    0
  or     b
  ldh    ($25),a
  ret
  
lut_stereodrums:
  .db %10010000
  .db %00001001
  .db %10011001

lut_stereosynth:
  .db %01000000
  .db %00000100
  .db %01000100

cfg_curlist:
      ;Line,start,len
  .db 1,5,3
  .db 3,6,12
  .db 5,8,9
  .db 6,11,3
  .db 8,7,2
  .db 9,7,2
  .db 12,11,3

cfg_paramlist:
  ;   min,max,variable
  .db 6,255
  .dw BPM,cfg_updbpm
  .db 0,4
  .dw SYNCMODE,cfg_updsync
  .db 0,3
  .dw LFOROUTE,cfg_updlforoute
  .db 0,1
  .dw LFORESET,cfg_updlforeset
  .db 0,2
  .dw SYNTHLR,cfg_updsynthlr
  .db 0,2
  .dw DRUMSLR,cfg_upddrumslr
  .db 0,1
  .dw POTPATTOVRD,cfg_updovr
  .db 0	;EOL

