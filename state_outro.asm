

state_outro_init: subroutine
        lda #state_outro_update_id
        sta state_update_id
        lda #state_outro_render_id
        sta state_render_id
        lda #do_nothing_id
        sta state_sprit0_id
        jsr render_disable
        
        lda state00
        sta scroll_x
        lda state01
        sta scroll_y
        
        lda #$00
        sta state00	; monologue line
        sta state01	; monologue timer
        sta state02	; shot
        sta state03	; counter
        
        ; load boss krok
	BANK_CHANGE 1
        lda #$1c
        sta PPU_ADDR
        lda #$00
        sta PPU_ADDR
        ldy #$00
.grafx_load_loop
	lda boss_krok_chr,y
        sta PPU_DATA
        iny
        bne .grafx_load_loop
        inc temp01
        ; do it twice?!?!
	BANK_CHANGE 1
        lda #$1c
        sta PPU_ADDR
        lda #$00
        sta PPU_ADDR
        ldy #$00
.grafx_load_loop2
	lda boss_krok_chr,y
        sta PPU_DATA
        iny
        bne .grafx_load_loop2
        inc temp01
        
        lda #ent_boss_krok_id
        jsr ents_system_spawn
        
        ; some palette
	PPU_SETADDR $3f19
        lda #$0f ;#$0c
        sta PPU_DATA
        lda #$25
        sta PPU_DATA
        lda #$30 ;#$36
        sta PPU_DATA
        
        ; clear hud tiles
        lda #$20
        sta PPU_ADDR
        lda #$00
        sta PPU_ADDR
        lda #text_space_pattern_id
        ldx #$60
.hud_tile_loop
	sta PPU_DATA
        inx
        bne .hud_tile_loop
        ; clear hud sprites
        ldy #$1f
        lda #$ff
.hud_sprite_loop
	sta $0208,y
        dey
        bne .hud_sprite_loop
	
        jsr render_enable
	rts
        
        
        
state_outro_render: subroutine
        lda state02
        cmp #$03
        beq .monologue
        cmp #$04
        beq .not_monologue
	jmp state_render_done
.monologue
	inc state01
        lda state01
        cmp #$60	; frames until next text
        bne .not_next_text
.next_text
        lda #$00
        sta state01
        lda #$18
        clc
        adc state00
        sta state00
        cmp #$98
        bcc .not_next_text
.text_done
	lda #$00
        sta state03
	inc state02
.not_next_text
        lda #$20
        sta PPU_ADDR
        lda #$64
        sta PPU_ADDR
        ldx #$18
	lda state00
        tay
.text_loop
        lda text_00c,y
        sta PPU_DATA
        iny
        dex
        bne .text_loop
	jmp state_render_done
.not_monologue
        
        
state_outro_supreme: subroutine
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
        
	lda #$00
        sta scroll_ms
	ldx wtf
        lda sine_table,x
        lsr
        lsr
        ;lsr
        sec
        sbc #$20
        ;lsr
        ;lsr
        sta scroll_x
        ; get carry into ms
        lda #$00
        rol
        eor #$01
        sta scroll_ms
        inc state03
        lda state03
        cmp #239
        bcc .y_in_range
        lda #0
        sta state03
.y_in_range
        sta scroll_y
        
	jmp state_render_done
        

state_outro_update: subroutine
        lda state02
        cmp #$04
        beq .murder
	jsr ents_system_update
	rts
.murder
	rts

