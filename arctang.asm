; quadrants
; 
;  0 | 1
;  --+--
;  2 | 3

; 24 angular regions total (0-23)
; 6 regions per quadrant
;  direction  
; 12 o'clock  6
;  3 o'clock  0
;  6 o'clock  18
;  9 o'clock  12

enemy_get_direction_of_player:
; references these zp vars
;	collision_0_x	= position
;	collision_0_y
;;;	collision_1_x	= target
;;;	collision_1_y
;	player_x_hi
;	player_y_hi
; uses these zp vars
;	collision_0_w	= x delta
;	collision_0_h	= y delta
;	collision_1_x	= "small"
;	collision_1_y	= "large"
;	collision_1_h	= "half"
;	temp00 		= quadrant
;	temp01 		= region
;	temp02		= x register stash
;	temp03		= y register stash
; returns a = direction (or region)
	stx temp02
        sty temp03
	; find quadrant
        lda #0
        sta temp00
; y quadrants
        lda player_y_hi
        sec
        sbc collision_0_y
        bcc .top_quadrant
.bottom_quadrant
        inc temp00
        inc temp00
        jmp .y_quadrant_done
.top_quadrant
	lda collision_0_y
        sec
        sbc player_y_hi
.y_quadrant_done
        sta collision_0_h
        tay
; x quadrants
        lda player_x_hi
        sec
        sbc collision_0_x
        bcc .left_quadrant
.right_quadrant
        inc temp00
        jmp .x_quadrant_done
.left_quadrant
	lda collision_0_x
        sec
        sbc player_x_hi
.x_quadrant_done
        sta collision_0_w
        tax
	; quadrant is now in temp00
   	; start finding that region
        cpx collision_0_h
        bcs .x_greater_or_equal_y
.x_less_than_y
	lda #16
        sta temp01
        stx collision_1_x
        sty collision_1_y
        bne .determine_region
.x_greater_or_equal_y
	lda #0
        sta temp01
        stx collision_1_y
        sty collision_1_x
.determine_region
	lda collision_1_x
        lsr
        sta collision_1_h
        lda collision_1_x
        asl
        bcs .q_smaller
        clc
        adc collision_1_h
        bcs .q_smaller
        cmp collision_1_y
        bcc .q_larger
.q_smaller ; S * 2.5 > L
	lsr collision_1_h
        lda collision_1_x
        clc
        adc collision_1_h
        cmp collision_1_y
        bcc .region1
        bcs .region0
.q_larger ; S * 2.5 < L
        lda collision_1_x
        asl
        asl
        asl
        bcs .region2
        sec
        sbc collision_1_h
        cmp collision_1_y
        bcc .region3
        jmp .region2
.region0  ; L / S < 1.25	; d = 3,9,15,21
	lda temp01
        clc
	bmi .result_lookup
.region1  ; 1.25 < L / S < 2.5	; d = 2,4,8,10,14,16,20,22
	lda temp01
        clc 
        adc #4
        bpl .result_lookup
.region2  ; 2.5 < L / S < 7.5	; d = 1,5,7,11,13,17,19,23
	lda temp01
        clc
        adc #8
        bpl .result_lookup
.region3 ; 7.5 < L / S		; d = 0,6,12,18
	lda temp01
        clc
        adc #12
.result_lookup
	; temp01 should be ready in the accumulator
        adc temp00
        tax
        lda ARCTANG_TRANSLATION_LOOKUP_TABLE,x
        ; restore enemy_ram_offset
	ldx temp02
        ldy temp03
        rts

        
        
   
arctang_bound_dir: subroutine
	; a = value to be bounded
        ; returns value 0..23 in a
        bpl .check_above_24
.below_0
	clc
        adc #24
        rts
.check_above_24
	cmp #24
        bcc .bounded
        sec
        sbc #24
.bounded
	rts

        


; arctang movement is 16-bit
; oam ram x,y = high byte
; enemy ram x,y = low byte

arctang_update_x: subroutine
        ; temp00 = hi
        ; temp01 = lo
        ; temp02 = region
        ldx temp02
        lda ARCTANG_REGION_TO_X_VELOCITY_TABLE,x
        asl
        tay
        lda ARCTANG_REGION_X_PLUS_OR_MINUS_TABLE,x
        bpl arctang_16bit_maths
        
arctang_update_y: subroutine
        ; temp00 = hi
        ; temp01 = lo
        ; temp02 = region
        ldx temp02
        lda ARCTANG_REGION_TO_Y_VELOCITY_TABLE,x
        asl
        tay
        lda ARCTANG_REGION_Y_PLUS_OR_MINUS_TABLE,x
        bpl arctang_16bit_maths
        
arctang_16bit_maths: subroutine
	; a = plus or minus
        ; y = velocity table offset
        bne .velocity_add
.velocity_sub
	; lo byte
	lda temp01
        sec 
        sbc (arctang_velocity_lo),y
        sta temp01
        ; hi byte
	lda temp00
        iny
        sbc (arctang_velocity_lo),y
        sta temp00
        jmp .done
