.org 0x0200

;first byte:  - - x -
;             - x x -
;second byte: - - x -
;             - - x -
SY_1:
.byte 0b00100110,0b00100010

SY_H:
.byte 0b10011111,0b10011001

SY_aa:
.byte 0b01100010,0b11101111

SY_ll:
.byte 0b01000100,0b01000010

SY_oo:
.byte 0b00000100,0b10100100

SY_SPACE:
.byte 0, 0

SY_W:
.byte 0b10011001,0b11011010

SY_ee:
.byte 0b11001110,0b10000110

SY_tt:
.byte 0b01001110,0b01000010

; !
SY_sign:
.byte 0b00100010,0b00000010

SY_A:
.byte 0b01001010,0b11101010

SY_L:
.byte 0b10001000,0b10001110

SY_O:
.byte 0b01001010,0b10100100
