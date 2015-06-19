input_piano:
  call   playstop
  
  ld     a,(JOYP_CURRENT)	;Select ?
  bit    2,a
  ret    nz

  ld     a,(JOYP_ACTIVE)	;Right: next note
  bit    4,a
  jr     z,+
  ld     a,(NOTECUR_X)
  cp     15
  jr     nz,++
  ld     a,-1			;Wrap around
++:
  inc    a
  ld     (NOTECUR_X),a
+:

  ld     a,(JOYP_ACTIVE)	;Left: prev note
  bit    5,a
  jr     z,+
  ld     a,(NOTECUR_X)
  or     a
  jr     nz,++
  ld     a,15+1			;Wrap around
++:
  dec    a
  ld     (NOTECUR_X),a
+:

  ld     a,(JOYP_ACTIVE)	;Up
  bit    6,a
  jr     z,+
  ld     a,(NOTECUR_X)
  call   getnotenumber
  ld     b,a
  and    $80			;Keep note on bit in C
  ld     c,a
  ld     a,b
  cp     36+$80			;If note was off, set to on, C-2
  jr     nz,++
  xor    a			;C-2
  jr     +++
++:
  ld     a,(JOYP_CURRENT)	;If B, move up by 6 notes
  bit    1,a
  jr     z,++
  ld     a,b
  and    $7F
  add    6
  cp     36			;3 octaves * 12 notes
  jr     c,+++
  ld     a,35
  jr     +++
++:
  ld     a,b
  and    $7F
  inc    a
  cp     36			;3 octaves * 12 notes
  jr     z,+
+++:
  or     c
  ld     (hl),a
  call   draw_notes
+:

  ld     a,(JOYP_ACTIVE)	;Down
  bit    7,a
  jr     z,+
  ld     a,(NOTECUR_X)
  call   getnotenumber
  ld     b,a
  and    $80			;Keep note on bit in C
  ld     c,a
  ld     a,(JOYP_CURRENT)	;If B, move down by 6 notes
  bit    1,a
  jr     z,++
  ld     a,b
  and    $7F
  cp     6
  jr     nc,++++
-:
  ld     a,36+$80		;Cap to note off
  jr     +++
++++:
  cp     36
  jr     z,-			;Hey, come back here !
  sub    6
  jr     +++
++:
  ld     a,b
  and    $7F
  dec    a
  cp     -1
  jr     z,++++
  cp     36-1			;Compensate for previous DEC A
  jr     z,+
  jr     +++
++++:
  ld     a,36+$80		;Cap to note off
+++:
  or     c
  ld     (hl),a
  call   draw_notes
+:

  ld     a,(JOYP_ACTIVE)	;A: Toggle note
  bit    0,a
  jr     z,+
  ld     a,(NOTECUR_X)
  call   getnotenumber
  cp     36+$80
  jr     z,+			;Don't toggle if note off
  xor    $80
  ld     (hl),a
  call   draw_notes
+:

  ret
