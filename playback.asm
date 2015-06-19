loadwave:
  xor    a
  ldh    ($1A),a		;CH3 off
  ;Wave RAM
  ld     hl,$FF30
  ld     a,(de)
  ldi    (hl),a			;See if ldh c is faster
  inc    e
  ld     a,(de)
  ldi    (hl),a
  inc    e
  ld     a,(de)
  ldi    (hl),a
  inc    e
  ld     a,(de)
  ldi    (hl),a
  inc    e
  ld     a,(de)
  ldi    (hl),a
  inc    e
  ld     a,(de)
  ldi    (hl),a
  inc    e
  ld     a,(de)
  ldi    (hl),a
  inc    e
  ld     a,(de)
  ldi    (hl),a
  inc    e
  ld     a,(de)
  ldi    (hl),a
  inc    e
  ld     a,(de)
  ldi    (hl),a
  inc    e
  ld     a,(de)
  ldi    (hl),a
  inc    e
  ld     a,(de)
  ldi    (hl),a
  inc    e
  ld     a,(de)
  ldi    (hl),a
  inc    e
  ld     a,(de)
  ldi    (hl),a
  inc    e
  ld     a,(de)
  ldi    (hl),a
  inc    e
  ld     a,(de)
  ldi    (hl),a

  ld     a,$80
  ldh    ($1A),a		;Wave output enable
  ld     a,(FHIGHF)		;DEBUG
  or     $80
  ldh    ($1E),a
  ret
