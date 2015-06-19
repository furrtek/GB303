draw_notes:
  ;Erase bottom BG line (note off's zone)
  ld     hl,$9800+(32*16)+4
  ld     bc,18
  call   clear_w

  ld     hl,$9800+(32*4)+3
  ld     b,12
-:
  ld     c,16
--:
  ld     a,T_GRIDNOTE
  di
  call   wait_write
  ldi    (hl),a
  ei
  dec    c
  jr     nz,--
  ld     a,l
  add    16
  ld     l,a
  jr     nc,+
  inc    h
+:
  dec    b
  jr     nz,-

  ld     de,SEQ
  ld     b,0
-:
  ld     a,(de)
  inc    de
  inc    de
  inc    de
  inc    de
  bit    7,a
  jr     z,++
  call   getnoteypos
+:

  ld     h,0
  ld     l,a
  sla    l		;*32
  rl     h
  sla    l
  rl     h
  sla    l
  rl     h
  sla    l
  rl     h
  sla    l
  rl     h
  push   de
  ld     de,$9800+(32*4)+3
  add    hl,de
  pop    de
  ld     a,b
  add    l
  ld     l,a
  jr     nc,+
  inc    h
+:
  ld     a,c
  di
  call   wait_write
  ld     (hl),a
  ei
++:
  inc    b
  ld     a,b
  cp     16
  jr     nz,-
  ret

getnoteypos:
  and    $7F
  cp     12
  jr     c,olo
  cp     24
  jr     nc,ohi
  sub    12
  cpl
  add    12
  ld     c,T_NOTE
  ret
ohi:
  cp     36
  jr     nz,+
  ;Note off code
  ld     a,12
  ld     c,T_NOTEOFF
  ret
+:
  sub    24
  cpl
  add    12
  ld     c,T_NOTEUP
  ret
olo:
  cpl
  add    12
  ld     c,T_NOTEDN
  ret

write_pattinfo:
  ld     hl,$9800+(32*0)+7
  ld     a,'P'-TXT_NORMAL
  di
  call   wait_write
  ld     (hl),a
  ei

  ld     a,(CURPATTERN)
  ld     hl,$9800+(32*0)+8
  ld     b,TXT_NORMAL
  call   writeAsmall
  
  ld     hl,$9800+(32*0)+10
  ld     a,':'-TXT_NORMAL
  di
  call   wait_write
  ld     (hl),a
  ei

  ld     de,PATTNAME
  ld     hl,$9800+(32*0)+11
  ld     b,0
  call   maptext
  ret

write_songinfo:
  ld     hl,$9800+(32*0)+7
  ld     a,'S'-TXT_NORMAL
  di
  call   wait_write
  ld     (hl),a
  ei

  ld     a,(CURSONG)
  ld     hl,$9800+(32*0)+8
  ld     b,TXT_NORMAL
  call   writeAsmall

  ld     hl,$9800+(32*0)+10
  ld     a,':'-TXT_NORMAL
  di
  call   wait_write
  ld     (hl),a
  ei

  ld     de,SONGNAME
  ld     hl,$9800+(32*0)+11
  ld     b,0
  call   maptext
  ret
