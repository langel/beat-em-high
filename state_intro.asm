
state_intro_palettes:
	hex 0f3d2d30 
        hex 0f3d2c20  
        ; binny
        hex 0f072437
        ; pando
        hex 0f0c2130
        

state_intro_init: subroutine

        lda #state_intro_update_id
        sta state_update_id
        lda #state_intro_render_id
        sta state_render_id
        lda #$00
        sta state_sprite_0
        jsr render_disable
        
        lda #$20
        ldx #text_space_pattern_id
        jsr clear_nametable
        lda #$24
        ldx #text_space_pattern_id
        jsr clear_nametable
        lda #$23
        ldx #$00
        jsr clear_attributes
        lda #$27
        ldx #$00
        jsr clear_attributes

; palette loader
	PPU_SETADDR $3f00
        ldy #0
.palette_loop
	lda state_intro_palettes,y
	sta PPU_DATA
        iny		
        cpy #16		
	bne .palette_loop
        
; graphx to chr ram
        ; title logo
	BANK_CHANGE 1
	lda #<char_tiles
        sta temp00
        lda #>char_tiles
        sta temp01
        lda #$00
        sta PPU_ADDR
        sta PPU_ADDR
        ldx #$10
        ldy #$00
.grafx_load_loop
	lda (temp00),y
        sta PPU_DATA
        iny
        bne .grafx_load_loop
        inc temp01
	dex
        bne .grafx_load_loop
        
        ; character set
	lda #<tiles_addr
        sta temp00
        lda #>tiles_addr+$0d
        sta temp01
        lda #$0d
        sta PPU_ADDR
        lda #$00
        sta PPU_ADDR
        ldx #$03
        ldy #$00
.char_load_loop
	lda (temp00),y
        sta PPU_DATA
        iny
        bne .char_load_loop
        inc temp01
	dex
        bne .char_load_loop

; plot characters and text
	;PANDO
        PPU_SETADDR $2183
        lda #$02
        sta PPU_DATA
        lda #$03
        sta PPU_DATA
        PPU_SETADDR $21a3
        lda #$12
        sta PPU_DATA
        lda #$13
        sta PPU_DATA
        PPU_SETADDR $21c3
        lda #$22
        sta PPU_DATA
        lda #$23
        sta PPU_DATA
        PPU_SETADDR $23d8
        lda #$ff
        sta PPU_DATA
        sta PPU_DATA
        PPU_PLOT_TEXT $2148,text_002 
        PPU_PLOT_TEXT $2188,text_003
        PPU_PLOT_TEXT $21c8,text_004
        ;BINNY
        PPU_SETADDR $2599
        lda #$00
        sta PPU_DATA
        lda #$01
        sta PPU_DATA
        PPU_SETADDR $25b9
        lda #$10
        sta PPU_DATA
        lda #$11
        sta PPU_DATA
        PPU_SETADDR $25d9
        lda #$20
        sta PPU_DATA
        lda #$21
        sta PPU_DATA
        PPU_SETADDR $27de
        lda #%10101010
        sta PPU_DATA
        sta PPU_DATA
        PPU_PLOT_TEXT $2549,text_005 
        PPU_PLOT_TEXT $2588,text_006
        PPU_PLOT_TEXT $25c5,text_007
        jsr render_enable
        lda #$01
        sta scroll_ms
	rts


state_intro_render: subroutine
	jmp state_render_done
        
        
state_intro_update: subroutine
	rts