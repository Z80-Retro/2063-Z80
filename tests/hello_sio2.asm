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

; A wrapper that can be used to test the SIO with IRQs.

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

    ; set mode 2 interrupts & load the vector table address into I
    im      2
    ld      a,vectab/256    ; A = MSB of the vectab address
    ld      i,a

    ; wipe the stack region to make the subsequent dump easier to see
    ld      hl,0xff00
    ld      (hl),0xa5
    ld      de,0xff01
    ld      bc,0xff
    ldir

    call    sioa_init
    call    siob_init

    ; dump the RAM copy of the text region 
    ld      hl,0
    ld      bc,_end
    ld      e,1
    call    hexdump

    ; dump the RAM stack region 
    ld      hl,0xff00
    ld      bc,0x100
    ld      e,1
    call    hexdump

    call    relay_init
    ei

halt_loop:
if 0
    ld      b,'z'
    call    siob_tx_char
endif
    halt
    jp      halt_loop


;##############################################################
; Configure the SIO to generate IRQs when receiving characters.
;##############################################################
relay_init:
    ; Channels A and B are a little different
    ; Not sure if can write to WR2 on both (and let A ignore it)

    ld  c,sio_ac
    ld  hl,relay_init_a     ; point to init string
    ld  b,relay_init_a_len  ; number of bytes to send
    otir                    ; write B bytes from (HL) into port in the C reg
    
    ld  c,sio_bc
    ld  hl,relay_init_b     ; point to init string
    ld  b,relay_init_b_len  ; number of bytes to send
    otir                    ; write B bytes from (HL) into port in the C reg

    ret

relay_init_b:               ; WR2 on channel B only
    db  00000010b           ; WR0 = select WR2
    db  vectab_sio-vectab   ; offset into vectab for the SIO handlers
relay_init_a:
    db  00000001b           ; WR0 = select WR1
    db  00011100b           ; WR1 = IRQ on all RX, ignore parity, status affects vector

relay_init_a_len:   equ $-relay_init_a
relay_init_b_len:   equ $-relay_init_b


;##############################################################
; These cases are ignored
;##############################################################
irq_tbmt_a:
irq_tbmt_b:
irq_ext_a:
irq_ext_b:
irq_rxs_a:
irq_rxs_b:
    ei
    reti

;##############################################################
; A char just arrived on port A, forward it to B
; Note this ignores potential overflow problems.
;##############################################################
irq_rx_a:
    push    af
    in      a,(sio_ad)
    out     (sio_bd),a
    pop     af
    ei
    reti

;##############################################################
; A char just arrived on port B, forward it to A
; Note this ignores potential overflow problems.
;##############################################################
irq_rx_b:
    push    af
    in      a,(sio_bd)
    out     (sio_ad),a
    pop     af
    ei
    reti




include 'sio.asm'
include 'hexdump.asm'

;#############################################################################
;#############################################################################
; The mode 2 IRQ vector table 
; The table must start at an even address since CTC vector is always even.
; It /can/ be different than a 256-byte boundary...
;   but the vector offsets are more obvious when it is.

    ds      0x100-($&0xff)  ; align to a 256-byte boundary
vectab:
vectab_sio:     ; vectab_sio-vectab MUST be a multiple of 8 due to SIO requirements
    dw      irq_tbmt_b
    dw      irq_ext_b
    dw      irq_rx_b
    dw      irq_rxs_b

    dw      irq_tbmt_a
    dw      irq_ext_a
    dw      irq_rx_a
    dw      irq_rxs_a

_end:
