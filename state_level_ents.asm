

oam_ram_x	= $0203
oam_ram_y	= $0200
oam_ram_spr	= $0201
oam_ram_att	= $0202

ent_type	= $0300
ent_hp		= $0301
ent_x		= $0302
ent_y		= $0303
ent_sx		= $0304
ent_sy		= $0305
ent_r0		= $0308
ent_r1		= $0309
ent_r2		= $030a
ent_r3		= $030b

ent_y_sort	= $0400

moar_ents	= $043f

ent_player_id	EQM	$00
ent_krok_id	EQM	$01
ent_krokw_id	EQM	$02

; TO DO
;	- sort set management
;         add/remove ents 
;	- blitting two sort orders
;	  y+x/2 vs. y-x/2

state_level_ents_init: subroutine
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
	sta $0400,x
        dex
        bpl .y_clear
        
; SETUP 3 ENTS for devving :D/
        lda #$00
        sta ent_type+$00
        sta ent_type+$10
        lda #$01
        sta ent_type+$20
        ldx #$00
        stx ent_y_sort+0
        inx
        stx ent_y_sort+1
        inx
        stx ent_y_sort+2
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
	lda #$ff
        sta moar_ents
	lda moar_ents
        bne .do_moar_ents
        rts
.do_moar_ents
	lda #$09
        sta temp00
.load_moar_ents_loop
	lda temp00
        clc
        adc #$03
        tax
        sta ent_y_sort,x
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
        ; ent update
_ENT_UPDATE:
        lda #$00
        sta ent_ram_offset
        lda #$10
        sta ent_oam_offset
.ent_update_loop
	ldx ent_ram_offset
        lda ent_type,x
        bmi ent_update_next
        tay
        lda ent_update_lo,y
        sta temp00
        lda ent_update_hi,y
        sta temp01
        jmp (temp00)
ent_update_next:
	lda #$10
        clc
        adc ent_ram_offset
        sta ent_ram_offset
        bne .ent_update_loop
        ; ent y sort
_ENT_Y_SORT:
        ldy #$00
.ent_y_sort_loop
        lda ent_y_sort,y
        sta temp00
        tax
        lda ent_ram_offset_table,x
        tax
        lda ent_y,x
        sta $0410,x
        sta temp03
        iny
        lda ent_y_sort,y
        sta temp01
        tax
        lda ent_ram_offset_table,x
        tax
        lda ent_y,x
        cmp temp03
        bcc .not_greater
.not_lesser
        lda temp00
        sta ent_y_sort,y
        lda temp01
        sta ent_y_sort-1,y
        jmp .ent_y_loop_check
.not_greater
.ent_y_loop_check
	cpy #$0f
        bne 	.ent_y_sort_loop
_ENT_SPRITE_CLEAR:
	lda #$ff
        ldx #$10
.ent_sprite_clear_loop
	sta $0200,x
        inx
        bne .ent_sprite_clear_loop
        ; ent render
_ENT_RENDER:
        lda #$00
        sta ent_y_sort_pos
	lda #$10
        sta ent_oam_offset
.ent_render_loop
	lda ent_y_sort_pos
        tay
        lda ent_y_sort,y
        bmi ent_render_next
        tay
        lda ent_ram_offset_table,y
        sta ent_ram_offset
        tay
        lda ent_type,y
        tax
        lda ent_render_lo,x
        sta temp00
        lda ent_render_hi,x
        sta temp01
        ldx ent_ram_offset
        ldy ent_oam_offset
        jmp (temp00)
ent_render_next:
	ldx ent_ram_offset
        lda ent_type,x
        tax
        lda ent_size,x
        clc
        adc ent_oam_offset
        sta ent_oam_offset
        inc ent_y_sort_pos
        lda ent_y_sort_pos
        cmp #$10
        bne .ent_render_loop
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
