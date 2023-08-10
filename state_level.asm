
state_level_init: subroutine
        
; SPRITE 0 SETUP
	lda #$21
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
        lda #CTRL_INC_32	; 23
        sta PPU_CTRL		; 27
        lda map_ppu_hi		; 30
        sta PPU_ADDR		; 34
        lda map_ppu_lo		; 37
        sta PPU_ADDR		; 41
        PPU_POPSLIDE 24  ; 8 cycles each
        ; 8 * 24 = 192		; 233 cycles
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
        ldx temp02		; 88wrong
        txs			; 90wrong
	rts
        
        
        
state_level_update: subroutine
	jsr state_level_ents_update
	jsr state_level_hud_update
        jsr state_level_cam_update
	jsr state_level_plot_update
	rts
