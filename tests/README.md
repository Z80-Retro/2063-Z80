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

