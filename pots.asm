readpots:
  ;Shift lowpass trail for pot 1
  ld     a,(POT1LP+1)
  ld     (POT1LP),a
  ld     a,(POT1LP+2)
  ld     (POT1LP+1),a
  ld     a,(POT1LP+3)
  ld     (POT1LP+2),a

  ld     c,%00010000		; Analog input select channel 1
  call   readpot
  ld     (POT1LP+3),a

  ;Do mean of LP trail for pot 1
  ld     hl,POT1LP
  call   domean
  ld     b,a
  ld     (POT1V),a
  

  ld     hl,lut_potsets
  ld     a,(INVERTPOTS)
  or     a
  ld     a,(POTLINK1)
  jr     z,+
  ld     a,(POTLINK3)
+:
  sla    a
  rst    0
  inc    hl
  ld     h,(hl)
  ld     l,a
  call   dojump


  ;Shift lowpass trail for pot 2
  ld     a,(POT2LP+1)
  ld     (POT2LP),a
  ld     a,(POT2LP+2)
  ld     (POT2LP+1),a
  ld     a,(POT2LP+3)
  ld     (POT2LP+2),a

  ld     c,%00001000		; Analog input select channel 3
  call   readpot
  ld     (POT2LP+3),a

  ;Do mean of LP trail for pot 2
  ld     hl,POT2LP
  call   domean
  ld     b,a
  ld     (POT2V),a
  ld     hl,lut_potsets
  ld     a,(POTLINK2)
  sla    a
  rst    0
  inc    hl
  ld     h,(hl)
  ld     l,a
  call   dojump


  ;Shift lowpass trail for pot 3
  ld     a,(POT3LP+1)
  ld     (POT3LP),a
  ld     a,(POT3LP+2)
  ld     (POT3LP+1),a
  ld     a,(POT3LP+3)
  ld     (POT3LP+2),a

  ld     c,%00011000		; Analog input select channel 2
  call   readpot
  ld     (POT3LP+3),a

  ;Do mean of LP trail for pot 3
  ld     hl,POT3LP
  call   domean
  ld     b,a
  ld     (POT3V),a
  ld     hl,lut_potsets
  ld     a,(INVERTPOTS)
  or     a
  ld     a,(POTLINK3)
  jr     z,+
  ld     a,(POTLINK1)
+:
  sla    a
  rst    0
  inc    hl
  ld     h,(hl)
  ld     l,a
  call   dojump

  ret
  
  
domean:
  ld     d,0
  ldi    a,(hl)
  add    (hl)
  inc    hl
  jr     nc,+
  inc    d
+:
  add    (hl)
  inc    hl
  jr     nc,+
  inc    d
+:
  add    (hl)
  jr     nc,+
  inc    d
+:
  srl    d
  rr     a
  srl    d
  rr     a
  ret


readpot:
  ld     hl,$2000		; CS high, so CS low for ADC
  ld     (hl),$08
  nop
  ld     hl,$2000		; CS low, so CS high for ADC - Acquisition...
  ld     (hl),$00
  nop
  nop
  nop
  nop
  ld     hl,$2000		; CS high, so CS low for ADC
  ld     (hl),$08
  nop

  call   spicomb
  ld     a,d
  and    $0F
  push   af
  ld     c,$00
  call   spicomb		; Get remaining bits
  ld     a,d
  and    $F0
  ld     d,a
  pop    af
  or     d
  swap   a
  ret
  
adcbootcheck:
  ld     hl,$2000		; CS high, so CS low for ADC
  ld     (hl),$08
  nop

  ld     c,%00000000
  call   spicomb    		; Ignore
  ld     c,%00000000
  call   spicomb		; If last 4 bits are 0 (as datasheet), assume ADC is there and working
  ld     a,d
  and    $0F
  ld     a,$FF
  jr     z,+
  xor    a
+:
  ld     (HWOK_ADC),a
  ret

lut_potsets:
  .dw pots_cutoff
  .dw pots_reson
  .dw pots_pitch
  .dw pots_slide
  .dw pots_lfospeed
  .dw pots_lfoamp

pots_cutoff:
  ld     a,b
  cpl
  srl    a			;128
  srl    a			;64
  ld     b,a
  srl    a			;32
  add    b			;64+32=96
  ld     (CUTOFFSET),a
  ret
  
pots_reson:
  ld     a,b
  swap   a			;/16
  and    $F
  ld     (RESON),a
  ret

pots_pitch:
  ld     a,b
  srl    a
  ld     (BEND),a
  ret
  
pots_slide:
  ld     a,b
  srl    a
  ld     (SLIDESPEED),a
  ret

pots_lfospeed:
  ld     a,b
  srl    a
  srl    a
  srl    a
  ld     (LFOSPEED),a
  ret
  
pots_lfoamp:
  ld     a,b
  swap   a			;/16
  and    $F
  ld     (LFOAMP),a
  ret

