;!symbollist "symbols.sym"

!src "vera.inc"
!src "system.inc"
!src "definitions.inc"
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
	+VERA_RESET
	jsr layer1_mode1
	jsr composer_setup
	+VERA_ENABLE_SPRITES
	jsr clearscreen
	jsr write_labels
	lda #0
	sta X_POS
	sta X_POS+1
	sta Y_POS
	sta Y_POS+1
	sta X_POS2
	sta X_POS2+1
	sta Y_POS2
	sta Y_POS2+1

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
	!byte $FF
	and #1 ;check that vsync bit is set
	beq .vsync_end ; if vsync bit not set, skip to end
	jsr GETJOY
	jsr write_controls1
	jsr write_controls2
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
	lda JOY1
	and #RIGHT_BUTTON ;check right
	bne rbend
	lda #1
	jsr add_x_pos
rbend:
	lda JOY1
	and #LEFT_BUTTON ;check right
	bne lbend
	lda #1
	jsr sub_x_pos
lbend:
	lda JOY1
	and #DOWN_BUTTON ;check down
	bne dbend
	lda #1
	jsr add_y_pos
dbend:
	lda JOY1
	and #UP_BUTTON ;check down
	bne ubend
	lda #1
	jsr sub_y_pos
ubend:
	rts


handle_controls2:
	lda JOY2
	and #RIGHT_BUTTON ;check right
	bne rbend2
	lda #1
	jsr add_x_pos2
rbend2:
	lda JOY2
	and #LEFT_BUTTON ;check right
	bne lbend2
	lda #1
	jsr sub_x_pos2
lbend2:
	lda JOY2
	and #DOWN_BUTTON ;check down
	bne dbend2
	lda #1
	jsr add_y_pos2
dbend2:
	lda JOY2
	and #UP_BUTTON ;check down
	bne ubend2
	lda #1
	jsr sub_y_pos2
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
	lda X_POS
	sta VERA_data
	lda X_POS+1
	sta VERA_data
	+VERA_SET_ADDR VRAM_sprdata+4, 1
	lda Y_POS
	sta VERA_data
	lda Y_POS+1
	sta VERA_data
	rts

update_sprite_pos2:
	+VERA_SET_ADDR VRAM_sprdata+8+2, 1
	lda X_POS2
	sta VERA_data
	lda X_POS2+1
	sta VERA_data
	+VERA_SET_ADDR VRAM_sprdata+8+4, 1
	lda Y_POS2
	sta VERA_data
	lda Y_POS2+1
	sta VERA_data
	rts

add_x_pos:
	sta Z0
	lda X_POS
	clc
	adc Z0
	bcc axpe; if carry not set, go to end
	sta X_POS
	lda X_POS+1
	clc
	adc #1
	sta X_POS+1
	;check if X_POS+1 is greater than 3, if so, set all to 0
	and #%11111100
	beq axpe;if 0, then go to end
	lda #0
	sta X_POS
	sta X_POS+1
axpe:
	sta X_POS
	rts

sub_x_pos:
	sta Z0
	lda X_POS
	sec
	sbc Z0
	bcs sxpe1; if carry set, go to end
	sta X_POS
	lda X_POS+1
	sec
	sbc #1
	bcs sxpe2; if carry still set, go to end, if not we need to loop
	lda #%11
	sta X_POS+1
	jmp sxpef
sxpe1:
	sta X_POS
	jmp sxpef
sxpe2:
	sta X_POS+1
sxpef:
	rts

add_y_pos:
	sta Z0
	lda Y_POS
	clc
	adc Z0
	bcc aype; if carry not set, go to end
	sta Y_POS
	lda Y_POS+1
	clc
	adc #1
	sta Y_POS+1
	;check if Y_POS+1 is greater than 3, if so, set all to 0
	and #%11111100
	beq aype;if 0, then go to end
	lda #0
	sta Y_POS
	sta Y_POS+1
aype:
	sta Y_POS
	rts

sub_y_pos:
	sta Z0
	lda Y_POS
	sec
	sbc Z0
	bcs sype1; if carry set, go to end
	sta Y_POS
	lda Y_POS+1
	sec
	sbc #1
	bcs sype2; if carry still set, go to end, if not we need to loop
	lda #%11
	sta Y_POS+1
	jmp sypef
sype1:
	sta Y_POS
	jmp sypef
sype2:
	sta Y_POS+1
sypef:
	rts

write_x_pos:
	lda #4
	jsr printonline
	lda X_POS+1
	sta VERA_data
	lda X_POS
	sta VERA_data
	rts

write_y_pos:
	lda #5
	jsr printonline
	lda Y_POS+1
	sta VERA_data
	lda Y_POS
	sta VERA_data
	rts


add_x_pos2:
	sta Z0
	lda X_POS2
	clc
	adc Z0
	bcc axpe2; if carry not set, go to end
	sta X_POS2
	lda X_POS2+1
	clc
	adc #1
	sta X_POS2+1
	;check if X_POS+1 is greater than 3, if so, set all to 0
	and #%11111100
	beq axpe2;if 0, then go to end
	lda #0
	sta X_POS2
	sta X_POS2+1
axpe2:
	sta X_POS2
	rts

