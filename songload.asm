loadsong:
  ld     a,(HWOK_EE)
  or     a
  ret    z			;No EE operation if EE boot check failed

  ld     a,(SAVECURSONGSLOT)
  cp     MAX_SONGS
  ret    nc			;Sanity check

  ld     b,a
  sla    a
  add    b			;*3

  ld     h,0			;*64
  ld     l,a

  add    hl,hl
  add    hl,hl
  add    hl,hl
  add    hl,hl
  add    hl,hl
  add    hl,hl

  ld     a,l
  ld     (EEWRADDRL),a
  ld     a,h
  add    $33			;Start at $3300
  ld     (EEWRADDRM),a

  call   readts

  ld     c,$00
  call   spicom
  
  ld     a,$08			; CS high
  ld     ($2000),a
  nop

  ld     a,d
  cp     e
  jr     z,+
  ;Bad checksum: whatever, go on, defaults will be restored if needed...
  ret

  ld     a,(TEMPSECTOR)
  or     a
  ret    z			;Blank song, don't load

+:
  ld     b,8
  ld     hl,SONGNAME
  ld     de,TEMPSECTOR+1
-:
  ld     a,(de)
  ldi    (hl),a
  inc    de
  dec    b
  jr     nz,-
  
  ld     a,$FF			;Security
  ld     (SONGNAME+8),a

  ld     hl,sngparams
  ld     de,TEMPSECTOR+$0B
-:
  ldi    a,(hl)
  or     (hl)
  jr     z,+
  ldd    a,(hl)		;BC is pointer to variable
  ld     c,(hl)
  ld     b,a
  ld     a,(de)         ;Get EE value
  inc    hl
  inc    hl
  cp     (hl)
  jr     c,++		;<
  jr     z,++		;=
  inc    hl
  ld     a,(hl)		;OOB: Restore default
  jr     +++
++:
  inc    hl
+++:
  inc    hl
  ld     (bc),a
  inc    de
  jr     -
+:

  ld     b,39
  ld     hl,SONG
  ld     de,TEMPSECTOR+$17
-:
  ld     a,(de)
  ldi    (hl),a
  inc    de
  dec    b
  jr     nz,-


  ld     a,(EEWRADDRL)
  add    $40
  ld     (EEWRADDRL),a
  jr     nc,+
  ld     hl,EEWRADDRM
  inc    (hl)
+:

  call   readts

  ld     c,$00
  call   spicom
  
  ld     a,$08			; CS high
  ld     ($2000),a
  nop

  ld     a,d
  cp     e
  jr     z,+
  ;Bad checksum:
  ret

+:
  ld     b,63
  ld     hl,SONG+39
  ld     de,TEMPSECTOR
-:
  ld     a,(de)
  ldi    (hl),a
  inc    de
  dec    b
  jr     nz,-
  
  ld     a,(EEWRADDRL)
  add    $40
  ld     (EEWRADDRL),a
  jr     nc,+
  ld     hl,EEWRADDRM
  inc    (hl)
+:

  call   readts

  ld     c,$00
  call   spicom
  
  ld     a,$08			; CS high
  ld     ($2000),a
  nop

  ld     a,d
  cp     e
  jr     z,+
  ;Bad checksum:
  ret

+:
  ld     b,58
  ld     hl,SONG+102
  ld     de,TEMPSECTOR
-:
  ld     a,(de)
  ldi    (hl),a
  inc    de
  dec    b
  jr     nz,-

  ld    a,(SAVECURSONGSLOT)
  ld    (CURSONG),a
  
  xor   a
  ld    (SONGPTR),a

  ld     hl,SONG
  rst    0
  cp     $FF
  jr     z,+
  ld     (SAVECURPATTSLOT),a
  call   loadpattern
+:

  call  setstereo
  ld    a,(CURSCREEN)
  cp    6
  call  z,setscreen

  ret
