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

; Blink the SD card select LED.
; This copies itself from the FLASH into the SRAM and then
; runs from there.


include 'io.asm'

stacktop:   equ 0   ; end of RAM + 1

    org     0x0000          ; Cold reset Z80 entry point.

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
    ldir                    ; Copy all the code in the FLASH into RAM at same address.

    ; Disable the FLASH and run from SRAM only from this point on.
    in  a,(flash_disable)   ; Dummy-read this port to disable the FLASH.

    ;###################################################
    ; STARTING HERE, WE ARE RUNNING FROM RAM
    ;###################################################

    ld      sp,stacktop

    ; Idle the control signals that could matter, select RAM bank 0,
    ; and toggle the SD card select line to flash the LED.
loop:
    ld      a,gpio_out_sd_mosi|gpio_out_prn_stb
    out     (gpio_out),a            ; turn the LED on

    call    delay

    ld      a,gpio_out_sd_mosi|gpio_out_sd_ssel|gpio_out_prn_stb
    out     (gpio_out),a            ; turn the LED off

    call    delay

    jp      loop



;##############################################################################
; Waste some time & return 
;##############################################################################
delay:
    ld      hl,0x8000
dloop:
    dec     hl
    ld      a,h
    or      l
    jp      nz,dloop
    ret




;##############################################################################
; This marks the end of the data that must be copied from FLASH into RAM
;##############################################################################
_end:       equ $

