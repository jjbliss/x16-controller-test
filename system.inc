!ifdef SYSTEM_INC !eof
SYSTEM_INC=1

; SYS_HEADER_0801
;   File header of a PRG loaded at $0801. Includes
;   encoded BASIC commands to start execution
;   without needing a SYS() command.
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: (none)
;
!macro SYS_HEADER_0801 {
!ifdef HEADER_A000_IN_USE {
    !warn "SYS_HEADER_A000 already in use. This second call may not do what you think, and may break file size detection."
}
HEADER_0801_IN_USE=1
*=$0801
    !byte $0b,$08,$01,$00,$9e,$32,$30,$36,$31,$00,$00,$00
}


;=================================================
; SYS_FOOTER
;   File footer for any file. This provides a warning
;   in case the file has exceeded the bounds of
;   the memory into which it is intended to be loaded.
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: (none)
;
!macro SYS_FOOTER {

  !ifndef HEADER_0801_IN_USE {
      !ifndef HEADER_A000_IN_USE {
          !warn "SYS_HEADER_* macro in use. Add SYS_HEADER_0801 or SYS_HEADER_A000, depending on where you expect to load this file."
      }
  }

  !ifdef HEADER_0801_IN_USE {
    !if * > $9EFF {
        !warn "Program size exceeds Fixed RAM space."
    }
  }

  !ifdef HEADER_A000_IN_USE {
    !if * > $BFFF {
        !warn "Program size exceeds Fixed RAM space."
    }
  }
}

;=================================================
;=================================================
;
;   IRQ Handling
;
;-------------------------------------------------


;=================================================
; SYS_SET_IRQ
;   Set where the kernal should jump to after
;   its own interrupt handling.
;-------------------------------------------------
; INPUTS:   .address    Label or address of IRQ handler
;
;-------------------------------------------------
; MODIFIES: A
;
!macro SYS_SET_IRQ .address {
    lda $0314
    sta irq_redirect
    lda $0315
    sta irq_redirect+1
    lda #<.address
    sta $0314
    lda #>.address
    sta $0315
}

;=================================================
; SYS_END_IRQ
;   Return to original IRQ location
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A
;
!macro SYS_END_IRQ {
    jmp (irq_redirect)
}

;=================================================
; SYS_COPY
;   Generic "copy a block of data from A to B" macro
;-------------------------------------------------
; INPUTS:   .src    Source address
;           .dst    Destination address
;           .size   Number of bytes to copy
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FB-$FF
;
!macro SYS_COPY .src, .dst, .size {
    lda #<.src ;.src to $FC $FB
    sta $FB
    lda #>.src
    sta $FC
    lda #<.dst ;.dst to $FE $FD
    sta $FD
    lda #>.dst
    sta $FE
    !if .size > $FF {
                    ; If we have at least 1 full page to copy, then include the
                    ; page copy portion which needs a 5th byte to track the number
                    ; of pages to copy.

        lda #>.size ; number of pages to copy
        sta $FF

        ldy #$00 ; reset y for our loop

-       lda ($FB),Y ; indirect index source memory address
        sta ($FD),Y ; indirect index dest memory address
        iny
        bne -       ; loop until our dest goes over 255

        inc $FC     ; increment high order source memory address
        inc $FE     ; increment high order dest memory address

        dec $FF     ; decrement number of pages remaining
        bne -       ; If we still have at least 1 page to copy, go back and copy it
    }
    !if <.size > 0 {
                    ; If we're not copying exactly some number of pages, include
                    ; the "copy the rest of it" section
        ldy #0
        ldx #<.size

-       lda ($FB),Y
        sta ($FD),Y
        iny
        dex
        bne -
    }
}

!macro SYS_COPY_2 .src, .dst {
	lda .src
	sta .dst
	lda .src+1
	sta .dst+1
}

