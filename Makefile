all: test.prg

test.prg: test.asm vera.inc
	acme -f cbm -o test.prg test.asm

run: all
	../bin/x16emu -prg test.prg -run -scale 2 -joy2 SNES

run1joy: all
	../bin/x16emu -prg test.prg -run -scale 2 -joy1 SNES


run2joy: all
	../bin/x16emu -prg test.prg -run -scale 2 -joy1 SNES -joy2 SNES

run-nes: all
	../bin/x16emu -rom ../bin/rom.bin -prg test.prg -run -scale 2 -joy1 NES

run-2joy: all
	../bin/x16emu -rom ../bin/rom.bin -prg test.prg -run -scale 2 -joy1 SNES -joy2 SNES

debug: all
	../bin/x16emu -debug -rom ../bin/rom.bin -prg test.prg -run -scale 2


clean:
	rm -f *.prg *.o *.bin
