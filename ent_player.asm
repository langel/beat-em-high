
ent_player_update: subroutine
	lda ent_ram_offset
        beq ent_binny_update
        jmp ent_pando_update
        
ent_player_render: subroutine
	lda ent_ram_offset
        bne .do_pando
        jmp ent_binny_render
.do_pando
        jmp ent_pando_render
        
        
        
ent_binny_update: subroutine; BINNY
	; demo update
        lda #$02
        sta temp00
        lda ent_x
        cmp ent_r0
        beq .binny_x_equal
        bcs .binny_x_greater
.binny_x_lesser
	inc ent_x
        lda #$01
        sta ent_r2
        jmp .binny_x_done
.binny_x_greater
	dec ent_x
        lda #$ff
        sta ent_r2
        jmp .binny_x_done
.binny_x_equal
	dec temp00
.binny_x_done

        lda ent_y
        cmp ent_r1
        beq .binny_y_equal
        bcs .binny_y_greater
.binny_y_lesser
	inc ent_y
        jmp .binny_y_done
.binny_y_greater
	dec ent_y
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
        sta ent_r0
	RNG0_NEXT
        lsr
        lsr
        adc #$a0
        sta ent_r1
.binny_skip_new_targ
        
	jmp ent_update_return
        
        
        
ent_binny_render: subroutine
	lda wtf
        and #$07
        bne .binny_not_next
        inc binny_cycle
.binny_not_next

        lda binny_cycle
        and #$01
        clc
        adc #$06
        asl
        jsr sprite_6_set_sprite
        lda ent_y,x
        sec
        sbc #$18
        jsr sprite_6_set_y
        lda ent_r2
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
     
     
     
        
; PANDO
        
ent_pando_update: subroutine
	lda wtf
        and #$07
        bne .pando_not_next
        inc ponda_cycle
.pando_not_next
	jmp ent_update_return


ent_pando_render: subroutine
	inc ent_r3,x
        lda ponda_cycle
        and #$01
        clc
        adc #$06
        asl
        clc
        adc #$60
        sty $03ef
        jsr sprite_6_set_sprite
        lda #$01
        jsr sprite_6_set_attr
	lda ent_x,x
        sec
        sbc #$08
        jsr sprite_6_set_x
	lda ent_y,x
        sec
        sbc #$18
        jsr sprite_6_set_y
	jmp ent_render_return