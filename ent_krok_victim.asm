


ent_krok_victim_init: subroutine
        lda #ent_krok_victim_id
        sta ent_type,x
        lda #$6c
        sta ent_x,x
        lda #$b1
        sta ent_y,x
        sta ent_r3,x
        lda #$02
        sta ent_r0,x
	rts
        
        
ent_krok_victim_update: subroutine
        ldx ent_ram_offset
; frame  00    = reset x pos
	lda wtf
        bne .dont_reset
        lda #$6c
        sta ent_x,x
        lda ent_r3,x
        sta ent_y,x
.dont_reset
; frames 68-7f = move right
.taking_hits
	lda wtf
        cmp #$70
        bcs .death
        lda wtf
        and #$10
        bne .is_hit
        beq .not_hit
.not_hit
	lda #$c0
        sta ent_r1,x
        bne .done
.is_hit
	lda #$cc
        sta ent_r1,x
        jmp .done
.death
	lda wtf
        cmp #$98
        bcs .dead
        lda #$cc
        sta ent_r1,x
        lda wtf
        and #$01
        bne .death_dont_right
        inc ent_x,x
.death_dont_right
	; parabola
        lda wtf
        clc
        adc #$50
        asl
        asl
        tay
        lda sine_table,y
        lsr
        lsr
        lsr
        sta temp00
        lda ent_r3,x
        sec
        sbc temp00
        sta ent_y,x
        jmp .done
.dead
        lda ent_r3,x
        sta ent_y,x
        lda #$ce
        sta ent_r1,x
.done
	jmp ent_update_return
        
        
ent_krok_victim_render: subroutine
        ldx ent_ram_offset
        lda ent_r1,x
        jsr sprite_4_set_sprite
	lda ent_x,x
        jsr sprite_4_set_x_mirror
        lda ent_y,x
        jsr sprite_4_set_y
        lda #$03
        jsr sprite_4_set_attr_mirror
	jmp ent_render_return
