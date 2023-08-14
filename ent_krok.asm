
ent_krok_update: subroutine
        
; KROK
	; sine pos
        dec ent_r0,x
        ;dec ent_r0,x
        ; x
        ldx ent_r0+$20
        lda sine_table,x
        lsr
        lsr
        clc
        adc #$38
        ldx ent_ram_offset
        sta ent_x,x
        ; y
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
        
	jmp ent_update_return
        
        
        
        
        
ent_krok_render: subroutine
	lda ent_x,x
        sec
        sbc #$08
        jsr sprite_4_set_x
        lda ent_y,x
        sec
        sbc #$10
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
	jmp ent_render_return
