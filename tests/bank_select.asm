;****************************************************************************
;
;    Copyright (C) 2021 John Winans
;
;    This library is free software; you can redistribute it and/or
;    modify it under the terms of the GNU Lesser General Public
;    License as published by the Free Software Foundation; either
;    version 2.1 of the License, or (at your option) any later version.
;
;    This library is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;    Lesser General Public License for more details.
;
;    You should have received a copy of the GNU Lesser General Public
;    License along with this library; if not, write to the Free Software
;    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301
;    USA
;
;****************************************************************************

; A test proggie to test the bank select logic & SRAM 

include 'io.asm'

stacktop:	equ	0	; end of RAM + 1

	jp		_start
	ds		0x8000-$,0xff	; push the remaining code into the high-bank

    ;###################################################
    ; NOTE THAT THE SRAM IS NOT READABLE AT THIS POINT
    ;###################################################
_start:
    ; Select SRAM low bank 0, idle the SD card, and idle printer signals
    ld  	a,gpio_out_sd_mosi|gpio_out_sd_ssel|gpio_out_sd_clk|gpio_out_prn_stb
    out 	(gpio_out),a

    ; Copy the FLASH into the SRAM by reading every byte and 
    ; writing it back into the same address.
    ld  	hl,0
    ld  	de,0
    ld  	bc,_end
    ldir

    ; Disable the FLASH and run from SRAM only from this point on.
    in  a,(flash_disable)   ; Dummy-read this port to disable the FLASH.

    ;###################################################
    ; STARTING HERE, WE ARE RUNNING FROM RAM
    ;###################################################

    ld      sp,stacktop

	; padd the stack with some recognizable data
	ld		hl,0xff00
	ld		(hl),0xaa
	ld		de,0xff01
	ld		bc,0xff
	ldir

	call	sioa_init
	ld		hl,startup_msg
	call	puts


	ld		c,0x00
	call	select_bank
	call	fill_lo_bank

	ld		c,0x10
	call	select_bank
	call	fill_lo_bank

	ld		c,0x20
	call	select_bank
	call	fill_lo_bank

	ld		c,0xe0
	call	select_bank
	call	fill_lo_bank

	ld		c,0x00
	call	dump_bank		; should still be 0x00 
	ld		c,0x10
	call	dump_bank		; should still be 0x10
	ld		c,0x20
	call	dump_bank		; should still be 0x20
	ld		c,0x30
	call	dump_bank		; should be garbage
	ld		c,0xe0
	call	dump_bank		; should be the executable code
	ld		c,0xf0
	call	dump_bank		; should be garbage followed by the stack data


halt_loop:
	halt
	jp		halt_loop


startup_msg:
	db		"\r\n\nlo-bank test.\r\n\0"

dots:
	db		"..."		; make sure this runs into the crlf below!
crlf:
	db		"\r\n\0"

bank_msg:
	db		"\r\nbank \0"


;#############################################################################
; Dump the bank in the C register
;#############################################################################
dump_bank:
	push	af
	push	hl
	push	bc
	call	select_bank

	ld		hl,bank_msg
	call	puts
	ld		a,c
	call	hexdump_a
	ld		hl,crlf
	call	puts

	ld		hl,0
	ld		bc,0x20
	ld		e,1
	call	hexdump
	ld		hl,dots
	call	puts
	ld		hl,0x7fe0
	ld		bc,0x20
	ld		e,1
	call	hexdump
	pop		bc
	pop		hl
	pop		af
	ret

;#############################################################################
; FIll the low bank of RAM with the value in C
; Clobbers nothing
;#############################################################################
fill_lo_bank:
	push	hl
	push	de
	push	bc
	ld		hl,0
	ld		(hl),c
	ld		de,1
	ld		bc,0x7fff
	ldir
	pop		bc
	pop		de
	pop		hl
	ret

;#############################################################################
; Select the LO memory bank given by the value in C (must be 0x00, 0x10..0xf0)
; Clobbers nothing
;#############################################################################
select_bank:
	push	af
	ld		a,(gpio_out_cache)
	and		0x0f
	or		c
	ld		(gpio_out_cache),a
	out		(gpio_out),a
	pop		af
	ret

;#############################################################################
; Write bytes from memory at address in HL to the console until we reach 
; a null character.
; Clobbers nothing
;#############################################################################
puts:
	push	af
	push	bc
	push	hl
puts_loop:
	ld		a,(hl)
	or		a		
	jp		z,puts_done
	ld		b,a
	call	sioa_tx_char
	inc		hl
	jp		puts_loop
puts_done:
	pop		hl
	pop		bc
	pop		af
	ret

include 'sio.asm'
include 'hexdump.asm'

;#############################################################################
; A copy of the state of the GPIO output port
;#############################################################################
gpio_out_cache:
	db	gpio_out_sd_mosi|gpio_out_sd_ssel|gpio_out_sd_clk|gpio_out_prn_stb

_end:
