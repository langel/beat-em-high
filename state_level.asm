
state_level_init: subroutine
        
; SPRITE 0 SETUP
	lda #$29
        sta oam_ram_y
	lda #$ce
        sta oam_ram_spr
        lda #$20
        sta oam_ram_att
        lda #$f0
        sta oam_ram_x
        jsr state_level_ents_init
        jsr state_level_hud_init
        jsr state_level_plot_nametable1    
	rts



state_level_render: subroutine
        tsx			; 14
        stx temp02		; 17
        ldx #$ff		; 19
        txs			; 21
        ; tile column from cache
        lda #CTRL_INC_32
        sta PPU_CTRL
        lda map_ppu_hi
        sta PPU_ADDR
        lda map_ppu_lo
        sta PPU_ADDR
        PPU_POPSLIDE 24  ; 8 cycles each
        ; attr column from cache
        tsx
        stx temp03
        lda #0
        sta PPU_CTRL
        lda map_ppu_hi
        ora #$03
        sta map_ppu_hi
        pla
        sta map_ppu_lo
        PPU_ATTRSLIDE 7
   	; reload stack pointer
        ldx temp02		; 88
        txs			; 90
	rts
        
        
        
state_level_update: subroutine

	jsr state_level_ents_update
        
; SCROOOLLLLL
	; scroll_dir = amount to increase scroll_x
        ; positive number goes right
        ; negative number goes left
	lda scroll_dir
        lda #$01
        lda wtf
        and #$01
        beq .scroll_update_done
        inc scroll_x
        lda scroll_x
        ; cmp #$ff ; for right-to-left
        bne .scroll_update_done
        inc scroll_ms
        lda scroll_ms
        and #$03
        sta scroll_ms
.scroll_update_done

	jsr state_level_plot_update
        
	rts
