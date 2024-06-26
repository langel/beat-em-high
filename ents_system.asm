

oam_ram_att	= $0202
oam_ram_spr	= $0201
oam_ram_x	= $0203
oam_ram_y	= $0200

ent_type	= $0300
ent_hp		= $0301
ent_x		= $0302
ent_y		= $0303
ent_ms		= $0304
ent_mx		= $0305 ; arctang direction
ent_x_lo	= $0306
ent_y_lo	= $0307
ent_r0		= $0308
ent_r1		= $0309
ent_r2		= $030a
ent_r3		= $030b
ent_s1		= $030e ; sort order 1 (y+x/2)
ent_s2		= $030f ; sort order 2 (y-x/2)
ent_ram_etc	= $0310

ent_y_sortup	= $0400
ent_y_sortdown	= $0410
ent_sort1	= $0420
ent_sort2	= $0430
ent_y_val	= $0440


ent_ram_offset_table:
	hex 00102030405060708090a0b0c0d0e0f0





ents_system_init: subroutine
	jsr ents_reset_sorts
	jsr ents_clear_slots
	rts


ents_system_spawn: subroutine
	; a = ent type
        sta temp00
        ldy #$00
.loop
	ldx ent_ram_offset_table,y
        lda ent_type,x
        cmp #$ff
        beq .done
        iny
        cpy #$10
        bne .loop
        ; no empty slots
        lda #$ff
        rts
.done
	lda temp00
        sta ent_type,x
	tay
        lda ent_init_lo,y
        sta temp02
        lda ent_init_hi,y
        sta temp03
        jmp (temp02)
	rts
        
        
ent_fix_y_visible: subroutine
	; a = y position to check
	; returns new y position in a
        cmp #255-8
        bcc .not_wrapped_from_top
        sta temp00
        lda #255
        sec
        sbc #240
        sta temp01
        lda temp00
        sec
        sbc temp01
        rts
.not_wrapped_from_top
	cmp #240
        bcc .not_wrapped_from_bottom
        sec
        sbc #240
.not_wrapped_from_bottom
	rts


ents_system_update: subroutine      

_ENT_UPDATE
        lda #$00
        sta ent_ram_offset
        sta ent_loop_slot
        lda #$10
        sta ent_oam_offset
.ent_update_loop
	ldx ent_ram_offset
        lda ent_type,x
        bmi .ent_update_next
        tay
        lda ent_update_lo,y
        sta temp00
        lda ent_update_hi,y
        sta temp01
        jmp (temp00)
ent_update_return:
_ENT_Y_PRE_SORT
;	- blitting two sort orders
;	  y+x/2 vs. y-x/2
	ldy ent_loop_slot
	ldx ent_ram_offset
        lda ent_type,x
        cmp #$ff
        bne .not_empty_ent_slot
        sta ent_sort1,y
        lda #$00
        sta ent_sort2,y
        jmp .ent_update_next
.not_empty_ent_slot
        ; offset y pos
        lda ent_y,x
        sta ent_y_val,y
        sec
        sbc #$40
        sta temp00	
        lda ent_x,x	; y+x/4
        lsr
        lsr
        clc
        adc temp00	; offset y
        sta ent_s1,x
        sta ent_sort1,y
        lda ent_x,x	; y-x/4
        lsr
        lsr
        sta ent_s2,x
        lda temp00	; offset y
        sec
        sbc ent_s2,x
        sta ent_s2,x
        sta ent_sort2,y
.ent_update_next
        inc ent_loop_slot
	lda #$10
        clc
        adc ent_ram_offset
        sta ent_ram_offset
        bne .ent_update_loop
        
_ENT_Y_SORT
_sort_up:
        ldy #$00
.sortup_loop
	; grab sortup values
        lda ent_y_sortup,y
        tax
        lda ent_sort1,x
        sta temp00
        lda ent_y_sortup+1,y
        tax
        lda ent_sort1,x
        sta temp01
        cmp temp00
        bcc .sortup_not_greater
.sortup_not_lesser
	lda ent_y_sortup,y
        ldx ent_y_sortup+1,y
        sta ent_y_sortup+1,y
        txa
        sta ent_y_sortup,y
.sortup_not_greater
.sortup_loop_end
	iny
        cpy #$0f
        bne .sortup_loop
_sort_down:
        ldy #$00
.sortdown_loop
	; grab sortdown values
        lda ent_y_sortdown,y
        tax
        lda ent_sort2,x
        sta temp00
        lda ent_y_sortdown+1,y
        tax
        lda ent_sort2,x
        sta temp01
        cmp temp00
        bcc .sortdown_not_greater
