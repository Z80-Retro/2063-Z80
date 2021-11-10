all: blinky1.bin blinky2.bin blinky3.bin hello1.bin hello2.bin hello_lpt.bin bank_select.bin

clean:
	rm -f ldr
	rm -f *.lst *.bin *.hex

DATE := $(shell date --rfc-3339=seconds)
GIT_VERSION := $(shell git describe --long --dirty; git show -s --format='%ci')
%.bin: %.asm
	expand -t4 $< | sed -e "s/@@DATE@@/$(DATE)/g" | sed -e "s/@@GIT_VERSION@@/$(GIT_VERSION)/g" | z80asm - -o $@ --list=$(basename $@).lst

world: clean all
