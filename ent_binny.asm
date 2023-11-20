



ent_binny_init: subroutine
	; full health
        lda #$ff
        sta ent_hp,x
        lda #$10
        sta ent_x,x
        sta ent_r0,x
        lda #$a8
        sta ent_y,x
        sta ent_r1,x
	rts
        
ent_binny_update: subroutine
	; demo update
        lda #$02
        sta temp00
        lda ent_x,x
        cmp ent_r0,x
        beq .binny_x_equal
        bcs .binny_x_greater
.binny_x_lesser
	inc ent_x,x
        lda #$01
        sta ent_r2,x
        jmp .binny_x_done
.binny_x_greater
	dec ent_x,x
        lda #$ff
        sta ent_r2,x
        jmp .binny_x_done
.binny_x_equal
	dec temp00
.binny_x_done

        lda ent_y,x
        cmp ent_r1,x
        beq .binny_y_equal
        bcs .binny_y_greater
.binny_y_lesser
	inc ent_y,x
        jmp .binny_y_done
.binny_y_greater
	dec ent_y,x
        jmp .binny_y_done
.binny_y_equal
	dec temp00
.binny_y_done

	; update new target position
        lda temp00
        bne .binny_skip_new_targ
	RNG0_NEXT
        lsr
        adc #$10
        sta ent_r0,x
	RNG0_NEXT
        lsr
        lsr
        adc #$a0
        sta ent_r1,x
.binny_skip_new_targ
        
	jmp ent_update_return
        
ent_binny_render: subroutine
	lda wtf
        and #$07
        bne .binny_not_next
        inc ent_r0,x
.binny_not_next

        lda ent_r0,x
        and #$01
        clc
        adc #$06
        asl
        jsr sprite_6_set_sprite
        lda ent_y,x
        sec
        sbc #$18
        jsr sprite_6_set_y
        lda ent_r2,x
        bmi .binny_mirror
.binny_not_mirror
        lda #$00
        jsr sprite_6_set_attr
        lda ent_x,x
        sec
        sbc #$08
        jsr sprite_6_set_x
        jmp .binny_done
.binny_mirror
        lda #$40
        jsr sprite_6_set_attr
        lda ent_x,x
        sec
        sbc #$08
        jsr sprite_6_set_x_mirror
.binny_done
	jmp ent_render_return