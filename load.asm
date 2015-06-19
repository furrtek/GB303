loadpattern:
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
  ;Bad checksum: whatever, go on, defaults will be restored if needed...
  ret
  
  ld     a,(TEMPSECTOR)
  or     a
  ret    z			;Blank pattern, don't load

+:
  ld     b,8
  ld     hl,PATTNAME
  ld     de,TEMPSECTOR+1
-:
  ld     a,(de)
  ldi    (hl),a
  inc    de
  dec    b
  jr     nz,-
  
  ld     a,$FF			;Security
  ld     (PATTNAME+8),a

  ld     hl,pparams
  ld     de,TEMPSECTOR+$10
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


  ld     a,(EEWRADDRL)
  or     $40
  ld     (EEWRADDRL),a

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
  ld     b,16*4
  ld     hl,SEQ
  ld     de,TEMPSECTOR
-:
  ld     a,(de)
  ldi    (hl),a
  inc    de
  dec    b
  jr     nz,-

  ld    a,(SAVECURPATTSLOT)
  ld    (CURPATTERN),a

  ld     a,(CURSCREEN)		; Update pattern name in specific screens (not table, nor memory)
  cp     1
  jr     z,+
  cp     6
  jr     nz,++
  ld    a,(CURSCREEN)
  cp    6
  call  z,setscreen
  ret
++:
  cp     2
  call   z,draw_seq
  jp     write_pattinfo		; Call+ret
+:
  or     a
  ret    nz
  call   liv_erasepotlinks	; To test !
  jp     liv_drawpotlinks       ; Call+ret
