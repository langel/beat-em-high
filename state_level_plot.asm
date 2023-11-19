
state_level_plot_nametable1: subroutine
; FILL NAMETABLES WITH MAP
	BANK_CHANGE 0
	lda #<map_0_tiles
        sta temp00
	lda #>map_0_tiles
        sta temp01
; nametable 1    
	lda #$04
        sta PPU_CTRL
        ldy #$00
        lda #$20
        sta temp02
.col_loop1
	lda #$20
        sta PPU_ADDR
        lda #$e0
        sec
        sbc temp02
        sta PPU_ADDR
	ldx #$18
.tile_loop1
        lda (temp00),y
        sta PPU_DATA
        inc temp00
        bne .tile1_nocarry
        inc temp01
.tile1_nocarry
        dex
        bne .tile_loop1
        dec temp02
        bne .col_loop1
; FILL NAMETABLE ATTRIBUTES
	ldy #$00
	sty PPU_CTRL
	; setup data pointer
	lda #<map_0_attributes
        sta temp00
	lda #>map_0_attributes
        sta temp01
        ; setup attr address
        lda #$00
        sta temp03 ; column counter
        ; loop columns
.attr_col_loop1
        lda #$08
        sta temp02 ; row counter
        ; loop columns attrs
        ldx #$07
.data_attr_loop1
	lda #$23
        sta PPU_ADDR
	lda temp02
        clc
        adc #$c0
        clc
        adc temp03
        sta PPU_ADDR
	lda (temp00),y
        sta PPU_DATA
        iny
        lda temp02
        clc
        adc #$08
        sta temp02
        dex
        bne .data_attr_loop1
	inc temp03
        lda temp03
        cmp #$08
        bne .attr_col_loop1
	rts
        
        
        
state_level_plot_nametable2: subroutine
; nametable 2
	lda #$04
        sta PPU_CTRL
        ldy #$00
        lda #$20
        sta temp02
.col_loop2
	lda #$24
        sta PPU_ADDR
        lda #$e0
        sec
        sbc temp02
        sta PPU_ADDR
	ldx #$18
.tile_loop2
        lda (temp00),y
        sta PPU_DATA
        inc temp00
        bne .tile2_nocarry
        inc temp01
.tile2_nocarry
        dex
        bne .tile_loop2
        dec temp02
        bne .col_loop2
	rts



state_level_plot_update: subroutine
	; setup for popslide
        ; $0100-$0117: tile column
        ; $0118: attr start addr
        ; $0119-$011f: attr column
	; find ppu tile column position
	ldx scroll_ms
        inx
        txa
        and #$01
        bne .nametable2
.nametable1
	lda #$20
        bne .nametable_done
.nametable2
	lda #$24
.nametable_done
        sta map_ppu_hi
        lda state00
        lsr
        lsr
        lsr
        clc
        adc #$c0
        sta map_ppu_lo
        ; find map data position
        lda state00
        lsr
        lsr
        lsr
        sta temp00
        ldx scroll_ms
        inx
        txa
        and #$03
        asl
        asl
        asl
        asl
        asl
        clc
        adc temp00
        ; setup multiplacation
        ; target column factor
        sta temp00
        ; maps are 24 tiles high factor
        lda #$18
        sta temp01
        jsr shift_multiply
        ; add map data address offset
        lda #>map_0_tiles
        clc
        adc temp01
        sta temp01
        ; pump the tiles for popslide
        ldx #$18
        ldy #$00
.tile_loop
	lda (temp00),y
        sta $0100,y
        iny
        dex
        bne .tile_loop
        
        ; attr column
        lda map_ppu_lo
        lsr
        lsr
        and #$07
        sta temp02 ; target column
        clc
        adc #$c0
        sta $0118 ; ppu attr addr
        ldx scroll_ms
        inx
        txa
        and #$03
        asl
        asl
        asl
        clc
        adc temp02 ; attr map addr column
        sta temp02
        asl
        asl
        asl
        sec
        sbc temp02 
        tax
        ldy #$00
.attr_loop
        lda map_0_attributes,x
        sta $0119,y
        inx
        iny
        cpy #$07
        bne .attr_loop
        
	rts
