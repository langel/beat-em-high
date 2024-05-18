
; r0 = walk cycle
; r1 = punch cycle
; r2 = kick cycle
; r3 = sprite index

ent_pando_init: subroutine
	; full health
        lda #$ff
        sta ent_hp,x
        ;lda #$63
        lda #$5b
        sta ent_x,x
        ;lda #$c1
        lda #$a9
        sta ent_y,x
	rts
        
ent_pando_attack_cycle:
	hex 66 68 6a 6a
	hex 66 68 6a 6a
	hex 66 68 6a 6a
	hex 90 92 94 94
        
ent_pando_update: subroutine
#IF 0
        lda state_update_id
        cmp #state_outro_update_id
        beq .not_walking
        lda wtf
        and #$07
        bne .pando_not_next
        inc ent_r0,x
        lda ent_r0,x
        and #$01
        clc
        adc #$06
        asl
        clc
        adc #$60
        sta ent_r3,x
.not_walking
	lda wtf
        and #$7f
        bne .pando_not_next
        lda #$20
        sta ent_r1,x
.pando_not_next
	lda ent_r1,x
        beq .not_punch
        cmp #$18
        bcc .pf1
.pf0
	lda #$66
        sta ent_r3,x
        jmp .punch_done
.pf1
        cmp #$10
        bcc .pf2
	lda #$68
        sta ent_r3,x
        jmp .punch_done
.pf2
	lda #$6a
        sta ent_r3,x
.punch_done
        dec ent_r1,x
.not_punch
	lda wtf
        and #$ff
        bne .pando_not_kcik
        lda #$20
        sta ent_r2,x
.pando_not_kcik
	lda ent_r2,x
        beq .not_kick
        cmp #$1a
        bcc .kf1
.kf0
	lda #$90
        sta ent_r3,x
        jmp .kick_done
.kf1
        cmp #$12
        bcc .kf2
	lda #$92
        sta ent_r3,x
        jmp .kick_done
.kf2
	lda #$94
        sta ent_r3,x
.kick_done
        dec ent_r2,x
.not_kick
.done
#ENDIF
; frame  00    = reset x pos
	lda wtf
        bne .dont_reset
        ;lda #$63
        lda #$5c
        sta ent_x,x
        ;lda #$c1
        lda #$a9
        sta ent_y,x
.dont_reset
; frames 68-7f = slowly move right
	lda wtf
        cmp #$68
        bcc .dont_advance
        cmp #$80
        bcs .dont_advance
        and #$01
        bne .dont_advance
        inc ent_x,x
.dont_advance
; frames 00-80 = attack anim
	lda wtf
        cmp #$81
        bcs .attack_done
        lsr
        lsr
        lsr
        and #$0f
        tay
        lda ent_pando_attack_cycle,y
        sta ent_r3,x
        lda wtf
        cmp #$63
        bcs .attack_done
        jmp .done
.attack_done
	lda wtf
        cmp #$d0
        bcc .done
.start_walk
	lda wtf
        lsr
        lsr
        lsr
        and #$01
        bne .walk01
.walk00
        lda #$60
        sta ent_r3,x
        jmp .walk_move
.walk01
        lda #$6c
        sta ent_r3,x
.walk_move
	lda wtf
        and #$03
        beq .move_right
.move_up
	clc
        adc #$01
        cmp #$02
        bne .done
	dec ent_y,x
	jmp .done
.move_right
	inc ent_x,x
.done
	jmp ent_update_return
        
        
ent_pando_render: subroutine
        lda ent_r3,x
        jsr sprite_6_set_sprite
        lda ent_r3,x
        cmp #$6a
        bne .not_fist
.has_fist
	lda #$e0
	sta oam_ram_spr+$18,y
        lda ent_x,x
        clc
        adc #$0f
        sta oam_ram_x+$18,y
        lda ent_y,x
        clc
        adc #$0a
        sta $450
        sta oam_ram_y+$18,y
        lda #$01
        sta oam_ram_att+$18,y
        jmp .fist_done
.not_fist
	lda #$ff
        sta $450
        sta oam_ram_y+18,y
.fist_done
        lda #$01
        jsr sprite_6_set_attr
	lda ent_x,x
        jsr sprite_6_set_x
	lda ent_y,x
        jsr sprite_6_set_y
#IF 0
        lda ent_r3,x
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
#ENDIF
	jmp ent_render_return
