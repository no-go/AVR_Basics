.include "myTiny13.h"

Main:
;initial values
			;        .---On
			;        |.--Clk
			;        ||.-Data
	ldi		A,0b00000111
	out		DDRB,A
	ldi		A,0
	out		PORTB,A

	; make 7seg on
	sbi		PORTB,2

MainLoop:
	; 5 = 0101
	sbi		PORTB,0
	rcall	Clock
	cbi		PORTB,0
	rcall	Clock
	sbi		PORTB,0
	rcall	Clock
	cbi		PORTB,0
	rcall	Clock

	rjmp	MainLoop

Clock:
	sbi		PORTB,1
	cbi		PORTB,1
	rcall	Waiter
	ret

Waiter:
	ldi		XH,8
	ldi		XL,0
Wloop:
	sbiw	X,1
	brne	Wloop
	ret