.velocity_add
	; lo byte
        lda temp01
        clc
        adc (arctang_velocity_lo),y
        sta temp01
        ; hi byte
	lda temp00
        iny
        adc (arctang_velocity_lo),y
        sta temp00
.done
	rts
        

        

arctang_ent_update:
	; updates both x and y position given:
        ;	- enemy_ram_ex holds region/direction
        ;	- enemy_ram_x/y holds lo bytes
        ;	- oam_ram_x/y holds hi bytes

        ; set region for arctang
        lda ent_mx,x
        sta temp02 ; region
        
        ; set x byte for arctang
        lda ent_x,y 
        sta temp00 ; hi byte
	lda ent_x,x 
        sta temp01 ; lo byte
        jsr arctang_update_x
        ldy ent_oam_offset
        lda temp00
        sta oam_ram_x,y
	ldx ent_ram_offset
        lda temp01
        sta ent_x,x
        
        ; set y byte for arctang
        lda oam_ram_y,y 
        sta temp00 ; hi byte
	lda ent_y,x 
        sta temp01 ; lo byte
        jsr arctang_update_y
        ldy ent_oam_offset
        lda temp00
        jsr ent_fix_y_visible
        sta oam_ram_y,y
	ldx ent_ram_offset
        lda temp01
        sta ent_y,x
        
        rts




        
        
;  0 = right
;  6 = up
; 12 = left
; 18 = down

ARCTANG_TRANSLATION_LOOKUP_TABLE:
	byte  9, 3,15,21
	byte 10, 2,14,22
	byte 11, 1,13,23
	byte 12, 0,12, 0
	byte  9, 3,15,21
	byte  8, 4,16,20
	byte  7, 5,17,19
	byte  6, 6,18,18
        
        
;     reduce cycle counts by keeping these
;     tables on the same page
ARCTANG_REGION_TO_X_VELOCITY_TABLE:
	byte 0, 1, 2, 3, 4, 5
        byte 6, 5, 4, 3, 2, 1
	byte 0, 1, 2, 3, 4, 5
        byte 6, 5, 4, 3, 2, 1
ARCTANG_REGION_TO_Y_VELOCITY_TABLE:
        byte 6, 5, 4, 3, 2, 1
	byte 0, 1, 2, 3, 4, 5
        byte 6, 5, 4, 3, 2, 1
	byte 0, 1, 2, 3, 4, 5
ARCTANG_REGION_X_PLUS_OR_MINUS_TABLE:
	; 1 = plus
        ; 0 = minus
        byte 1, 1, 1, 1, 1, 1
        byte 0, 0, 0, 0, 0, 0
        byte 0, 0, 0, 0, 0, 0
        byte 1, 1, 1, 1, 1, 1
ARCTANG_REGION_Y_PLUS_OR_MINUS_TABLE:
	; 1 = plus
        ; 0 = minus
        byte 0, 0, 0, 0, 0, 0
        byte 0, 0, 0, 0, 0, 0
        byte 1, 1, 1, 1, 1, 1
        byte 1, 1, 1, 1, 1, 1


arctang_velocity_tables:
	; region id	angle degrees
        ; 	0	0
        ; 	1 	15
        ; 	2	30
        ; 	3	45
        ; 	4	60
        ; 	5	75
        ; 	6	90
arctang_velocity_6.66:
	byte 168, 6
        byte 109, 6
        byte 193, 5
        byte 119, 4
        byte  84, 3
        byte 183, 1
        byte   0, 0
arctang_velocity_4.5:
	byte 127, 4
        byte  88, 4
        byte 229, 3
        byte  46, 3
        byte  64, 2
        byte  42, 1
        byte   0, 0
arctang_velocity_3.33:
	byte  85, 3
        byte  56, 3
        byte 227, 2
        byte  91, 2
        byte 171, 1
        byte 221, 0
        byte   0, 0
arctang_velocity_2.5:
	byte 127, 2
        byte 104, 2
        byte  43, 2
        byte 197, 1
        byte  64, 1
        byte 166, 0
        byte   0, 0
arctang_velocity_1.75:
	byte 191, 1
        byte 176, 1
        byte 131, 1
        byte  61, 1
        byte 223, 0
        byte 115, 0
        byte   0, 0
arctang_velocity_1.25:
	byte  64, 1
	byte  53, 1
        byte  20, 1
        byte 225, 0
        byte 161, 0
        byte  81, 0
        byte   0, 0
arctang_velocity_0.75:
	byte 191, 0
        byte 184, 0
        byte 166, 0
        byte 135, 0
        byte  96, 0
        byte  49, 0
        byte   0, 0
arctang_velocity_0.33:
	byte  84, 0
        byte  81, 0
        byte  73, 0
        byte  59, 0
        byte  42, 0
        byte  22, 0
        byte   0, 0
arctang_velocities_lo:
	byte #<arctang_velocity_6.66
	byte #<arctang_velocity_4.5
	byte #<arctang_velocity_3.33
	byte #<arctang_velocity_2.5
	byte #<arctang_velocity_1.75
	byte #<arctang_velocity_1.25
	byte #<arctang_velocity_0.75
	byte #<arctang_velocity_0.33

