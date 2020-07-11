;!symbollist "symbols.sym"

!src "vera.inc"
!src "system.inc"
!src "definitions.inc"
!src "math.inc"
*=$0801


+SYS_HEADER_0801

;=================================================
;=================================================
;
;   main code
;
;-------------------------------------------------
setup:
	;setup VERA
	;+VERA_RESET
	jsr composer_setup
	+LAYER_0_OFF
	+LAYER_1_OFF
	jsr clearscreen

	jsr layer0_mode0
	+VERA_ENABLE_SPRITES
	jsr write_labels

	+SYS_ZERO X_POS, 2
	+SYS_ZERO Y_POS, 2
	+SYS_ZERO X_POS2, 2
	+SYS_ZERO Y_POS2, 2

	;setup Sprite
	jsr create_sprite_entry
	jsr create_sprite_entry2
	jsr copy_sprite_to_vram

	;setup IRQ
	+SYS_SET_IRQ irq_handler
	+VERA_ENABLE_IRQ
	cli

setup_done:

	jmp *



;=================================================
; irq_handler
;   This is essentially my "do_frame".
;-------------------------------------------------
; INPUTS: (none)
;
;-------------------------------------------------
; MODIFIES: A, X, Y
;
irq_handler:
	;check that this is a VSYNC interrupt
	lda VERA_irq
	and #1 ;check that vsync bit is set
	+BEQ_LONG .vsync_end ; if vsync bit not set, skip to end
	jsr joystick_scan

	+SYS_ZERO M0, 4

	lda #0
	jsr joystick_get
	sta M0
	txa
	sta M0+1
	tya
	sta M0+2
	+SYS_COPY_3 M0, JOY1_DATA
	lda #1
	sta Z0
	jsr write_controls
	lda #1
	jsr joystick_get
	sta M0
	txa
	sta M0+1
	tya
	sta M0+2
	+SYS_COPY_3 M0, JOY2_DATA
	lda #2
	sta Z0
	jsr write_controls
	lda #2
	jsr joystick_get
	sta M0
	txa
	sta M0+1
	tya
	sta M0+2
	+SYS_COPY_3 M0, JOY3_DATA
	lda #3
	sta Z0
	jsr write_controls
	lda #3
	jsr joystick_get
	sta M0
	txa
	sta M0+1
	tya
	sta M0+2
	+SYS_COPY_3 M0, JOY4_DATA
	lda #4
	sta Z0
	jsr write_controls

	jsr write_x_pos
	jsr write_y_pos
	jsr write_x_pos2
	jsr write_y_pos2
	jsr handle_controls1
	jsr handle_controls2
	jsr update_sprite_pos
	jsr update_sprite_pos2
	+VERA_END_IRQ
	;;jmp to here if not VERA interrupt
.vsync_end:
	+SYS_END_IRQ




;=================================================
; handle_controls
;   create an entry in the sprite index
;-------------------------------------------------
; INPUTS: (none)
;
;-------------------------------------------------
; MODIFIES: A, X, Y, X_POS, Y_POS
;
handle_controls1:
	lda JOY1_DATA
	and #RIGHT_BUTTON ;check right
	bne rbend
	+ADD_TO_16 X_POS, 1
rbend:
	lda JOY1_DATA
	and #LEFT_BUTTON ;check right
	bne lbend
	+ADD_TO_16 X_POS, -1
lbend:
	lda JOY1_DATA
	and #DOWN_BUTTON ;check down
	bne dbend
	+ADD_TO_16 Y_POS, 1
dbend:
	lda JOY1_DATA
	and #UP_BUTTON ;check down
	bne ubend
	+ADD_TO_16 Y_POS, -1
ubend:
	rts


handle_controls2:
	lda JOY2_DATA
	and #RIGHT_BUTTON ;check right
	bne rbend2
	+ADD_TO_16 X_POS2, 1
rbend2:
	lda JOY2_DATA
	and #LEFT_BUTTON ;check right
	bne lbend2
	lda #1
	+ADD_TO_16 X_POS2, -1
lbend2:
	lda JOY2_DATA
	and #DOWN_BUTTON ;check down
	bne dbend2
	lda #1
	+ADD_TO_16 Y_POS2, 1
dbend2:
	lda JOY2_DATA
	and #UP_BUTTON ;check down
	bne ubend2
	lda #1
	+ADD_TO_16 Y_POS2, -1
ubend2:
	rts

