


ent_boss_krok_init: subroutine
	rts
        
ent_boss_krok_update: subroutine
	jmp ent_update_return
        
ent_boss_krok_render: subroutine
        ; x = ent_ram_offset
        ; y = ent_oam_offset
	jmp ent_render_return