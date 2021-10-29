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

include	'io.asm'

stacktop:	equ	0	; end of RAM + 1

	org		0x0000			; Cold reset Z80 entry point.

	;###################################################
	; NOTE THAT THE SRAM IS NOT READABLE AT THIS POINT
	;###################################################

	; Select SRAM low bank 0, idle the SD card, and idle printer signals
	ld	a,gpio_out_sd_mosi|gpio_out_sd_ssel|gpio_out_prn_stb
	out	(gpio_out),a

	; Copy the FLASH into the SRAM by reading every byte and 
	; writing it back into the same address.
	ld	hl,0
	ld	de,0
	ld	bc,_end
	ldir					; Copy all the code in the FLASH into RAM at same address.

	; Disable the FLASH and run from SRAM only from this point on.
	in	a,(flash_disable)	; Dummy-read this port to disable the FLASH.

	;###################################################
	; STARTING HERE, WE ARE RUNNING FROM RAM
	;###################################################

	ld		sp,stacktop

	; Idle the control signals that could matter, select RAM bank 0,
	; and toggle the SD card select line to flash the LED.

	; Also toggle the printer STROBE to see that it is working.

	; Use B as a counter to see printer data lines changing in a recognizable way.
	ld		b,0

loop:
	ld		a,gpio_out_sd_mosi
	out		(gpio_out),a			; turn the LED on

	; send the counter value to the printer's data port
	ld		a,b
	out		(prn_dat),a
	inc		b

	call	delay

	ld		a,gpio_out_sd_mosi|gpio_out_sd_ssel|gpio_out_prn_stb
	out		(gpio_out),a			; turn the LED off

	; count on the printer in double-time
	ld		a,b
	out		(prn_dat),a
	inc		b

	call	delay

	jp		loop



;##############################################################################
; Waste some time & return 
;##############################################################################
delay:
	ld		hl,0x4000			; blonk faster so printer counter doesn't take so long
dloop:
	dec		hl
	ld		a,h
	or		l
	jp		nz,dloop
	ret


;##############################################################################
; This marks the end of the data that must be copied from FLASH into RAM
;##############################################################################
_end:		equ	$

