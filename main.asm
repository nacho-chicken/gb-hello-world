INCLUDE "hardware.inc" ; Basic GB hardware-related variables
INCLUDE "macros.asm" ; My custom macros


SECTION "Entry Point", ROM0[$0100]

	nop ; nop is needed to keep ROM the correct size
	jp	Begin


SECTION "Header", ROM0[$104]

	HEADER "HELLOWORLD01234" ; Header must be 15 characters


SECTION "Main", ROM0[$150]

Begin:
	di ; Not using interrupts at all, might as well disable them

WaitForVBlank: ; Need to wait for VBlank period before messing with graphics
	ld	a, [rLY]
	cp	144
	jr	c, WaitForVBlank

Main:
	ld	a, 0
	ld	[rLCDC], a ; I couldn't be bothered timing cycles, so disabling the LCD is the safest way to load my tiles
	ld	a, %11100100 ; Set normal palette
	ld	[rBGP], a
	; Setting parameters for LoadTiles call
	ld	hl, _VRAM9000 ; Fonts are probably most useful in the BG layer
	ld	bc, FontMain
	ld	de, FontMain_END - FontMain
	call	LoadTiles

CleanTilemap:
	ld	hl, _SCRN0 ; Screen VRAM
	ld	bc, _SCRN1 - _SCRN0 ; All tiles
.loop: ; This is really quick and dirty, but I figured it was reasonable in a hello world
	ld	a, $00
	ld	[hli], a
	dec	bc
	ld	a, b
	or	c
	jr	nz, .loop

DrawText:
	ld	bc, HelloWorld
	ld	hl, _SCRN0 + $21
.loop:
	ld	a, [bc]
	cp	$FF ; Finish if 0xFF terminator is reached
	jp	nc, EnableLCD
	inc	bc
	ld	[hli], a
	jr	.loop

EnableLCD:
	ld	a, %10000001
	ld	[rLCDC], a

Done:
	nop
	jr	Done

HelloWorld: ; "Hello World!" in an 0xFF-terminated string
	db $28,$45,$4C,$4C,$4F,$00,$37,$4F,$52,$4C,$44,$01,$FF
; I couldn't be bothered right now to do a whole CHARMAP for two words lol


;	LoadTiles
; This function loads tiles into VRAM.
; Data in register A will be lost.
;
;	Parameters:
;	hl	- Location in VRAM
;	bc	- Location of tiles in ROM
;	de	- Amount of tiles to copy from ROM
LoadTiles:
	ld	a, [bc]
	ld	[hli], a
	inc	bc
	dec	de
	ld	a, d
	or	e
	jr	nz, LoadTiles
	ret


SECTION "Main Font", ROM0[$2000]

; My custom hand-drawn font.
; It's not optimized as it has a ton of useless characters,
; but "quick and dirty" is the name of the game in a first program
FontMain:
	INCBIN "commode32.2bpp"
FontMain_END:


; vim:ft=rgbds

