
ftm_order	= $fd
ftm_row		= $fe
ftm_temp	= $ff

ftm_frame: subroutine
        
        inc ftm_temp
        lda ftm_temp
        cmp #$02
        bne .done
        lda #$00
        sta ftm_temp
        
        lda ftm_order
        sta temp00
        lda #$05
        sta temp01
        jsr shift_add_mult
        lda temp00
        sta $f6
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
        beq .row_done
        
        tay

	lda #%00001111			;stop DPCM
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
	lda #%00011111			;start DMC
	sta APU_CHAN_CTRL
        
.row_done   
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