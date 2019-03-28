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
	ldi		YL,0x34
	ldi		YH,0x12

MainLoop:
	sbiw	Y,1		; Y=Y-1

	; make 7seg off
	cbi		PORTB,2
	
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
	rcall	Waiter2	

	rjmp	MainLoop
; -----------------------------------

;subroutine
Clock:
	sbi		PORTB,1
	rcall	Waiter
	cbi		PORTB,1
	rcall	Waiter
	ret

;subroutine
Waiter:
	ldi		A,10
Wloop:
	dec		A
	brne	Wloop
	ret

;subroutine
Waiter2:
	ldi		XH,16
	ldi		XL,0
Wloop2:
	sbiw	X,1
	brne	Wloop2
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
	ror		C			;move bit to right
	ret

