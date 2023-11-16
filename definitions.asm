
	processor 6502

;;;;; CONSTANTS

PPU_CTRL	= $2000
PPU_MASK	= $2001
PPU_STATUS	= $2002
OAM_ADDR	= $2003
OAM_DATA	= $2004
PPU_SCROLL	= $2005
PPU_ADDR	= $2006
PPU_DATA	= $2007

PPU_OAM_DMA	= $4014
DMC_FREQ	= $4010
APU_STATUS	= $4015
APU_NOISE_VOL   = $400C
APU_NOISE_FREQ  = $400E
APU_NOISE_TIMER = $400F
APU_DMC_CTRL    = $4010
APU_DMC_WRITE	= $4011
APU_DMC_ADDR    = $4012
APU_DMC_LEN  	= $4013
APU_CHAN_CTRL   = $4015
APU_FRAME       = $4017

JOYPAD1		= $4016
JOYPAD2		= $4017

; NOTE: I've put this outside of the PPU & APU, because it is a feature
; of the APU that is primarily of use to the PPU.
OAM_DMA         = $4014
; OAM local RAM copy goes from $0200-$02FF:
OAM_RAM         = $0200

; PPU_CTRL flags
CTRL_NMI	EQM %10000000	; Execute Non-Maskable Interrupt on VBlank
CTRL_8x8	EQM %00000000 	; Use 8x8 Sprites
CTRL_8x16	EQM %00100000 	; Use 8x16 Sprites
CTRL_BG_0000	EQM %00000000 	; Background Pattern Table at $0000 in VRAM
CTRL_BG_1000	EQM %00010000 	; Background Pattern Table at $1000 in VRAM
CTRL_SPR_0000	EQM %00000000 	; Sprite Pattern Table at $0000 in VRAM
CTRL_SPR_1000	EQM %00001000 	; Sprite Pattern Table at $1000 in VRAM
CTRL_INC_1	EQM %00000000 	; Increment PPU Address by 1 (Horizontal rendering)
CTRL_INC_32	EQM %00000100 	; Increment PPU Address by 32 (Vertical rendering)
CTRL_NT_2000	EQM %00000000 	; Name Table Address at $2000
CTRL_NT_2400	EQM %00000001 	; Name Table Address at $2400
CTRL_NT_2800	EQM %00000010 	; Name Table Address at $2800
CTRL_NT_2C00	EQM %00000011 	; Name Table Address at $2C00

; PPU_MASK flags
MASK_TINT_RED	EQM %00100000	; Red Background
MASK_TINT_BLUE	EQM %01000000	; Blue Background
MASK_TINT_GREEN	EQM %10000000	; Green Background
MASK_SPR	EQM %00010000 	; Sprites Visible
MASK_BG		EQM %00001000 	; Backgrounds Visible
MASK_SPR_CLIP	EQM %00000100 	; Sprites clipped on left column
MASK_BG_CLIP	EQM %00000010 	; Background clipped on left column
MASK_COLOR	EQM %00000000 	; Display in Color
MASK_MONO	EQM %00000001 	; Display in Monochrome

; read flags
F_BLANK		EQM %10000000 	; VBlank Active
F_SPRITE0	EQM %01000000 	; VBlank hit Sprite 0
F_SCAN8		EQM %00100000 	; More than 8 sprites on current scanline
F_WIGNORE	EQM %00010000 	; VRAM Writes currently ignored.

;;;;; CARTRIDGE FILE HEADER

NES_MIRR_HORIZ	EQM 0
NES_MIRR_VERT	EQM 1
NES_MIRR_QUAD	EQM 8

	MAC NES_HEADER
	seg Header
	org $7ff0
.NES_MAPPER	SET {1}	;mapper number
.NES_PRG_BANKS	SET {2}	;number of 16K PRG banks, change to 2 for NROM256
.NES_CHR_BANKS	SET {3}	;number of 8K CHR banks (0 = RAM)
.NES_MIRRORING	SET {4}	;0 horizontal, 1 vertical, 8 four screen
	byte $4e,$45,$53,$1a ; header
	byte .NES_PRG_BANKS
	byte .NES_CHR_BANKS
	byte .NES_MIRRORING|(.NES_MAPPER<<4)
	byte .NES_MAPPER&$f0
	byte 0,0,0,0,0,0,0,0 ; reserved, set to zero
	seg Code
	org $8000
	ENDM

