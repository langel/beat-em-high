
cart_start: subroutine
	NES_INIT	; set up stack pointer, turn off PPU
        jsr wait_sync	; wait for VSYNC
        jsr ClearRAM	; clear RAM

; reset PPU address and scroll registers
        lda #0
        sta PPU_SCROLL
        sta PPU_SCROLL  ; PPU scroll = $0000
	jsr SetPalette	; set palette colors
        jsr sprites_clear
        
; reset unrom bank
	BANK_CHANGE 0
        
; graphx to chr ram
	lda #<graphics_addr
        sta temp00
        lda #>graphics_addr
        sta temp01
        lda #$00
        sta PPU_ADDR
        sta PPU_ADDR
        ldx #$20
        ldy #$00
.grafx_load_loop
	lda (temp00),y
        sta PPU_DATA
        iny
        bne .grafx_load_loop
        inc temp01
	dex
        bne .grafx_load_loop
        
; graphx on nametable
        lda #$97
        sta tile_empty
	PPU_SETADDR $2106
cut_scene_alien_main_draw: subroutine
        lda #$00
        sta temp00 ; pattern tile counter
        ldx #$0f
.alien_tile_loop
	ldy #$f
.alien_tile_row_loop
	lda temp00
	sta PPU_DATA
        inc temp00
	dey
        bpl .alien_tile_row_loop
        ; setup empty tile fill
        ldy #$0f
        lda tile_empty
.alien_row_filler_loop
	sta PPU_DATA
	dey
        bpl .alien_row_filler_loop
	dex
        bpl .alien_tile_loop
        
backfillbg: subroutine
        PPU_SETADDR $2400
        ldx #$00
        ldy #$04
.loop
	stx PPU_DATA
        inx
        bne .loop
        dey
        bne .loop
        
        jsr state_level_hud_init
        
; SPRITE 0 SETUP
	lda #$28
        sta $0200
	lda #$cf
        sta $0201
        lda #$20
        sta $0202
        lda #$f2
        sta $0203
        
        
; activate PPU graphics
        jsr wait_sync	; wait for VSYNC (and PPU warmup)
	jsr render_enable
        
        
.endless
	jmp .endless	; endless loop



;;;;; INTERRUPT HANDLERS

nmi_handler: subroutine
	SAVE_REGS
; enable NMI lockout
	lda nmi_lockout
        cmp #$00
        beq .no_lock
        jmp nmi_end
.no_lock
        inc nmi_lockout
        
	; OAM DMA	513 cycles
	lda #$02
        sta PPU_OAM_DMA
        
        bit PPU_STATUS
        lda #$00
        sta PPU_SCROLL
        sta PPU_SCROLL
        lda #CTRL_NMI|#CTRL_SPR_1000
        sta PPU_CTRL
        ; kill time to exit vblank
;        ldy #$00
.killy
;	dey
 ;       bne .killy
        
	; wait for Sprite 0; SPRITE 0 WAIT TIME!!!
.wait0	bit PPU_STATUS
        bvs .wait0
        lda #$c0
.wait1	bit PPU_STATUS
        beq .wait1
        
        
        bit PPU_STATUS
        lda scroll_x
        sta PPU_SCROLL
        lda scroll_y
        sta PPU_SCROLL  ; PPU scroll = $0000
        lda scroll_n
        and #$01
        ora #CTRL_NMI|#CTRL_SPR_1000
        sta PPU_CTRL
        
        
; SCROOOLLLLL
        dec scroll_x
        lda scroll_x
        cmp #$ff
        bne .same_nametable
        inc scroll_n
.same_nametable


	BANK_CHANGE 2
        jsr ftm_frame


binny_head:
        ldy #$28
        lda #$06
        jsr sprite_4_set_sprite
        lda #$00
        jsr sprite_4_set_attr
        lda #$10
        jsr sprite_4_set_x
        lda #$18
        jsr sprite_4_set_y
pando_head:
        ldy #$50
        lda #$66
        jsr sprite_4_set_sprite
        lda #$01
        jsr sprite_4_set_attr
        lda #$90
        jsr sprite_4_set_x
        lda #$18
        jsr sprite_4_set_y
	
        
        
        
binny_walk: subroutine
	lda wtf
        and #$07
        bne .not_next
        inc binny_cycle
.not_next
        lda binny_cycle
        and #$01
        asl
        ldy #$10
        jsr sprite_6_set_sprite
        lda #$40
        jsr sprite_6_set_attr
        lda #$a0
        jsr sprite_6_set_x_mirror
        lda #$80
        jsr sprite_6_set_y
        
ponda_walk: subroutine
	lda wtf
        and #$07
        bne .not_next
        inc ponda_cycle
.not_next
        lda ponda_cycle
        and #$01
        asl
        clc
        adc #$60
        ldy #$38
        jsr sprite_6_set_sprite
        lda #$41
        jsr sprite_6_set_attr
        lda #$b8
        jsr sprite_6_set_x_mirror
        lda #$78
        jsr sprite_6_set_y
        
        
        inc wtf
        dec nmi_lockout
nmi_end:
	RESTORE_REGS
	rti
