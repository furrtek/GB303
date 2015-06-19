input_loadsave:
  ld     a,(JOYP_CURRENT)	;Select ?
  bit    2,a
  ret    nz

  ld     a,(JOYP_ACTIVE)	;Right
  bit    4,a
  jr     z,+
  ld     a,(MEM_CUR)
  or     a
  jr     nz,++
  ld     a,(SAVECURPATTSLOT)
  cp     99
  jr     z,+
  inc    a
  ld     (SAVECURPATTSLOT),a
  ld     b,TXT_INVERT
  call   mem_updpattslot
  jr     +
++:
  cp     3
  jr     nz,+
  ld     a,(SAVECURSONGSLOT)
  cp     16
  jr     z,+
  inc    a
  ld     (SAVECURSONGSLOT),a
  ld     b,TXT_INVERT
  call   mem_updsongslot
+:

  ld     a,(JOYP_ACTIVE)	;Left
  bit    5,a
  jr     z,+
  ld     a,(MEM_CUR)
  or     a
  jr     nz,++
  ld     a,(SAVECURPATTSLOT)
  or     a
  jr     z,+
  dec    a
  ld     (SAVECURPATTSLOT),a
  ld     b,TXT_INVERT
  call   mem_updpattslot
  jr     +
++:
  cp     3
  jr     nz,+
  ld     a,(SAVECURSONGSLOT)
  or     a
  jr     z,+
  dec    a
  ld     (SAVECURSONGSLOT),a
  ld     b,TXT_INVERT
  call   mem_updsongslot
+:

  ld     a,(JOYP_ACTIVE)	;Up:
  bit    6,a
  jr     z,+
  ld     a,(MEM_CUR)
  or     a
  jr     z,+
  dec    a
  ld     (MEM_CUR),a
  call   redrawcur_mem
+:

  ld     a,(JOYP_ACTIVE)	;Down:
  bit    7,a
  jr     z,+
  ld     a,(MEM_CUR)
  cp     8
  jr     z,+
  inc    a
  ld     (MEM_CUR),a
  call   redrawcur_mem
+:

  ld     a,(JOYP_ACTIVE)	;A:
  bit    0,a
  jr     z,+
  ld     hl,mem_paramlist
  ld     a,(MEM_CUR)
  sla    a
  ld     b,a
  sla    a			;*6
  add    b
  rst    0
  cp     $FF
  jr     nz,+
  inc    hl                     ;Skip
  inc    hl
  ldi    a,(hl)
  ld     h,(hl)
  ld     l,a
  call   dojump
+:

  ret
  
  
prompt_savepatt:
  ld     de,TEMPNAME
  ld     hl,PATTNAME		;Set temp name to previous saved name
  ld     b,9
-:
  ldi    a,(hl)
  ld     (de),a
  inc    de
  dec    b
  jr     nz,-
  ld     hl,savepattern
  ld     a,l
  ld     (KBCALLBACK),a
  ld     a,h
  ld     (KBCALLBACK+1),a
  call   keyboard_show
  ret
  
prompt_loadpatt:
  ld     hl,loadpattern
  ld     a,l
  ld     (KBCALLBACK),a
  ld     a,h
  ld     (KBCALLBACK+1),a
  call   confirm_show
  ret

prompt_savesong:
  ld     de,TEMPNAME
  ld     hl,SONGNAME		;Set temp name to previous saved name
  ld     b,9
-:
  ldi    a,(hl)
  ld     (de),a
  inc    de
  dec    b
  jr     nz,-
  ld     hl,savesong
  ld     a,l
  ld     (KBCALLBACK),a
  ld     a,h
  ld     (KBCALLBACK+1),a
  call   keyboard_show
  ret
  
prompt_loadsong:
  ld     hl,loadsong
  ld     a,l
  ld     (KBCALLBACK),a
  ld     a,h
  ld     (KBCALLBACK+1),a
  call   confirm_show
  ret
  
prompt_format:
  ld     hl,formatee
  ld     a,l
  ld     (KBCALLBACK),a
  ld     a,h
  ld     (KBCALLBACK+1),a
  call   confirm_show
  ret

  
redrawcur_mem:
  ;Set previous cur to normal
  ld     a,(MEM_PREVCUR)
  ld     hl,mem_curlist
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
  ld     a,(MEM_CUR)
  ld     hl,mem_curlist
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

  ld     a,(MEM_CUR)
  ld     (MEM_PREVCUR),a
  ret
  
curcommon:
  ld     b,a
  sla    a
  add    b
  rst    0
  inc    hl
  push   hl
  ld     hl,$9800
  call   getline
  pop    de
  ld     a,(de)
  inc    de
  ld     b,0
  ld     c,a
  add    hl,bc
  ld     a,(de)
  ld     b,a
  ret


mem_updpattslot:
  ld     a,(SAVECURPATTSLOT)
  ld     hl,$9800+(32*6)+1
  call   writeAsmall
  
  ld     hl,$9800+(32*6)+3
  ld     de,text_memdef
  ld     b,TXT_NORMAL
  call   maptext

  call   geteepattname

  ld     de,SELPATTNAME
  ld     hl,$9800+(32*6)+4
  ld     b,0
  call   maptext
  ret

mem_updsongslot:
  ld     a,(SAVECURSONGSLOT)
  ld     hl,$9800+(32*10)+1
  call   writeAsmall

  ld     hl,$9800+(32*10)+3
  ld     de,text_memdef
  ld     b,TXT_NORMAL
  call   maptext

  call   geteesongname

  ld     de,SELSONGNAME
  ld     hl,$9800+(32*10)+4
  ld     b,0
  call   maptext
  ret
  
dumpmemlink:
  ld     hl,$0000
  ld     a,l
  ld     (EEWRADDRL),a
  ld     a,h
  ld     (EEWRADDRM),a
  call   eesetr

  ld     c,255
-:
  push   bc

  call   readts
  
  ld     hl,TEMPSECTOR
  ld     b,64
--:
  ldi    a,(hl)
  ldh    ($01),a
  ld     a,$81		;Master
  ldh    ($02),a
  ld     d,$FF
---:
  dec    d
  jr     nz,---
  dec    b
  jr     nz,--

  ld     a,(EEWRADDRL)
  add    $40
  ld     (EEWRADDRL),a
  jr     nc,+
  ld     hl,EEWRADDRM
  inc    (hl)
+:

  ld     a,(EEWRADDRM)
  ld     d,a
  ld     a,(EEWRADDRL)
  ld     e,a
  ld     hl,$9800+(32*14)+13
  call   writeDE

  pop    bc
  dec    c
  jr     nz,-
  ret

  
mem_curlist:
      ;Line,start,len
  .db 5,1,2
  .db 6,2,12
  .db 7,2,12

  .db 9,1,2
  .db 10,2,9
  .db 11,2,9

  .db 13,1,4
  .db 14,1,6
  .db 15,1,7

mem_paramlist:
  ;   min,max,variable,call
  .db 0,99
  .dw SAVECURPATTSLOT,mem_updpattslot
  .db $FF,$FF
  .dw prompt_savepatt,0
  .db $FF,$FF
  .dw prompt_loadpatt,0

  .db 0,99
  .dw SAVECURSONGSLOT,mem_updsongslot
  .db $FF,$FF
  .dw prompt_savesong,0
  .db $FF,$FF
  .dw prompt_loadsong,0
  
  .db $FF,$FF
  .dw dumpmemlink,0		;TODO
  .db $FF,$FF
  .dw prompt_format,0
  .db $FF,$FF
  .dw setscreen_credits,0

  .db 0	;EOL

