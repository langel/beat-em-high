
; r0 = walk cycle
; r1 = punch cycle
; r2 = kick cycle
; r3 = sprite index

ent_pando_init: subroutine
	; full health
        lda #$ff
        sta ent_hp,x
        lda #$58
        sta ent_x,x
        lda #$a4
        sta ent_y,x
	rts
        
ent_pando_update: subroutine
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
	jmp ent_update_return
        
        
ent_pando_render: subroutine
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
	jmp ent_render_return
