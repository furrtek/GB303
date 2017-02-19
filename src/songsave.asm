savesong:
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

  call   clearts

  ld     de,TEMPSECTOR
  ld     a,$01                  ;Used slot flag
  ld     (de),a
  inc    de

  ld     hl,TEMPNAME		;Song name (no shit)
  ld     b,9
-:
  ldi    a,(hl)
  ld     (de),a
  inc    de
  dec    b
  jr     nz,-

  ld     de,TEMPSECTOR+$0B

  ld     hl,sngparams
-:
  ldi    a,(hl)
  or     (hl)
  jr     z,+
  ldd    a,(hl)		;BC is pointer to variable
  ld     c,(hl)
  ld     b,a
  ld     a,(bc)         ;Get variable value
  inc    hl
  inc    hl
  cp     (hl)
  jr     c,++		;<
  jr     z,++		;=
  ld     b,b		;Should never happen, so BP DEBUG
  inc    hl
  ld     a,(hl)		;Restore default just for sanitizing runtime data
  ld     (bc),a
  jr     +++
++:
  inc    hl
+++:
  inc    hl
  ld     (de),a
  inc    de
  jr     -
+:

  ld     hl,TEMPSECTOR+$17	; Block 0
  ld     b,39
  ld     de,SONG
-:
  ld     a,(de)
  ldi    (hl),a
  inc    de
  dec    b
  jr     nz,-

  call   dotschecksum
  call   writesave


  ld     a,(EEWRADDRL)
  add    $40
  ld     (EEWRADDRL),a
  jr     nc,+
  ld     hl,EEWRADDRM
  inc    (hl)
+:

  call   clearts

  ld     hl,TEMPSECTOR		; Block 1: $1F~$5D
  ld     b,63
  ld     de,SONG+39
-:
  ld     a,(de)
  ldi    (hl),a
  inc    de
  dec    b
  jr     nz,-

  call   dotschecksum
  call   writesave
  

  ld     a,(EEWRADDRL)
  add    $40
  ld     (EEWRADDRL),a
  jr     nc,+
  ld     hl,EEWRADDRM
  inc    (hl)
+:

  call   clearts

  ld     hl,TEMPSECTOR		; Block 2: $5E~$5D
  ld     b,58
  ld     de,SONG+102
-:
  ld     a,(de)
  ldi    (hl),a
  inc    de
  dec    b
  jr     nz,-

  call   dotschecksum
  call   writesave
  
  ld     a,(SAVECURSONGSLOT)
  ld     (LASTSAVED_SONG),a

  ld     de,SONGNAME
  ld     hl,TEMPNAME		;Set runtime song name to saved name
  ld     b,9
-:
  ldi    a,(hl)
  ld     (de),a
  inc    de
  dec    b
  jr     nz,-
  
  ld     a,(SAVECURSONGSLOT)
  ld     (CURSONG),a
  
  call   savegparams
  call   setscreen

  ret
