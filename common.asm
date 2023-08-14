;;;;; SUBROUTINES

clear_ram: subroutine
	lda #0		; A = 0
        tax		; X = 0
.loop
	sta $0,x	; clear $0-$ff
        cpx #$fe	; last 2 bytes of stack?
        bcs .skip_stack	; don't clear it
	sta $100,x	; clear $100-$1fd
.skip_stack
	sta $200,x	; clear $200-$2ff
	sta $300,x	; clear $300-$3ff
	sta $400,x	; clear $400-$4ff
	sta $500,x	; clear $500-$5ff
	sta $600,x	; clear $600-$6ff
	sta $700,x	; clear $700-$7ff
        inx		; X = X + 1
        bne .loop	; loop 256 times
        rts

; wait for VSYNC to start
wait_sync:
	bit PPU_STATUS
	bpl wait_sync
        rts

;;;;; RANDOM NUMBERS

rng_next: subroutine
	lsr
        bcc .no_eor
        eor #$d4
.no_eor
	rts
        
rng_prev: subroutine
	asl
        bcc .no_eor
        eor #$a9
.no_eor
        rts
        
        
; disable PPU drawing and NMI
render_enable_all:
	lda #MASK_BG|MASK_SPR|MASK_SPR_CLIP|MASK_BG_CLIP
        sta PPU_MASK	; enable rendering
        lda #CTRL_NMI|#CTRL_SPR_1000
        sta PPU_CTRL	; enable NMI
	rts
        
render_enable_bg:
	lda #MASK_BG|MASK_SPR_CLIP|MASK_BG_CLIP
        sta PPU_MASK	; enable rendering
        lda #CTRL_NMI|#CTRL_SPR_1000
        sta PPU_CTRL	; enable NMI
	rts
        
render_disable:
	lda #$00
        sta PPU_MASK	
	rts


shift_multiply: subroutine
        ; shift + add multiplication
        ; temp00, temp01 in = factors
        ; returns little endian 16bit val
        ;         at temp01, temp00
        lda #$00
        ldx #$08
        lsr temp00
.loop
	bcc .no_add
        clc
        adc temp01
.no_add
	ror
        ror temp00
        dex
        bne .loop
        sta temp01
        rts        
        
shift_divide: subroutine
	; shift + add division
        ; temp00 = dividend
        ; temp01 = divisor
        ; ...or is it the other way around? xD
        ; returns quotient in a and temp00
        ldx #$08
        dec temp00
.loop
	lsr temp01
        bcc .no_add
        adc temp00
.no_add
	ror
        dex
        bne .loop
        sta temp00
        rts
        
        

distance: subroutine
; from https://forums.parallax.com/discussion/147522/dog-leg-hypotenuse-approximation
; hi = max( a, b )
; lo = min( a, b )
; hypot ~= hi + lo/2
; 
; but johnybot on nesdev discord said:
; hi + (lo >> 2) + (lo >> 4) + (lo >> 6) 
; seems like a much better approximation for 8 bit ASM
        rts
        
        
shift_percent: subroutine
	; a = 8bit base value
        ; x = 8bit percentage
        sta temp00
        txa
        eor #$ff
        sta temp01
        lda #$00
        lsr temp00
        asl temp01
        bcs .not_7
        adc temp00
.not_7
        lsr temp00
        asl temp01
        bcs .not_6
        adc temp00
.not_6
        lsr temp00
        asl temp01
        bcs .not_5
        adc temp00
.not_5
        lsr temp00
        asl temp01
        bcs .not_4
        adc temp00
.not_4
        lsr temp00
        asl temp01
        bcs .not_3
        adc temp00
.not_3
        lsr temp00
        asl temp01
        bcs .not_2
        adc temp00
.not_2
        lsr temp00
        asl temp01
        bcs .not_1
        adc temp00
.not_1
	rts

        
        
        
;;;;; CONTROLLER READING

BUTTON_A      	EQM 1 << 7
BUTTON_B   	EQM 1 << 6
BUTTON_SELECT 	EQM 1 << 5
BUTTON_START  	EQM 1 << 4
BUTTON_UP     	EQM 1 << 3
BUTTON_DOWN   	EQM 1 << 2
BUTTON_LEFT   	EQM 1 << 1
BUTTON_RIGHT  	EQM 1 << 0

controller_poller: subroutine
	ldx #$01
        stx JOYPAD1
        dex
        stx JOYPAD1
        ldx #$08
.read_loop
	lda JOYPAD1
        lsr
        rol temp00
        lsr
        rol temp01
        dex
        bne .read_loop
        lda temp00
        ora temp01
        sta temp00
        rts
        
controller_read: subroutine
	jsr controller_poller
.checksum_loop
        ldy temp00
        jsr controller_poller
        cpy temp00
        bne .checksum_loop
        lda temp00
        tay
        eor controls
        and temp00
        sta controls_debounced
        sty controls
        rts

  
        
; set palette colors
SetPalette: subroutine
; set PPU address to palette start
	PPU_SETADDR $3f00
        ldy #0
.loop:
	lda Palette,y	; lookup byte in ROM
	sta PPU_DATA	; store byte to PPU data
        iny		; Y = Y + 1
        cpy #32		; is Y equal to 32?
	bne .loop	; not yet, loop
        rts		; return to caller
        
;;;;; CONSTANT DATA

Palette:
        
	hex 0f3d2d30 
        hex 0f3d2c20 
        hex 0f3d1627 
        hex 0f3d1939  
        ; binny
        hex 0f072437
        ; pando
        hex 0f0c2130
        ; other
        hex 0f081a39
        hex 0f041536 
        
	hex 0f002630
	hex 0f2d2630
	hex 0f2d2630
	hex 0f220430


sine_table:
	hex 808386898c8f9295
	hex 989b9ea2a5a7aaad
	hex b0b3b6b9bcbec1c4
	hex c6c9cbced0d3d5d7
	hex dadcdee0e2e4e6e8
	hex eaebedeef0f1f3f4
	hex f5f6f8f9fafafbfc
	hex fdfdfefefeffffff
	hex fffffffffefefefd
	hex fdfcfbfafaf9f8f6
	hex f5f4f3f1f0eeedeb
	hex eae8e6e4e2e0dedc
	hex dad7d5d3d0cecbc9
	hex c6c4c1bebcb9b6b3
	hex b0adaaa7a5a29e9b
	hex 9895928f8c898683
	hex 807c797673706d6a
	hex 6764615d5a585552
	hex 4f4c494643413e3b
	hex 393634312f2c2a28
	hex 2523211f1d1b1917
	hex 151412110f0e0c0b
	hex 0a09070605050403
	hex 0202010101000000
	hex 0000000001010102
	hex 0203040505060709
	hex 0a0b0c0e0f111214
	hex 1517191b1d1f2123
	hex 25282a2c2f313436
	hex 393b3e414346494c
	hex 4f5255585a5d6164
	hex 676a6d707376797c