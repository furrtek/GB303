savepattern:
  ld     a,(HWOK_EE)
  or     a
  ret    z			;No EE operation if EE boot check failed
  
  ld     a,(SAVECURPATTSLOT)
  cp     MAX_PATTERNS
  ret    nc			;Sanity check

  ld     b,a                    ;00000000 aAAAAAAA
  rrca                          ;0aAAAAAA A0000000
  and    $80
  ld     (EEWRADDRL),a
  ld     a,b
  srl    a
  and    $3F
  inc    a			;Start at $0100
  ld     (EEWRADDRM),a

  call   clearts

  ld     de,TEMPSECTOR
  ld     a,$01                  ;Used slot flag
  ld     (de),a
  inc    de

  ld     hl,TEMPNAME		;Pattern name
  ld     b,9
-:
  ldi    a,(hl)
  ld     (de),a
  inc    de
  dec    b
  jr     nz,-
  
  ld     de,TEMPSECTOR+$10

  ld     hl,pparams
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
  ld     b,b		;Should never happen
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

  call   dotschecksum
  call   writesave



  ld     a,(EEWRADDRL)
  or     $40
  ld     (EEWRADDRL),a

  call   clearts

  ld     hl,TEMPSECTOR
  ld     b,4*16
  ld     de,SEQ
-:
  ld     a,(de)
  ldi    (hl),a
  inc    de
  dec    b
  jr     nz,-

  call   dotschecksum
  call   writesave

  ld     a,(SAVECURPATTSLOT)
  ld     (LASTSAVED_PATT),a
  
  ld     de,PATTNAME
  ld     hl,TEMPNAME		;Set runtime pattern name to saved name
  ld     b,9
-:
  ldi    a,(hl)
  ld     (de),a
  inc    de
  dec    b
  jr     nz,-
  
  ld     a,(SAVECURPATTSLOT)
  ld     (CURPATTERN),a

  call   savegparams
  ld     a,(CURSCREEN)
  cp     6
  call   z,setscreen

  ret


eetosave:
;-:
  ;jp     start
  ;jr     -
  ret
