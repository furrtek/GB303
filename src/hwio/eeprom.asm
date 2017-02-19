;Tests for magic bytes, set HWOK_EE or jump to format
eebootcheck:
  xor    a
  ld     (EEWRADDRL),a
  ld     (EEWRADDRM),a
  
  call   readts

  ld     hl,TEMPSECTOR
  ld     de,magic
  ld     b,9
-:
  ld     a,(de)
  cp     (hl)
  jr     nz,+
  inc    hl
  inc    de
  dec    b
  jr     nz,-
  ld     hl,$2000		; CS high
  ld     (hl),$08
  nop
  ld     a,1
  ld     (HWOK_EE),a		; Magic bytes are ok, assume EEPROM is good
  call   loadgparams
  ret
+:
  xor    a
  ld     (HWOK_EE),a		; EEPROM didn't work :(
  call   checkee
  ret

eefullcheck:
  ld     hl,$0100
  call   eesetr
  ld     b,126
-:
  push   bc
  ld     e,0
  ld     b,127			; Make checksum
--:
  ld     c,$00
  call   spicom
  ld     a,e
  add    d
  ld     e,a
  dec    b
  jr     nz,--
  ld     c,$00
  call   spicom
  ld     a,e
  cp     d			; Compare calculated/read
  jr     z,+
  pop    bc
  xor    a
  ret				; Ret with A = 0 (error)
+:
  pop    bc
  push   bc
  ld     d,0
  ld     e,b
  ld     hl,$9800+(32*15)+13
  call   writeDE
  pop    bc
  dec    b
  jr     nz,-
  ld     a,1			; Ret with A = 1 (ok)
  ret

;HL=Address
eesetr:
  ld     a,$08			; CS high
  ld     ($2000),a
  nop
  ld     a,$00			; CS low
  ld     ($2000),a
  nop
  ld     c,$03			; Read command
  call   spicom
  ld     c,h			; Address MSB
  call   spicom
  ld     c,l			; Address LSB
  call   spicom
  ret
  
;HL=Address
eesetw:
  ld     a,$08			; CS high
  ld     ($2000),a
  nop
  ld     a,$00			; CS low
  ld     ($2000),a
  nop
  ld     c,$02			; Write command
  call   spicom
  ld     c,h			; Address MSB
  call   spicom
  ld     c,l			; Address LSB
  call   spicom
  ret

checkee:
  ;See if EEPROM is there and alive, at least

  ld     hl,$0000
  call   eesetr
  ld     c,$00
  call   spicom			; Make forcibly new byte in E from EE address location 0000
  ld     a,$55
  xor    d
  ld     e,a

  xor    a
  ld     (EEWRADDRL),a
  ld     (EEWRADDRM),a

  push   de
  call   clearts
  pop    de

  ld     a,e
  ld     (TEMPSECTOR),a

  call   dotschecksum
  ld     a,1
  ld     (HWOK_EE),a		; To allow verify to work
  call   writesave

  or     a
  jr     nz,+

  xor    a
  ld     (HWOK_EE),a		; EEPROM didn't work :(
  ret

eeto:
  xor    a
  ld     (HWOK_EE),a		; EEPROM didn't work :(
  ret

+:
  call   eewmagic

  ld     a,1
  ld     (HWOK_EE),a		; Magic bytes are ok, assume EEPROM is good
  ret
  
eewmagic:
  ;Write magic bytes
  xor    a
  ld     (EEWRADDRL),a
  ld     (EEWRADDRM),a

  call   clearts

  ld     hl,TEMPSECTOR
  ld     de,magic
  ld     b,9
-:
  ld     a,(de)
  ldi    (hl),a
  inc    de
  dec    b
  jr     nz,-

  call   dotschecksum
  ld     a,1
  ld     (HWOK_EE),a		; To allow verify to work
  call   writesave

  ret

  ;EEPROM seems to work
formatee:
  ;Format EEPROM
  call   ee_wren

  call   eewmagic

  ;Clear user data
  xor    a
  ld     (EEWRADDRL),a
  ld     a,1
  ld     (EEWRADDRM),a		; Start at $0100

  ld     b,252			; 252 64-byte blocks to erase
--:
  push   bc
  call   ee_wren
  ld     hl,$2000		; CS low
  ld     (hl),$00
  nop
  ld     c,$02			; Write command
  call   spicom
  ld     a,(EEWRADDRM)		; Address MSB
  ld     c,a
  call   spicom
  ld     a,(EEWRADDRL)		; Address LSB
  ld     c,a
  call   spicom

  ld     b,64