!macro SYS_COPY_3 .src, .dst {
	lda .src
	sta .dst
	lda .src+1
	sta .dst+1
	lda .src+2
	sta .dst+2
}
;=================================================
; SYS_ZERO
;   Generic "zero a block of data at a given adress" macro
;-------------------------------------------------
; INPUTS:
;           .dst    Destination address
;           .size   Number of bytes to copy
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FB-$FF
;
!macro SYS_ZERO .dst, .size {
  lda #<.dst ;.dst to $FE $FD
  sta $FD
  lda #>.dst
  sta $FE
  !if .size > $FF {
                  ; If we have at least 1 full page to copy, then include the
                  ; page copy portion which needs a 5th byte to track the number
                  ; of pages to copy.

      lda #>.size ; number of pages to copy
      sta $FF

      ldy #$00 ; reset y for our loop

-       lda #0 ;
      sta ($FD),Y ; indirect index dest memory address
      iny
      bne -       ; loop until our dest goes over 255


      inc $FE     ; increment high order dest memory address

      dec $FF     ; decrement number of pages remaining
      bne -       ; If we still have at least 1 page to copy, go back and copy it
  }
  !if <.size > 0 {
                  ; If we're not copying exactly some number of pages, include
                  ; the "copy the rest of it" section
      ldy #0
      ldx #<.size

-       lda #0
      sta ($FD),Y
      iny
      dex
      bne -
  }
}
;=================================================
; SYS_STREAM_OUT
;   Copy a block of data starting at a source address,
;   to exactly one destination address, because it's
;   memory-mapped IO that will auto-increment its own
;   destination.
;-------------------------------------------------
; INPUTS:   .src    Source address
;           .dst    Destination address
;           .size   Number of bytes to copy
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FB-$FC, $FF
;
!macro SYS_STREAM_OUT .src, .dst, .size {
    lda #<.src ;.src to $FC $FB
    sta $FB
    lda #>.src
    sta $FC

    !if .size > $FF {
                    ; If we have at least 1 full page to copy, then include the
                    ; page copy portion which needs a 5th byte to track the number
                    ; of pages to copy.

        lda #>.size ; number of pages to copy
        sta $FF

        ldy #$00 ; reset y for our loop

-       lda ($FB),Y ; indirect index source memory address
        sta .dst
        iny
        bne -       ; loop until our dest goes over 255

        inc $FC     ; increment high order source memory address

        dec $FF     ; decrement number of pages remaining
        bne -       ; If we still have at least 1 page to copy, go back and copy it
    }
    !if <.size > 0  {
                    ; If we're not copying exactly some number of pages, include
                    ; the "copy the rest of it" section
        ldy #0
        ldx #<.size

-       lda ($FB),Y
        sta .dst
        iny
        dex
        bne -
    }
}

;=================================================
; SYS_STREAM_IN
;   Copy a block of data from exactly one source address,
;   because it's memory-mapped IO that will auto-increment
;   its own source, to a destination starting at some address.
;-------------------------------------------------
; INPUTS:   .src    Source address
;           .dst    Destination address
;           .size   Number of bytes to copy
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FD-$FF
;
!macro SYS_STREAM_IN .src, .dst, .size {
    lda #<.dst ;.dst to $FE $FD
    sta $FD
    lda #>.dst
    sta $FE

    !if .size > $FF {
                    ; If we have at least 1 full page to copy, then include the
                    ; page copy portion which needs a 5th byte to track the number
                    ; of pages to copy.

        lda #>.size ; number of pages to copy
        sta $FF

        ldy #$00 ; reset y for our loop
.loop:
        lda .src
        sta ($FD),Y ; indirect index dest memory address
        iny
        bne .loop   ; loop until our dest goes over 255

        inc $FE     ; increment high order dest memory address

        dec $FF     ; decrement number of pages remaining
        bne .loop   ; If we still have at least 1 page to copy, go back and copy it
    }
    !if <.size > 0 {
                    ; If we're not copying exactly some number of pages, include
                    ; the "copy the rest of it" section
        ldy #0
        ldx #<.size

-       lda .src
        sta ($FD),Y
        iny
        dex
        bne -
    }
}

;=================================================
; SYS_STREAM
;   Copy a block of data from exactly one source address,
;   because it's memory-mapped IO that will auto-increment
;   its own source, to exactly one destination address,
;   because it too is memory-mapped IO.
;-------------------------------------------------
; INPUTS:   .src    Source address
;           .dst    Destination address
;           .size   Number of bytes to copy
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FF
;
!macro SYS_STREAM .src, .dst, .size {
    !if .size > $FF {
                    ; If we have at least 1 full page to copy, then include the
                    ; page copy portion which needs a 5th byte to track the number
                    ; of pages to copy.

        lda #>.size ; number of pages to copy
        sta $FF

        ldy #0 ; reset y for our loop

-       lda .src
        sta .dst
        iny
        bne -       ; loop until our dest goes over 255

        dec $FF     ; decrement number of pages remaining
        bne -       ; If we still have at least 1 page to copy, go back and copy it
    }
    !if <.size > 0  {
                    ; If we're not copying exactly some number of pages, include
                    ; the "copy the rest of it" section
        ldy #0
        ldx #<.size

-       lda .src
        sta .dst
        iny
        dex
        bne -
    }
}

!macro BEQ_LONG .lbl {
	bne .bel1
	jmp	.lbl
.bel1:
}

!macro BNE_LONG .lbl {
	beq .bel1
	jmp	.lbl
.bel1:
}

!macro BCC_LONG .lbl {
	bcs .bel1
	jmp	.lbl
.bel1:
}

!macro BCS_LONG .lbl {
	bcc .bel1
	jmp	.lbl
.bel1:
}
