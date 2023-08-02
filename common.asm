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

NextRandom subroutine
	lsr
        bcc .NoEor
        eor #$d4
.NoEor:
	rts
; Get previous random value
PrevRandom subroutine
	asl
        bcc .NoEor
        eor #$a9
.NoEor:
        rts
        
        
; disable PPU drawing and NMI
render_enable:
	lda #MASK_BG|MASK_SPR|MASK_SPR_CLIP|MASK_BG_CLIP
        sta PPU_MASK	; enable rendering
        lda #CTRL_NMI|#CTRL_SPR_1000
        sta PPU_CTRL	; enable NMI
	rts
        
render_disable:
	lda #$00
        sta PPU_MASK	
	rts


shift_add_mult:
        ; shift + add multiplication
        ; temp00, temp01 in = factors
        ; temp01, temp00 out = 16bit address
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
        hex 0f1f2437
        hex 0f1f2130 
        
	hex 0f002630
	hex 0f2d2630
	hex 0f2d2630
	hex 0f220430
