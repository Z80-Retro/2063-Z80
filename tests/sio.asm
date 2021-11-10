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


; Test proggie for the SIO 


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

	call	sioa_init
	call	siob_init

	call	helloa
;	call	spew_loop
;	call	echo_loop
	call	relay

halt_loop:
	halt
	jp		halt_loop

;##############################################################
; Print 'Hello' on SIO_A
;##############################################################
helloa:
	ld		b,'H'
	call	sioa_tx_char
	ld		b,'e'
	call	sioa_tx_char
	ld		b,'l'
	call	sioa_tx_char
	call	sioa_tx_char
	ld		b,'o'
	call	sioa_tx_char
	ld		b,'\r'
	call	sioa_tx_char
	ld		b,'\n'
	call	sioa_tx_char
	ret



;##############################################################
; Print all printable characters in an endless loop on SIO A
;##############################################################
spew_loop:
	ld		b,0x20		; ascii space character
spew_loop1:
	call	sioa_tx_char
	inc		b
	ld		a,0x7f		; last graphic character + 1
	cp		b
	jp		nz,spew_loop1
	jp		spew_loop


;##############################################################
; Echo characters from SIO back after adding one.
;##############################################################
echo_loop:
	call	sioa_rx_char	; get a character from the SIO
	ld		b,a
	inc		b				; add 1 (A becomes B, ...)
	call	sioa_tx_char	; print the character
	jp		echo_loop




;##############################################################
; Read from A and send to B and at the same time, 
; read from B and send to A.
;##############################################################
relay:
	call	sioa_rx_ready
	jp		z,relay_b		; not ready? skip tx
	call	sioa_rx_char
	ld		b,a
	call	siob_tx_char

relay_b:
	call	siob_rx_ready
	jp		z,relay			; not ready? skip tx
	call	siob_rx_char
	ld		b,a
	call	sioa_tx_char

	jp		relay


;##############################################################
; Return NZ if sio A rx is ready
;##############################################################
sioa_tx_ready:
    in  	a,(sio_ac)	; read sio control status byte
    and		4			; check the xmtr empty bit
	ret					; a = 0 = not ready

;##############################################################
; Return NZ if sio B rx is ready
;##############################################################
siob_tx_ready:
    in  	a,(sio_bc)	; read sio control status byte
    and		4			; check the xmtr empty bit
	ret					; a = 0 = not ready

;##############################################################
; Return NZ if sio A rx is ready
;##############################################################
sioa_rx_ready:
    in  	a,(sio_ac)	; read sio control status byte
    and 	1			; check the rcvr ready bit
	ret					; 0 = not ready

;##############################################################
; Return NZ if sio B tx is ready
;##############################################################
siob_rx_ready:
    in  	a,(sio_bc)	; read sio control status byte
    and 	1			; check the rcvr ready bit
	ret					; 0 = not ready



if 0
;##############################################################
;##############################################################
;##############################################################
;##############################################################


;##############################################################
; Init SIO port A
; Clobbers HL, BC, AF
;##############################################################
sioa_init:
	ld	hl,sioa_init_wr		; point to init string
	ld	b,sioa_init_len_wr	; number of bytes to send
	ld	c,sio_ac			; port to write into (port A control)
	otir					; write B bytes from (HL) into port in the C reg
	ret

;##############################################################
; Initialization string for the Z80 SIO
;##############################################################
sioa_init_wr:
	db		11011000b	; wr0 = reset everything
    db		00000100b   ; wr0 = select reg 4
    db		01000100b   ; wr4 = /16 N1 (115200 from 1.8432 MHZ clk)
    db		00000011b   ; wr0 = select reg 3
    db		11100001b   ; wr3 = RX enable, 8 bits/char
    db		00000101b   ; wr0 = select reg 5
    db		11101000b   ; wr5 = DTR=1, TX enable, 8 bits/char
sioa_init_len_wr:   equ $-sioa_init_wr



;##############################################################
; Wait for the transmitter to become ready and then
; print the character in the C register.
; Clobbers: AF
;##############################################################
sioa_tx_char:
    in  	a,(sio_ac)	; read sio control status byte
    and		4			; check the xmtr empty bit
    jr  	z,sioa_tx_char	; if is busy, wait

	ld		a,c
    out		(sio_ad),a	; send the char
    ret

;##############################################################
; Wait for the receiver to become ready and then return the 
; character in the A register.
; Clobbers: AF
;##############################################################
sioa_rx_char:
    in  a,(sio_ac)	; read sio control status byte
    and 1			; check the rcvr ready bit
    jr  z,sioa_rx_char

    in  a,(sio_ad)	; read the char
    ret

endif

;##############################################################
;##############################################################
;##############################################################
;##############################################################

;##############################################################
; init SIO port A/B
; Clobbers HL, BC, AF
;##############################################################
siob_init:
	ld	c,sio_bc			; port to write into (port B control)
	jp	sio_init

sioa_init:
	ld	c,sio_ac			; port to write into (port A control)

sio_init:
	ld	hl,sio_init_wr		; point to init string
	ld	b,sio_init_len_wr	; number of bytes to send
	otir					; write B bytes from (HL) into port in the C reg
	ret

;##############################################################
; Initialization string for the Z80 SIO
;##############################################################
sio_init_wr:
	db		11011000b	; wr0 = reset everything
    db		00000100b   ; wr0 = select reg 4
    db		01000100b   ; wr4 = /16 N1 (115200 from 1.8432 MHZ clk)
    db		00000011b   ; wr0 = select reg 3
    db		11100001b   ; wr3 = RX enable, 8 bits/char
    db		00000101b   ; wr0 = select reg 5
    db		11101000b   ; wr5 = DTR=1, TX enable, 8 bits/char
sio_init_len_wr:   equ $-sio_init_wr



;##############################################################
; Wait for the transmitter to become ready and then
; print the character in the B register.
; Clobbers: AF C
;##############################################################
siob_tx_char:
	ld		c,sio_bc
	jp		sio_tx_char

sioa_tx_char:
	ld		c,sio_ac

sio_tx_char:
    in  	a,(c)			; read sio control status byte
    and		4				; check the xmtr empty bit
    jr  	z,sio_tx_char	; if is busy, wait

	dec		c
	dec		c				; c = data register
    out		(c),b			; send the char
    ret

;##############################################################
; Wait for the receiver to become ready and then return the 
; character in the A register.
; Clobbers: AF C
;##############################################################
siob_rx_char:
	ld		c,sio_bc
	jp		sio_rx_char

sioa_rx_char:
	ld		c,sio_ac

sio_rx_char:
    in  	a,(c)			; read sio control status byte
    and 	1				; check the rcvr ready bit
    jr		z,sio_rx_char	; if rx not ready, wait

	dec		c
	dec		c				; c = data register
    in  	a,(c)			; read the char	
    ret


_end:
