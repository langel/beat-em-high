

oam_ram_x	= $0203
oam_ram_y	= $0200
oam_ram_spr	= $0201
oam_ram_att	= $0202

ent_type	= $0300
ent_hp		= $0301
ent_x		= $0302
ent_y		= $0303
ent_r0		= $0304
ent_r1		= $0305
ent_r2		= $0306
ent_r3		= $0307

; XXX need a bubble sort sprite priority

state_level_ents_init: subroutine
	; binny init pos
	lda #$33
        sta ent_x
        sta ent_r0
        lda #$b0
        sta ent_y
        sta ent_r1
        ; pando init post
        lda #$48
        sta ent_x+$10
        sta ent_r0+$10
        lda #$a8
        sta ent_y+$10
        sta ent_r1+$10
	rts


state_level_ents_update: subroutine        
        
; BINNY
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
        adc #$30
        sta ent_r0
	RNG0_NEXT
        lsr
        lsr
        adc #$88
        sta ent_r1
.binny_skip_new_targ
        
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
        ldy #$10
        jsr sprite_6_set_sprite
        lda ent_y
        jsr sprite_6_set_y
        lda ent_r2
        bmi .binny_mirror
.binny_not_mirror
        lda #$00
        jsr sprite_6_set_attr
        lda ent_x
        jsr sprite_6_set_x
        jmp .binny_done
.binny_mirror
        lda #$40
        jsr sprite_6_set_attr
        lda ent_x
        jsr sprite_6_set_x_mirror
.binny_done
        
; PANDO
	lda wtf
        and #$07
        bne .pando_not_next
        inc ponda_cycle
.pando_not_next
        lda ponda_cycle
        and #$01
        clc
        adc #$06
        asl
        clc
        adc #$60
        ldy #$38
        jsr sprite_6_set_sprite
        lda #$01
        jsr sprite_6_set_attr
        lda ent_x+$10
        jsr sprite_6_set_x
        lda ent_y+$10
        jsr sprite_6_set_y
        
; KROK
	ldy #$60
	lda #$c0
        jsr sprite_4_set_sprite
        lda #$20
        ldx ent_r0+$20
        lda sine_table,x
        lsr
        lsr
        clc
        adc #$28
        jsr sprite_4_set_x
        lda ent_r0+$20
        clc
        adc #$40
        tax
        lda sine_table,x
        sta temp01
        sta ent_r2+$20
        lda #$15
        sta temp00
        sta ent_r3+$20
        jsr shift_divide
        sta ent_r1+$20
        clc
        adc #$a4
        jsr sprite_4_set_y
        lda #$02
        jsr sprite_4_set_attr
        dec ent_r0+$20
        
        
	rts
