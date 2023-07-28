
ftm_temp	= $ff

ftm_frame: subroutine
	lda wtf
        bne .done
        
        ldy ftm_temp

	lda #%00001111			;stop DPCM
	sta APU_CHAN_CTRL

        lda ftm_dpcm_addr,y
	sta APU_DMC_ADDR
	lda ftm_dpcm_len,y		;sample length
	sta APU_DMC_LEN
	lda #$0f			;pitch and loop
	sta APU_DMC_CTRL

	lda #32					;reset DAC counter
	sta APU_DMC_WRITE
	lda #%00011111			;start DMC
	sta APU_CHAN_CTRL
        
        inc ftm_temp
        lda ftm_temp
        cmp #$05
        bne .done
        lda #$00
        sta ftm_temp
        
.done
	rts