.include "myTiny13.h"

Main:
	sbi		DDRB, 1			; PortB1 is output = OC0B
	ldi		A, 0b00110011	; Fast PWM Mode 7 with a set on Compare for OC0B
	out		TCCR0A, A
	ldi		A, 0b00001101	; timer: count on every 1024 clock-ticks
	out		TCCR0B, A
	ldi		A, 10
	out		OCR0A, A		; set Compare for Timer

MainLoop:
	rjmp	MainLoop

