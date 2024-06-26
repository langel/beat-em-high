;;;;; SUBROUTINES

clear_nametable: subroutine
	; a = high address
        ; x = fill pattern id
        sta PPU_ADDR
        lda #$00
        sta PPU_ADDR
        txa
        ldx #$04
        ldy #$00
.inner
	sta PPU_DATA
        iny
        bne .inner
.outer
	inc temp01
        dex
        bne .inner
	rts
        
clear_attributes: subroutine
	; a = high address
        ; x = fill attribute value
        sta PPU_ADDR
        lda #$c0
        sta PPU_ADDR
        txa
        ldy #$c0
.loop
	sta PPU_DATA
        iny
        bne .loop
	rts
        

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
        
        
clear_sprites: subroutine
	lda #$ff
        ldx #$00
.loop
	sta $0200,x
        inx
        bne .loop
        rts
        
        
;;;; COLLISION DETECTOR
;	
;	works by putting object data into the following 0 page variables
;
;	collision_0_x	byte
;	collision_0_y	byte
;	collision_0_w	byte
;	collision_0_h	byte
;	collision_1_x	byte
;	collision_1_y	byte
;	collision_1_w	byte
;	collision_1_h	byte
;
;	returns ff (true) or 00 (false) in accumulator
; the detect_collision subroutine was moved to player_bullets.asm
; saving over 12 cycles per usage

collision_detect: subroutine
	clc
        lda collision_0_x
        adc collision_0_w
        bcs .no_collision ; make sure x+w is not less than x
        cmp collision_1_x
        bcc .no_collision
        clc
        lda collision_1_x
        adc collision_1_w
        cmp collision_0_x
        bcc .no_collision
        clc
        lda collision_0_y
        adc collision_0_h
        cmp collision_1_y
        bcc .no_collision
        clc 
        lda collision_1_y
        adc collision_1_h
        cmp collision_0_y
        bcc .no_collision
.collision
	lda #$ff
        rts
.no_collision
	lda #$00
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
render_enable:
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
        
        
shift_percent: subroutine
	; a = 8bit base value
        ; x = 8bit percentage
        ; returns result in a
        sta temp00
        txa
        eor #$ff
        sta temp01
        lda #$00	; 12 cycles
        lsr temp00
        asl temp01
        bcs .not_7
        adc temp00
.not_7			; +15 per bit
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
        lsr temp00
        asl temp01
        bcs .not_0
        adc temp00
.not_0			; 15 * 7 + 12
	rts		; +6 = 123 cycles

        
        
        
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

  
        

        
;;;;; CONSTANT DATA


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
        
 
 
text_space_pattern_id EQM $fa

text_000:	; langel iloveui miau  present
 hex e5dae7e0dee5fae2e5e8efdeeee2fae6e2daeefafae9ebdeecdee7ed00
text_001:	; NesDEV COMPO 2023 Teaser
 hex e7deecdddeeffadce8e6e9e8fad2d0d2d3faeddedaecdeeb00
text_002:	; Binny, the Krok Gang
 hex dbe2e7e7f2f7faede1defae4ebe8e4fae0dae7e000
text_003:	; stole all our best
 hex ecede8e5defadae5e5fae8eeebfadbdeeced00
text_004:	; ice cream again!
 hex e2dcdefadcebdedae6fadae0dae2e7f400
text_005:	; Oh no, Pando!
 hex e8e1fae7e8f7fae9dae7dde8f400
text_006:	; Pesky dingles,
 hex e9deece4f2fadde2e7e0e5deecf700
text_007:	; They never learn!
 hex ede1def2fae7deefdeebfae5dedaebe7f400
text_008:	; Lets
 hex e5deedec00
text_009:	; KICK
 hex e4e2dce400
text_00a:	; KROK
 hex e4ebe8e400
text_00b:	; #@0!
 hex f8f9d0f400
text_00c:	;   where is ice cream?  
 hex fafaf0e1deebdefae2ecfae2dcdefadcebdedae6f5fafa00
text_00d:	;    you have murdered   
 hex fafafaf2e8eefae1daefdefae6eeebdddeebdeddfafafa00
text_00e:	;     all my children    
 hex fafafafadae5e5fae6f2fadce1e2e5ddebdee7fafafafa00
text_00f:	;   no general hospital  
 hex fafae7e8fae0dee7deebdae5fae1e8ece9e2eddae5fafa00
text_010:	;  the days of our lives 
 hex faede1defadddaf2ecfae8dffae8eeebfae5e2efdeecfa00
text_011:	;    now is my duty to   
 hex fafafae7e8f0fae2ecfae6f2faddeeedf2faede8fafafa00
text_012:	;   murder the universe  
 hex fafae6eeebdddeebfaede1defaeee7e2efdeebecdefafa00