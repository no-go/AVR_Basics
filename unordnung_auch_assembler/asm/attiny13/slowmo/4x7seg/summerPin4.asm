.include "myTiny13.h"

Main:
;initial values ----------------------------
			;       .-----Speaker
			;       |
			;       | 
	ldi		A,0b00001111
	out		DDRB,A
	ldi		A,0
	out		PORTB,A

MainLoop:
	; toggle
	ldi		A,0b00001000
	in		B,PINB
	eor		B,A
	out		PORTB,B
	rcall	WaiterFast
	rjmp	MainLoop
; -----------------------------------

;subroutine
Waiter:
;	ldi		XH,0x80	; 8000 => 1    sec on 128 kHz (X=32768)
	ldi		XH,0x0C	; 0CCD => 1/10 sec on 128 kHz (X= 3277)
	ldi		XL,0xCD
Wloop:
	sbiw	X,1
	brne	Wloop
	ret

;subroutine
WaiterFast:
	push	A		; save A
	ldi		A,100
	mov		r3,A	; Copy A into Register3
	pop		A		; restore A 
WloopF:
	dec		r3
	brne	WloopF
	ret
