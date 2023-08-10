

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

ent_y_sort	= $0400

; XXX need a bubble sort sprite priority

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
        lda #$48
        sta ent_x+$10
        sta ent_r0+$10
        lda #$a8
        sta ent_y+$10
        sta ent_r1+$10
	rts


state_level_ents_update: subroutine        
        ; ent update
        lda #$00
        sta ent_ram_offset
        lda #$10
        sta ent_oam_offset
.ent_update_loop
	ldy ent_ram_offset
        lda ent_type,y
        bmi ent_update_next
        tax
        lda state_level_ent_update_lo,x
        sta temp00
        lda state_level_ent_update_hi,x
        sta temp01
        jmp (temp00)
ent_update_next:
	lda #$10
        clc
        adc ent_ram_offset
        sta ent_ram_offset
        bne .ent_update_loop
        ; ent y sort
        lda #$00
        sta ent_y_sort_pos
.ent_y_sort_loop
        ; ent render
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
        asl
        asl
        asl
        asl
        sta ent_ram_offset
        tay
        lda ent_type,y
        sta $03e8
        tax
        lda state_level_ent_render_lo,x
        sta temp00
        sta $03ea
        lda state_level_ent_render_hi,x
        sta temp01
        sta $03eb
        ldx ent_ram_offset
        ldy ent_oam_offset
        jmp (temp00)
ent_render_next:
	ldx ent_ram_offset
        lda ent_type,x
        tax
        lda state_level_ent_size,x
        clc
        adc ent_oam_offset
        sta ent_oam_offset
        inc ent_y_sort_pos
        lda ent_y_sort_pos
        cmp #$10
        bne .ent_render_loop
	rts
        
        
state_level_ent_size:
	; number of sprites * 4
	byte 24,16
state_level_ent_update_lo:
	byte #<ent_player_update
        byte #<ent_krok_update
state_level_ent_update_hi:
	byte #>ent_player_update
        byte #>ent_krok_update
state_level_ent_render_lo:
	byte #<ent_player_render
        byte #<ent_krok_render
state_level_ent_render_hi:
	byte #>ent_player_render
        byte #>ent_krok_render
