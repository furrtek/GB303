.DEFINE T_ALPHA		0
.DEFINE T_ALPHAI	64

.DEFINE T_GRIDNOTE 	128
.DEFINE T_NOTE 		128+1
.DEFINE T_NOTEUP	128+1+1
.DEFINE T_NOTEDN	128+1+1+1
.DEFINE T_NOTEOFF	128+1+1+1+1
.DEFINE T_WINGRAD	128+1+1+1+1+1
.DEFINE T_CURSEQ	128+1+1+1+1+1+1
.DEFINE T_CURNOTE	128+1+1+1+1+1+1+1
.DEFINE T_GRID          128+1+1+1+1+1+1+1+1
.DEFINE T_GRIDCUR       128+1+1+1+1+1+1+1+1+1
.DEFINE T_CURSEQ2	128+1+1+1+1+1+1+1+1+1+1
.DEFINE T_ERROR         128+1+1+1+1+1+1+1+1+1+1+1
.DEFINE T_SCREENMAP	128+1+1+1+1+1+1+1+1+1+1+1+9
.DEFINE T_LOGO		128+1+1+1+1+1+1+1+1+1+1+1+9+7
.DEFINE T_KEYB		128+1+1+1+1+1+1+1+1+1+1+1+9+7+16
.DEFINE T_BIGNUMS       128+1+1+1+1+1+1+1+1+1+1+1+9+7+16+8
.DEFINE T_LFOSHAPES     128+1+1+1+1+1+1+1+1+1+1+1+9+7+16+8+20
.DEFINE T_DISTS         128+1+1+1+1+1+1+1+1+1+1+1+9+7+16+8+20+12
.DEFINE T_POT           128+1+1+1+1+1+1+1+1+1+1+1+9+7+16+8+20+12+12

inittiles:
  ld     hl,tiles_alpha
  ld     de,$8000+(T_ALPHA*16)
  call   loadtiles_2BPPc
  ld     hl,tiles_alpha
  ld     de,$8000+(T_ALPHAI*16)
  call   loadtiles_2BPPcr

  ld     hl,tiles_gridnote
  ld     de,$8000+(T_GRIDNOTE*16)
  call   loadtiles_auto
  ld     hl,tiles_note
  ld     de,$8000+(T_NOTE*16)
  call   loadtiles_auto
  ld     hl,tiles_noteup
  ld     de,$8000+(T_NOTEUP*16)
  call   loadtiles_auto
  ld     hl,tiles_notedn
  ld     de,$8000+(T_NOTEDN*16)
  call   loadtiles_auto
  ld     hl,tiles_noteoff
  ld     de,$8000+(T_NOTEOFF*16)
  call   loadtiles_auto
  ld     hl,tile_wingrad
  ld     de,$8000+(T_WINGRAD*16)
  call   loadtiles_auto
  ld     hl,tiles_curseq
  ld     de,$8000+(T_CURSEQ*16)
  call   loadtiles_auto
  ld     hl,tiles_curnote
  ld     de,$8000+(T_CURNOTE*16)
  call   loadtiles_auto
  ld     hl,tiles_grid
  ld     de,$8000+(T_GRID*16)
  call   loadtiles_auto
  ld     hl,tiles_gridcur
  ld     de,$8000+(T_GRIDCUR*16)
  call   loadtiles_auto
  ld     hl,tiles_curseq2
  ld     de,$8000+(T_CURSEQ2*16)
  call   loadtiles_auto
  ld     hl,tiles_error
  ld     de,$8000+(T_ERROR*16)
  call   loadtiles_auto
  ld     hl,tiles_screenmap
  ld     de,$8000+(T_SCREENMAP*16)
  call   loadtiles_auto
  ld     hl,tiles_logo
  ld     de,$8000+(T_LOGO*16)
  call   loadtiles_auto
  ld     hl,tiles_keyb
  ld     de,$8000+(T_KEYB*16)
  call   loadtiles_auto

  ld     hl,tiles_bignums
  ld     de,$8000+(T_BIGNUMS*16)
  call   loadtiles_auto
  
  ld     hl,tiles_lfoshapes
  ld     de,$8000+(T_LFOSHAPES*16)
  call   loadtiles_auto
  
  ld     hl,tiles_dists
  ld     de,$8000+(T_DISTS*16)
  call   loadtiles_auto

  ld     hl,tiles_pot
  ld     de,$8000+(T_POT*16)
  call   loadtiles_auto
  ret
