
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
        ldy #$08
        lda #$06
        jsr sprite_4_set_sprite
        lda #$00
        jsr sprite_4_set_attr
        lda #$12
        jsr sprite_4_set_x
        lda #$0e
        jsr sprite_4_set_y
; PANDO HEAD SPRITE
        ldy #$18
        lda #$66
        jsr sprite_4_set_sprite
        lda #$01
        jsr sprite_4_set_attr
        lda #$93
        jsr sprite_4_set_x
        lda #$0e
        jsr sprite_4_set_y
        
; expirement sprite
	lda #$fa
        sta oam_ram_spr+4
        sta oam_ram_spr+$f8
        sta oam_ram_spr+$fc
        lda #$02
        sta oam_ram_att+4
        sta oam_ram_att+$f8
        lda #$03
        sta oam_ram_att+$fc
        lda #$26
        sta oam_ram_y+4
        sta oam_ram_y+$f8
        sta oam_ram_y+$fc
        lda wtf
        sta oam_ram_x+$f8
        bne .no_reset
        RNG0_NEXT
        sta $0505
        tax
        lda #$ff
        jsr shift_percent
        sta $e8
        lda #$00
        sta oam_ram_x+$fc
        sta $e9
        sta $ea
.no_reset
	; rigid
        lda wtf
        ldx $0505
        jsr shift_percent
        sta oam_ram_x+4
        ; smoother?
        lda $e8
        clc
        adc $e9
        sta $e9
        bcs .dont_move_guy
        inc $ea
.dont_move_guy
        lda $ea
        sta oam_ram_x+$fc
	rts
