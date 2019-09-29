all: test.prg

test.prg: test.asm vera.inc
	acme -f cbm -DMACHINE_C64=0 -o test.prg test.asm

run: all
	../bin/x16emu -rom ../bin/rom.bin -prg test.prg -run -scale 2 -joy1 SNES -joy2 NES

debug: all
	../bin/x16emu -debug -rom ../bin/rom.bin -prg test.prg -run -scale 2


clean:
	rm -f *.prg *.o *.bin