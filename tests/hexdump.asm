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
; Dump BC bytes of memory from address in HL.
; if E is zero, no fancy formatting
; Does not clobber any registers
;#############################################################################
hexdump:
    push    af
    push    de
    push    hl
    push    bc
    jp      hexdump0

hexdump_loop:
    ld      a,e             ; fancy format or continuous?
    or      a
    jr      z,hd_not8       ; not fancy -> hd_not8

    ld      a,l
    and     0x0f
    jr      z,hexdump0n
    cp      0x08            ; put an extra space between positiioons 7 and 8
    jr      nz,hd_not8
    ld      b,' '
    call    sioa_tx_char
hd_not8:
    ld      b,' '
    call    sioa_tx_char
    jp      hexdump1

hexdump0n:
    call    hexdump_crlf
hexdump0:
    ld      a,h
    call    hexdump_a
    ld      a,l
    call    hexdump_a
    ld      b,':'
    call    sioa_tx_char
    ld      b,' '
    call    sioa_tx_char
    
hexdump1:
    ld      a,(hl)
    call    hexdump_a
    inc     hl

    pop     bc
    dec     bc
    push    bc

    ld      a,b
    or      c
    jr      nz,hexdump_loop
    call    hexdump_crlf

    pop     bc
    pop     hl
    pop     de
    pop     af
    ret


;#############################################################################
; Print the value in A in hex
; Clobbers AF, BC
;#############################################################################
hexdump_a:
    push    af
    srl     a
    srl     a
    srl     a
    srl     a
    call    hexdump_nib
    pop     af
    and     0x0f

hexdump_nib:
    add     '0'
    cp      '9'+1
    jp      m,hexdump_num
    add     'A'-'9'-1
hexdump_num:
    ld      b,a
    jp      sioa_tx_char            ; tail


;#############################################################################
; Clobbers AF, BC
;#############################################################################
hexdump_crlf:
    ld      b,'\r'
    call    sioa_tx_char            
    ld      b,'\n'
    jp      sioa_tx_char            ; tail
