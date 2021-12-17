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
; To initialize the printer:
; - set the printer PRN_STROBE signal high
; - set the PRN_INIT signal high
; - set the PRN_LF signal high
;
; BUG: Aughtta tweak the values in the SIO that control INIT & LF signals.
;       This will foolishly assume that the 'default' state of them is OK.
;
; Clobbers AF
;#############################################################################
lpt_init:
    ld      a,(gpio_out_cache)
    or      gpio_out_prn_stb    ; make sure that the printer STB signal is high
    ld      (gpio_out_cache),a
    out     (gpio_out),a
    ret

;#############################################################################
; Return A=0 and set the Z flag if the printer is ready
; Clobbers AF
;#############################################################################
lpt_ready:
    in      a,(gpio_in)
    and     gpio_in_prn_bsy         ; if this bit is low then it is ready
    ret

;#############################################################################
; Wait for the printer to become ready and send the character in C. 
; Clobbers AF
;#############################################################################
lpt_tx:
    call    lpt_ready               ; is the printer ready?
    jr      nz,lpt_tx               ; No? Loop until it is.

    ld      a,c                     ; A = character to be printed
    out     (prn_dat),a             ; put the character code into the output latch

    ; assert the strobe signal
    ld      a,(gpio_out_cache)      ; get the global saved state of the GP Output latch
    and     ~gpio_out_prn_stb       ; set the strobe signal low
    out     (gpio_out),a            ; output the new value on the port (note not saving into cache!)

    ; A brief delay so that strobe signal can be seen by the printer.
    ld      a,0x10                  ; count to 0x10 to waste a little time
lpt_stb_wait:
    dec     a
    jr      nz,lpt_stb_wait

    ; raise the strobe signal
    ld      a,(gpio_out_cache)      ; set the GP Output latch value...
    out     (gpio_out),a            ;               ...back to what it was

    ret