;=================================================
; create_sprite_entry
;   create an entry in the sprite index
;-------------------------------------------------
; INPUTS: (none)
;
;-------------------------------------------------
; MODIFIES: A, X, Y
;
create_sprite_entry:
	;take sprite_data_entry and copy it into vera memory at VRAM_sprdata
	+VERA_SET_ADDR VRAM_sprdata, 1;set vera address to the composer and set increment to 1
	+SYS_STREAM_OUT sprite_data_entry, VERA_data, 8; source, destination, size
	rts

create_sprite_entry2:
	;take sprite_data_entry and copy it into vera memory at VRAM_sprdata
	+VERA_SET_ADDR VRAM_sprdata+8, 1;set vera address to the composer and set increment to 1
	+SYS_STREAM_OUT sprite_data_entry, VERA_data, 8; source, destination, size
	rts

;=================================================
; copy_sprite_to_vram
;   copy the sprite data to video memory
;-------------------------------------------------
; INPUTS: (none)
;
;-------------------------------------------------
; MODIFIES: A, X, Y
;
copy_sprite_to_vram:
	;take sprite_data and copy it into vera memory at SPRITE_DATA
	+VERA_SET_ADDR SPRITE_DATA, 1;set vera address to the composer and set increment to 1
	+SYS_STREAM_OUT sprite_data, VERA_data, 64; source, destination, size
	rts

;=================================================
; update_sprite_pos
;   update the x and y positions of the sprite
;-------------------------------------------------
; INPUTS: (none)
;
;-------------------------------------------------
; MODIFIES: A, X, Y
;
update_sprite_pos:
	+VERA_SET_ADDR VRAM_sprdata+2, 1
	+SYS_STREAM_OUT X_POS, VERA_data, 2
	+VERA_SET_ADDR VRAM_sprdata+4, 1
	+SYS_STREAM_OUT Y_POS, VERA_data, 2
	rts

update_sprite_pos2:
	+VERA_SET_ADDR VRAM_sprdata+8+2, 1
	+SYS_STREAM_OUT X_POS2, VERA_data, 2
	+VERA_SET_ADDR VRAM_sprdata+8+4, 1
	+SYS_STREAM_OUT Y_POS2, VERA_data, 2
	rts


write_x_pos:
	lda #6
	jsr printonline
	+SYS_STREAM_OUT X_POS, VERA_data, 2
	rts

write_y_pos:
	lda #7
	jsr printonline
	+SYS_STREAM_OUT Y_POS, VERA_data, 2
	rts

write_x_pos2:
	lda #10
	jsr printonline
	+SYS_STREAM_OUT X_POS2, VERA_data, 2
	rts

write_y_pos2:
	lda #11
	jsr printonline
	+SYS_STREAM_OUT Y_POS2, VERA_data, 2
	rts


;=================================================
; write_controls
;   This will write out the current status the joystick
;	as written in M0 to the screen
;-------------------------------------------------
; INPUTS:	M0 - joystatus
;			Z0 - line number
;
;-------------------------------------------------
; MODIFIES: Z1, x, Z5
;
write_controls:
	pha
	lda Z0
	jsr printonline
	lda M0
	sta Z1
	jsr write_bits_in_Z1
	lda M0+1
	sta Z1
	jsr write_bits_in_Z1
	lda M0+2
	sta Z1
	jsr write_bits_in_Z1
	pla
 	rts


write_bits_in_Z1:
	lda #$80
	sta Z5
wbiz0:
	lda Z1
	ldx #"1"
	AND Z5
	bne wbiz1
	ldx #"0"
wbiz1:
	txa
	sta VERA_data
	lsr Z5
	bcc wbiz0
wbize:
	rts


;=================================================
; write_labels
;   Write out the control labels to first line of
;			screen
;-------------------------------------------------
; INPUTS: (none)
;
;-------------------------------------------------
; MODIFIES: X
;
write_labels:
	ldx #0
	lda #0
	jsr printonline
	 +SYS_STREAM_OUT controlstring, VERA_data, 12
	rts

;=================================================
; printonline
;   prepares VERA to write on given line from left
;-------------------------------------------------
; INPUTS: A, the line to print on
;
;-------------------------------------------------
; MODIFIES: X
;
printonline:
	sta Z0
	pha
	+VERA_SET_ADDR 0, 2
	lda Z0
	sta VERA_addr_high
	pla
	rts


