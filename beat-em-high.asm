
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
	include "map_data.asm"
        nop
title_logo_map:
        incbin "title logo.map"
        nop
        
	seg CODE_BANK1
        org $c000
        rorg $8000
tiles_addr:	
	incbin "street.chr"	; 4k
sprites_addr:			
	incbin "sprites.chr"	; 4k
title_logo_chr:
        incbin "title logo.chr" ; 2k
char_tiles:
	incbin "char tiles.chr"	; 2k
boss_krok_chr:
	incbin "boss_krok.chr"	; 256 bytes
        nop
        
	seg CODE_BANK2
        org $10000
        rorg $8000
	include "ftm_engine.asm"
	nop
	include "ftm_data.asm"
	nop
        
	seg CODE_BANK3
        org $14000
        rorg $c000
        
        
	include "dpcm.asm"
	nop
	include "vectors.asm"
	nop
	include "common.asm"
	nop
	include "sprites.asm"
	nop
	include "arctang.asm"
	nop
	include "state.asm"
        nop
	include "state_demo.asm"
	nop
	include "state_title.asm"
	nop
	include "state_intro.asm"
	nop
	include "state_level.asm"
        nop
	include "state_level_cam.asm"
	nop
	include "state_level_hud.asm"
        nop
	include "state_level_plot.asm"
        nop
	include "state_outro.asm"
	nop
	include "ents_system.asm"
	nop
	include "ent_pando.asm"
	nop
	include "ent_binny.asm"
	nop
	include "ent_krok.asm"
        nop
	include "ent_krok_victim.asm"
        nop
	include "ent_boss_krok.asm"
	nop
	include "ent_title_player.asm"
	nop
	include "ent_title_krok_elipse.asm"
 	nop
	include "ent_title_krok_wave.asm"



        
	seg VECTORS
	org $17ffa	
        rorg $fffa ; start at address $fffa
       	.word nmi_handler	; $fffa vblank nmi
	.word cart_start	; $fffc reset
	.word nmi_handler	; $fffe irq / brk
        
        

