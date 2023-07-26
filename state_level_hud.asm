
state_level_hud_init: subroutine
; TOP LINE
	PPU_SETADDR $2041
        lda #$c0
        sta PPU_DATA
        lda #$c1
        ldy #12
.l1	; binny top line
	sta PPU_DATA
        dey
        bne .l1
        lda #$c0
        sta PPU_DATA
        lda #$c3
        sta PPU_DATA
        sta PPU_DATA
        lda #$c0
        sta PPU_DATA
        lda #$c1
        ldy #12
.l2	; pando line
	sta PPU_DATA
        dey
        bne .l2
        lda #$c0
        sta PPU_DATA
; BOTTOM LINE
	PPU_SETADDR $20a1
        lda #$c0
        sta PPU_DATA
        lda #$c1
        ldy #12
.l3	; binny top line
	sta PPU_DATA
        dey
        bne .l3
        lda #$c0
        sta PPU_DATA
        lda #$c3
        sta PPU_DATA
        sta PPU_DATA
        lda #$c0
        sta PPU_DATA
        lda #$c1
        ldy #12
.l4	; pando line
	sta PPU_DATA
        dey
        bne .l4
        lda #$c0
        sta PPU_DATA
	rts
        
        
state_level_hud_update: subroutine
	rts
