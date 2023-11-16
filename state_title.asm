

state_title_init: subroutine
        ; set state
        lda #state_title_update_id
        sta state_update_id
        lda #state_title_render_id
        sta state_render_id
        lda #$00
        sta state_sprite_0
        jsr render_disable
        
        ; palette
	PPU_SETADDR $3f00
        lda #$07
        sta PPU_DATA
        lda #$10
        sta PPU_DATA
        lda #$27
        sta PPU_DATA
        lda #$1b
        sta PPU_DATA
        
    	; graphx to chr ram
        ; title logo
	BANK_CHANGE 1
	lda #<title_logo_chr
        sta temp00
        lda #>title_logo_chr
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
        
	; graphx to chr ram
        ; character set
	lda #<tiles_addr
        sta temp00
        lda #>tiles_addr+$08
        sta temp01
        lda #$08
        sta PPU_ADDR
        lda #$00
        sta PPU_ADDR
        ldx #$08
        ldy #$00
.char_load_loop
	lda (temp00),y
        sta PPU_DATA
        iny
        bne .char_load_loop
        inc temp01
	dex
        bne .char_load_loop
        
        ; tiles to nametable
	BANK_CHANGE 0
	lda #<title_logo_map
        sta temp00
        lda #>title_logo_map
        sta temp01
        lda #$20
        sta PPU_ADDR
        lda #$60
        sta PPU_ADDR
        lda #$00
        sta PPU_CTRL
        ldy #$00
.chr_load_loop
	lda (temp00),y
        sta PPU_DATA
        iny
        bne .chr_load_loop
        inc temp01
.chr_load_loop2
	lda (temp00),y
        sta PPU_DATA
        iny
        cpy #$60
        bne .chr_load_loop2
        
        ; text on screen
        lda #$22
        sta PPU_ADDR
        lda #$67
        sta PPU_ADDR
        ldx #$00
.text_loop
	lda state_title_text,x
        beq .text_done
        sta PPU_DATA
        inx
        jmp .text_loop
.text_done
	jsr render_enable
	rts
        
        
        
state_title_render: subroutine
	jmp state_render_done
        
        
        
state_title_update: subroutine
	lda controls
        beq .do_nothing
        jsr state_level_init
.do_nothing
	rts
        
state_title_text:        
 hex e7deecdddeeffadce8e6e9e8fad2d0d2d300