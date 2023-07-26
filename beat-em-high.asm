
	include "definitions.asm"
	include "zeropage.asm"


	seg HEADER
MAPPER EQM 2
	org $7ff0
        ;NES\n header demarcation
        byte $4e,$45,$53,$1a
        ;NES_PRG_BANKS
	byte 4
        ;NES_CHR_BANKS
	byte 0 
        ;NES_MIRRORING|(.NES_MAPPER<<4)
	byte NES_MIRR_VERT | (MAPPER << 4) 
        ;.NES_MAPPER&$f0
	byte MAPPER & $f0 
        ; reserved, set to zero
	byte 0,0,0,0,0,0,0,0 
        
        
	seg CODE_BANK0
	org $8000
        rorg $8000
graphics_addr:	
	incbin "tiles.chr"		; 4k
sprites_addr:			
	incbin "binny ponda.chr"	; 4k
	seg CODE_BANK1
        org $c000
        rorg $8000
	seg CODE_BANK2
        org $10000
        rorg $8000
	seg CODE_BANK3
        org $14000
        rorg $c000
        
        
	include "vectors.asm"
	nop
	include "state.asm"
	nop
	include "state_level.asm"
	nop
	include "state_level_hud.asm"
	nop
        include "nesppu.dasm"
        nop
	include "sprites.asm"
	nop
        
        
	seg VECTORS
	org $17ffa	
        rorg $fffa ; start at address $fffa
       	.word nmi_handler	; $fffa vblank nmi
	.word cart_start	; $fffc reset
	.word nmi_handler	; $fffe irq / brk
        
        

