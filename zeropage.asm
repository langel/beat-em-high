;;;;; VARIABLES

	seg.u ZEROPAGE
        org $0
        
wtf	byte
nmi_lockout byte
rng0	byte
rng1	byte
temp00	byte
temp01	byte
temp02	byte
temp03	byte

scroll_x  byte
scroll_y  byte
scroll_nt byte ; nametable bit
scroll_ms byte ; map screen
scroll_dir byte

state_render_id	byte
state_update_id byte
state_sprit0_id	byte
state00	byte
state01	byte
state02 byte
state03 byte
state04 byte
state05 byte
state06 byte
state07 byte

ent_ram_offset	byte
ent_oam_offset	byte
ent_y_sort_pos	byte
ent_loop_slot	byte
ent_sort_lo	byte
ent_sort_hi	byte

arctang_velocity_lo	byte
arctang_velocity_hi	byte
player_x_hi	byte
player_y_hi	byte

collision_0_x	byte
collision_0_y	byte
collision_0_w	byte
collision_0_h	byte
collision_1_x	byte
collision_1_y	byte
collision_1_w	byte
collision_1_h	byte


map_ppu_lo byte
map_ppu_hi byte

controls		byte
controls_debounced	byte
