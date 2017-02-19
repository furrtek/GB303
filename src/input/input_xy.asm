input_xy:
  call   playstop
  
  ld     a,(JOYP_CURRENT)	;Select ?
  bit    2,a
  ret    nz
  
  ld     a,(HWOK_ADC)		;No controls if pots are OK
  or     a
  ret    nz

  ld     a,(JOYP_ACTIVE)
  bit    4,a
  jr     z,+
  ld     a,(CUTOFFSET)
  cp     96-1
  jr     z,+
  inc    a
  ld     (CUTOFFSET),a
+:

  ld     a,(JOYP_ACTIVE)
  bit    5,a
  jr     z,+
  ld     a,(CUTOFFSET)
  or     a
  jr     z,+
  dec    a
  ld     (CUTOFFSET),a
+:

  ld     a,(JOYP_ACTIVE)
  bit    6,a
  jr     z,+
  ld     a,(RESON)
  cp     16-1
  jr     z,+
  inc    a
  ld     (RESON),a
+:

  ld     a,(JOYP_ACTIVE)
  bit    7,a
  jr     z,+
  ld     a,(RESON)
  or     a
  jr     z,+
  dec    a
  ld     (RESON),a
+:

  ret
