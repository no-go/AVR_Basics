.include "myTiny13.h"
Main:

; set frequency higher in steps -> 7F = 200%
	ldi		r16, 0x00
SetFreq:
	inc		r16
	out		OSCCAL, r16
	cpi		r16, 0x7F
	brne	SetFreq
; now, we have a higher frequency!!

	ldi		r16, 0b00011111	; all 5 are output
	out		DDRB, r16

	ldi		r16, 0b00000101 ; timer auf clock/1024
	out		TCCR0B, r16
	
loop:
	cbi		PORTB, 4	; bit4 = 0
	rcall	Waiter
	sbi		PORTB, 4	; bit4 = 1
	rcall	Waiter
	rjmp	loop


Waiter:
	in		r16, TCNT0		; load timer counter
	cpi		r16, 0
	brne 	Waiter			; loop while timer not 0
	ret
