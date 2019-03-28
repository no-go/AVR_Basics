.include "myTiny13.h"

.equ SENADC,0b00000010	; 10 = ADC2 -> PB4
.equ SENBIT,4			; PB4
.equ SPEAKER,3

;irq Vector
.org 0x0000
	rjmp	Main

.org 0x0010
Main:
	sbi		DDRB,SPEAKER	; output
	cbi		DDRB,SENBIT		; input
	
mainLoop:

; Toggle Speaker-Bit Start ----
	sbis	PORTB,SPEAKER
	rjmp	bitSet
	cbi		PORTB,SPEAKER
	rjmp	bitEnd
bitSet:
	sbi		PORTB,SPEAKER
bitEnd:
; Toggle Speaker-Bit End ------
	rcall	GetADC
	rcall	WaiterX
	rjmp	mainLoop


;subroutine -------------------------------------
WaiterX:
	subi	XL,100
WloopX:
	dec		XL
	brne	WloopX
	ret

;subroutine ------------------------------------
GetADC:
	push	A				; save A
	ldi		A,SENADC
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
