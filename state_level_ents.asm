

oam_ram_att	= $0202
oam_ram_spr	= $0201
oam_ram_x	= $0203
oam_ram_y	= $0200

ent_type	= $0300
ent_hp		= $0301
ent_x		= $0302
ent_y		= $0303
ent_ms		= $0304
ent_mx		= $0305
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


ent_player_id	EQM	$00
ent_krok_id	EQM	$01
ent_krokw_id	EQM	$02

; TO DO
;	- sort set management
;         add/remove ents 

state_level_ents_init: subroutine
	jsr ent_reset_sorts
        ; init types
        lda #$00
        sta temp00
        ldy #$ff
.type_clear
	tax
        lda #$ff
	sta ent_type,x
        lda #$10
        clc
        adc temp00
        sta temp00
        bne .type_clear
        ; init y sort
        lda #$ff
        ldx #$0f
.y_clear
	;sta $0400,x
        dex
        bpl .y_clear
        
; SETUP 3 ENTS for devving :D/
        lda #$00
        sta ent_type+$00
        sta ent_type+$10
        lda #$01
        sta ent_type+$20
	; binny init pos
	lda #$33
        sta ent_x
        sta ent_r0
        lda #$b0
        sta ent_y
        sta ent_r1
        ; pando init post
        lda #$58
        sta ent_x+$10
        sta ent_r0+$10
        lda #$c0
        sta ent_y+$10
        sta ent_r1+$10
; LET's TEST SOME STUFF
.do_moar_ents
	lda #$09
        sta temp00
.load_moar_ents_loop
        lda temp00
        asl
        asl
        asl
        asl
        clc
        adc #$30
        tax
        jsr ent_krokw_init
	dec temp00
        bne .load_moar_ents_loop
	rts



state_level_ents_update: subroutine      

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
     
     
ent_clear_ents: subroutine
	lda #$ff
        ldx #$0f
.loop
	ldy ent_ram_offset_table,x
        sta ent_type,y
        dex
        bpl .loop
	rts
     
     
ent_reset_sorts: subroutine
	ldy #$0f
.loop
	tya
        sta ent_y_sortup,y
        sta ent_y_sortdown,y
        dey
        bpl .loop
	rts
        
        
ent_size:
	; number of sprites * 4
	byte 24,16,16
ent_update_lo:
	byte #<ent_player_update
        byte #<ent_krok_update
        byte #<ent_krokw_update
ent_update_hi:
	byte #>ent_player_update
        byte #>ent_krok_update
        byte #>ent_krokw_update
ent_render_lo:
	byte #<ent_player_render
        byte #<ent_krok_render
        byte #<ent_krokw_render
ent_render_hi:
	byte #>ent_player_render
        byte #>ent_krok_render
        byte #>ent_krokw_render
ent_ram_offset_table:
	hex 00102030405060708090a0b0c0d0e0f0
