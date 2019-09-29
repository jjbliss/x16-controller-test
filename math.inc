;=================================================
; ADD_TO_16
;   Add to 16-bit data
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: (none)
;
!macro ADD_TO_16 .address, .value {
    sta Z0
    lda .address
    clc
    adc #<.value
    sta .address
    lda .address+1
    adc #>.value
    sta .address+1
}

;=================================================
; ADD_TO_24
;   Add to 24-bit data
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: (none)
;
!macro ADD_TO_24 .address, .value {
    lda #.value
    sta Z0
  	lda .address
  	clc
    adc #<.value
    sta .address
    lda .address+1
    adc #>.value
    sta .address+1
    lda .address+2
    adc #^.value
    sta .address+2
}

;=================================================
; SUB_FROM_16
;   Subtract from 16-bit data
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: (none)
;
!macro SUB_FROM_16 .address {
  sta Z0
  lda .address
  sec
  sbc Z0
  bcs +; if carry set, go to end
  sta .address
  lda .address+1
  sec
  sbc #1
  bcs ++; if carry still set, go to end, if not we need to loop
  lda #%11
  sta .address+1
  jmp +++
+ sta .address
  jmp +++
++ sta .address+1
+++
}

;=================================================
; MULTI_LSR
;   Does a logical shift right the given number of times
;-------------------------------------------------
; INPUTS:
;           .num    Number of times to shift
;
;-------------------------------------------------
; MODIFIES: A
;
!macro MULTI_LSR .num {
  !for i, 1, .num {
    lsr
  }
}

;=================================================
; MULTI_LSR_24
;   Does a logical shift right the given number of times
;-------------------------------------------------
; INPUTS:
;           .address Address of the number to shift
;           .num    Number of times to shift
;
;-------------------------------------------------
; MODIFIES: A
;
!macro MULTI_LSR_24 .address, .num {
  !for i, 1, .num {
    lda .address+2
    clc
    ror
    sta .address+2
    lda .address+1
    ror
    sta .address+1
    lda .address
    ror
    sta .address
  }
}

;=================================================
; MULTI_ASL
;   Does an arithmatic shift left the given number of times
;-------------------------------------------------
; INPUTS:
;           .num    Number of times to shift
;
;-------------------------------------------------
; MODIFIES: A
;
!macro MULTI_ASL .num {
  !for i, 1, .num {
    asl
  }
}
