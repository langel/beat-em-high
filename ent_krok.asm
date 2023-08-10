
ent_krok_update: subroutine
        
; KROK
        lda #$20
        ldx ent_r0+$20
        lda sine_table,x
        lsr
        lsr
        clc
        adc #$38
        ldx ent_ram_offset
        sta ent_x,x
        sec
        sbc #$08
        sta ent_sx,x
        lda ent_r0,x
        clc
        adc #$40
        tax
        lda sine_table,x
        sta temp01
        lda #$15
        sta temp00
        jsr shift_divide
        ldx ent_ram_offset
        sta ent_r1,x
        clc
        adc #$b4
        sta ent_y,x
        sec
        sbc #$10
        sta ent_sy,x
        dec ent_r0,x
        ;dec ent_r0,x
        
	jmp ent_update_next
        
        
        
        
        
ent_krok_render: subroutine
	lda ent_sx,x
        jsr sprite_4_set_x
        lda ent_sy,x
        jsr sprite_4_set_y
        lda #$02
        jsr sprite_4_set_attr
        lda wtf
        lsr
        lsr
        and #$01
        asl
        clc
	adc #$c0
        jsr sprite_4_set_sprite
	jmp ent_render_next
