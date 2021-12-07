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

; Drivers for the CTC


;#############################################################################
; Init the bit-rate generator for SIO A.
; C = clock divisor
;#############################################################################
init_ctc_1:
;   ld      a,0x07      ; TC follows, Timer, Control, Reset
    ld      a,0x47      ; TC follows, Counter, Control, Reset
    out     (ctc_1),a
    ld      a,c
    out     (ctc_1),a
    ret

;#############################################################################
; Init the bit-rate generator for SIO B.
; C = clock divisor
;#############################################################################
init_ctc_2:
;   ld      a,0x07      ; TC follows, Timer, Control, Reset
    ld      a,0x47      ; TC follows, Counter, Control, Reset
    out     (ctc_1),a
    ld      a,c
    out     (ctc_1),a
    ret

;#############################################################################
;#############################################################################
irq_ctc_0:
    ei
    reti
irq_ctc_1:
    ei
    reti
irq_ctc_2:
    ei
    reti

;#############################################################################
; Set CTC3 to free-run and generate IRQs at system_clock_hz/65536.
;
; Note: It is OK to EI before we send the time-constant because the
; timer will not yet have been started.
;#############################################################################
init_ctc_3:
    ld      a,0xb7      ; EI, timer mode, /256 prescale, TC follows, reset, ctl
    out     (ctc_3),a
    ld      a,0         ; 0=256 (as slow as it can go = system_clock_hz/256/256)
    out     (ctc_3),a
    ret

;#############################################################################
;#############################################################################
irq_ctc_3:
    push    af
    push    hl

    ld      hl,(uptime)
    inc     hl              ; increment the LSW of the uptime counter
    ld      (uptime),hl
    ld      a,h
    or      l
    jp      nz,irq_ctc_3_lo
    ld      hl,(uptime+2)
    inc     hl              ; increment the MSW of the uptime counter
    ld      (uptime+2),hl

irq_ctc_3_lo:
    pop     hl
    pop     af
    ei
    reti

; uint32_t uptime = number of ctc3 IRQ-ticks that the system has been running
uptime:
    dw  0,0




;#############################################################################
;#############################################################################
init_ctc_irq:
    ; The channel 0 vector used for all channels!
    ld      a,vectab_ctc-vectab
    out     (ctc_0),a   ; set the mode-2 IRQ vector (LSB is zero)
    ret
