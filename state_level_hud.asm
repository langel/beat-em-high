
hud_life_ppu_hi	EQM #$20
hud_life_ppu_lo EQM #$65

hud_life_blob_full	EQM #$cb
hud_life_blob_empty	EQM #$cc

hud_life_binny_popslide = $0120
hud_life_pando_popslide	= $0130

state_level_hud_init: subroutine
        
	PPU_SETADDR $2020
        ; setup hud in nametable
        ldx #$00
.hud_tile_loop
        lda hud_tile_table,x
        sta PPU_DATA
        inx 
        cpx #$80
        bne .hud_tile_loop
        ; setup lifebars in popslider
        ldx #$45
        ldy #$00
.hud_life_loop
        lda hud_tile_table,x
        sta $0120,y
        inx
        iny
        cpx #$48+22
        bne .hud_life_loop
; PANDO HEAD SPRITE
        ldy #$18
        lda #$66
        jsr sprite_4_set_sprite
        lda #$01
        jsr sprite_4_set_attr
        lda #$12
        jsr sprite_4_set_x
        lda #$0e
        jsr sprite_4_set_y
; BINNY HEAD SPRITE
        ldy #$08
        lda #$06
        jsr sprite_4_set_sprite
        lda #$00
        jsr sprite_4_set_attr
        lda #$92
        jsr sprite_4_set_x
        lda #$0e
        jsr sprite_4_set_y
	rts
        
hud_tile_table:
        hex 00adaeaeaeaeaeaeaeaeaeaeaeaeaf00
        hex 00adaeaeaeaeaeaeaeaeaeaeaeaeaf00
        hex 00bd000000e9dae7dde80000f1d0bf00
        hex 00bd000000dbe2e7e7f20000f1d0bf00
        hex 00bd000000cbcbcbcbcbcbcbcbcbbf00
        hex 00bd000000cbcbcbcbcbcbcbcbcbbf00
        hex 00cdcececececececececececececf00
        hex 00cdcececececececececececececf00
        
        
        
state_level_hud_update: subroutine

; BINNY LIFE BAR
	ldx #$00
	lda ent_hp+$00
        sta temp00
        beq .binny_fillout_empties
.binny_not_dead
        lda #hud_life_blob_full
        sta hud_life_binny_popslide
        
.binny_bar_cache
	inx
	lda temp00
        sec
        sbc #$1c
        sta temp00
        bcc .binny_fillout_empties
        lda #hud_life_blob_full
        sta hud_life_binny_popslide,x
        cpx #$08
        bne .binny_bar_cache
        beq .binny_lifebar_done

.binny_fillout_empties
        lda #hud_life_blob_empty
        sta hud_life_binny_popslide,x
        inx
        cpx #$09
        bne .binny_fillout_empties
.binny_lifebar_done
        
; PANDO LIFE BAR
	ldx #$00
	lda ent_hp+$10
        sta temp00
        beq .pando_fillout_empties
.pando_not_dead
        lda #hud_life_blob_full
        sta hud_life_pando_popslide
        
.pando_bar_cache
	inx
	lda temp00
        sec
        sbc #$1c
        sta temp00
        bcc .pando_fillout_empties
        lda #hud_life_blob_full
        sta hud_life_pando_popslide,x
        cpx #$08
        bne .pando_bar_cache
        beq .pando_lifebar_done

.pando_fillout_empties
        lda #hud_life_blob_empty
        sta hud_life_pando_popslide,x
        inx
        cpx #$09
        bne .pando_fillout_empties
.pando_lifebar_done
	
        
        
	rts
