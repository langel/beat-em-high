ppu_popslide	= $0100

state_level_init: subroutine
        ; set state
        lda #state_level_update_id
        sta state_update_id
        lda #state_level_render_id
        sta state_render_id
        
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
        ; map tile column from cache
        lda #CTRL_INC_32	; 23
        sta PPU_CTRL		; 27
        lda map_ppu_hi		; 30
        sta PPU_ADDR		; 34
        lda map_ppu_lo		; 37
        sta PPU_ADDR		; 41
        PPU_POPSLIDE 24  ; 8 * 24 = 192		
        ; 233 cycles for map tiles
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
        ; redraw player lifebars
        lda #CTRL_INC_1
        sta PPU_CTRL
        lda #hud_life_ppu_hi
        sta PPU_ADDR
        lda #hud_life_ppu_lo
        sta PPU_ADDR
        PPU_POPSLIDE 25
   	; reload stack pointer
        ldx temp02		; 88wrong
        txs			; 90wrong
        ;rts
	jmp state_render_done
        
        
        
state_level_update: subroutine
	jsr state_level_ents_update
	jsr state_level_hud_update
        jsr state_level_cam_update
	jsr state_level_plot_update
	rts
