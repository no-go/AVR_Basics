.include "myTiny13.h"

Main:
	sbi		DDRB, 4
Bittoggle:
	ldi		A, 0b00010000
	in		B, PINB
	eor		A, B
	out		PORTB, A
	ldi		XH, 255	; X := 128k
	ldi		XL, 255
Loop:
	sbiw	X, 1	; X = X-1
	breq	Bittoggle
	rjmp	Loop

