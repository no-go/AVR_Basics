.include "myTiny13.h"

; 0 1 2 3 up = minus
; 4 5 6 7
; 4 5 6 7 down = minus 
; 0 1 2 3

Main:
;initial values
			;   down  up
			;       \/
	ldi		A, 0b00011111	; up- , down- / 7 6 5 4 / 3 2 1 0 
	out		DDRB, A
	
Loop:
			;   down  up
			;       \/
	ldi		A, 0b00001000
	out		PORTB, A
	ldi		A, 0b00001001
	out		PORTB, A
	ldi		A, 0b00001010
	out		PORTB, A
	ldi		A, 0b00001011
	out		PORTB, A
	; -----------------------
			;   down  up
			;       \/
	ldi		A, 0b00001100
	out		PORTB, A
	ldi		A, 0b00001101
	out		PORTB, A
	ldi		A, 0b00001110
	out		PORTB, A
	ldi		A, 0b00001111
	out		PORTB, A
	; -----------------------
			;   down  up
			;       \/
	ldi		A, 0b00010100
	out		PORTB, A
	ldi		A, 0b00010101
	out		PORTB, A
	ldi		A, 0b00010110
	out		PORTB, A
	ldi		A, 0b00010111
	out		PORTB, A
	; -----------------------
			;   down  up
			;       \/
	ldi		A, 0b00010000
	out		PORTB, A
	ldi		A, 0b00010001
	out		PORTB, A
	ldi		A, 0b00010010
	out		PORTB, A
	ldi		A, 0b00010011
	out		PORTB, A
	; -----------------------
	rjmp	Loop

