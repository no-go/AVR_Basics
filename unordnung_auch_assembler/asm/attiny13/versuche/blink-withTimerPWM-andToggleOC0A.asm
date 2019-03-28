.include "myTiny13.h"

Main:
	sbi		DDRB, 0			; PortB0 is output = OC0A
	ldi		A, 0b01000011	; Fast PWM Mode 7 with a toggle on Compare for OC0A
	out		TCCR0A, A
	ldi		A, 0b00001101	; timer: count on every 1024 clock-ticks
	out		TCCR0B, A		; toggle: only if wgm2 = 1
	ldi		A, 90
	out		OCR0A, A		; set Compare for Timer

MainLoop:
	rjmp	MainLoop

