ppu_popslide	= $0100

; state00 = scroll_x
; state01 = scroll_y


state_level_00_palettes:
	hex 0f3d2d30 
        hex 0f3d2c20 
        hex 0f3d1627 
        hex 0f3d1939  
        ; binny
        hex 0f072437
        ; pando
        hex 0f0c2130
        ; other
        hex 0f041536 ; pink krok
        hex 0f081a38 ; yellow krok
        hex 0f0f391a ; green krok
        hex 0f0a391a ; all green krok
        
        
state_level_00_load_palettes: subroutine
	PPU_SETADDR $3f00
        ldy #0
.palette_loop
	lda state_level_00_palettes,y
	sta PPU_DATA
        iny		
        cpy #32		
	bne .palette_loop
        rts
        

state_level_init: subroutine
        ; set state
        lda #state_level_update_id
        sta state_update_id
        lda #state_level_render_id
        sta state_render_id
        lda #state_level_sprite_0_id
        sta state_sprit0_id
        jsr render_disable
        
        lda #$20
        ldx #text_space_pattern_id
        jsr clear_nametable
        lda #$24
        ldx #text_space_pattern_id
        jsr clear_nametable
        lda #$23
        ldx #$00
        jsr clear_attributes
        jsr clear_sprites
        
        jsr state_level_00_load_palettes
        
        lda #$00
        sta state00
        sta state01
        
; grafx to chr ram
	BANK_CHANGE 1
	lda #<tiles_addr
        sta temp00
        lda #>tiles_addr
        sta temp01
        lda #$00
        sta PPU_ADDR
        sta PPU_ADDR
        ldx #$20
        ldy #$00
.grafx_load_loop
	lda (temp00),y
        sta PPU_DATA
        iny
        bne .grafx_load_loop
        inc temp01
	dex
        bne .grafx_load_loop
        
; SPRITE 0 SETUP
	lda #$21
        sta oam_ram_y
	lda #$ce
        sta oam_ram_spr
        lda #$20
        sta oam_ram_att
        lda #$f0
        sta oam_ram_x

	jsr ents_system_init
        jsr state_level_hud_init
        jsr state_level_plot_nametable1    
        jsr render_enable
        
        
	lda #ent_pando_id
        jsr ents_system_spawn
        lda #$a0
        sta ent_hp
	lda #ent_binny_id
        jsr ents_system_spawn
        lda #$10
        sta ent_hp+16
        lda #ent_krok_id 
        jsr ents_system_spawn
        lda #ent_krok_id 
        jsr ents_system_spawn
        lda #ent_krok_id 
        jsr ents_system_spawn
        lda #ent_krok_id 
        jsr ents_system_spawn
        
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
	jmp state_render_done
        
        
state_level_sprite_0: subroutine
        lda scroll_ms
        and #$01
        ora #CTRL_NMI|#CTRL_SPR_1000
        sta PPU_CTRL
        
        bit PPU_STATUS
        lda state00
        sta PPU_SCROLL
        lda state01
        sta PPU_SCROLL  ; PPU scroll = $0000
        rts
        
        
        
state_level_update: subroutine
	jsr ents_system_update
	jsr state_level_hud_update
        jsr state_level_cam_update
	jsr state_level_plot_update
	rts
