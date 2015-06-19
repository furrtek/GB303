;Max	default

gparams:
  .dw SYNCMODE
  .db 4,0
  .dw LASTSAVED_SONG
  .db 16,0
  .dw LASTSAVED_PATT
  .db 99,0
  .dw 0			;EOL

pparams:
  .dw POTPATTOVRD
  .db 255,0
  .dw LFORESET
  .db 1,0
  .dw POTLINK1
  .db 5,0
  .dw POTLINK2
  .db 5,3
  .dw POTLINK3
  .db 5,1
  .dw 0			;EOL

sngparams:
  .dw BPM
  .db 255,6
  .dw POTLINK1
  .db 5,0
  .dw POTLINK2
  .db 5,3
  .dw POTLINK3
  .db 5,1
  .dw LFOSPEED
  .db 255,20
  .dw LFOAMP
  .db 31,15
  .dw DISTTYPE
  .db 2,0
  .dw OSCTYPE
  .db 2,0
  .dw SYNTHLR
  .db 2,0
  .dw DRUMSLR
  .db 2,0
  .dw 0			;EOL
