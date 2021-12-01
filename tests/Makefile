
PROGS=\
	blinky1.bin \
	blinky2.bin \
	blinky3.bin \
	hello_sio1.bin \
	hello_sio2.bin \
	hello_ctc.bin \
	bank_select.bin \
	hello_lpt.bin \
	hello_lpt2.bin

all: $(PROGS)

clean:
	rm -f ldr
	rm -f *.lst *.bin *.hex

DATE := $(shell date --rfc-3339=seconds)
GIT_VERSION := $(shell git describe --long --dirty; git show -s --format='%ci')
%.bin: %.asm
	cat $< | sed -e "s/@@DATE@@/$(DATE)/g" -e "s/@@GIT_VERSION@@/$(GIT_VERSION)/g" | z80asm - -o $@ --list=$(basename $@).lst

world: clean all
