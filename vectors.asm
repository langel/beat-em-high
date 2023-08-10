
cart_start: subroutine
	NES_INIT	; set up stack pointer, turn off PPU
        jsr wait_sync	; wait for VSYNC
        jsr clear_ram	; clear RAM

; reset PPU address and scroll registers
        lda #0
        sta PPU_SCROLL
        sta PPU_SCROLL  ; PPU scroll = $0000
	jsr SetPalette	; set palette colors
        jsr sprites_clear
        
; seed rng
	lda #$01
        sta rng0
        sta rng1
        
; reset unrom bank
	BANK_CHANGE 1
        
; graphx to chr ram
	lda #<tiles_addr
        sta temp00
        lda #>tiles_addr
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
	jsr render_enable_all
        
        
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
        
        jsr state_level_render
        
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
        lda scroll_ms
        and #$01
        ora #CTRL_NMI|#CTRL_SPR_1000
        sta PPU_CTRL
        


	BANK_CHANGE 2
        jsr ftm_frame
        
        BANK_CHANGE 0
        jsr state_level_update


	
        
        
        lda rng0
        jsr rng_next
        sta rng0
        lda rng1
        jsr rng_prev
        sta rng1
        inc wtf
        dec nmi_lockout
nmi_end:
	RESTORE_REGS
	rti
