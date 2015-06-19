savegparams:
  ld     a,(HWOK_EE)
  or     a
  ret    z			;No EE operation if EE boot check failed
 
  ld     a,$40
  ld     (EEWRADDRL),a
  xor    a
  ld     (EEWRADDRM),a

  call   clearts
  
  ld     de,TEMPSECTOR

  ld     hl,gparams
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

  ret
  
  
loadgparams:
  ld     a,$40
  ld     (EEWRADDRL),a
  xor    a
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

+:
  ld     hl,gparams
  ld     de,TEMPSECTOR
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

  ld     a,(LASTSAVED_SONG)
  ld     (SAVECURSONGSLOT),a
  call   loadsong

  ret

