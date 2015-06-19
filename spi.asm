;Talk to ADC (don't forget CS assertion)
;Out in C, In in D
spicomb:
  push   bc
  ld     d,0
  ld     b,8
-:
  rl     c
  ld     a,$08
  jr     nc,+
  ld     a,$28
+:                              ; 00D0 1000
  ld     ($2000),a		; Data out
  nop

  or     $10			; 00D1 1000
  ld     ($2000),a		; SCK high
  nop

  push   af
  sla    d
  ld     a,($A000)		; Read SO
  xor    1
  and    1
  or     d
  ld     d,a
  pop    af

  and    $28                    ; 00D0 1000
  ld     ($2000),a		; SCK low
  nop

  dec    b
  jr     nz,-
  pop    bc
  ret
  
;Talk to EEPROM (don't forget CS assertion)
;Out in C, In in D
spicom:
  push   bc
  ld     d,0
  ld     b,8
-:
  rl     c
  ld     a,0
  jr     nc,+
  ld     a,$20
+:                              ; 00D0 0000
  ld     ($2000),a		; Data out
  nop

  or     $10			; 00D1 0000
  ld     ($2000),a		; SCK high
  nop

  push   af
  sla    d
  ld     a,($A000)		; Read SO
  xor    1
  and    1
  or     d
  ld     d,a
  pop    af

  and    $20                    ; 00D0 0000
  ld     ($2000),a		; SCK low
  nop

  dec    b
  jr     nz,-
  pop    bc
  ret

