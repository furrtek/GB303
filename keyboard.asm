keyboard_show:
  ;Separation bar
  ld     hl,$9C00
  ld     b,20
  ld     a,T_WINGRAD
-:
  di
  call   wait_hblank
  ldi    (hl),a
  ei
  dec    b
  jr     nz,-
  
  ;Underline typed text
  ld     hl,$9C00+(32*2)+6
  ld     b,8
  ld     a,T_WINGRAD
-:
  di
  call   wait_hblank
  ldi    (hl),a
  ei
  dec    b
  jr     nz,-

  ld     de,text_keyboard
  ld     hl,$9C00+(32*1)+3
  ld     b,TXT_NORMAL
  call   maptext

  xor    a
  ld     (KBX),a
  ld     (KBY),a

  ld     a,$FF			;Security
  ld     (TEMPNAME+8),a

  ld     de,text_clearname
  ld     hl,$9C00+(32*1)+6
  ld     b,TXT_NORMAL
  call   maptext
  ld     de,TEMPNAME
  ld     hl,$9C00+(32*1)+6
  ld     b,0
  call   maptext

  ;Detect end of text
  ld     hl,TEMPNAME
  ld     b,0
-:
  ldi    a,(hl)
  or     a
  jr     z,+			;Zero or $FF
  inc    a
  jr     z,+
  inc    b
  jr     -			;Risky risky :x
+:
  ld     a,b
  cp     8
  jr     nz,+			;Cap to 7
  ld     a,7
+:
  ld     (NAMEPTR),a

  ld     hl,$9C00+(32*3)+3
  di
  call   wait_hblank
  ld     a,(hl)
  add    $40
  ld     (hl),a
  ei
  
  ld     hl,vbl_keyboard
  ld     a,l
  ld     (VBL_HANDLER),a
  ld     a,h
  ld     (VBL_HANDLER+1),a

  ld     a,80
  ldh    ($4A),a	;Window Y

  ld     a,7
  ldh    ($4B),a        ;Window X
  
  ldh    a,($40)
  or     %00100000
  ldh    ($40),a

  ld     a,1
  ld     (KEYBOARDMODE),a
  ret

keyboard_hide:
  ldh    a,($40)
  and    %11011111
  ldh    ($40),a

  ld     a,144
  ldh    ($4A),a	;Window Y

  ld     hl,vbl_loadsave
  ld     a,l
  ld     (VBL_HANDLER),a
  ld     a,h
  ld     (VBL_HANDLER+1),a


  ret
  

vbl_keyboard:
  call   RAMtoOAM

  ld     hl,FRAME
  inc    (hl)

  ld     a,(FRAME)		;Blink cursor
  and    7
  jr     nz,+
  ld     hl,$9C00+(32*1)+6
  ld     a,(NAMEPTR)
  cp     8
  jr     nz,++
  ld     a,7
++:
  add    l
  ld     l,a
  jr     nc,++
  inc    h
++:
  di
  call   wait_hblank
  ld     a,(hl)
  xor    %01000000
  ld     (hl),a
  ei
+:

  call   readinput

  call   input_keyboard

  ld     hl,OAMCOPY
  ld     bc,$40
  call   clear

  ret


input_keyboard:
  ld     a,(JOYP_ACTIVE)	;A
  bit    0,a
  jr     z,+++
  ld     a,(KBY)
  cp     3
  jr     nz,+
  ld     a,(KBX)
  and    1
  jr     z,++
  ;OK
  ld     a,(KBCALLBACK)
  ld     l,a
  ld     a,(KBCALLBACK+1)
  ld     h,a
  call   dojump
++:
  ;CANCEL
  call   keyboard_hide
  jr     +++
+:
  ld     a,(NAMEPTR)
  cp     8
  jr     z,+++
  call   makekbaddr
  di
  call   wait_hblank
  ld     a,(hl)
  ei
  and    $3F
  ld     c,a
  ld     hl,TEMPNAME
  ld     a,(NAMEPTR)
  add    l
  ld     l,a
  jr     nc,++
  inc    h
++:
  ld     (hl),c
  ld     de,TEMPNAME
  ld     hl,$9C00+(32*1)+6
  ld     b,0
  call   maptext
  ld     a,(NAMEPTR)
  inc    a
  ld     (NAMEPTR),a
+++:

  ld     a,(JOYP_ACTIVE)	;B
  bit    1,a
  jr     z,+
  ld     a,(NAMEPTR)
  or     a
  jr     z,+
  dec    a
  ld     (NAMEPTR),a
  ld     hl,TEMPNAME
  ld     a,(NAMEPTR)
  add    l
  ld     l,a
  jr     nc,++
  inc    h
