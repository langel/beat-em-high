;; INIT STATES by using state_hook_init

;;;;;; JUMP AROUND

jsr_to_subroutine: subroutine
	; a = jump table offset
        ; caches x and leaves y alone
        stx temp03
        tax
        lda prime_jump_table_lo,x
        sta temp00
        lda prime_jump_table_hi,x
        sta temp01
        ldx temp03
        jmp (temp00)
jump_to_rts:
	rts

jump_to_subroutine: subroutine
	; a = jump table offset
        ; caches x and leaves y alone
        stx temp03
        tax
        lda prime_jump_table_lo,x
        sta temp00
        lda prime_jump_table_hi,x
        sta temp01
        ldx temp03
        jmp (temp00)
        
do_nothing: subroutine        
        rts
        
    	;  jump tables defined 
utility_jump_table_offset           EQM	0
do_nothing_id                       EQM	0
state_title_jump_table_offset       EQM	1
state_title_init_id                 EQM	1
state_title_render_id               EQM	2
state_title_update_id               EQM	3
state_intro_jump_table_offset       EQM	4
state_intro_init_id                 EQM	4
state_intro_render_id               EQM	5
state_intro_update_id               EQM	6
state_level_jump_table_offset       EQM	7
state_level_init_id                 EQM	7
state_level_render_id               EQM	8
state_level_update_id               EQM	9
state_outro_jump_table_offset       EQM	10
state_outro_init_id                 EQM	10
state_outro_render_id               EQM	11
state_outro_update_id               EQM	12


prime_jump_table_lo:
utility_jump_table_lo:
	byte <do_nothing
state_title_jump_table_lo:
	byte <state_title_init
	byte <state_title_render
	byte <state_title_update
state_intro_jump_table_lo:
	byte <state_intro_init
	byte <state_intro_render
	byte <state_intro_update
state_level_jump_table_lo:
	byte <state_level_init
	byte <state_level_render
	byte <state_level_update
state_outro_jump_table_lo:
	byte <state_outro_init
	byte <state_outro_render
	byte <state_outro_update

prime_jump_table_hi:
utility_jump_table_hi:
	byte >do_nothing
state_title_jump_table_hi:
	byte >state_title_init
	byte >state_title_render
	byte >state_title_update
state_intro_jump_table_hi:
	byte >state_intro_init
	byte >state_intro_render
	byte >state_intro_update
state_level_jump_table_hi:
	byte >state_level_init
	byte >state_level_render
	byte >state_level_update
state_outro_jump_table_hi:
	byte >state_outro_init
	byte >state_outro_render
	byte >state_outro_update