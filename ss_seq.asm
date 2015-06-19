setscreen_seq:
  ld     de,text_seq
  ld     hl,$9800+(32*0)+1
  ld     b,TXT_NORMAL
  call   maptext

  ld     de,text_seqhelp
  ld     hl,$9800+(32*1)
  ld     b,TXT_INVERT
  call   maptext

  call   write_pattinfo

  ld     a,(NOTEIDX)
  ld     (SEQ_PREVY),a
  xor    a
  ld     (SEQ_CURX),a
  ld     (SEQ_PREVX),a
  call   draw_seq

  call   setdefaultpal

  ld     hl,vbl_seq
  call   setvblhandler

  call   intset

  ret

draw_seq:
  ld     b,16
-:
  push   bc
  ld     a,b
  dec    a
  xor    $F
  ld     (INITSEQLINE),a
  ld     b,TXT_NORMAL
  call   redrawnote_seq_a
  ld     a,(INITSEQLINE)
  ld     b,TXT_NORMAL
  call   redrawaccent_seq_a
  ld     a,(INITSEQLINE)
  ld     b,TXT_NORMAL
  call   redrawslide_seq_a
  ld     a,(INITSEQLINE)
  ld     b,TXT_NORMAL
  call   redrawosc_seq_a
  ld     a,(INITSEQLINE)
  ld     b,TXT_NORMAL
  call   redrawarp_seq_a
  ld     a,(INITSEQLINE)
  ld     b,TXT_NORMAL
  call   redrawdrum_seq_a
  pop    bc
  dec    b
  jr     nz,-
  call   showcur_seq
  ret

getnotename:
  call   getnotenumber
  bit    7,a
  jr     nz,+
  ld     de,text_noteempty
  ret
+:
  and    $7F
  cp     36+1
  jr     nc,+
  ld     hl,note_names
  sla    a
  sla    a
  ld     d,0
  ld     e,a
  add    hl,de
  ld     d,h
  ld     e,l
  ret
+:
  ;Corrupted note security
  ld     de,text_notecorrupt
  ret

lut_seqlayout:
;Start tile in X, length
.db 1,3
.db 5,1
.db 7,1
.db 9,1
.db 11,2
.db 14,5

getline:
  push   bc
  ld     bc,32
  inc    a
-:
  add    hl,bc
  dec    a
  jr     nz,-
  pop    bc
  ret

