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

; A test proggie that writes a string out the printer port.

include 'io.asm'

stacktop:	equ	0	; end of RAM + 1

    ;###################################################
    ; NOTE THAT THE SRAM IS NOT READABLE AT THIS POINT
    ;###################################################

    ; Select SRAM low bank 0, idle the SD card, and idle printer signals
    ld  a,gpio_out_sd_mosi|gpio_out_sd_ssel|gpio_out_sd_clk|gpio_out_prn_stb
    out (gpio_out),a

    ; Copy the FLASH into the SRAM by reading every byte and 
    ; writing it back into the same address.
    ld  hl,0
    ld  de,0
    ld  bc,_end
    ldir

    ; Disable the FLASH and run from SRAM only from this point on.
    in  a,(flash_disable)   ; Dummy-read this port to disable the FLASH.

    ;###################################################
    ; STARTING HERE, WE ARE RUNNING FROM RAM
    ;###################################################

    ld      sp,stacktop

	call	sioa_init
	call	lpt_init

	ld		hl,msg
	ld		bc,msg_len
	call	print_str

halt_loop:
	halt
	jp		halt_loop

msg:
	db		"Hello from the printer!\r\n"
	db		"This is a test to make sure that the newline works in a sane manner.\r\n"
msg_len: equ $-msg

;#############################################################################
; Write BC bytes from memory at address in HL
;#############################################################################
print_str:
	push	bc
	ld		c,(hl)
	call	lpt_tx
	inc		hl
	pop		bc
	dec		bc
	ld		a,b
	or		c
	jr		nz,print_str
	ret


include 'lpt.asm'
include 'sio.asm'
include 'hexdump.asm'

;#############################################################################
; A copy of the state of the GPIO output port
;#############################################################################
gpio_out_cache:
	db	gpio_out_sd_mosi|gpio_out_sd_ssel|gpio_out_sd_clk|gpio_out_prn_stb

_end:
