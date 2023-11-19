


ent_title_krok_wave_init: subroutine
        lda #ent_title_krok_wave_id
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
        
        
        
ent_title_krok_wave_update: subroutine
	RNG0_NEXT
        lsr
        and #$01
        beq .not_forward
	inc ent_x,x
.not_forward
	RNG0_NEXT
        and #$01
        bne .not_around
	inc ent_r0,x
.not_around
	jmp ent_update_return



ent_title_krok_wave_render:
	lda ent_r0,x
        tax
        lda sine_table,x
        lsr
        lsr
        clc
        adc #$a0
        ldx ent_ram_offset
        sta ent_y,x
        lda ent_y,x
        sec
        sbc #$10
        jsr sprite_4_set_y
        lda wtf
        lsr
        lsr
        and #$01
        asl
        clc
	adc #$c0
        jsr sprite_4_set_sprite
	lda ent_x,x
        sec
        sbc #$08
        jsr sprite_4_set_x
        lda #$03
        jsr sprite_4_set_attr
        ; check view direction
        lda ent_x,x
        cmp $0312
        bcs .mirror
.no_mirror
	lda ent_x,x
        sec
        sbc #$08
        jsr sprite_4_set_x
        lda #$03
        jsr sprite_4_set_attr
        jmp .done
.mirror
	lda ent_x,x
        sec
        sbc #$08
        jsr sprite_4_set_x_mirror
        lda #$43
        jsr sprite_4_set_attr
.done
	jmp ent_render_return
        
