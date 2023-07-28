
ftm_row		= $fe
ftm_temp	= $ff

ftm_frame: subroutine
        
        inc ftm_temp
        lda ftm_temp
        cmp #$02
        bne .done
        lda #$00
        sta ftm_temp
        
        
        ldy ftm_row
        lda ftm_pattern,y
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
        and #$3f
        sta ftm_row
        
.done
	rts