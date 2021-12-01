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

; Driver for the printer port 

;#############################################################################
; BUG: Aughtta tweak the values in the SIO that control INIT & LF signals.
;       This will foolishly assume that the 'default' state of them is OK.
; Clobbers AF
;#############################################################################
lpt_init:
    ld      a,(gpio_out_cache)
    or      gpio_out_prn_stb
    ld      (gpio_out_cache),a
    out     (gpio_out),a
    ret

;#############################################################################
; Return A=0 if the printer is ready
; Clobbers AF
;#############################################################################
lpt_ready:
    in      a,(gpio_in)
    and     gpio_in_prn_bsy     ; if this bit is low then it is ready
    ret

;#############################################################################
; Wait for the printer to become ready and send the character in C. 
; Clobbers AF
;#############################################################################
lpt_tx:
    call    lpt_ready
    jr      nz,lpt_tx

    ld      a,c
    out     (prn_dat),a             ; put the character code into the output latch

    ; assert the strobe signal
    ld      a,(gpio_out_cache)
    and     ~gpio_out_prn_stb       ; set the strobe signal low
    out     (gpio_out),a

    ; A brief delay so that strobe signal can be seen by the printer.
    ld      a,0x10
lpt_stb_wait:
    dec     a
    jr      nz,lpt_stb_wait

    ; raise the strobe signal
    ld      a,(gpio_out_cache)
    out     (gpio_out),a
    ret

