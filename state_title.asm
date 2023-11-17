

state_title_init: subroutine
        ; set state
        lda #state_title_update_id
        sta state_update_id
        lda #state_title_render_id
        sta state_render_id
        lda #$00
        sta state_sprite_0
        jsr render_disable
        
        lda #$20
        ldx #text_space_pattern_id
        jsr clear_nametable
        lda #$23
        ldx #$00
        jsr clear_attributes
        
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
        lda #$80
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
        ; PRESENTS
        lda #$20
        sta PPU_ADDR
        lda #$42
        sta PPU_ADDR
        ldx #$00
.text_loop
	lda text_miau__iloveui__puke7__present,x
        beq .text_done
        sta PPU_DATA
        inx
        jmp .text_loop
.text_done
        ; DEMO
        lda #$22
        sta PPU_ADDR
        lda #$05
        sta PPU_ADDR
        ldx #$00
.demo_loop
	lda text_NesDEV_COMPO_2023_Demo,x
        beq .demo_done
        sta PPU_DATA
        inx
        jmp .demo_loop
.demo_done

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
        
        
text_space_pattern_id EQM $fa

text_miau__iloveui__puke7__present:
 hex e6e2daeefafae2e5e8efdeeee2fafae9eee4ded7fae9ebdeecdee7ed00
text_NesDEV_COMPO_2023_Demo:
 hex e7deecdddeeffadce8e6e9e8fad2d0d2d3fadddee6e800