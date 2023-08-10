
state_level_hud_init: subroutine
; BINNY HEAD SPRITE
        ldy #$28
        lda #$06
        jsr sprite_4_set_sprite
        lda #$00
        jsr sprite_4_set_attr
        lda #$12
        jsr sprite_4_set_x
        lda #$16
        jsr sprite_4_set_y
; PANDO HEAD SPRITE
        ldy #$50
        lda #$66
        jsr sprite_4_set_sprite
        lda #$01
        jsr sprite_4_set_attr
        lda #$93
        jsr sprite_4_set_x
        lda #$16
        jsr sprite_4_set_y
        
; BG TILE TOP LINE
	PPU_SETADDR $2041
        lda #$ad
        sta PPU_DATA
        lda #$ae
        ldy #12
.l1	; binny top line
	sta PPU_DATA
        dey
        bne .l1
        lda #$af
        sta PPU_DATA
        lda #$00
        sta PPU_DATA
        sta PPU_DATA
        lda #$ad
        sta PPU_DATA
        lda #$ae
        ldy #12
.l2	; pando line
	sta PPU_DATA
        dey
        bne .l2
        lda #$af
        sta PPU_DATA
; BG TILE BOTTOM LINE
	PPU_SETADDR $20a1
        lda #$cd
        sta PPU_DATA
        lda #$ce
        ldy #12
.l3	; binny bottom line
	sta PPU_DATA
        dey
        bne .l3
        lda #$cf
        sta PPU_DATA
        lda #$00
        sta PPU_DATA
        sta PPU_DATA
        lda #$cd
        sta PPU_DATA
        lda #$ce
        ldy #12
.l4	; pando line
	sta PPU_DATA
        dey
        bne .l4
        lda #$cf
        sta PPU_DATA
; BG TILE VERTICAL LINES
	lda #$04
        sta PPU_CTRL
	ldx #$bd
        PPU_SETADDR $2061
        stx PPU_DATA
        stx PPU_DATA
        PPU_SETADDR $2071
        stx PPU_DATA
        stx PPU_DATA
	ldx #$bf
        PPU_SETADDR $206e
        stx PPU_DATA
        stx PPU_DATA
        PPU_SETADDR $207e
        stx PPU_DATA
        stx PPU_DATA
; BG TILE HEALTH
	lda #$00
        sta PPU_CTRL
	ldx #$cb
        PPU_SETADDR $2085
        stx PPU_DATA
        stx PPU_DATA
        stx PPU_DATA
        stx PPU_DATA
        stx PPU_DATA
        stx PPU_DATA
        stx PPU_DATA
        stx PPU_DATA
        stx PPU_DATA
        PPU_SETADDR $2095
        stx PPU_DATA
        stx PPU_DATA
        stx PPU_DATA
        stx PPU_DATA
        stx PPU_DATA
        stx PPU_DATA
        stx PPU_DATA
        stx PPU_DATA
        stx PPU_DATA
; BG TILE NAMES
        PPU_SETADDR $2065
        lda #$e0
        sta PPU_DATA
        sta PPU_DATA
        sta PPU_DATA
        sta PPU_DATA
        sta PPU_DATA
        PPU_SETADDR $2075
        lda #$e0
        sta PPU_DATA
        sta PPU_DATA
        sta PPU_DATA
        sta PPU_DATA
        sta PPU_DATA
; COLOR ATTRIBUTES
	PPU_SETADDR $23c0
        lda #$ff
        sta PPU_DATA
        sta PPU_DATA
        sta PPU_DATA
        sta PPU_DATA
        sta PPU_DATA
        sta PPU_DATA
        sta PPU_DATA
        sta PPU_DATA
        lda #$0f
        sta PPU_DATA
        sta PPU_DATA
        sta PPU_DATA
        sta PPU_DATA
        sta PPU_DATA
        sta PPU_DATA
        sta PPU_DATA
        sta PPU_DATA
	rts
        
        
state_level_hud_update: subroutine
	rts
