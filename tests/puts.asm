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

;#############################################################################
; Write bytes from memory at address in HL to the console until we reach 
; a null character.
; Clobbers nothing
;#############################################################################
puts:
    push    af              ; save everything that we will alter
    push    bc
    push    hl

puts_loop:
    ld      a,(hl)          ; A = next byte to print
    or      a               ; is it zero?
    jp      z,puts_done     ; if so then we are done
    ld      b,a             ; else put it into B 
    call    sioa_tx_char    ;   ...so we can print it
    inc     hl              ; advance HL to point to the next character to print 
    jp      puts_loop       ; ...and go back to print some more

puts_done:
    pop     hl              ; restore what we had to save
    pop     bc
    pop     af
    ret
