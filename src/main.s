;GB303 v1.0
;Furrtek 2015

;Square:
;  Accent 0~1
;    Resonnance 0~15
;      Cutoff 0~95
;Saw:
;  Accent 0~1
;    Resonnance 0~15
;      Cutoff 0~95

;Each sample bin is 1536 bytes organized as 96 period recordings of 16bytes (32 4-bit samples)
;Each sample bin is one note played. Start to end gives the cutoff envelope
;For both of the two waveforms (square and triangle) there are 16 resonnance values
;For each of the resonnance values, there is the accent on and accent off
;Making: 2*2*16*96*16=98304=96kB

;25128 = 16KB

; The following infos might not be up to date ! Please check source or wait for documents

;00~FF: General parameters
;       00~07: "LYSERGIC" magic bytes DO NOT WRITE TO EXCEPT DURING FORMAT

;       40: Last sync mode
;       41: Last saved song
;       42: Last save pattern
;       ...
;       FF: Checksum of 40~7E

;Pattern zone format:
;  00: 0=Free 1=Used
;  01~0F: Name
;  10~3E: Various pattern params
;    10: Nonzero = Override default pot assignments with following:
;    11: Pot assign 1
;    12: Pot assign 2
;    13: Pot assign 3
;  3F!!!: Checksum of 40~7E

;  40~7F: Sequence (16*3 actuellement, mais place pour 4*16=64 bytes)
;  7F!!!: Checksum of 40~7E
;Sequence:
;ABCD ABCD... *16 steps = 64 bytes
;A=Note|$80 note-on flag
;B=DDDDDOSA Drums(0~F)
;C=RRRRrrrr R=Arpeggio MSB / r=Arpeggio LSB
;D=Free except last byte of pattern (checksum)...
;Getnotenumber:A
;Getnoteattrl:B
;Getnoteattrh:C
;D: Free

;Makes 100 (0~99) patterns max = $3200+100=$3300 is start of pattern tables

;Pattern tables zone format:
;  20 songs of 160: 3 blocks of 64 per song: -> 3FC0
;  00: 0=Free 1=Used
;  01~0A: Name
;       0B: Default pot assign 1	Block 1 FALSE: SEE SONGSAVE.ASM !!!!
;       0C: Default pot assign 2
;       0D: Default pot assign 3
;       0E: Default LFO speed
;	0F: Default LFO intensity
;	10: Default Distortion type
;	11: Default Osc type
;	12: SynthLR
;	13: DrumsLR
;       17: Pattern numbers...
;  	3F!!!: Checksum of 40~7E
;       00: Pattern numbers...		Block 2
;  	3F!!!: Checksum of 40~7E
;       00: Pattern numbers...		Block 3
;  	3F!!!: Checksum of 40~7E

;REMEMBER: Only the first 16 sprites are copied to OAM in RAM2OAM (can't use DMA because of timer)
;REMEMBER: After a write, write is locked again, issue WREN ! Also, 64 bytes page write is cool :)
;REMEMBER: Never bankswitch during play !

;------------------------------------------------------------------------------

