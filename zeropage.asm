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
scroll_ms byte ; map screen
scroll_dir byte

state_render_id	byte
state_update_id byte
state_sprite_0	byte

ent_ram_offset	byte
ent_oam_offset	byte
ent_y_sort_pos	byte

map_ppu_lo byte
map_ppu_hi byte

controls		byte
controls_debounced	byte

binny_cycle byte
ponda_cycle byte