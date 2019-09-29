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