;AUTOLOAD DOES NOT WORK :( NEEDS TO WORK
;After song load, load first pattern of song !

;OK-: Update pattern name in screens during song play
;OK-: Update live screen pot assign during play of pattern which overrides
;OK-: Song play (get patt #, stop on FF)
;OK-: Autoload last song and pattern
;OK-: After save/load, update MEM screen (current, selectors)
;TODO: Reverse pot mode (for GBA SP, press start on startup)

;TODO: Dump saves to link port !
;Sysex dump: data...

;TODO FUTURE ?:
;MIDI CC 74: Cutoff
;MIDI CC 71: Resonance
;MIDI CC 5: Slide rate
;1011nnnn	0ccccccc 0vvvvvvv

;TODO: MIDI Slide or accent activate with velocity ? MANUAL
;VEL: 0 ~ 63: accent
;     64~ 95: slide
;     96~127: accent+slide

;TODO: Konami code etch-a-sketch

  .DEFINE TXT_NORMAL 	32
  .DEFINE TXT_INVERT 	(-32)

  .DEFINE MAX_PATTERNS  	100
  .DEFINE MAX_SONGS		17
  .DEFINE KEY_REPEAT_MASK 	7

  .DEFINE SYNC_NONE 	0
  .DEFINE SYNC_LSDJS	1
  .DEFINE SYNC_LSDJMIDI	2
  .DEFINE SYNC_NANO	3
  .DEFINE SYNC_MIDI	4

  .INCLUDE "directives.inc"

.BANK 0 SLOT 0

  .INCLUDE "common/ram.asm"

.ORG $0000                      ;A=(HL+A) LUT
  add    l
  jr     nc,+
  inc    h
+:
  ld     l,a
  ld     a,(hl)
  ret

.org $0010                      ;(HL)=DE
  ld     (hl),d
  inc    hl
  ld     (hl),e
  ret

.ORG $0040
  jp     vblank

.ORG $0048
  jp     hblank

.ORG $0050
  jp     timer

.ORG $0058
  jp     serial

.ORG $0100
nop
jp       start                   ;Entry point

.ORG $0104
;Nintendo logo
.db $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C
.db $00,$0D,$00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6
.db $DD,$DD,$D9,$99,$BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC
.db $99,$9F,$BB,$B9,$33,$3E

.org $014A
.db 1				;Non-Japanese

.org $0152
  .db 1				;Code version
  .db 1                         ;Wave version

start:
  di

  ld     sp,$FFF4               ;SP in HRAM

  xor    a
  ldh    ($26),a                ;Sound off

  ld     hl,$C000		;Clear RAM
  ld     bc,$1FFE
  call   clear

  call   readinput
  ld     a,(JOYP_CURRENT)
  bit    3,a
  jr     z,+
  ld     a,1
  ld     (INVERTPOTS),a
+:

  ld     a,$C3
  ld     (hblank),a
  ld     hl,hblank+1
  ld     a,<int_play
  ldi    (hl),a
  ld     a,>int_play
  ld     (hl),a

  ld     a,1
  ld     ($2000),a		;MBC1 bank 1

  ld     a,$80
  ldh    ($26),a		;Sound on

  xor    a
  ldh    ($1A),a		;CH3 off
  ld     a,$80
  ldh    ($1B),a
  ld     a,%00100000
  ldh    ($1C),a		;CH3 max volume

  ld     a,$77
  ldh    ($24),a
  ld     a,$CC
  ldh    ($25),a		;CH3 & CH4 mixing only

  call   wait_vbl
  call	 screen_off
  call   clearbkg
  call   clearsprites

  ld     a,7			;Bank 7
  ld     ($2000),a

  ld     a,$FF			;Security
  ld     (TEMPNAME),a
  ld     (PATTNAME+8),a
  ld     (SONGNAME+8),a
  ld     (SELPATTNAME+8),a
  ld     (SELSONGNAME+8),a

  call   inittiles

  call   setdefaultpal

  ;Copy example sequence in case EE is fuxxored
  ld     hl,defaultseq
  ld     de,SEQ
  ld     b,16*4
-:
  ldi    a,(hl)
  ld     (de),a
  inc    de
  dec    b
  jr     nz,-

  ld     a,130			;Default BPM
  ld     (BPM),a
  xor    a
  ld     (OSCTYPE),a
  ld     (BEND),a
  ld     (MIDIBPUT),a
  ld     (MIDIBGET),a
  ld     a,1
  ld     (DRUMSMUTE),a
  ld     a,8
  ld     (RESON),a
  ld     a,$20
  ld     (CUTOFFSET),a
  ld     a,$18
  ld     (SLIDESPEED),a

  call   eebootcheck
  call   adcbootcheck

  ;Error messages if needed:
  ld     a,(HWOK_EE)
  or     a
  jr     nz,+
  ld     de,text_nosaves
  ld     hl,$9800+(32*3)+1
  ld     b,TXT_NORMAL
  call   maptext
  ld     a,T_ERROR
  ld     hl,$9800+(32*2)+2
  ld     bc,$0303
  call   mapinc
+:
  ld     a,(HWOK_ADC)
  or     a
  jr     nz,+
  ld     de,text_nopots
  ld     hl,$9800+(32*10)+4
  ld     b,TXT_NORMAL
  call   maptext
  ld     a,T_ERROR
  ld     hl,$9800+(32*9)+4
  ld     bc,$0303
  call   mapinc
+:
  ld     a,(HWOK_ADC)
  ld     b,a
  ld     a,(HWOK_EE)
  and    b
  jr     nz,+
  ld     a,%11010011		;Screen on
  ldh    ($40),a
-:
  call   wait_vbl
  call   readinput
  ld     a,(JOYP_ACTIVE)	;Wait for button press
  or     a
  jr     z,-
+:

  ld     a,38
  ldh    ($45),a		;LYC kickstart

  ld     a,%00000100		;Timer start 4096Hz for BPM
  ldh    ($07),a

  call   setbpm

  ei

  ld     a,2
  ld     (CURSCREEN),a
  ld     (SCREENMID),a
  call   setscreen

ml:
  ;Handle serial receive
  ld      a,(SYNCMODE)
  cp      SYNC_LSDJMIDI
  jr      z,+
  cp      SYNC_NANO
  jr      z,++
  ld      a,$80         ;Slave
  ldh     ($02),a
  jr      ++
+:
  ld      a,$81		;Master
  ldh     ($02),a
++:

  ld     a,(MIDIBPUT)
  ld     b,a
  ld     a,(MIDIBGET)
  cp     b
  call   nz,serialhnd

  ld     a,(VBL)
  or     a
  jr     z,ml
  xor    a
  ld     (VBL),a		;Wait for vblank

  ld     hl,VBL_HANDLER
  ldi    a,(hl)
  ld     h,(hl)
  ld     l,a
  call   dojump

  jp     ml

dojump:
  jp     hl


playstop:
  ld     a,(JOYP_ACTIVE)	;Start
  bit    3,a
  ret    z
  ld     a,(SYNCMODE)
  or     a
  cp     SYNC_NONE
  jr     z,+
  cp     SYNC_NANO
  jr     z,+
  jr     stopp
+:
  ld     a,(JOYP_CURRENT)	;+Select ?
  bit    2,a
  jr     z,++
  ld     a,(PLAYING)
  or     a
  jr     nz,stopp
  ld     a,(CURPATTERN)
  ld     (SAVECURPATTSLOT),a
  call   savepattern		;Save last edited pattern
  ;If in table screen, play from cursor
  ld     a,(CURSCREEN)
  cp     1
  ld     a,0			;Or else, play from beginning
  jr     nz,+++
  ld     a,(SONG_CURX)
  swap   a                      ;*16
  and    $F0			;Security
  ld     b,a
  ld     a,(SONG_CURY)
  add    b
  ld     b,a
  ld     a,(SONGOFS)
  add    b
  ld     c,a
  ld     hl,SONG
  rst    0
  cp     $FF
  ret    z
  push   bc
  ld     (SAVECURPATTSLOT),a
  call   loadpattern
  pop    bc
  ld     a,c
+++:
  ld     (SONGPTR),a
  ld     a,2			;Play song
  ld     (PLAYING),a
  jr     pscommon
++:
  ld     a,(PLAYING)
  or     a
  jr     nz,stopp
  ld     a,1			;Play pattern only
  ld     (PLAYING),a
pscommon:
  ld     a,$80
  ldh    ($1A),a		;CH3 on, CH1/4 will be turned on during play
  ld     a,-1
  ld     (NOTEIDX),a
  xor    a
  ld     (BPM_CNT),a
  ld     a,1
  ld     (BEAT),a
  ret

stopp:
  xor    a
  ld     (PLAYING),a
  ldh    ($12),a		;CH1 off
  ldh    ($1A),a		;CH3 off
  ldh    ($21),a		;CH4 off
  ret

defaultseq:
  .db $98,0,0,0
  .db $0C,0,0,0
  .db $0C,0,0,0
  .db $0C,0,0,0
  .db $8C,0,0,0
  .db $0C,0,0,0
  .db $0C,0,0,0
  .db $0C,0,0,0
  .db $8C,0,0,0
  .db $0C,0,0,0
  .db $0C,0,0,0
  .db $0C,0,0,0
  .db $8C,0,0,0
  .db $0C,0,0,0
  .db $0C,0,0,0
  .db $0C,0,0,0

cutofflut:
  .INCBIN "tables\cutofflut.bin"

  .INCLUDE "inittiles.asm"
  .INCLUDE "hwio\serial.asm"
  .INCLUDE "common\system.asm"
  .INCLUDE "common\gfxutil.asm"
  .INCLUDE "playback.asm"
  .INCLUDE "play.asm"
  .INCLUDE "draw.asm"
  .INCLUDE "tables\bpm.asm"
  .INCLUDE "hwio\pots.asm"
  .INCLUDE "screen.asm"
  .INCLUDE "hwio\spi.asm"
  .INCLUDE "hwio\eeprom.asm"
  .INCLUDE "setup\ss_piano.asm"
  .INCLUDE "setup\ss_config.asm"
  .INCLUDE "setup\ss_loadsave.asm"
  .INCLUDE "setup\ss_credits.asm"
  .INCLUDE "setup\ss_table.asm"
  .INCLUDE "setup\ss_live.asm"
  .INCLUDE "setup\ss_xy.asm"
  .INCLUDE "setup\ss_seq.asm"
  .INCLUDE "vbl\vbl_credits.asm"
  .INCLUDE "vbl\vbl_loadsave.asm"
  .INCLUDE "vbl\vbl_piano.asm"
  .INCLUDE "vbl\vbl_config.asm"
  .INCLUDE "vbl\vbl_seq.asm"
  .INCLUDE "vbl\vbl_xy.asm"
  .INCLUDE "vbl\vbl_table.asm"
  .INCLUDE "vbl\vbl_live.asm"
  .INCLUDE "input\input_table.asm"
  .INCLUDE "input\input_piano.asm"
  .INCLUDE "input\input_config.asm"
  .INCLUDE "input\input_loadsave.asm"
  .INCLUDE "input\input_live.asm"
  .INCLUDE "input\input_xy.asm"
  .INCLUDE "input\input_seq.asm"
  .INCLUDE "keyboard.asm"
  .INCLUDE "confirm.asm"
  .INCLUDE "arp.asm"
  .INCLUDE "tables\paramlist.asm"
  .INCLUDE "params.asm"
  .INCLUDE "save.asm"
  .INCLUDE "load.asm"
  .INCLUDE "songsave.asm"
  .INCLUDE "songload.asm"
  .INCLUDE "gparams.asm"
  .INCLUDE "hwio\getee.asm"
  .INCLUDE "lfo.asm"
  .INCLUDE "tables\drums.asm"
  .INCLUDE "tables\cosine.asm"			;Used for LFO and credits copperbars
  .INCLUDE "tables\text.asm"
  .INCLUDE "tables\notelut.asm"

map_keyb:
  .INCBIN "gfx\keyb.map"

  .INCLUDE "tables\softdist.asm"
  .INCLUDE "tables\harddist.asm"

;Bankswitched data:
  .INCLUDE "tables\wavetables.asm"
  .INCLUDE "tables\mmap.asm"
