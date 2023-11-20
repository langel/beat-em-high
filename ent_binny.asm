



ent_binny_init: subroutine
	; full health
        lda #$ff
        sta ent_hp,x
	rts
        
ent_binny_update: subroutine
	jmp ent_update_return
        
ent_binny_render: subroutine
	jmp ent_render_return