;;;;; NES_INIT SETUP MACRO (place at start)
        
        MAC NES_INIT
        sei			;disable IRQs
        cld			;decimal mode not supported
        ldx #$ff
        txs			;set up stack pointer
        inx			;increment X to 0
        stx PPU_MASK		;disable rendering
        stx DMC_FREQ		;disable DMC interrupts
        stx PPU_CTRL		;disable NMI interrupts
	bit PPU_STATUS		;clear VBL flag
        bit APU_CHAN_CTRL	;ack DMC IRQ bit 7
	lda #$40
	sta APU_FRAME		;disable APU Frame IRQ
	lda #$0F
	sta APU_CHAN_CTRL	;disable DMC, enable/init other channels.        
        ENDM

;;;;; NES_VECTORS - CPU vectors at end of address space

	MAC NES_VECTORS
	seg Vectors		; segment "Vectors"
	org $fffa		; start at address $fffa
       	.word NMIHandler	; $fffa vblank nmi
	.word Start		; $fffc reset
	.word NMIHandler	; $fffe irq / brk
	ENDM

;;;;; PPU_SETADDR <address> - set 16-bit PPU address

	MAC PPU_SETADDR
        lda #>{1}	; upper byte
        sta PPU_ADDR
        lda #<{1}	; lower byte
        sta PPU_ADDR
        ENDM

;;;;; PPU_SETVALUE <value> - feed 8-bit value to PPU
        
        MAC PPU_SETVALUE
        lda #{1}
        sta PPU_DATA
        ENDM
        
;;;;; BANK_CHANGE <bank id> - UNROM specific

	MAC BANK_CHANGE
        lda #{1}
        sta $8000
        ENDM

;;;;; PPU_POPSLIDE <count>
	MAC PPU_POPSLIDE
.COUNT	SET {1}
	REPEAT .COUNT
        pla
        sta PPU_DATA
        REPEND
        ENDM
        
;;;;; PPU_ATTRSLIDE <count>
	MAC PPU_ATTRSLIDE
.COUNT	SET {1}
	REPEAT .COUNT
        lda map_ppu_hi
        sta PPU_ADDR
        lda map_ppu_lo
        clc
        adc #$08
        sta map_ppu_lo
        sta PPU_ADDR
        pla
        sta PPU_DATA
        REPEND
        ENDM
        
;;;;;; RNG0_NEXT
        MAC RNG0_NEXT
        lda rng0
        jsr rng_next
        sta rng0
        ENDM
        
;;;;; SAVE_REGS - save A/X/Y registers

        MAC SAVE_REGS
        pha
        txa
        pha
        tya
        pha
        ENDM

;;;;; RESTORE_REGS - restore Y/X/A registers

        MAC RESTORE_REGS
        pla
        tay
        pla
        tax
        pla
        ENDM

;-------------------------------------------------------------------------------
; SLEEP clockcycles
; Original author: Thomas Jentzsch
; Inserts code which takes the specified number of cycles to execute.  This is
; useful for code where precise timing is required.
; LEGAL OPCODE VERSION MAY AFFECT FLAGS (uses 'bit' opcode)

NO_ILLEGAL_OPCODES EQM 1

            MAC SLEEP            ;usage: SLEEP n (n>1)
.CYCLES     SET {1}

                IF .CYCLES < 2
                    ECHO "MACRO ERROR: 'SLEEP': Duration must be > 1"
                    ERR
                ENDIF

                IF .CYCLES & 1
                    IFNCONST NO_ILLEGAL_OPCODES
                        nop 0
                    ELSE
                        bit $00
                    ENDIF
.CYCLES             SET .CYCLES - 3
                ENDIF
            
                REPEAT .CYCLES / 2
                    nop
                REPEND
            ENDM
