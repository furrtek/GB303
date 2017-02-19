confirm_show:
  ;Separation bar
  ld     hl,$9C00
  ld     b,20
  ld     a,T_WINGRAD
-:
  di
  call   wait_write
  ldi    (hl),a
  ei
  dec    b
  jr     nz,-

  ld     de,text_confirm
  ld     hl,$9C00+(32*1)+3 
  ld     b,TXT_NORMAL
  call   maptext
  
  ld     hl,$9C00+(32*2)+4		;Highlight "no"
  ld     b,3
-:
  di
  call   wait_write
  ld     a,(hl)
  ei
  or     %01000000
  di
  call   wait_write
  ldi    (hl),a
  ei
  dec    b
  jr     nz,-

  xor    a
  ld     (CONFIRM_YN),a

  ld     hl,vbl_confirm
  ld     a,l
  ld     (VBL_HANDLER),a
  ld     a,h
  ld     (VBL_HANDLER+1),a

  ld     a,112
  ldh    ($4A),a	;Window Y

  ld     a,7
  ldh    ($4B),a        ;Window X

  ldh    a,($40)
  or     %00100000
  ldh    ($40),a

  ld     a,1
  ld     (KEYBOARDMODE),a
  ret


vbl_confirm:
  call   RAMtoOAM

  ld     hl,FRAME
  inc    (hl)

  call   readinput

  call   input_confirm

  ld     hl,OAMCOPY
  ld     bc,$40
  call   clear

  ret


input_confirm:
  ld     a,(JOYP_ACTIVE)	;A
  bit    0,a
  jr     z,+
  ld     a,(CONFIRM_YN)
  or     a
  jr     z,++
  ;OK
  call   keyboard_hide
  ld     a,(KBCALLBACK)
  ld     l,a
  ld     a,(KBCALLBACK+1)
  ld     h,a
  call   dojump
  jr     +
++:
  ;CANCEL
  call   keyboard_hide
+:

  ld     a,(JOYP_ACTIVE)	;B
  bit    1,a
  call   nz,keyboard_hide

  ld     a,(JOYP_ACTIVE)	;Right
  bit    4,a
  jr     z,+
  ld     a,(CONFIRM_YN)
  or     a
  jr     nz,+
  inc    a
  ld     (CONFIRM_YN),a
  ld     hl,$9C00+(32*2)+4
  ld     b,3
-:
  di
  call   wait_write
  ld     a,(hl)
  ei
  and    %10111111
  di
  call   wait_write
  ldi    (hl),a
  ei
  dec    b
  jr     nz,-
  ld     hl,$9C00+(32*2)+12
  ld     b,3
-:
  di
  call   wait_write
  ld     a,(hl)
  ei
  or     %01000000
  di
  call   wait_write
  ldi    (hl),a
  ei
  dec    b
  jr     nz,-
+:

  ld     a,(JOYP_ACTIVE)	;Left
  bit    5,a
  jr     z,+
  ld     a,(CONFIRM_YN)
  or     a
  jr     z,+
  dec    a
  ld     (CONFIRM_YN),a
  ld     hl,$9C00+(32*2)+12
  ld     b,3
-:
  di
  call   wait_write
  ld     a,(hl)
  ei
  and    %10111111
  di
  call   wait_write
  ldi    (hl),a
  ei
  dec    b
  jr     nz,-
  ld     hl,$9C00+(32*2)+4
  ld     b,3
-:
  di
  call   wait_hblank
  ld     a,(hl)
  or     %01000000
  ldi    (hl),a
  ei
  dec    b
  jr     nz,-
+:

  ret

