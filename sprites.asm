oam_ram_y	EQU $0200
oam_ram_spr	EQU $0201
oam_ram_att	EQU $0202
oam_ram_x	EQU $0203
oam_ram_etc	EQU $0204

sprites_clear: subroutine
	lda #$ff
        ldy #$00
.loop
	sta $0200,y
        dey
        bne .loop
        rts

sprite_4_set_attr: subroutine
	; a = attribute value
        ; y = oam ram offset
        sta oam_ram_att+$00,y
        sta oam_ram_att+$04,y
        sta oam_ram_att+$08,y
        sta oam_ram_att+$0c,y
        rts

sprite_4_set_sprite: subroutine
	; a = top left tile id
        ; y = oam ram offset
	sta oam_ram_spr,y
        clc
        adc #$01
	sta oam_ram_spr+$04,y
        adc #$0f
	sta oam_ram_spr+$08,y
	adc #$01
	sta oam_ram_spr+$0c,y
        rts
        
sprite_4_set_sprite_flip: subroutine
	; a = top left tile id
        ; y = oam ram offset
	sta oam_ram_spr+$08,y
        clc
        adc #$01
	sta oam_ram_spr+$0c,y
        adc #$0f
	sta oam_ram_spr,y
	adc #$01
	sta oam_ram_spr+$04,y
        rts
        
sprite_4_set_x: subroutine
	; a = x pos
        ; y = oam ram offset
	sta oam_ram_x,y
	sta oam_ram_x+$08,y
	clc
	adc #$08
	sta oam_ram_x+$04,y
	sta oam_ram_x+$0c,y
	rts
        
sprite_4_set_x_mirror: subroutine
	; a = x pos
        ; y = oam ram offset
	sta oam_ram_x+$04,y
	sta oam_ram_x+$0c,y
	clc
	adc #$08
	sta oam_ram_x,y
	sta oam_ram_x+$08,y
	rts
        
sprite_4_set_y: subroutine
	; a = y pos
        ; y = oam ram offset
	sta oam_ram_y,y
	sta oam_ram_y+$04,y
	clc
	adc #$08
	sta oam_ram_y+$08,y
	sta oam_ram_y+$0c,y
	rts


sprite_6_set_palette: subroutine
	; a = palette id
        ; y = oam ram offset
        sta oam_ram_att+$00,y
        sta oam_ram_att+$04,y
        sta oam_ram_att+$08,y
        sta oam_ram_att+$0c,y
        sta oam_ram_att+$10,y
        sta oam_ram_att+$14,y
        rts
        
sprite_6_set_attr: subroutine
	; a = attributes value
        ; y = oam ram offset
        sta oam_ram_att+$00,y
        sta oam_ram_att+$04,y
        sta oam_ram_att+$08,y
        sta oam_ram_att+$0c,y
        sta oam_ram_att+$10,y
        sta oam_ram_att+$14,y
        rts

sprite_6_set_sprite: subroutine
	; a = top left tile id
        ; y = oam ram offset
	sta oam_ram_spr,y
        clc
        adc #$01
	sta oam_ram_spr+$04,y
        adc #$0f
	sta oam_ram_spr+$08,y
	adc #$01
	sta oam_ram_spr+$0c,y
        adc #$0f
	sta oam_ram_spr+$10,y
	adc #$01
	sta oam_ram_spr+$14,y
        rts
        
        ; XXX not done
sprite_6_set_sprite_flip: subroutine
	; a = top left tile id
        ; y = oam ram offset
	sta oam_ram_spr+$08,y
        clc
        adc #$01
	sta oam_ram_spr+$0c,y
        adc #$0f
	sta oam_ram_spr,y
	adc #$01
	sta oam_ram_spr+$04,y
        rts
        
sprite_6_set_x: subroutine
	; a = x pos
        ; y = oam ram offset
	sta oam_ram_x,y
	sta oam_ram_x+$08,y
	sta oam_ram_x+$10,y
	clc
	adc #$08
	sta oam_ram_x+$04,y
	sta oam_ram_x+$0c,y
	sta oam_ram_x+$14,y
	rts
        
sprite_6_set_x_mirror: subroutine
	; a = x pos
        ; y = oam ram offset
	sta oam_ram_x+$04,y
	sta oam_ram_x+$0c,y
	sta oam_ram_x+$14,y
	clc
	adc #$08
	sta oam_ram_x,y
	sta oam_ram_x+$08,y
	sta oam_ram_x+$10,y
	rts
        
sprite_6_set_y: subroutine
	; a = y pos
        ; y = oam ram offset
	sta oam_ram_y,y
	sta oam_ram_y+$04,y
	clc
	adc #$08
	sta oam_ram_y+$08,y
	sta oam_ram_y+$0c,y
	clc
	adc #$08
	sta oam_ram_y+$10,y
	sta oam_ram_y+$14,y
	rts