.sortdown_not_lesser
	lda ent_y_sortdown,y
        ldx ent_y_sortdown+1,y
        sta ent_y_sortdown+1,y
        txa
        sta ent_y_sortdown,y
.sortdown_not_greater
.sortdown_loop_end
	iny
        cpy #$0f
        bne .sortdown_loop
        
_ENT_RENDER:
	lda #$04
        sta ent_sort_hi
        lda wtf
        lsr
        and #$01
        beq .ref_sortdown
.ref_sortup
	lda #$10
        sta ent_sort_lo
        jmp .ref_set
.ref_sortdown
	lda #$00
        sta ent_sort_lo
.ref_set
        lda #$00
        sta ent_y_sort_pos
	lda #$28
        sta ent_oam_offset
.ent_render_loop
	ldy ent_y_sort_pos
        lda (ent_sort_lo),y
        tay
        ldx ent_ram_offset_table,y
        stx ent_ram_offset
        lda ent_type,x
        bmi .ent_render_next
        tax
        lda ent_render_lo,x
        sta temp00
        lda ent_render_hi,x
        sta temp01
        ldx ent_ram_offset
        ldy ent_oam_offset
        jmp (temp00)
ent_render_return:
	ldx ent_ram_offset
        lda ent_type,x
        tax
        lda ent_size,x
        clc
        adc ent_oam_offset
        sta ent_oam_offset
.ent_render_next
        inc ent_y_sort_pos
        lda ent_y_sort_pos
        cmp #$10
        bne .ent_render_loop
        
        ; clear unused sprites
_ENT_SPRITE_CLEAR:
	lda #$ff
        ldx ent_oam_offset
.ent_sprite_clear_loop
	sta $0200,x
        inx
        bne .ent_sprite_clear_loop
	rts
     
     
ents_clear_slots: subroutine
	lda #$ff
        ldx #$0f
.loop
	ldy ent_ram_offset_table,x
        sta ent_type,y
        dex
        bpl .loop
	rts
     
     
ents_reset_sorts: subroutine
	ldy #$0f
.loop
	tya
        sta ent_y_sortup,y
        sta ent_y_sortdown,y
        dey
        bpl .loop
	rts
        
     

; ENT TABLES
ent_pando_id                        EQM	0
ent_binny_id                        EQM	1
ent_krok_id                         EQM	2
ent_boss_krok_id                    EQM	3
ent_title_player_id                 EQM	4
ent_title_krok_elipse_id            EQM	5
ent_title_krok_wave_id              EQM	6
ent_krok_victim_id                  EQM 7
ent_size:
	byte 28,24,16,64,24,16,16,16
ent_init_lo:
	byte #<ent_pando_init
	byte #<ent_binny_init
	byte #<ent_krok_init
	byte #<ent_boss_krok_init
	byte #<ent_title_player_init
	byte #<ent_title_krok_elipse_init
	byte #<ent_title_krok_wave_init
        byte #<ent_krok_victim_init
ent_init_hi:
	byte #>ent_pando_init
	byte #>ent_binny_init
	byte #>ent_krok_init
	byte #>ent_boss_krok_init
	byte #>ent_title_player_init
	byte #>ent_title_krok_elipse_init
	byte #>ent_title_krok_wave_init
        byte #>ent_krok_victim_init
ent_update_lo:
	byte #<ent_pando_update
	byte #<ent_binny_update
	byte #<ent_krok_update
	byte #<ent_boss_krok_update
	byte #<ent_title_player_update
	byte #<ent_title_krok_elipse_update
	byte #<ent_title_krok_wave_update
        byte #<ent_krok_victim_update
ent_update_hi:
	byte #>ent_pando_update
	byte #>ent_binny_update
	byte #>ent_krok_update
	byte #>ent_boss_krok_update
	byte #>ent_title_player_update
	byte #>ent_title_krok_elipse_update
	byte #>ent_title_krok_wave_update
        byte #>ent_krok_victim_update
ent_render_lo:
	byte #<ent_pando_render
	byte #<ent_binny_render
	byte #<ent_krok_render
	byte #<ent_boss_krok_render
	byte #<ent_title_player_render
	byte #<ent_title_krok_elipse_render
	byte #<ent_title_krok_wave_render
        byte #<ent_krok_victim_render
ent_render_hi:
	byte #>ent_pando_render
	byte #>ent_binny_render
	byte #>ent_krok_render
	byte #>ent_boss_krok_render
	byte #>ent_title_player_render
	byte #>ent_title_krok_elipse_render
	byte #>ent_title_krok_wave_render
        byte #>ent_krok_victim_render