-:
  ld     c,$00
  call   spicom
  dec    b
  jr     nz,-
  ld     hl,$2000		; CS high (starts writing)
  ld     (hl),$08

  call   eewaitwrite
  or     a
  jp     z,eeto			; Timeout

  ld     a,(EEWRADDRL)
  add    $40
  ld     e,a
  ld     (EEWRADDRL),a
  ld     a,(EEWRADDRM)
  adc    0
  ld     d,a
  ld     (EEWRADDRM),a

  ld     hl,$9800+(32*15)+8
  call   writeDE

  pop    bc
  dec    b
  jr     nz,--

  ld     hl,$2000		; CS high
  ld     (hl),$08
  nop

  call   eefullcheck
  ld     (HWOK_EE),a
  
  push   af
  call   setstereo
  pop    af

  ret

eewaitwrite:
  ld     hl,$2000		; CS low
  ld     (hl),$00
  nop
  nop
  ld     b,255			; Timeout
-:
  ld     c,$05			; Read status command
  call   spicom
  nop
  nop
  nop
  nop
  ld     a,d
  and    1
  jr     nz,eewriting
  dec    b
  jr     nz,-

  xor    a
  ld     hl,$2000		; CS high
  ld     (hl),$08
  ret
eewriting:
  ld     b,255			; Timeout
-:
  ld     c,$05			; Read status command
  call   spicom
  nop
  nop
  nop
  nop
  nop
  nop
  ld     a,d
  and    1
  jr     z,eewriten
  dec    b
  jr     nz,-
  ;Timed out !
  xor    a
  ld     hl,$2000		; CS high
  ld     (hl),$08
  ret
eewriten:
  ld     a,1
  ld     hl,$2000		; CS high
  ld     (hl),$08
  ret


ee_wren:
  ld     hl,$2000		; CS high
  ld     (hl),$08
  nop
  ld     hl,$2000		; CS low
  ld     (hl),$00
  nop
  ld     c,$06			; WREN command
  call   spicom
  nop
  nop
  nop
  nop
  ld     hl,$2000		; CS high
  ld     (hl),$08
  nop
  ret
  

verifyts:
  ld     a,(HWOK_EE)
  or     a
  ret    z			;No EE operation if EE boot check failed

verifyts_force:
  ld     a,$08			; CS high
  ld     ($2000),a
  nop
  ld     a,$00			; CS low
  ld     ($2000),a
  nop

  ld     a,(EEWRADDRL)
  ld     l,a
  ld     a,(EEWRADDRM)
  ld     h,a
  call   eesetr

  ld     b,64
  ld     hl,TEMPSECTOR
-:
  ld     c,$00
  call   spicom
  ld     a,d
  cp     (hl)
  jr     nz,vdiff
  inc    hl
  dec    b
  jr     nz,-
  ;Checked ok
  ld     a,$08			; CS high
  ld     ($2000),a
  nop
  ld     a,1
  ret
vdiff:
  ;Checked wrong
  ld     a,$08			; CS high
  ld     ($2000),a
  nop
  xor    a
  ;jp     start
  ret

clearts:
  ld     hl,TEMPSECTOR
  ld     bc,64
  jp     clear
  
dotschecksum:
  ld     hl,TEMPSECTOR
  ld     b,63
  ld     e,0
-:
  ldi    a,(hl)
  add    e
  ld     e,a
  dec    b
  jr     nz,-
  ld     (hl),e
  ret
  
readts:
  ld     a,$08			; CS high
  ld     ($2000),a
  nop
  ld     a,$00			; CS low
  ld     ($2000),a
  nop
  
  ld     a,(EEWRADDRL)
  ld     l,a
  ld     a,(EEWRADDRM)
  ld     h,a
  call   eesetr

  ld     b,63
  ld     e,0
  ld     hl,TEMPSECTOR
-:
  ld     c,$00
  call   spicom
  ld     a,d
  ldi    (hl),a
  add    e
  ld     e,a
  dec    b
  jr     nz,-

  ret
  
  
writesave:
  call   ee_wren
  ld     a,(EEWRADDRM)		; Address MSB
  ld     h,a
  ld     a,(EEWRADDRL)		; Address LSB
  ld     l,a
  call   eesetw

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

  ld     a,(EEWRADDRM)		; Address MSB
  ld     h,a
  ld     a,(EEWRADDRL)		; Address LSB
  ld     l,a
  call   verifyts
  ret


magic:
  .db "LYSERGIC"
  .db 1,0,0,0,0,0,0,0
