
ftm_order	= $fd
ftm_row		= $fe
ftm_temp	= $ff

ftm_frame: subroutine
        
        inc ftm_temp
        lda ftm_temp
        cmp #$02
        beq .continue
        rts
.continue
        lda #$00
        sta ftm_temp
        
        lda ftm_order
        sta $f7
        sta temp00
        lda #$05
        sta temp01
        jsr shift_add_mult
        lda temp00
        sta $f6 ; order offset
        
        ; TRIANGLE
        lda $f6
        clc
        adc #$02
        tay
        lda ftm_track_0_order,y
        sta $e0
        tay
        lda ftm_track_0_chan_2_patterns_lo,y
        sta $f8
        lda ftm_track_0_chan_2_patterns_hi,y
        sta $f9
        ldy ftm_row
        lda ($f8),y
        sta $e1
        cmp #$ff
        beq .triangle_done
        cmp #$fe
        bne .triangle_not_note_cut
        lda #$00
        sta $4008
        lda #%00000100
        jsr ftm_channel_disable
        jmp .triangle_done
.triangle_not_note_cut
        lda #%00000100
        jsr ftm_channel_enable
        lda #$7f
        sta $4008
        lda $e1
	tax
        lda apu_period_lo,x
        sta $400a
        lda apu_period_hi,x
        ora #%11111000
        sta $400b
.triangle_done

        ; DPCM
        lda $f6
        clc
        adc #$04
        tay
        lda ftm_track_0_order,y
        tay
        lda ftm_track_0_chan_4_patterns_lo,y
        sta $f8
        lda ftm_track_0_chan_4_patterns_hi,y
        sta $f9
        ldy ftm_row
        lda ($f8),y
        cmp #$ff
        beq .dpcm_done
        tay
	lda APU_CHAN_CTRL
	and #%00001111			;stop DPCM
	sta APU_CHAN_CTRL
	lda ftm_dpcm_samp_table,y
        tax
        lda ftm_dpcm_addr,x
        sta $f0
	sta APU_DMC_ADDR
	lda ftm_dpcm_len,x		;sample length
        sta $f1
	sta APU_DMC_LEN
	lda ftm_dpcm_freq_table,y	;pitch and loop
        sta $f2
        sty $f3
        ;lda #$0f
	sta APU_DMC_CTRL
	lda #32					;reset DAC counter
	sta APU_DMC_WRITE
        lda APU_CHAN_CTRL
	ora #%00010000			;start DMC
	sta APU_CHAN_CTRL
.dpcm_done 

        inc ftm_row
        lda ftm_row
        cmp #$3f
        bne .done
.pattern_done
	lda #$00
        sta ftm_row
        inc ftm_order
        lda ftm_order
        cmp #$0c
        bne .done
.song_loop
	lda #$00
        sta ftm_order
        
.done
	rts
        
        
ftm_channel_disable: subroutine
	; a = bit value of channel
        ; #%00000001 sqaure 1
        ; #%00000010 sqaure 2
        ; #%00000100 triangle
        ; #%00001000 noise
        ; #%00010000 dpcm
	eor #$FF
	and APU_CHAN_CTRL
	sta APU_CHAN_CTRL
	rts

ftm_channel_enable: subroutine
	; a = bit value of channel
	ora APU_CHAN_CTRL
	sta APU_CHAN_CTRL
        rts
        ; XXX do we need to restart oscillators
        ;     by writing to freq high
;	lda #$FF
;	cpx #$00
;	beq :+
;	cpx #$01
;	beq :++
;	rts
;:	sta var_ch_PrevFreqHigh
;	rts
;:	sta var_ch_PrevFreqHigh + 1
;	rts


apu_period_lo:
 ;     A   A#  B   C   C#  D   D#  E   F   F#  G   G#
 byte $f1,$7f,$13,$ad,$4d,$f3,$9d,$4c,$00,$b8,$74,$34 ; 12
 byte $f8,$bf,$89,$56,$26,$f9,$ce,$a6,$80,$5c,$3a,$1a ; 24
 byte $fb,$df,$c4,$ab,$93,$7c,$67,$52,$3f,$2d,$1c,$0c ; 36
 byte $fd,$ef,$e1,$d5,$c9,$bd,$b3,$a9,$9f,$96,$8e,$86 ; 48
 byte $7e,$77,$70,$6a,$64,$5e,$59,$54,$4f,$4b,$46,$42 ; 60
 byte $3f,$3b,$38,$34,$31,$2f,$2c,$29,$27,$25,$23,$21 ; 72
 byte $1f,$1d,$1b,$1a,$18,$17,$15,$14
apu_period_hi:
 byte $07,$07,$07,$06,$06,$05,$05,$05,$05,$04,$04,$04
 byte $03,$03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$02
 byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
 byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 byte $00,$00,$00,$00,$00,$00,$00,$00
 
 
apu_set_pitch: subroutine
	; x = pitch table offset
        ; y = channel low byte offset
        lda apu_period_lo,x
;        sta apu_cache+0,y
        lda apu_period_hi,x
        ora #%11111000
;        sta apu_cache+1,y
        rts