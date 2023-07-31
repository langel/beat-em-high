;;;;; VARIABLES

	seg.u ZEROPAGE
        org $0
        
wtf	byte
nmi_lockout byte
temp00	byte
temp01	byte
temp02	byte
temp03	byte

scroll_x  byte
scroll_y  byte
scroll_ms byte ; map screen

map_ppu_lo byte
map_ppu_hi byte

controls		byte
controls_debounced	byte

binny_cycle byte
ponda_cycle byte