sub_x_pos2:
	sta Z0
	lda X_POS2
	sec
	sbc Z0
	bcs sxpe12; if carry set, go to end
	sta X_POS2
	lda X_POS2+1
	sec
	sbc #1
	bcs sxpe22; if carry still set, go to end, if not we need to loop
	lda #%11
	sta X_POS2+1
	jmp sxpef2
sxpe12:
	sta X_POS2
	jmp sxpef2
sxpe22:
	sta X_POS2+1
sxpef2:
	rts

add_y_pos2:
	sta Z0
	lda Y_POS2
	clc
	adc Z0
	bcc aype2; if carry not set, go to end
	sta Y_POS2
	lda Y_POS2+1
	clc
	adc #1
	sta Y_POS2+1
	;check if Y_POS+1 is greater than 3, if so, set all to 0
	and #%11111100
	beq aype2;if 0, then go to end
	lda #0
	sta Y_POS2
	sta Y_POS2+1
aype2:
	sta Y_POS2
	rts

sub_y_pos2:
	sta Z0
	lda Y_POS2
	sec
	sbc Z0
	bcs sype12; if carry set, go to end
	sta Y_POS2
	lda Y_POS2+1
	sec
	sbc #1
	bcs sype22; if carry still set, go to end, if not we need to loop
	lda #%11
	sta Y_POS2+1
	jmp sypef2
sype12:
	sta Y_POS2
	jmp sypef2
sype22:
	sta Y_POS2+1
sypef2:
	rts

write_x_pos2:
	lda #8
	jsr printonline
	lda X_POS2+1
	sta VERA_data
	lda X_POS2
	sta VERA_data
	rts

write_y_pos2:
	lda #9
	jsr printonline
	lda Y_POS2+1
	sta VERA_data
	lda Y_POS2
	sta VERA_data
	rts


;=================================================
; write_controls
;   This will write out the current status of
;		JOY1 to the second line of the screen
;-------------------------------------------------
; INPUTS: (none)
;
;-------------------------------------------------
; MODIFIES: X
;
write_controls1:
	pha
	lda #1
	jsr printonline
	lda #$80
	sta Z5
wc0:
	lda JOY1
	ldx #"1"
	AND Z5
	bne wc1
	ldx #"0"
wc1:
	txa
	sta VERA_data
	lsr Z5
	bcc wc0
wce:
	lda #$80
	sta Z5
wc0h:
	lda JOY1+1
	ldx #"1"
	AND Z5
	bne wc1h
	ldx #"0"
wc1h:
	txa
	sta VERA_data
	lsr Z5
	bcc wc0h
wceh:
	lda #$80
	sta Z5
wc0b:
	lda JOY1+2
	ldx #"1"
	AND Z5
	bne wc1b
	ldx #"0"
wc1b:
	txa
	sta VERA_data
	lsr Z5
	bcc wc0b
wceb:
	pla
 	rts

write_controls2:
	pha
	lda #2
	jsr printonline
	lda #$80
	sta Z5
wc20:
	lda JOY2
	ldx #"1"
	AND Z5
	bne wc21
	ldx #"0"
wc21:
	txa
	sta VERA_data
	lsr Z5
	bcc wc20
wc2e:
	lda #$80
	sta Z5
wc20h:
	lda JOY2+1
	ldx #"1"
	AND Z5
	bne wc21h
	ldx #"0"
wc21h:
	txa
	sta VERA_data
	lsr Z5
	bcc wc20h
wc2eh:
	lda #$80
	sta Z5
wc20b:
	lda JOY2+2
	ldx #"1"
	AND Z5
	bne wc21b
	ldx #"0"
wc21b:
	txa
	sta VERA_data
	lsr Z5
	bcc wc20b
wc2eb:
	pla
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
	lda #$20
	sta VERA_addr_bank
	lda Z0
	sta VERA_addr_high
	lda #0
	sta VERA_addr_low
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
	ldx #SCREEN_HEIGHT
csloop:
	cpx #0
	beq csdone
	sta Z4
	stx Z3
	jsr blankline
	lda Z4
	ldx Z3
	dex
	clc
	adc #1
	jmp csloop
csdone:
	pla
	rts
blankline:
	sta Z0
	pha
	lda #$10
	sta VERA_addr_bank
	lda Z0
	sta VERA_addr_high
	lda #0
	sta VERA_addr_low
	ldx #0
blloop: ;loop over each line
	cpx #SCREEN_WIDTH
	beq bldone
	inx
	+VERA_WRITE $20, $01 ;write character and color data
	jmp blloop
bldone:
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
	+VERA_SET_ADDR VRAM_composer, 1;set vera address to the composer and set increment to 1
	+SYS_STREAM_OUT composor_setup_data, VERA_data, 9; source, destination, size
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
layer1_mode1: ;layer1_mode1_data is 10 bytes long
	pha
	+VERA_SET_ADDR VRAM_layer1, 1;set vera address to layer1 and set increment to 1
	+SYS_STREAM_OUT layer1_mode1_data, VERA_data, 9; source, destination, size
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
composor_setup_data:
	!byte 1, 128, 128, 14, 0, 128, 0, 224, 40
layer1_mode1_data:
	!byte 1, 6, 0, 0, 0, 124, 0, 0, 0, 0
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
