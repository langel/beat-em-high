
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
	BANK_CHANGE 1
        
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
        
        jsr state_level_init
        
        
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
        inc scroll_x
        lda scroll_x
        ; cmp #$ff ; for right-to-left
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
        clc
        adc #$06
        asl
        ldy #$10
        jsr sprite_6_set_sprite
        lda #$00
        jsr sprite_6_set_attr
        lda #$33
        jsr sprite_6_set_x
        lda #$b0
        jsr sprite_6_set_y
        
ponda_walk: subroutine
	lda wtf
        and #$07
        bne .not_next
        inc ponda_cycle
.not_next
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
        lda #$48
        jsr sprite_6_set_x
        lda #$a8
        jsr sprite_6_set_y
        
        
        inc wtf
        dec nmi_lockout
nmi_end:
	RESTORE_REGS
	rti
