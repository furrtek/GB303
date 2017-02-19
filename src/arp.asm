arpcommon:
  and    $F
  ld     (ARPOFFSET),a
  ld     a,(ARPIDX)
  inc    a
  cp     3
  jr     nz,+++
  xor    a
+++:
  ld     (ARPIDX),a

  ld     a,(DOSLIDE)
  or     a
  ret    nz

  ld     a,(LASTNOTE)
  ld     hl,ARPOFFSET
  add    (hl)
  sla    a
  ld     hl,notelut
  rst    0
  ld     (FLOW),a
  inc    hl
  ld     a,(hl)
  ld     (FHIGH),a

  ret
