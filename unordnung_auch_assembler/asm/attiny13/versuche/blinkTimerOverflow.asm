.include "myTiny13.h"
Main:
	sbi		DDRB, 4	; PortB4 is output

	ldi		A, 0b00000101 ; timer auf clock/1024
	out		TCCR0B, A
	
loop:
	cbi		PORTB, 4	; bit4 = 0
	rcall	Waiter
	sbi		PORTB, 4	; bit4 = 1
	rcall	Waiter
	rjmp	loop


Waiter:
	in		A, TIFR0		; load timer counter
	andi	A, 0b00000010	; (TOV0 - Timer overflow)
	breq 	Waiter			; loop while overflow is set
	ldi		A, 0b00000010	; clear it via write a 1
	out		TIFR0, A
	ret

