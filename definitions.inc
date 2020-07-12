!ifdef DEFINITIONS_INC !eof
DEFINITIONS_INC=1

;GETJOY =  $FF06
;JOY1 = $02BC
;JOY2 = $02BF
joystick_scan =  $FF53
joystick_get = $FF56


;ZeroPage registers
;assume that these are very volatile
Z0 = $02
Z1 = $03
Z2 = $04
Z3 = $05
Z4 = $06
Z5 = $07

JOY1_DATA = $50
JOY2_DATA = $55
JOY3_DATA = $60
JOY4_DATA = $65

;32-bit data
M0 = $30 ; 31, 33, 34
M1 = $35 ; 36, 37, 38

;Sprite RAM locations
X_POS = $10 ; also includes two extra bits from $11
Y_POS = $12 ; also includes two extra bits from $13
X_POS2 = $14 ; also includes two extra bits from $15
Y_POS2 = $16 ; also includes two extra bits from $17
X_POS3 = $18 ; also includes two extra bits from $19
Y_POS3 = $1A ; also includes two extra bits from $1B
X_POS4 = $1C ; also includes two extra bits from $1D
Y_POS4 = $1E ; also includes two extra bits from $1F

;Sprite VRAM locations
SPRITE_DATA = $10000

UP_BUTTON = 1 << 3
DOWN_BUTTON = 1 << 2
LEFT_BUTTON = 1 << 1
RIGHT_BUTTON = 1
