

state_demo_init: subroutine
	jsr state_level_init
        jsr render_disable
        ;jsr state_level_plot_nametable1  
        ;jsr state_level_plot_nametable2
        lda #$00
        sta state04
.plot_loop
        inc state04
        lda state04
        cmp #$20
        beq .plot_loop_done
        lda state04
        sta state00
	jsr state_level_plot_update
        jmp .plot_loop
.plot_loop_done
        jsr render_enable
        lda #state_demo_update_id
        sta state_update_id
        rts
        
state_demo_update: subroutine
	jsr ents_system_update
	jsr state_level_hud_update
        jsr state_level_cam_update
        ;lda #$00
        ;sta state00
	jsr state_level_plot_update
	rts
