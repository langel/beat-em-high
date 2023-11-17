

state_intro_init: subroutine
        ; set state
        lda #state_intro_update_id
        sta state_update_id
        lda #state_intro_render_id
        sta state_render_id
        lda #$00
        sta state_sprite_0
        jsr render_disable
        
        lda #$20
        ldx #text_space_pattern_id
        jsr clear_nametable
        lda #$24
        ldx #text_space_pattern_id
        jsr clear_nametable
        lda #$23
        ldx #$00
        jsr clear_attributes
        
        jsr state_level_00_load_palettes
        
                ; text on screen
        ; PRESENTS
        PPU_PLOT_TEXT $2042,text_002 
        jsr render_enable
	rts


state_intro_render: subroutine
	jmp state_render_done
        
        
state_intro_update: subroutine
	rts