.include "myTiny13.h"

Main:
;initial values ----------------------------
			;        .------Poti
			;        |.-----Speaker
			;        || 
	ldi		A,0b00000010
	out		DDRB,A
	ldi		A,0
	out		PORTB,A

MainLoop:
	; toggle Sound-Bit
	ldi		A,0b00000010
	in		B,PINB
	eor		B,A
	out		PORTB,B

	rcall	GetADC

; split the X value into 5 steps/partitions/tones

	cpi		X,200		; X >= 200 ? -> X=50, else jump to next compare
	brlo	step4
	ldi		X,50
	rjmp	stepEnd
step4:
	cpi		X,150		; X >= 150 ? -> X=70
	brlo	step3
	ldi		X,80
	rjmp	stepEnd
step3:
	cpi		X,100
	brlo	step2
	ldi		X,110
	rjmp	stepEnd
step2:
	cpi		X,50
	brlo	step1
	ldi		X,140
	rjmp	stepEnd
step1:					; default X=170
	ldi		X,170

stepEnd:
	clr		XH ; only work with XL
	rcall	WaiterX
	
	rjmp	MainLoop
; -----------------------------------

;subroutine
WaiterX:
	push	YH		; Save Y
	push	YL	
	mov		YH,XH	; Copy X into Y
	mov		YL,XL
WloopX:
	sbiw	Y,1
	brne	WloopX

	pop		YL		; Restore Y
	pop		YH
	ret

;subroutine
GetADC:
	push	A				; save A
	ldi		A,0b00000001	; 01 = ADC1 -> PB2
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

	pop		A				; restore A
	ret
