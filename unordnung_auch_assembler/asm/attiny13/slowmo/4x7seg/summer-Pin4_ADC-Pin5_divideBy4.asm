.include "myTiny13.h"

Main:
;initial values ----------------------------
			;      .------Poti
			;      |.-----Speaker
			;      || 
	ldi		A,0b00001111
	out		DDRB,A
	ldi		A,0
	out		PORTB,A

MainLoop:
	; toggle Sound-Bit
	ldi		A,0b00001000
	in		B,PINB
	eor		B,A
	out		PORTB,B

	rcall	GetADC
	rcall	WaiterX
	
	rjmp	MainLoop
; -----------------------------------

;subroutine
WaiterX:
	push	YH		; Save Y
	push	YL	
	mov		YH,XH	; Copy X into Y
	mov		YL,XL
	; devide Y by 2 -> High+Low make a Right-Shift
	clc
	ror		YH ; Ybit0 -> Carry
	ror		YL ; Carry -> Ybit7
	
	; devide Y by 2 -> High+Low make a Right-Shift
	clc
	ror		YH ; Ybit0 -> Carry
	ror		YL ; Carry -> Ybit7

WloopX:
	sbiw	Y,1
	brne	WloopX

	pop		YL		; Restore Y
	pop		YH
	ret

;subroutine
GetADC:
	push	A				; save A
	ldi		A,0b00000010	; 10 = ADC2 -> PB4
	out		ADMUX,A
; ADC		On,ADSC,ADIF (single conversion)
	ldi		A,0b11010000
	out		ADCSRA,A
getADCloop:
	sbis	ADCSRA,4		; ADIF Ready?
	rjmp	getADCloop
	in		XL,ADCL
	in		XH,ADCH
	pop		A				; restore A
	ret
