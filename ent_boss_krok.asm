
ent_boss_krok_base_x	EQM #$aa
ent_boss_krok_base_y	EQM #$ac


ent_boss_krok_init: subroutine
	lda #ent_boss_krok_base_x
        sta ent_x,x
        lda #ent_boss_krok_base_y
        sta ent_y,x
        lda #$db
        sta state03
	rts
        
ent_boss_krok_update: subroutine
        ; x = ent_ram_offset
        lda state02
        bne .bounce
.fall
	lda state03
        tay
        lda sine_table,y
        asl
        sta temp00
        lda #ent_boss_krok_base_y
        clc
        adc temp00
        sta ent_y,x
        inc state03
        bne .done
        lda #$00
        sta state03
        inc state02
.bounce
	cmp #$01
        bne .bounce2
        lda state03
        tay
        lda sine_table,y
        sec
        sbc #$80
        lsr
        lsr
        sta temp00
        lda #ent_boss_krok_base_y
        sec
        sbc temp00
        sta ent_y,x
        inc state03
        inc state03
        inc state03
        inc state03
        lda state03
        cmp #$80
        bne .done
        lda #$00
        sta state03
        inc state02
.bounce2
	cmp #$02
        bne .done
        lda state03
        tay
        lda sine_table,y
        sec
        sbc #$80
        lsr
        lsr
        lsr
        sta temp00
        lda #ent_boss_krok_base_y
        sec
        sbc temp00
        sta ent_y,x
        inc state03
        inc state03
        inc state03
        inc state03
        lda state03
        cmp #$80
        bne .done
        inc state02
.done
        ; animate head y
	inc ent_r0,x
	inc ent_r0,x
	inc ent_r0,x
        lda ent_r0,x
        tay
        lda sine_table,y
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
        clc
        adc ent_y,x
        sta ent_r1,x
        ; animate body x
        lda ent_r2,x
        clc
        adc #$19
        sta ent_r2,x
        tay
        lda sine_table,y
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
        sta ent_r3,x
        
	jmp ent_update_return
        
ent_boss_krok_render: subroutine
        ; x = ent_ram_offset
        ; y = ent_oam_offset
        
        lda ent_x,x
        sta oam_ram_x+$00,y
        sta oam_ram_x+$10,y
        clc
        adc #$08
        sta oam_ram_x+$04,y
        sta oam_ram_x+$14,y
        clc
        adc #$08
        sta oam_ram_x+$08,y
        sta oam_ram_x+$18,y
        lda ent_x,x
        sec
        sbc #$04
        clc
        adc ent_r3,x
        sta oam_ram_x+$20,y
        sta oam_ram_x+$30,y
        clc
        adc #$08
        sta oam_ram_x+$24,y
        sta oam_ram_x+$34,y
        clc
        adc #$08
        sta oam_ram_x+$28,y
        sta oam_ram_x+$38,y
        clc
        adc #$08
        sta oam_ram_x+$0c,y
        sta oam_ram_x+$1c,y
        sta oam_ram_x+$2c,y
        sta oam_ram_x+$3c,y
        
        lda ent_r1,x
        sta oam_ram_y+$00,y
        sta oam_ram_y+$04,y
        sta oam_ram_y+$08,y
        sta oam_ram_y+$0c,y
        clc
        adc #$08
        sta oam_ram_y+$10,y
        sta oam_ram_y+$14,y
        sta oam_ram_y+$18,y
        sta oam_ram_y+$1c,y
        lda ent_y,x
        adc #$10
        sta oam_ram_y+$20,y
        sta oam_ram_y+$24,y
        sta oam_ram_y+$28,y
        sta oam_ram_y+$2c,y
        clc
        adc #$08
        sta oam_ram_y+$30,y
        sta oam_ram_y+$34,y
        sta oam_ram_y+$38,y
        sta oam_ram_y+$3c,y
        
        lda #$c0
        sta temp00
        sta oam_ram_spr+#$00,y
        inc temp00
        lda temp00
        sta oam_ram_spr+#$04,y
        inc temp00
        lda temp00
        sta oam_ram_spr+#$08,y
        inc temp00
        lda temp00
        sta oam_ram_spr+#$0c,y
        inc temp00
        lda temp00
        sta oam_ram_spr+#$10,y
        inc temp00
        lda temp00
        sta oam_ram_spr+#$14,y
        inc temp00
        lda temp00
        sta oam_ram_spr+#$18,y
        inc temp00
        lda temp00
        sta oam_ram_spr+#$1c,y
        inc temp00
        lda temp00
        sta oam_ram_spr+#$20,y
        inc temp00
        lda temp00
        sta oam_ram_spr+#$24,y
        inc temp00
        lda temp00
        sta oam_ram_spr+#$28,y
        inc temp00
        lda temp00
        sta oam_ram_spr+#$2c,y
        inc temp00
        lda temp00
        sta oam_ram_spr+#$30,y
        inc temp00
        lda temp00
        sta oam_ram_spr+#$34,y
        inc temp00
        lda temp00
        sta oam_ram_spr+#$38,y
        inc temp00
        lda temp00
        sta oam_ram_spr+#$3c,y
        
        lda #$02
        sta oam_ram_att+$00,y
        sta oam_ram_att+$04,y
        sta oam_ram_att+$08,y
        sta oam_ram_att+$0c,y
        sta oam_ram_att+$10,y
        sta oam_ram_att+$14,y
        sta oam_ram_att+$18,y
        sta oam_ram_att+$1c,y
        sta oam_ram_att+$20,y
        sta oam_ram_att+$24,y
        sta oam_ram_att+$28,y
        sta oam_ram_att+$2c,y
        sta oam_ram_att+$30,y
        sta oam_ram_att+$34,y
        sta oam_ram_att+$38,y
        sta oam_ram_att+$3c,y
	jmp ent_render_return