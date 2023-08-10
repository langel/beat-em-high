
state_level_hud_init: subroutine
        
	PPU_SETADDR $2020
        ldx #$00
.hud_tile_loop
        lda hud_tile_table,x
        sta PPU_DATA
        inx 
        cpx #$80
        bne .hud_tile_loop
	rts
        
hud_tile_table:
        hex 00adaeaeaeaeaeaeaeaeaeaeaeaeaf00
        hex 00adaeaeaeaeaeaeaeaeaeaeaeaeaf00
        hex 00bd000000dbe2e7e7f20000f1d0bf00
        hex 00bd000000e9dae7dde80000f1d0bf00
        hex 00bd000000cbcbcbcbcbcbcbcbcbbf00
        hex 00bd000000cbcbcbcbcbcbcbcbcbbf00
        hex 00cdcececececececececececececf00
        hex 00cdcececececececececececececf00
        
        
        
state_level_hud_update: subroutine
; BINNY HEAD SPRITE
        ldy #$28
        lda #$06
        jsr sprite_4_set_sprite
        lda #$00
        jsr sprite_4_set_attr
        lda #$12
        jsr sprite_4_set_x
        lda #$0e
        jsr sprite_4_set_y
; PANDO HEAD SPRITE
        ldy #$50
        lda #$66
        jsr sprite_4_set_sprite
        lda #$01
        jsr sprite_4_set_attr
        lda #$93
        jsr sprite_4_set_x
        lda #$0e
        jsr sprite_4_set_y
	rts
