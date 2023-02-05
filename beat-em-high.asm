
	include "nesdefs.dasm"
	include "zeropage.asm"


;;;;; NES CARTRIDGE HEADER

	NES_HEADER 0,2,1,NES_MIRR_HORIZ ; mapper 0, 2 PRGs, 1 CHR

;;;;; START OF CODE

cart_start: subroutine
	NES_INIT	; set up stack pointer, turn off PPU
        jsr WaitSync	; wait for VSYNC
        jsr ClearRAM	; clear RAM
        jsr WaitSync	; wait for VSYNC (and PPU warmup)

; reset PPU address and scroll registers
        lda #0
        sta PPU_ADDR
        sta PPU_ADDR	; PPU addr = $0000
        sta PPU_SCROLL
        sta PPU_SCROLL  ; PPU scroll = $0000
	jsr SetPalette	; set palette colors
; activate PPU graphics
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
	lda $00
        sta $00
	SAVE_REGS

        ; Distressed Alien
	PPU_SETADDR #$2086
cut_scene_alien_main_draw: subroutine
        lda #$00
        sta temp00 ; pattern tile counter
        ldx #$2f
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
        lda #tile_empty
.alien_row_filler_loop
	sta PPU_DATA
	dey
        bpl .alien_row_filler_loop
	dex
        bpl .alien_tile_loop
	lda $00
        sta $00
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
        
        
;;;;; GRAPHX
	org $010000
	incbin "Winter_Chip_V.chr"

