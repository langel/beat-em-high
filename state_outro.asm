

state_outro_init: subroutine
        lda #state_outro_update_id
        sta state_update_id
        lda #state_outro_render_id
        sta state_render_id
        lda #$00
        sta state_sprite_0
        jsr render_disable
        
        lda #$00
        sta state00
        sta state01
        
        jsr render_enable
	rts
        
state_outro_render: subroutine
	; muck up nametable
	lda wtf
        and #$03
        clc
        adc #$20
        sta temp00
        sta PPU_ADDR
        lda rng0
        jsr rng_next
        sta rng0
        sta temp01
        sta PPU_ADDR
        jsr rng_next
        lda rng1
        adc state00
        sta temp02
        sta PPU_DATA
        jsr rng_next
        sta temp03
        sta PPU_DATA
        ; mirror nametable
        lda temp00
        clc
        adc #$04
        sta PPU_ADDR
        lda temp01
        sta PPU_ADDR
        lda temp02
        sta PPU_DATA
        lda temp03
        sta PPU_DATA
        ; muck pattern data
        ldy #$0b
.pattern_loop_big
        inc state00
        lda state00
        and #$0f
        sta PPU_ADDR
        lda state00
        jsr rng_next
        sta PPU_ADDR
        ldx #$08
.pattern_loop
	adc rng1
        sta PPU_DATA
	dex
        bne .pattern_loop
        dey
        bne .pattern_loop_big
        
        
	jmp state_render_done

state_outro_update: subroutine
	ldx wtf
        lda sine_table,x
        lsr
        lsr
        lsr
        lsr
        lsr
        sta scroll_x
        adc #$80
        sta scroll_y
	rts

