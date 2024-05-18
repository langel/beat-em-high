



ent_krok_init: subroutine
        lda #ent_krok_id
        sta ent_type,x
	rts
        
ent_krok_update: subroutine
	lda wtf
        bne .skip_pos
	; mult sine position
        lda ent_ram_offset
        clc
        adc #$0f
        sta temp00
        lda #$f0
        sta temp01
        jsr shift_multiply
        ldx ent_ram_offset
        lda temp01
        tay
        lda sine_table,y
        clc
        adc #$c4
        sta ent_x,x
        lda temp01
        clc
        adc #$40
        tay
        lda sine_table,y
        lsr
        clc
        adc #$6e
        sta ent_y,x
.skip_pos
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
        lda #$03
        jsr sprite_4_set_attr_mirror
        lda wtf 
        cmp #$90
        bcc .done
        lda ent_ram_offset
        lsr
        lsr
        lsr
        lsr
        cmp #$05
        beq .next_fighter
        lda wtf
        asl 
        sta temp00
        txa
        asl
        asl
        clc
        adc temp00
        and #$10
        beq .done
	lda ent_x,x
        jsr sprite_4_set_x
        lda #$03
        jsr sprite_4_set_attr
        jmp .done
.next_fighter
        lda wtf
        lsr
        lsr
        and #$01
        bne .walk_sprite
	lda #$c0
        jsr sprite_4_set_sprite
        jmp .walk_check
.walk_sprite
	lda #$ca
        jsr sprite_4_set_sprite
.walk_check
	lda wtf
        and #$03
        beq .move_left
.move_down
	clc
        adc #$01
        cmp #$02
        bne .done
	inc ent_y,x
        lda ent_y,x
        jsr sprite_4_set_y
	jmp .done
.move_left
	dec ent_x,x
	lda ent_x,x
        jsr sprite_4_set_x_mirror
.done
	jmp ent_render_return