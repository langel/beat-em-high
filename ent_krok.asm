
ent_krok_update: subroutine
        
; KROK
        lda #$20
        ldx ent_r0+$20
        lda sine_table,x
        lsr
        lsr
        clc
        adc #$28
        sta ent_x+$20
        lda ent_r0+$20
        clc
        adc #$40
        tax
        lda sine_table,x
        sta temp01
        lda #$15
        sta temp00
        jsr shift_divide
        sta ent_r1+$20
        clc
        adc #$a4
        sta ent_y+$20
        dec ent_r0+$20
        dec ent_r0+$20
        
	jmp ent_update_next
        
        
        
        
        
ent_krok_render: subroutine
	lda ent_x,x
        jsr sprite_4_set_x
        lda ent_y,x
        jsr sprite_4_set_y
        lda #$02
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