;=================================================
; clearscreen
;   Clears all characters from screen
;		Sets all characters to Black background and
;		white foreground
;-------------------------------------------------
; INPUTS:
;
;-------------------------------------------------
; MODIFIES: X, Z0, Z3, Z4
;
clearscreen:
	pha
	lda #0
	+VERA_SET_ADDR 0, 2
	lda #$20
	sta Z0
	+SYS_STREAM Z0, VERA_data, 7679

	+VERA_SET_ADDR 1, 2
	lda #$01
	sta Z0
	+SYS_STREAM Z0, VERA_data, 7679

	pla
	rts

;=================================================
; composer_setup
;   Initializes the VERA composer to defaults
;-------------------------------------------------
; INPUTS:
;
;-------------------------------------------------
; MODIFIES:
;
composer_setup: ;composor_setup_data is 9 bytes long
	pha
	;+VERA_SET_ADDR VRAM_composer, 1;set vera address to the composer and set increment to 1
	;+SYS_STREAM_OUT composor_setup_data, VERA_data, 9; source, destination, size
	+DC_SEL_0
	+SYS_COPY composor_setup_data, VERA_DC, 4
	+DC_SEL_1
	+SYS_COPY composor_setup_data+4, VERA_DC, 4
	pla
	rts

;=================================================
; layer1_mode1
;   Initializes VERA layer1 to mode1
;-------------------------------------------------
; INPUTS:
;
;-------------------------------------------------
; MODIFIES:
;
layer0_mode0: ;layer1_mode1_data is 10 bytes long
	pha
	;+VERA_SET_ADDR VRAM_layer0, 1;set vera address to layer1 and set increment to 1
	;+SYS_STREAM_OUT layer_mode0_data, VERA_data, 9; source, destination, size
	+SYS_COPY layer_mode0_data, VERA_L0, 7

	+LAYER_0_ON

	pla
	rts

;=================================================
;=================================================
;
;   Data
;
;-------------------------------------------------


controlstring:
  !scr "byssudlraxlr"
;composor_setup_data:;
;	!byte 1, 128, 128, 14, 0, 128, 0, 224, 40
composor_setup_data:
;	!byte 1, 64, 64, 0, 0, %10000000, 0, %11100000, (0 | (%10 << 2) | (%0 << 4) | (%1 << 5))
	!byte 1;DC_VIDEO
	!byte 128	;DC_HSCALE
	!byte 128	;DC_VSCALE
	!byte 0		;DC_BORDER
	!byte 0 	;DC_HSTART
	!byte %10100000	;DC_HSTOP
	!byte 0	;DC_VSTART
	!byte %11110000	;DC_VSTOP
layer_mode0_data:
	;!byte 1, %00000110, 0, 0, 0, 62, 0, 0, 0, 0
	!byte %01100000;Config Map Height	Map Width	T256C	Bitmap Mode	Color Depth
	!byte 0;MAPBASE
	!byte %01111100;TILEBASE, TILEH, TILEW
	!byte 0;H-SCROLL  -- Low
	!byte 0;H-SCROLL  -- High
	!byte 0;V-SCROLL  -- Low
	!byte 0;V-SCROLL  -- High
;layer1_mode1_data:
;	!byte 1, 6, 0, 0, 0, 124, 0, 0, 0, 0
irq_redirect:
  !byte $00, $00

;sprite data entry is 8 bytes
sprite_data_entry:
  !byte <(SPRITE_DATA >> 5) ;address in vram is at $10000 (%00010000000000000000) we use the top three parts
  !byte >(SPRITE_DATA >> 5) | %10000000   ;this contains the mode and the top part of the address 1=8bpp
  !byte $F0	;x position
  !byte $00	;top two bits of x position
  !byte $F0	;y position
  !byte $00	;top two bits of y position
  !byte ((1 << 4) | (3 << 2) | 0) ; collision mask, z-depth, and flip-bits
  !byte $00 ; height, width, and pallete offset.  Set to 8x8px

sprite_data:
  !byte $00, $00, $00, $01, $01, $00, $00, $00
  !byte $00, $00, $01, $FF, $FF, $01, $00, $00
  !byte $00, $01, $FF, $01, $01, $FF, $01, $00
  !byte $01, $FF, $01, $01, $01, $01, $FF, $01
  !byte $01, $FF, $01, $01, $01, $01, $FF, $01
  !byte $00, $01, $FF, $01, $01, $FF, $01, $00
  !byte $00, $00, $01, $FF, $FF, $01, $00, $00
  !byte $00, $00, $00, $01, $01, $00, $00, $00





+SYS_FOOTER
