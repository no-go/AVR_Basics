.include "myTiny13.h"

Main:
;initial values ----------------------------
			;        .---On
			;        |.--Clk
			;        ||.-Data
	ldi		A,0b00000111
	out		DDRB,A
	ldi		A,0
	out		PORTB,A
	; StartValue
	ldi		YL,0x00
	ldi		YH,0x00	; Y has 4 digits: HH LL

MainLoop:
	; make 7seg off
	cbi		PORTB,2
	rcall	AddOneToY
	
	ldi		N,9		;fill 8 flipflops with C (N=8..1) if N=0 then jump
	mov		C,YL
NextLowBit:
	dec		N
	breq	HighBit
	rcall	AnalyseC
	rjmp	NextLowBit

HighBit:
	ldi		N,9		;fill 8 flipflops with C (N=8..1) if N=0 then jump
	mov		C,YH
NextHighBit:
	dec		N
	breq	Power7seg
	rcall	AnalyseC
	rjmp	NextHighBit
	
Power7seg:
	; make 7seg on
	sbi		PORTB,2
	rcall	Waiter

	rjmp	MainLoop
; -----------------------------------

;subroutine
Clock:
	sbi		PORTB,1
	nop
	cbi		PORTB,1
	ret

;subroutine
Waiter:
	ldi		XH,8
	ldi		XL,0
Wloop:
	sbiw	X,1
	brne	Wloop
	ret

;subroutine
AnalyseC:
	mov		A,C
	andi	A,0b00000001		
	breq	WasZero
	sbi		PORTB,0
	rjmp	ClkTick
WasZero:
	cbi		PORTB,0
ClkTick:
	rcall	Clock
	ror		C			; move bit to right
	ret

;subroutine (add a 6 on High and Low Bit, neccessary to get DEC instead of Hex)
AddOneToY:
	ldi		A,1
	add		YL,A	; YL = YL +1
	in		A,SREG	; save status
	push	A

CheckLL:
	ldi		A,0x0F
	and		A,YL	; now A has only the lower 4 bit (L)
	cpi		A,0x0A	; is A=10 ?
	breq	Add6LL
	rjmp	CheckLH
Add6LL:
	ldi		A,0x06
	add		YL,A
CheckLH:
	ldi		A,0xF0
	and		A,YL	; now A has only the higher 4 bit (H)
	cpi		A,0xA0	; is A=10 ?
	breq	Add6LH
	rjmp	CheckHL
Add6LH:
	ldi		A,0x60
	add		YL,A
	pop		A
	in		A,SREG	; save status	
	push	A

CheckHL:
	pop		A
	out		SREG,A	; restore status
	ldi		A,0
	adc		YH,A	; YH = YH +0 +Carry

; alles nochmal mit YH ---------------------

	ldi		A,0x0F
	and		A,YH	; now A has only the lower 4 bit (L)
	cpi		A,0x0A	; is A=10 ?
	breq	Add6HL
	rjmp	CheckHH
Add6HL:
	ldi		A,0x06
	add		YH,A
CheckHH:
	ldi		A,0xF0
	and		A,YH	; now A has only the higher 4 bit (H)
	cpi		A,0xA0	; is A=10 ?
	breq	Add6HH
	rjmp	EndCheck
Add6HH:
	ldi		A,0x60
	add		YH,A

EndCheck:
	ret

