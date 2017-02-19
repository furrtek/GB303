vbl_live:
  call   RAMtoOAM

  ld     hl,FRAME
  inc    (hl)

  call   readinput

  call   input_live

  ld     a,(HWOK_ADC)
  or     a
  call   nz,readpots
  
  ld     hl,$9800+(32*3)+4
  ld     b,TXT_NORMAL
  ld     a,(POT1V)
  call   writeAhex
  
  ld     hl,$9800+(32*3)+10
  ld     b,TXT_NORMAL
  ld     a,(POT2V)
  call   writeAhex
  
  ld     hl,$9800+(32*3)+16
  ld     b,TXT_NORMAL
  ld     a,(POT3V)
  call   writeAhex

  ;Render sprites
  ld     hl,OAMCOPY
  ld     bc,$40
  call   clear

  ld     hl,OAMCOPY

  ld     a,144+7-6
  ldi    (hl),a
  ld     a,(DISTTYPE)
  swap   a
  and    $F0
  add    32-4
  ldi    (hl),a
  ld     a,'^'-TXT_NORMAL
  ldi    (hl),a
  xor    a
  ldi    (hl),a

  ld     a,(OSCTYPEOVD)
  or     a
  jr     z,+
  ld     a,144+7-6
  ldi    (hl),a
  ld     a,(OSCTYPEOVD)
  dec    a
  swap   a
  and    $F0
  add    48-4+64
  ldi    (hl),a
  ld     a,'^'-TXT_NORMAL
  ldi    (hl),a
  xor    a
  ldi    (hl),a
+:
  call   changescreen           ;Always do this at end of VBL

  ret


liv_erasepotlinks:
  ld     a,(POTLINK1)
  ld     hl,$9800+(32*5)+1
  call   liv_eplcommon
  
  ld     a,(POTLINK2)
  ld     hl,$9800+(32*5)+7
  call   liv_eplcommon
  
  ld     a,(POTLINK3)
  ld     hl,$9800+(32*5)+13
  call   liv_eplcommon
  ret
  
liv_eplcommon:
  or     a
  jr     z,+
  ld     de,32
-:
  add    hl,de
  dec    a
  jr     nz,-
+:
  ld     a,' '-TXT_NORMAL
  di
  call   wait_write
  ld     (hl),a
  ei
  ld     de,5
  add    hl,de
  ld     a,' '-TXT_NORMAL
  di
  call   wait_write
  ld     (hl),a
  ei
  ret

liv_drawpotlinks:
  ld     a,(POTLINK1)
  ld     hl,$9800+(32*5)+1
  call   liv_dplcommon
  
  ld     a,(POTLINK2)
  ld     hl,$9800+(32*5)+7
  call   liv_dplcommon
  
  ld     a,(POTLINK3)
  ld     hl,$9800+(32*5)+13
  call   liv_dplcommon
  ret

liv_dplcommon:
  or     a
  jr     z,+
  ld     de,32
-:
  add    hl,de
  dec    a
  jr     nz,-
+:
  ld     a,'['-TXT_NORMAL
  di
  call   wait_write
  ld     (hl),a
  ei
  ld     de,5
  add    hl,de
  ld     a,']'-TXT_NORMAL
  di
  call   wait_write
  ld     (hl),a
  ei
  ret