++:
  ld     a,$FF
  ld     (hl),a
  ld     de,text_clearname
  ld     hl,$9C00+(32*1)+6
  ld     b,TXT_NORMAL
  call   maptext
  ld     de,TEMPNAME
  ld     hl,$9C00+(32*1)+6
  ld     b,0
  call   maptext
+:

  ld     a,(JOYP_ACTIVE)	;Right
  bit    4,a
  jr     z,+
  ;Erase previous cursor
  call   makekbaddr
  di
  call   wait_hblank
  ld     a,(hl)
  and    %10111111
  ld     (hl),a
  ei
  ;See if we're on ok/cancel line
  ld     a,(KBY)
  cp     3
  jr     z,+++
  ld     a,(KBX)
  inc    a
  cp     14
  jr     nz,++
  xor    a			;Wrap
++:
  ld     (KBX),a
  jr     ++
+++:
  ld     a,(KBX)
  inc    a
  and    1
  ld     (KBX),a
++:
  ;Print new cursor
  call   makekbaddr
  di
  call   wait_hblank
  ld     a,(hl)
  add    $40
  ld     (hl),a
  ei
+:

  ld     a,(JOYP_ACTIVE)	;Left
  bit    5,a
  jr     z,+
  ;Erase previous cursor
  call   makekbaddr
  di
  call   wait_hblank
  ld     a,(hl)
  and    %10111111
  ld     (hl),a
  ei
  ;See if we're on ok/cancel line
  ld     a,(KBY)
  cp     3
  jr     z,+++
  ld     a,(KBX)
  dec    a
  cp     $FF
  jr     nz,++
  ld     a,14-1			;Wrap
++:
  ld     (KBX),a
  jr     ++
+++:
  ld     a,(KBX)
  dec    a
  and    1
  ld     (KBX),a
++:
  ;Print new cursor
  call   makekbaddr
  di
  call   wait_hblank
  ld     a,(hl)
  add    $40
  ld     (hl),a
  ei
+:

  ld     a,(JOYP_ACTIVE)	;Up
  bit    6,a
  jr     z,+
  ld     a,(KBY)
  or     a
  jr     z,+
  ;Erase previous cursor
  call   makekbaddr
  di
  call   wait_hblank
  ld     a,(hl)
  and    %10111111
  ld     (hl),a
  ei
  ld     a,(KBY)
  dec    a
  cp     2
  jr     nz,++
  xor    a
  ld     (KBX),a
  ld     a,2
++:
  ld     (KBY),a
  ;Print new cursor
  call   makekbaddr
  di
  call   wait_hblank
  ld     a,(hl)
  add    $40
  ld     (hl),a
  ei
+:

  ld     a,(JOYP_ACTIVE)	;Down
  bit    7,a
  jr     z,+
  ld     a,(KBY)
  cp     4-1
  jr     z,+
  ;Erase previous cursor
  call   makekbaddr
  di
  call   wait_hblank
  ld     a,(hl)
  and    %10111111
  ld     (hl),a
  ei
  ld     a,(KBY)
  inc    a
  cp     3
  jr     nz,++
  ;Default to "cancel"
  xor    a
  ld     (KBX),a
  ld     a,3
++:
  ld     (KBY),a
  ;Print new cursor
  call   makekbaddr
  di
  call   wait_hblank
  ld     a,(hl)
  add    $40
  ld     (hl),a
  ei
+:

  ret


makekbaddr:
  ld     a,(KBY)
  cp     3
  jr     z,++
  ld     h,0
  ld     l,a
  add    hl,hl
  add    hl,hl
  add    hl,hl
  add    hl,hl
  add    hl,hl
  ld     de,$9C00+(32*3)+3
  add    hl,de
  ld     a,(KBX)
  add    l
  ld     l,a
  jr     nc,+
  inc    h
+:
  ret
++:
  ld     hl,$9C00+(32*6)+3
  ld     a,(KBX)
  and    1		;Security
  jr     z,+
  ld     hl,$9C00+(32*6)+15
+:
  ret

text_keyboard:
;   01234567890123456789
  .db "              ",$FE
  .db "              ",$FE
  .db "0123456789ABCD",$FE
  .db "EFGHIJKLMNOPQR",$FE
  .db "STUVWXYZ-+!?/_",$FE
  .db "CANCEL      OK",$FF
