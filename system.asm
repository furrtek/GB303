setvblhandler:
  ldh    a,($FF)
  and    $FE			;Disable vblank
  ldh    ($FF),a
  ld     a,l
  ld     (VBL_HANDLER),a
  ld     a,h
  ld     (VBL_HANDLER+1),a
  ldh    a,($FF)
  or     1			;Enable vblank
  ldh    ($FF),a
  ret

readinput:
  push   bc
  ld     a,%00010000		;Buttons
  ldh    ($00),a
  nop
  nop
  nop
  ldh    a,($00)
  and    $0F
  xor    $0F
  ld     b,a
  ld     a,%00100000  		;Directions
  ldh    ($00),a
  nop
  nop
  nop
  ldh    a,($00)
  and    $0F
  xor    $0F
  swap   a
  or     b
  ld     (JOYP_CURRENT),a
  ld     b,a
  ld     hl,JOYP_PREV
  ld     a,(hl)
  xor    b
  ld     c,a
  jr     nz,+
  ;No difference: inc repeat timer if button press
  ld     a,b
  and    $F0
  jr     z,+
  ld     a,(JOYP_RPTTIMER)
  inc    a
  and    KEY_REPEAT_MASK
  cp     KEY_REPEAT_MASK
  jr     nz,+++
  ;Strobe key
  ld     c,b
+++:
  ld     (JOYP_RPTTIMER),a
  jr     ++
+:
  xor    a
  ld     (JOYP_RPTTIMER),a
++:
  ld     a,c
  and    b            		;Keep rising edges
  ld     (hl),b
  ld     (JOYP_ACTIVE),a
  pop    bc
  ret

clear:
  xor    a
  ldi    (hl),a
  dec    bc
  ld     a,c
  or     b
  jr     nz,clear
  ret
  
intset:
  ld     a,%11100100            ;Palette BG
  ldh    ($47),a
  ld     a,%11100100            ;Palette SPR0
  ldh    ($48),a
  xor    a
  ldh    ($0F),a
  ld     a,%00001111		;Vblank + STAT + timer + serial
  ldh    ($FF),a
  ld     a,%01000000		;LYC causes STAT interrupt
  ldh    ($41),a
  ld     a,%11010011		;Screen on
  ldh    ($40),a
  ret

;Converts A to BCD
bin2bcd:
  push	 bc
  ld	 b,10
  ld	 c,-1
div10:
  inc	 c
  sub	 b
  jr	 nc,div10
  add	 b
  ld	 b,a
  ld 	 a,c
  add	 a
  add	 a
  add	 a
  add	 a
  or	 b
  pop	 bc
  ret

vblank:
  push   af
  ld     a,1
  ld     (VBL),a
  pop    af
  reti

timer:
  push   af
  ld     a,(SYNCMODE)		;Only activate internal sync when SYNCMODE = NONE
  cp     SYNC_NONE
  jr     z,+
  cp     SYNC_NANO
  jr     z,+
  jr     ++
+:
  push   hl
  ;Handle beat tick
  ld     hl,BPM_MATCH
  ld     a,(BPM_CNT)
  inc    a
  cp     (hl)
  jr     c,+
  ld     a,1
  ld     (BEAT),a
  dec    a
+:
  ld     (BPM_CNT),a
  pop    hl
++:
  pop    af
  reti

;Input: D = Dividend, E = Divisor, A = 0
;Output: D = Quotient, A = Remainder
;Routine stolen from "Z80 Bits"
div8_8:
  xor    a

  sla	 d		; unroll 8 times
  rla			; ...
  cp	 e		; ...
  jr	 c,+		; ...
  sub	 e		; ...
  inc	 d		; ...
+:
  sla	 d		; unroll 8 times
  rla			; ...
  cp	 e		; ...
  jr	 c,+		; ...
  sub	 e		; ...
  inc	 d		; ...
+:
  sla	 d		; unroll 8 times
  rla			; ...
  cp	 e		; ...
  jr	 c,+		; ...
  sub	 e		; ...
  inc	 d		; ...
+:
  sla	 d		; unroll 8 times
  rla			; ...
  cp	 e		; ...
  jr	 c,+		; ...
  sub	 e		; ...
  inc	 d		; ...
+:
  sla	 d		; unroll 8 times
  rla			; ...
  cp	 e		; ...
  jr	 c,+		; ...
  sub	 e		; ...
  inc	 d		; ...
+:
  sla	 d		; unroll 8 times
  rla			; ...
  cp	 e		; ...
  jr	 c,+		; ...
  sub	 e		; ...
  inc	 d		; ...
+:
  sla	 d		; unroll 8 times
  rla			; ...
  cp	 e		; ...
  jr	 c,+		; ...
  sub	 e		; ...
  inc	 d		; ...
+:
  sla	 d		; unroll 8 times
  rla			; ...
  cp	 e		; ...
  jr	 c,+		; ...
  sub	 e		; ...
  inc	 d		; ...
+:
  ret
