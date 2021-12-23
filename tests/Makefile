
PROGS=\
	blinky1.bin \
	blinky2.bin \
	blinky3.bin \
	hello_sio1.bin \
	hello_sio2.bin \
	hello_ctc1.bin \
	hello_ctc2.bin \
	bank_select.bin \
	hello_lpt1.bin \
	hello_lpt2.bin \
	status_gpio.bin

all: $(PROGS)

clean:
	rm -f ldr
	rm -f *.lst *.bin *.hex

DATE := $(shell date --rfc-3339=seconds)
GIT_VERSION := $(shell git describe --long --dirty; git show -s --format='%ci')
%.bin: %.asm
	cat $< | sed -e "s/@@DATE@@/$(DATE)/g" -e "s/@@GIT_VERSION@@/$(GIT_VERSION)/g" | z80asm - -o $@ --list=$(basename $@).lst

world: clean all

blinky1.bin: blinky1.asm io.asm
blinky2.bin: blinky2.asm io.asm
blinky3.bin: blinky3.asm io.asm
hello_sio1.bin: hello_sio1.asm io.asm sio.asm hexdump.asm
hello_sio2.bin: hello_sio2.asm io.asm sio.asm hexdump.asm
hello_lpt1.bin: hello_lpt1.asm io.asm lpt.asm sio.asm hexdump.asm
hello_lpt2.bin: hello_lpt2.asm io.asm lpt.asm sio.asm hexdump.asm
hello_ctc1.bin: hello_ctc1.asm ctc.asm io.asm sio.asm hexdump.asm
hello_ctc2.bin: hello_ctc2.asm ctc.asm io.asm sio.asm hexdump.asm
bank_select.bin: bank_select.asm io.asm sio.asm hexdump.asm puts.asm
status_gpio.bin: status_gpio.asm io.asm sio.asm hexdump.asm puts.asm
