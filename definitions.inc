!ifdef DEFINITIONS_INC !eof
DEFINITIONS_INC=1

GETJOY =  $FF06
JOY1 = $EF
JOY2 = $F2

;ZeroPage registers
;assume that these are very volatile
Z0 = $00
Z1 = $01
Z2 = $02
Z3 = $04
Z4 = $05
Z5 = $06

;Sprite RAM locations
X_POS = $10 ; also includes two extra bits from $11
Y_POS = $12 ; also includes two extra bits from $13
X_POS2 = $14 ; also includes two extra bits from $15
Y_POS2 = $16 ; also includes two extra bits from $17

;Sprite VRAM locations
SPRITE_DATA = $10000

A_BUTTON = 1 << 7
B_BUTTON = 1 << 6
SELECT_BUTTON = 1 << 5
START_BUTTON = 1 << 4
UP_BUTTON = 1 << 3
DOWN_BUTTON = 1 << 2
LEFT_BUTTON = 1 << 1
RIGHT_BUTTON = 1

;screen size
SCREEN_WIDTH = 80
SCREEN_HEIGHT = 60
