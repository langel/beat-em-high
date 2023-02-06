
	include "nesdefs.dasm"
	include "zeropage.asm"


;;;;; NES CARTRIDGE HEADER
	; mapper 0, 4 PRGs, 0 CHR
	;NES_HEADER 0,4,0,NES_MIRR_HORIZ 
MAPPER EQM 2
        
	seg Header
	org $7ff0
        ;NES\n header demarcation
        byte $4e,$45,$53,$1a
        ;NES_PRG_BANKS
	byte 2 
        ;NES_CHR_BANKS
	byte 0 
        ;NES_MIRRORING|(.NES_MAPPER<<4)
	byte NES_MIRR_HORIZ | (MAPPER<<4) 
        ;.NES_MAPPER&$f0
	byte MAPPER & $f0 
        ; reserved, set to zero
	byte 0,0,0,0,0,0,0,0 
        
	seg Code
	org $8000
        
;;;;; GRAPHX
graphics_addr:
	incbin "Winter_Chip_V.chr"

;;;;; START OF CODE
	org $c000

cart_start: subroutine
	NES_INIT	; set up stack pointer, turn off PPU
        jsr WaitSync	; wait for VSYNC
        jsr ClearRAM	; clear RAM

; reset PPU address and scroll registers
        lda #0
        sta PPU_SCROLL
        sta PPU_SCROLL  ; PPU scroll = $0000
	jsr SetPalette	; set palette colors
        
; graphx to chr ram
	lda #<graphics_addr
        sta temp00
        lda #>graphics_addr
        sta temp01
        lda #$00
        sta PPU_ADDR
        sta PPU_ADDR
        ldx #$20
        ldy #$00
.grafx_load_loop
	lda (temp00),y
        sta PPU_DATA
        iny
        bne .grafx_load_loop
        inc temp01
	dex
        bne .grafx_load_loop
        
; graphx on nametable
        lda #$50
        sta tile_empty
	PPU_SETADDR #$2086
cut_scene_alien_main_draw: subroutine
        lda #$00
        sta temp00 ; pattern tile counter
        ldx #$0f
.alien_tile_loop
	ldy #$f
.alien_tile_row_loop
	lda temp00
	sta PPU_DATA
        inc temp00
	dey
        bpl .alien_tile_row_loop
        ; setup empty tile fill
        ldy #$0f
        lda tile_empty
.alien_row_filler_loop
	sta PPU_DATA
	dey
        bpl .alien_row_filler_loop
	dex
        bpl .alien_tile_loop
        
        
; activate PPU graphics
        jsr WaitSync	; wait for VSYNC (and PPU warmup)
        lda #MASK_BG
        sta PPU_MASK 	; enable rendering
        lda #CTRL_NMI|#CTRL_BG_1000
        sta PPU_CTRL	; enable NMI
        
        
.endless
	jmp .endless	; endless loop


; set palette colors
SetPalette: subroutine
; set PPU address to palette start
	PPU_SETADDR $3f00
        ldy #0
.loop:
	lda Palette,y	; lookup byte in ROM
	sta PPU_DATA	; store byte to PPU data
        iny		; Y = Y + 1
        cpy #32		; is Y equal to 32?
	bne .loop	; not yet, loop
        rts		; return to caller
        
;;;;; CONSTANT DATA

Palette:
	hex 1f		;screen color
	hex 01112100	;background 0
        hex 02122200	;background 1
        hex 02112100	;background 2
        hex 01122200	;background 3
        hex 19293900	;sprite 0
        hex 1a2a3a00	;sprite 1
        hex 1b2b3b00	;sprite 2
        hex 1c2c3c	;sprite 3

;;;;; INTERRUPT HANDLERS

nmi_handler: subroutine
	SAVE_REGS
        
        lda #0
        sta PPU_SCROLL
        sta PPU_SCROLL  ; PPU scroll = $0000

	RESTORE_REGS
	rti
        
;;;;; COMMON SUBROUTINES

	include "nesppu.dasm"
        

;;;;; CPU VECTORS

	seg Vectors
	org $fffa		; start at address $fffa
       	.word nmi_handler	; $fffa vblank nmi
	.word cart_start	; $fffc reset
	.word nmi_handler	; $fffe irq / brk
        
        

