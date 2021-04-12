all: test.prg

test.prg: test.asm vera.inc
	acme -f cbm -o test.prg test.asm

run: all
	../bin/x16emu -prg test.prg -run -scale 2 -joy2

run1joy: all
	../bin/x16emu -prg test.prg -run -scale 2 -joy1


run2joy: all
	../bin/x16emu -prg test.prg -run -scale 2 -joy1 -joy2

run-nes: all
	../bin/x16emu -rom ../bin/rom.bin -prg test.prg -run -scale 2 -joy1

run-2joy: all
	../bin/x16emu -rom ../bin/rom.bin -prg test.prg -run -scale 2 -joy1 -joy2

debug: all
	../bin/x16emu -debug -rom ../bin/rom.bin -prg test.prg -run -scale 2


clean:
	rm -f *.prg *.o *.bin
