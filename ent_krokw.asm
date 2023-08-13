
ent_krokw_init: subroutine
        lda #ent_krokw_id
        sta ent_type,x
        ; x
        RNG0_NEXT
        sta ent_x,x
        ; y
        RNG0_NEXT
        lsr
        lsr
        clc
        adc #$9e
        sta ent_y,x
        ; dir
        RNG0_NEXT
        RNG0_NEXT
        RNG0_NEXT
        sta ent_r0,x
	rts
        
ent_krokw_update:
	inc ent_x,x
	jmp ent_update_next

ent_krokw_render:
	inc ent_r0,x
	lda ent_r0,x
        tax
        lda sine_table,x
        lsr
        lsr
        clc
        adc #$a0
        ldx ent_ram_offset
        sta ent_y,x
	lda ent_x,x
        sec
        sbc #$08
        jsr sprite_4_set_x
        lda ent_y,x
        sec
        sbc #$10
        jsr sprite_4_set_y
        lda #$03
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