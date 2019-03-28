.include "myTiny13.h"

; sets Bit0 OFF if timer match 250, makes Bit0 ON if Timer if on TOP

.org 0x0000
	rjmp	Main
.org 0x0006
	rjmp	CompareFits

; fade via tick-length (=255-N)
.org 0x0010
CompareFits:
	; toggle
	ldi		A, 0b00010000
	in		B, PINB
	eor		A, B
	out		PORTB, A
	dec		N
	out		OCR0A, N
	reti

.org 0x0040
Main:
	sbi		DDRB, 0			; PortB0 is output = OC0A
	sbi		DDRB, 4			; PortB4 is output for IRQ ping
	
	ldi		A, 0b10000011	; Fast PWM 7
	out		TCCR0A, A
	ldi		A, 0b00001011	; timer: count on every 64 clock-ticks
	out		TCCR0B, A
	ldi		A, 0b00000100	; set timer-compare IRQ
	out		TIMSK0, A
	ldi		N, 250
	out		OCR0A, N
	sei

Loop:
	rjmp	Loop

