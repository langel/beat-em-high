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
state_title_update_id               EQM	2
state_level_jump_table_offset       EQM	3
state_level_init_id                 EQM	3
state_level_update_id               EQM	4
state_level_render_id               EQM	5


prime_jump_table_lo:
utility_jump_table_lo:
	byte <do_nothing
state_title_jump_table_lo:
	byte <state_title_init
	byte <state_title_update
state_level_jump_table_lo:
	byte <state_level_init
	byte <state_level_update
	byte <state_level_render

prime_jump_table_hi:
utility_jump_table_hi:
	byte >do_nothing
state_title_jump_table_hi:
	byte >state_title_init
	byte >state_title_update
state_level_jump_table_hi:
	byte >state_level_init
	byte >state_level_update
	byte >state_level_render