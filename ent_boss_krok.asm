
ent_krok_boss_init: subroutine
	
	rts


ent_krok_boss_update: subroutine
	jmp ent_update_return

ent_krok_boss_render: subroutine
        ; x = ent_ram_offset
        ; y = ent_oam_offset
	rts
