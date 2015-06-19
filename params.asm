paramsave:
  call   clearts

  ld     de,TEMPSECTOR

  ;Magic bytes
  ld     b,16
  ld     hl,magic
-:
  ldi    a,(hl)
  ld     (de),a
  inc    de
  inc    a
  dec    b
  jr     nz,-

  ld     hl,gparams
-:
  ldi    a,(hl)
  or     (hl)
  jr     z,+
  ldd    a,(hl)		;BC is pointer to variable
  ld     b,(hl)
  ld     c,a
  ld     a,(bc)         ;Get variable value
  inc    hl
  inc    hl
  cp     (hl)
  jr     c,++		;<
  jr     z,++		;=
  ld     b,b		;Should never happen, so BP
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

  ld     a,(HWOK_EE)
  or     a
  ret    z			;No EE operation if EE boot check failed

  call   ee_wren
  ld     hl,$2000		; CS low
  ld     (hl),$00
  nop
  ld     c,$02			; Write command
  call   spicom
  ld     c,0                    ; Address MSB
  call   spicom
  ld     c,0                    ; Address LSB
  call   spicom

  ld     b,64
  ld     hl,TEMPSECTOR
-:
  ldi    a,(hl)			; Byte to write
  ld     c,a
  call   spicom
  dec    b
  jr     nz,-

  ld     hl,$2000		; CS high (starts writing)
  ld     (hl),$08

  call   eewaitwrite
  or     a
  jp     z,eetosave		; Timeout

  ld     hl,$0000
  call   verifyts

  ret
  

paramload:
  ld     a,(HWOK_EE)
  or     a
  ret    z			;No EE operation if EE boot check failed

  ld     hl,$0000
  call   eesetr

  call   readts
  
  ld     c,$00
  call   spicom
  ld     a,d
  cp     e
  jr     z,+
  ;Bad checksum: whatever, go on, defaults will be restored if needed...
  jr     +
  ret

+:
  ld     hl,gparams
  ld     de,TEMPSECTOR
-:
  ldi    a,(hl)
  or     (hl)
  jr     z,+
  ldd    a,(hl)		;BC is pointer to variable
  ld     b,(hl)
  ld     c,a
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
  ret
