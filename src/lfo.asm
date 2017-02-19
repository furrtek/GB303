lfostep:
  ld     a,(LFOACC)
  ld     b,a
  ld     hl,lut_cos
  add    64
  rst    0
  bit    7,a
  jr     z,+
  cpl
+:
  ld     c,a
  ld     a,(LFOSPEED)
  add    b
  ld     (LFOACC),a

  ld     d,c
  ld     a,(LFOAMP)
  and    $0F			;Security
  xor    $0F
  inc    a			;Avoid /0
  ld     e,a
  xor    a
  call   div8_8
  ld     c,d

  ld     a,(LFOROUTE)
  or     a
  ret    z
  dec    a
  jr     nz,+
  ld     a,c
  sra    a
  sra    a
  ld     (LFOCUTOFF),a
  xor    a
  ld     (LFORESON),a
  ld     (LFOPITCH),a
  ret
+:
  dec    a
  jr     nz,+
  ld     a,c
  swap   a
  and    $F
  ld     (LFORESON),a
  xor    a
  ld     (LFOCUTOFF),a
  ld     (LFOPITCH),a
  ret
+:
  dec    a
  ret    nz
  ld     a,c
  sra    a
  ld     (LFOPITCH),a
  xor    a
  ld     (LFOCUTOFF),a
  ld     (LFORESON),a
  ret

resetlfo:
  ld     a,(LFORESET)
  or     a
  ret    z
  xor    a
  ld     (LFOACC),a
  ret
