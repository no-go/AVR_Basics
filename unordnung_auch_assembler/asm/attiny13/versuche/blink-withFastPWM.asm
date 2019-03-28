.include "myTiny13.h"

; sets Bit0 OFF if timer match 250, makes Bit0 ON if Timer if on TOP

Main:
	sbi		DDRB, 0			; PortB0 is output = OC0A
	ldi		A, 0b10000011	; Fast PWM Mode
	out		TCCR0A, A
	ldi		A, 0b00000101	; timer: count on every 1024 clock-ticks
	out		TCCR0B, A
	ldi		A, 250
	out		OCR0A, A		; set Compare for Timer

Loop:
	rjmp	Loop

