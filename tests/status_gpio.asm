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

; Test the GP input port

include 'io.asm'

stacktop:   equ 0   ; end of RAM + 1

    ;###################################################
    ; NOTE THAT THE SRAM IS NOT READABLE AT THIS POINT
    ;###################################################

    ; Select SRAM low bank 0, idle the SD card, and idle printer signals
    ld  a,(gpio_out_cache)
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

    call    sioa_init

    ld      hl,start_msg
    call    puts
    
stat_loop:
    ld      hl,status_msg
    call    puts
    in      a,(gpio_in)
    call    hexdump_a
    jp      stat_loop

    ; we never reach here


start_msg:
    db      "\r\nGP input status tester\r\n\n\0"

status_msg:
    db      "\rGPIN: \0"


include 'puts.asm'
include 'sio.asm'
include 'hexdump.asm'

;#############################################################################
; A copy of the state of the GPIO output port
;#############################################################################
gpio_out_cache:
    db  gpio_out_sd_mosi|gpio_out_sd_ssel|gpio_out_sd_clk|gpio_out_prn_stb

_end:
