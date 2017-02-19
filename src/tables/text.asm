text_config:
  .db "CFG",$FE,$FE
  .db "BPM:",$FE,$FE
  .db "SYNC:",$FE,$FE
  .db "LFO TO:",$FE,
  .db "LFO RESET:",$FE,$FE
  .db "SYNTH:",$FE
  .db "DRUMS:",$FE,$FE
  .db "PATTERN",$FE
  .db "OVERRIDES:",$FF

text_yes:
  .db "YES",$FF
text_no:
  .db "NO ",$FF
  
text_memdef:
  .db ":        ",$FF
  
text_confirm:
  .db "ARE YOU SURE ?",$FE
  .db " NO      YES",$FE
  .db "              ",$FF

textptr_yesno:
  .dw text_no
  .dw text_yes

text_syncnone:
  .db "NONE        ",$FF
text_synclsdjs:
  .db "LSDJ SLAVE  ",$FF
text_synclsdjmidi:
  .db "LSDJ MIDI-IN",$FF
text_syncnano:
  .db "NANO MASTER ",$FF
text_syncfmidi:
  .db "FULL MIDI   ",$FF

textptr_sync:
  .dw text_syncnone
  .dw text_synclsdjs
  .dw text_synclsdjmidi
  .dw text_syncnano
  .dw text_syncfmidi

text_lfon:
  .db "NOTHING  ",$FF
text_lforc:
  .db "CUTOFF   ",$FF
text_lforr:
  .db "RESONANCE",$FF
text_lforp:
  .db "PITCH    ",$FF

textptr_lfor:
  .dw text_lfon
  .dw text_lforc
  .dw text_lforr
  .dw text_lforp

text_l:
  .db "L-",$FF
text_r:
  .db "-R",$FF
text_lr:
  .db "LR",$FF
  
text_stop:
  .db "ST",$FF
  
textptr_lr:
  .dw text_l
  .dw text_r
  .dw text_lr

text_piano:
  .db "PRL",$FF


text_xy:
  .db "X/Y",$FE
  .db "      CUTOFF",$FE,$FE,$FE,$FE
  .db "R",$FE,"E",$FE,"S",$FE,"O",$FE,"N",$FE,"A",$FE,"N",$FE,"C",$FE,"E",$FF

text_live:
  .db "LIV",$FE,$FE
  .db "   P1    P2    P3",$FE,$FE,$FE
  .db " CUTF  CUTF  CUTF",$FE
  .db " RESO  RESO  RESO",$FE
  .db " PITC  PITC  PITC",$FE
  .db " SLID  SLID  SLID",$FE
  .db " LFOS  LFOS  LFOS",$FE
  .db " LFOA  LFOA  LFOA",$FE,$FE
  .db " DIST:     OSC:",$FE,$FE
  .db "           "
  .db T_LFOSHAPES+4+TXT_NORMAL,T_LFOSHAPES+5+TXT_NORMAL
  .db T_LFOSHAPES+2+TXT_NORMAL,T_LFOSHAPES+3+TXT_NORMAL
  .db $FE
  .db "           "
  .db T_LFOSHAPES+10+TXT_NORMAL,T_LFOSHAPES+11+TXT_NORMAL
  .db T_LFOSHAPES+8+TXT_NORMAL,T_LFOSHAPES+9+TXT_NORMAL
  .db $FF

text_loadsave:
  .db "MEM",$FE,$FE
  .db "CURRENT",$FE
  .db " SONG:",$FE
  .db " PATT:",$FE,$FE
  .db $FE
  .db " SAVE PATTERN",$FE
  .db " LOAD PATTERN",$FE,$FE
  .db $FE
  .db " SAVE SONG",$FE
  .db " LOAD SONG",$FE,$FE
  .db "DUMP",$FE
  .db "FORMAT",$FE
  .db "CREDITS",$FF

text_seq:
  .db "TRK",$FF
text_seqhelp:
  .db "  N  A S O RR DRUMS ",$FF

text_table:
  .db "SNG",$FF
text_eos:
  .db "()",$FF

text_free:
  .db "FREE SLOT",$FF
text_used:
  .db "USED SLOT",$FF

text_nosaves:
  .db "     EEPROM ERROR",$FE,$FE,$FE
  .db "SAVING AND LOADING",$FE
  .db "     DISABLED",$FF

text_nopots:
  .db "    HW ERROR",$FE,$FE,$FE
  .db "POT CONTROLS",$FE
  .db "  DISABLED",$FF

text_credits:
  ;  0123456789ABCDEF0123
  .db "CODE, GFX AND",$FE
  .db "HARDWARE:",$FE
  .db "         FURRTEK",$FE,$FE
  .db "THANKS:",$FE
  .db "MRMEGAHERTZ 2080",$FE
  .db "2XAA  JANKENPOPP",$FE
  .db "ULTRASYD CYBERIC",$FE
  .db "DJPIE SABREPULSE",$FE
  .db "NITRO2K01   KEFF",$FE
  .db "CHIPMUSIC FORUMS",$FE,$FE
  .db "SW V1,0  WT V1,0",$FF

text_clearname:
.db "        ",$FF

text_noteempty:
.db "---",$FF

text_notecorrupt:
.db "???",$FF

note_names:
.db "C-2",$FF
.db "C#2",$FF
.db "D-2",$FF
.db "D#2",$FF
.db "E-2",$FF
.db "F-2",$FF
.db "F#2",$FF
.db "G-2",$FF
.db "G#2",$FF
.db "A-2",$FF
.db "A#2",$FF
.db "B-2",$FF

.db "C-3",$FF
.db "C#3",$FF
.db "D-3",$FF
.db "D#3",$FF
.db "E-3",$FF
.db "F-3",$FF
.db "F#3",$FF
.db "G-3",$FF
.db "G#3",$FF
.db "A-3",$FF
.db "A#3",$FF
.db "B-3",$FF

.db "C-4",$FF
.db "C#4",$FF
.db "D-4",$FF
.db "D#4",$FF
.db "E-4",$FF
.db "F-4",$FF
.db "F#4",$FF
.db "G-4",$FF
.db "G#4",$FF
.db "A-4",$FF
.db "A#4",$FF
.db "B-4",$FF

.db "OFF",$FF

