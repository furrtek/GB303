geteepattname:
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
  ld     b,8
  ld     hl,SELPATTNAME
  ld     de,TEMPSECTOR+1
-:
  ld     a,(de)
  ldi    (hl),a
  inc    de
  dec    b
  jr     nz,-
  
  ld     a,$FF			;Security
  ld     (SELPATTNAME+8),a
  ret
  
geteesongname:
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
  ;Bad checksum:
  ret

+:
  ld     b,8
  ld     hl,SELSONGNAME
  ld     de,TEMPSECTOR+1
-:
  ld     a,(de)
  ldi    (hl),a
  inc    de
  dec    b
  jr     nz,-
  
  ld     a,$FF			;Security
  ld     (SELSONGNAME+8),a
  ret

