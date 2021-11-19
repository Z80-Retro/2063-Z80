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
; This runs entirely from the FLASH (does not use SRAM).

include 'io.asm'

    org     0x0000          ; Cold reset Z80 entry point.

    ; Idle the control signals that could matter, select RAM bank 0
    ; and toggle the SD card select line to flash the LED.

loop:
    ld      a,gpio_out_sd_mosi|gpio_out_prn_stb
    out     (gpio_out),a            ; turn the LED on
    ld      hl,0x0000
dly1:
    dec     hl
    ld      a,h
    or      l
    jp      nz,dly1

    ld      a,gpio_out_sd_mosi|gpio_out_sd_ssel|gpio_out_prn_stb
    out     (gpio_out),a            ; turn the LED off
    ld      hl,0x0000
dly2:
    dec     hl
    ld      a,h
    or      l
    jp      nz,dly2

    jp      loop
