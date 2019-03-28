.include "myTiny13.h"
Main:

; set frequency higher in steps (50% = 4,8MHz) -> 7F = 100%
	ldi		r17, 0x00
	
	sbi		DDRB, 4			; PortB4 is output

	ldi		A, 0b00000101	; timer auf clock/1024
	out		TCCR0B, A
	
loop:
	inc		r17				; set freq higher
	out		OSCCAL, r17
	
	cbi		PORTB, 4	; bit4 = 0
	rcall	Waiter
	sbi		PORTB, 4	; bit4 = 1
	rcall	Waiter

	cpi		r17, 0x7F	; is highest? set to zero (save??)
	brne	loop
	ldi		r17, 0
	rjmp	loop


Waiter:
	in		A, TIFR0		; load timer counter
	andi	A, 0b00000010	; (TOV0 - Timer overflow)
	breq 	Waiter			; loop while overflow is set
	ldi		A, 0b00000010	; clear it via write a 1
	out		TIFR0, A
	ret

