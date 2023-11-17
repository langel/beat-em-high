
cart_start: subroutine
	NES_INIT	; set up stack pointer, turn off PPU
        jsr wait_sync	; wait for VSYNC
        jsr wait_sync	; do it twice to be sure
        jsr clear_ram	; clear RAM

; reset PPU address and scroll registers
        lda #0
        sta PPU_SCROLL
        sta PPU_SCROLL  ; PPU scroll = $0000
        jsr sprites_clear
        
; seed rng
	lda #$01
        sta rng0
        sta rng1
        
; reset unrom bank
        
        BANK_CHANGE 0
        jsr state_level_init
        ;jsr state_title_init
        ;jsr state_intro_init
        
        
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
        
        BANK_CHANGE 0
	; RENDER	va cycles
        lda state_render_id
        jmp jump_to_subroutine
state_render_done:
        
        bit PPU_STATUS
        lda #$00
        sta PPU_SCROLL
        sta PPU_SCROLL
        lda #CTRL_NMI|#CTRL_SPR_1000
        sta PPU_CTRL
	
        ; use HUD draW time for audio engine
	BANK_CHANGE 2
        jsr ftm_frame
        
        jsr controller_read
        
sprite0_wait:
	lda state_sprite_0
        beq sprite_0_off
        
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
sprite_0_off:
        

	BANK_CHANGE 0
; main state logic
	lda state_update_id
        jsr jsr_to_subroutine
state_update_done:

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
