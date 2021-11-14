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

; Test proggie for the CTC w/support for the SIO.
; CTC runs with IRQs to implement an uptime timer.

include 'io.asm'

stacktop:	equ	0	; end of RAM + 1

    ;###################################################
    ; NOTE THAT THE SRAM IS NOT READABLE AT THIS POINT
    ;###################################################

    ; Select SRAM low bank 0, idle the SD card, and idle printer signals
    ld  a,gpio_out_sd_mosi|gpio_out_sd_ssel|gpio_out_prn_stb
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

	; set mode 2 interrupts & load the vector table address into I
	im		2
	ld		a,vectab/256	; A = MSB of the vectab address
	ld		i,a	

	call	init_ctc_irq
	call	init_ctc_3

	ld		c,12			; divide the bit-rate clock by 12 (9600 bps)
;	ld		c,96			; divide the bit-rate clock by 96 (1200 bps)
	call	init_ctc_1

	call	sioa_init

	ei

	ld		hl,0		; start address
	ld		bc,_end		; how many bytes to print
	ld		e,1			; fancy format
	call	hexdump


loop:
	halt

if 1
	; print on modulo N of the uptime
	ld		hl,(uptime)
	ld		a,l
	and		0x3f
	jp		nz,loop
endif

	ld		hl,uptime	; start address
	ld		bc,0x0004	; how many bytes to print
	ld		e,0			; do not fancy format
	call	hexdump

	jp		loop


include 'ctc.asm'
include 'sio.asm'
include 'hexdump.asm'

;#############################################################################
;#############################################################################
; The mode 2 IRQ vector table 
; The table must start at an even address since CTC vector is always even.
; It /can/ be different than a 256-byte boundary...
;	but the vector offsets are more obvious when it is.

	ds		0x100-($&0xff)	; align to a 256-byte boundary
vectab:
vectab_ctc:		; vectab_ctc-vectab MUST be a multiple of 8 due to CTC requirements
    dw      irq_ctc_0
    dw      irq_ctc_1
    dw      irq_ctc_2
    dw      irq_ctc_3


_end:
