; Bits:
; 7 6 5 4 3 = tone
;         C   D   E   F   G   A   H   C   D   E   F
;.byte 0,146,128,109,101, 89, 78, 72, 62, 55, 47, 45
;  ???     Cis Dis Es  Fis Gis  As  b  Cis Dis  Es Fis
;.byte     139,119,106, 95, 83, 75, 67, 59, 51, 46, 43

; 2 1 0     = tone-length
; 1    1/2  1/4  1/8  1/16

.org 0x0000
.byte 0b00001010,0b00011010,0b00111010,0b00011010
.byte 0b00101001,0b00111011,0b00110011,0b00101011
.byte 0b00100011,0b00011010,0b00101010,0b00001010
.byte 0b00011010,0b00100001,0b00110001,0,0,0
.byte 0xFF


