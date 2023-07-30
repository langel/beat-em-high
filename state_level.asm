
state_level_init: subroutine
        
; SPRITE 0 SETUP
	lda #$29
        sta oam_ram_y
	lda #$ce
        sta oam_ram_spr
        lda #$20
        sta oam_ram_att
        lda #$f0
        sta oam_ram_x
        jsr state_level_hud_init
        
; FILL NAMETABLES WITH MAP
	BANK_CHANGE 0
	lda #<map_data_0_table
        sta temp00
	lda #>map_data_0_table
        sta temp01
; nametable 1    
	lda #$04
        sta PPU_CTRL
        ldy #$00
        lda #$20
        sta temp02
.col_loop1
	lda #$20
        sta PPU_ADDR
        lda #$e0
        sec
        sbc temp02
        sta PPU_ADDR
	ldx #$18
.tile_loop1
        lda (temp00),y
        sta PPU_DATA
        inc temp00
        bne .tile1_nocarry
        inc temp01
.tile1_nocarry
        dex
        bne .tile_loop1
        dec temp02
        bne .col_loop1
; nametable 2
	lda #$04
        sta PPU_CTRL
        ldy #$00
        lda #$20
        sta temp02
.col_loop2
	lda #$24
        sta PPU_ADDR
        lda #$e0
        sec
        sbc temp02
        sta PPU_ADDR
	ldx #$18
.tile_loop2
        lda (temp00),y
        sta PPU_DATA
        inc temp00
        bne .tile2_nocarry
        inc temp01
.tile2_nocarry
        dex
        bne .tile_loop2
        dec temp02
        bne .col_loop2
	rts

state_level_update: subroutine
	rts
