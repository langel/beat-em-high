
state_intro_palettes:
	hex 0f3d2d30 
        hex 0f3d2c20  
        ; binny
        hex 0f072437
        ; pando
        hex 0f0c2130
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
        cpy #24
	bne .palette_loop
        
        lda #$00
        sta state00
        sta state01
        lda #$ef
        sta scroll_y
        
; grafx to chr ram
	BANK_CHANGE 1
	lda #<tiles_addr
        sta temp00
        lda #>tiles_addr
        sta temp01
        lda #$00
        sta PPU_ADDR
        sta PPU_ADDR
        ldx #$20
        ldy #$00
.sprites_load_loop
	lda (temp00),y
        sta PPU_DATA
        iny
        bne .sprites_load_loop
        inc temp01
	dex
        bne .sprites_load_loop
	; binny and pando rows
	lda #<char_tiles
        sta temp00
        lda #>char_tiles
        sta temp01
        lda #$00
        sta PPU_ADDR
        lda #$00
        sta PPU_ADDR
        ldx #$04
        ldy #$00
.grafx_load_loop
	lda (temp00),y
        sta PPU_DATA
        iny
        bne .grafx_load_loop
        inc temp01
	dex
        bne .grafx_load_loop
        
        jsr state_intro_shot1_init

	rts


state_intro_render: subroutine
	jmp state_render_done
        
        
state_intro_update: subroutine
	inc state00
	inc state00
        bne .not_next_shot
        inc state01
.not_next_shot
	lda state01
 	bne .step01
.step00
.step01
	cmp #$01
        bne .step02
        lda state00
        sta scroll_x
	inc state00
	inc state00
        jmp switch_done
.step02
	cmp #$02
        bne .step03
        jmp switch_done
.step03
	cmp #$03
        bne .step04
        jsr state_intro_shot2_init
        inc state01
        jmp switch_done
.step04
	cmp #$04
        bne .step05
        jmp switch_done
.step05
	cmp #$05
        bne .step06
        jsr state_level_init
.step06
switch_done
	rts
        
        
state_intro_shot1_init: subroutine
	jsr render_disable
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
	rts
        

state_intro_shot2_init: subroutine
	jsr render_disable
        lda #$00
        sta scroll_x
        lda #$20
        ldx #text_space_pattern_id
        jsr clear_nametable
        lda #$23
        ldx #$00
        jsr clear_attributes
; plot characters and text
	;pando
        ldy #$00
        lda #$60
        jsr sprite_6_set_sprite
        lda #$01
        jsr sprite_6_set_attr
	lda #$30
        jsr sprite_6_set_x
	lda #$60
        jsr sprite_6_set_y
        ;binny
        ldy #$20
        lda #$00
        jsr sprite_6_set_sprite
        lda #$40
        jsr sprite_6_set_attr
	lda #$c0
        jsr sprite_6_set_x_mirror
	lda #$60
        jsr sprite_6_set_y
        PPU_PLOT_TEXT $214e,text_008
        PPU_PLOT_TEXT $218e,text_009
        PPU_PLOT_TEXT $21ce,text_00a
        PPU_PLOT_TEXT $220e,text_00b
        jsr render_enable
	rts