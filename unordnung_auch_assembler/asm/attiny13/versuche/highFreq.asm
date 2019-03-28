.include "myTiny13.h"

Main:
; if lfuse 7A -> not 9.6 MHz divided to 8
; if hfuse F9 -> Brown-Out is 00 = 4.3V because lower Voltage makes
;                write corrupt by high frequency
; set frequency higher in steps -> 7F = 200%
	ldi		r16, 0x00
SetFreq:
	inc		r16
	out		OSCCAL, r16
	cpi		r16, 0x7F
	brne	SetFreq
; now, we have a higher frequency!!

			;         43210
			;         HV
			;        r  RGB
	ldi		r16, 0b00011111	; H: new line, V: new frame, Red Green Blue
	out		DDRB, r16
	
Loop:
	cbi		PORTB, 4
	sbi		PORTB, 4
	rjmp	Loop
