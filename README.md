beat-em-high
=====

[Open this project in 8bitworkshop](http://8bitworkshop.com/redir.html?platform=nes&githubURL=https%3A%2F%2Fgithub.com%2Flangel%2Fbeat-em-high&file=beat-em-high.asm).


basic UNROM layout (4 banks of 16kb):

BANK0 [~80% full]
- level data
-- level maps are 128x24 tiles = 3072 bytes
-- level colors are 64x12 attributes = 768 bytes
-- level data size = 3840 bytes (256 bytes shy of 4k)
--- fit level palettes and object/enemy spawn data in 256 bytes?
- 3 full sized levels = 11520 bytes
- 1 screen level = 758 tiles + 192 attrs = 950 bytes 
- 3 level + 1 room = 12,470 bytes (or 13kb w/ round up)

BANK1 [full]
- 4 4kb pattern tables worth of grafx

BANK2 [50%+ full]
- 2(?) more pattern tables worth of grafx
- song and sfx data

BANK3 (fixed)
- startup sequence
- state handler
- 2k(?) of DPCM data

stuff that needs a home:
- audio play routine
- game engine
- title screen
- options screen(?)
