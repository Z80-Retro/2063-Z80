# Basic test applications for the Z80 Retro board.

These applications require the use of `z80asm`.  You can install it like this:

	sudo apt install z80asm

Assemble these test applications like this:

	make world

Download them into the FLASH by using the `flash` programming application in the 
[2065-Z80-programmer](https://github.com/johnwinans/2065-Z80-programmer/tree/master/pi) 
project in github.  If you cloned the 2065-Z80-programmer project into your
home directory and built it on your PI then you can program these files like this:

	~/2065-Z80-programmer/pi/flash < blinky1.bin


## Test Programs

### blinky1.asm
Flash the SD card select LED.  This runs entirely from the FLASH (does not use SRAM).

### blinky2.asm
Flash the SD card select LED.  This copies itself from the FLASH into the SRAM and then runs from there.

### blinky3.asm
Flash the SD card select LED and at the same time, count on the printer port data lines.

### hello_sio1.asm
Test the SIO ports in polled mode.

### hello_sio2.asm
Test the SIO ports in IRQ mode.

### hello_ctc.asm
Test the CTC with IRQs and print an 'uptime' counter using the SIO.

## bank_select.asm
Test the SRAM blank select logic by padding and dumping regions of memory in different banks.

## hello_lpt.asm
Test the printer port by priting a 'hello world' type message.

## hello_lpt2.asm
Test the printer port by priting gaudy banners.

## io.asm
Equates for the IO ports on the Z80 Retro! board.

## sio.asm
Simple driver for the SIO.

## hexdump.asm
A library to print a memory hex dump.

## ctc.asm
Simple driver for the CTC.

## lpt.asm
Simple driver for the printer.

