.include "myTiny13.h"
			;         43210
			;         HV
Main:		;        r  RGB
	ldi		r16, 0b00011111	; H: new line, V: new frame, Red Green Blue
	out		DDRB, r16
	
Loop:
	cbi		PORTB, 4
	sbi		PORTB, 4
	rjmp	Loop
