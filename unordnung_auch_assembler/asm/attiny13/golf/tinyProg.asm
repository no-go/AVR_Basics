.include "myTiny13.h"

Main:
;initial values ----------------------------
			;       .------Poti is input
			;       |.----- max is output
			;       ||.---- ok  is output
			;       |||.----min is output
	ldi		A,0b00000111
	out		DDRB,A
	ldi		A,0		; start: all on (Leds gets -)
	out		PORTB,A

	rcall	GetADC	; get Poti value -> X (low)
	mov		r5,XL	; save power-on value in R5
	ldi		C,5		; sace tollerance in C: +/- value
	
MainLoop:
	rcall	GetADC

	mov		B,r5
	add		B,C
	cp		XL,B			; to high: X > r5+C
	brlo	step2			; jump to step2 if lower
	ldi		B,0b00000011
	out		PORTB,B
	rjmp	stepEnd			; jump to end
step2:
	mov		B,r5
	sub		B,C
	cp		XL,B			; ok: X >= r5-C
	brlo	step1
	ldi		B,0b00000101	; the middle LED gets 0 = Minus
	out		PORTB,B
	rjmp	stepEnd
step1:						; default: to low
	ldi		B,0b00000110
	out		PORTB,B

stepEnd:
	rjmp	MainLoop	; endless loop
	
;subroutine ---------------------------------
GetADC:
	ldi		A,0b00000011	; 11 = ADC3 -> PB3
	out		ADMUX,A
; ADC		On,ADSC,ADIF (single conversion)
	ldi		A,0b11010000
	out		ADCSRA,A
getADCloop:
	sbis	ADCSRA,4		; ADIF Ready?
	rjmp	getADCloop
	in		XL,ADCL
	in		XH,ADCH

	; devide by 4: make 10bit to 8bit
	clc
	ror		XH ; bit0 -> Carry
	ror		XL ; Carry -> bit7
	clc
	ror		XH ; bit0 -> Carry
	ror		XL ; Carry -> bit7

	ret
