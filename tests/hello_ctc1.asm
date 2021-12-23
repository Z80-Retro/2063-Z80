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
; SIO runs in polled mode.
; Use J11-A to select between 115200 and 19200.

include 'io.asm'

stacktop:   equ 0   ; end of RAM + 1

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

    ; initialize the CTC to provide an alternate bit-rate for SIOA
    ld      c,6             ; divide the bit-rate clock by 12 (19200 bps)
;   ld      c,12            ; divide the bit-rate clock by 12 (9600 bps)
;   ld      c,96            ; divide the bit-rate clock by 96 (1200 bps)
    call    init_ctc_1

    call    sioa_init

    ; skip a line
    ld      b,'\r'          
    call    sioa_tx_char
    ld      b,'\n'
    call    sioa_tx_char

    ; Dump the memory containing this code
    ld      hl,0            ; start address
    ld      bc,_end         ; how many bytes to print
    ld      e,1             ; fancy format
    call    hexdump

    ; fall through to a loop that echos characters on the terminal


;##############################################################
; Echo characters from SIO back to the SIO
;##############################################################
echo_loop:
    call    sioa_rx_char    ; get a character from the SIO
    ld      b,a
;   inc     b               ; add 1 (A becomes B, ...)
    call    sioa_tx_char    ; print the character
    jp      echo_loop



;#############################################################################
; Init the bit-rate generator for SIO A.
; C = clock divisor
;#############################################################################
init_ctc_1:
    ld      a,0x57      ; TC follows, Rising, Counter, Control, Reset
    out     (ctc_1),a
    ld      a,c
    out     (ctc_1),a
    ret


include 'sio.asm'
include 'hexdump.asm'


_end:
