.include "myTiny13.h"

; 0 1 2 3 up = minus
; 4 5 6 7
; 4 5 6 7 down = minus 
; 0 1 2 3

Main:
;initial values
			;   down  up
			;       \/		; Werte: 8-23
	ldi		A, 0b00011111	; up- , down- / 7 6 5 4 / 3 2 1 0 
	out		DDRB, A
	ldi		N, 7
Loop:
	inc		N
	cpi		N, 24
	breq	Main
	out		PORTB, N
	; -----------------------
	rjmp	Loop

