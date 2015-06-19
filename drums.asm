;(only 30 as code 0 is used for no drums)
;10 11 12 13 14(and 7) 20 21 22
lut_drumsounds:
.db 0,0,0,0,0,$C0,$51,$21	;Closed hihat
.db 0,0,0,0,0,$F7,$51,$4A	;Mini hard hat
.db 0,0,0,0,0,$C0,$53,$21	;Open hihat
.db 0,0,0,0,0,$C0,$49,$21 ;Reverse hat
.db 0,0,0,0,0,$C0,$19,$51 ;ScratchH
.db 0,0,0,0,0,$C0,$19,$61 ;ScratchM
.db 0,0,0,0,0,$C0,$19,$81 ;ScratchL
.db 0,0,0,0,0,$C0,$51,$42 ;Snare1
.db 0,0,0,0,0,$C0,$51,$44 ;Snare2
.db 0,0,0,0,0,$C0,$51,$4C ;Vib1
.db 0,0,0,0,0,$C0,$51,$3B ;Vib2
.db 0,0,0,0,0,$C0,$09,$5A ;Vib3
.db 0,0,0,0,0,$C0,$09,$4B ;Vib4
.db $9C,$7F,$C1,$D8,$07,0,0,0	;Kick1
.db $AA,$BF,$C1,$D8,$06,0,0,0	;Kick2
.db $9C,$7F,$C1,$D8,$07,$C0,$51,$21	;Closed hihat
.db $9C,$7F,$C1,$D8,$07,$F7,$51,$4A	;Mini hard hat
.db $9C,$7F,$C1,$D8,$07,$C0,$53,$21	;Open hihat
.db $9C,$7F,$C1,$D8,$07,$C0,$49,$21 ;Reverse hat
.db $9C,$7F,$C1,$D8,$07,$C0,$19,$51 ;ScratchH
.db $9C,$7F,$C1,$D8,$07,$C0,$19,$61 ;ScratchM
.db $9C,$7F,$C1,$D8,$07,$C0,$19,$81 ;ScratchL
.db $AA,$BF,$C1,$D8,$06,$C0,$51,$42 ;Snare1
.db $AA,$BF,$C1,$D8,$06,$C0,$51,$44 ;Snare2
.db $AA,$BF,$C1,$D8,$06,$C0,$51,$4C ;Vib1
.db $AA,$BF,$C1,$D8,$06,$C0,$51,$3B ;Vib2
.db $AA,$BF,$C1,$D8,$06,$C0,$09,$5A ;Vib3
.db $AA,$BF,$C1,$D8,$06,$C0,$09,$4B ;Vib4
.db $AA,$BF,$C1,$D8,$06,$C0,$1B,$42
.db $9C,$7F,$C1,$D8,$C0,$1B,$3B

text_drums:
.db "-OFF-",$FF
.db "-----",$FF
.db "CLSHH",$FF
.db "HRDHH",$FF
.db "OPNHH",$FF
.db "REVHH",$FF
.db "SCRTH",$FF
.db "SCRTM",$FF
.db "SCRTL",$FF
.db "SNAR1",$FF
.db "SNAR2",$FF
.db "VIBR1",$FF
.db "VIBR2",$FF
.db "VIBR3",$FF
.db "VIBR4",$FF
.db "KICK1",$FF
.db "KICK2",$FF
.db "HARD1",$FF
.db "HARD2",$FF
.db "HARD3",$FF
.db "SWEE1",$FF
.db "SWEE2",$FF
.db "SWEE3",$FF
.db "SWEE4",$FF
.db "DRUM1",$FF
.db "DRUM2",$FF
.db "DRUM3",$FF
.db "SLAP1",$FF
.db "KVIB1",$FF
.db "KVIB2",$FF
.db "KVIB3",$FF
.db "KVIB4",$FF
