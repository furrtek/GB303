setscreen_credits:
  call   stopp			;Just in case
  call	 screen_off
  call   clearbkg
  call   clearsprites

  ld     a,$9B			;Logo
  ld     hl,$9800+(32*1)+6
  ld     bc,$0802
  call   mapinc

  ld     de,text_credits
  ld     hl,$9800+(32*4)+2
  ld     b,TXT_NORMAL
  call   maptext

  ld     hl,hblank+1
  ld     a,<hblank_copperline
  ldi    (hl),a
  ld     a,>hblank_copperline
  ld     (hl),a

  ld     hl,vbl_credits
  call   setvblhandler
  
  xor    a
  ld     (COPPERFLIP),a

  ld     a,%00011011            ;Palette BG
  ldh    ($47),a
  ld     a,%11100100            ;Palette SPR0
  ldh    ($48),a

  ld     a,%00000111		;Vblank + STAT + timer
  ldh    ($FF),a
  ld     a,%00001000		;Hblank causes STAT interrupt
  ldh    ($41),a

  ld     a,%11010011		;Screen on
  ldh    ($40),a
  ret
