



ent_krok_init: subroutine
        lda #ent_krok_id
        sta ent_type,x
	rts
        
ent_krok_update: subroutine
	; mult sine position
        lda ent_ram_offset
        clc
        adc #$f
        sta temp00
        lda #$e0
        sta temp01
        jsr shift_multiply
        ldx ent_ram_offset
        lda temp01
        tay
        lda sine_table,y
        clc
        adc #$c0
        sta ent_x,x
        lda temp01
        clc
        adc #$40
        tay
        lda sine_table,y
        lsr
        clc
        adc #$6a
        sta ent_y,x
	jmp ent_update_return
        
ent_krok_render: subroutine
        ldx ent_ram_offset
        lda wtf
        clc
        adc ent_ram_offset
        and #$03
        bne .anim_skip
	RNG0_NEXT
        lsr
        lsr
        and #$03
        asl
        clc
	adc #$c0
        sta ent_r0,x
.anim_skip
        lda ent_r0,x
        jsr sprite_4_set_sprite
	lda ent_x,x
        jsr sprite_4_set_x_mirror
        lda ent_y,x
        jsr sprite_4_set_y
        lda #$43
        jsr sprite_4_set_attr
	jmp ent_render_return