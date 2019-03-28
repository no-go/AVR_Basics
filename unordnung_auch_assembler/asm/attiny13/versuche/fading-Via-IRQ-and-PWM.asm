.include "myTiny13.h"

; sets Bit0 OFF if timer match 250, makes Bit0 ON if Timer if on TOP

.org 0x0000
	rjmp	Main
.org 0x0006
	rjmp	CompareFits

; fade via tick-length (=255-N)
.org 0x0010
CompareFits:
	; toggle Bit4
	ldi		A, 0b00010000
	in		B, PINB
	eor		A, B
	out		PORTB, A
	; change compareValue to make IRQ earlier
	dec		N
	out		OCR0A, N
	reti

.org 0x0040
Main:
	sbi		DDRB, 4			; PortB4 is output for IRQ ping
	
	ldi		A, 0b10000001	; PWM mode 1 (phase correct!!)
	out		TCCR0A, A
	ldi		A, 0b00000010	; timer: count on every 8 clock-ticks
	out		TCCR0B, A
	ldi		A, 0b00000100	; say timer to make IRQ on a fiting compare
	out		TIMSK0, A
	ldi		N, 100
	sei

Loop:
	rjmp	Loop

