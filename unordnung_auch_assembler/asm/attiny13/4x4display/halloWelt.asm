.include "myTiny13.h"

; Positions
; ---------------------
; .byte 11,10, 9, 8
; .byte 15,14,13,12
; .byte 23,22,21,20
; .byte 19,18,17,16

Main:
;initial values
	ldi		A, 0b00011111	; up , down / 7 - 0 
	out		DDRB, A

	ldi		ZL, lo8(SY_SPACE)
	ldi		ZH, hi8(SY_SPACE)
	rcall	Show

	ldi		ZL, lo8(SY_H)
	ldi		ZH, hi8(SY_H)
	rcall	Show
	
	ldi		ZL, lo8(SY_aa)
	ldi		ZH, hi8(SY_aa)
	rcall	Show
	
	ldi		ZL, lo8(SY_ll)
	ldi		ZH, hi8(SY_ll)
	rcall	Show

	ldi		ZL, lo8(SY_ll)
	ldi		ZH, hi8(SY_ll)
	rcall	Show

	ldi		ZL, lo8(SY_oo)
	ldi		ZH, hi8(SY_oo)
	rcall	Show

	ldi		ZL, lo8(SY_SPACE)
	ldi		ZH, hi8(SY_SPACE)
	rcall	Show
		
	ldi		ZL, lo8(SY_W)
	ldi		ZH, hi8(SY_W)
	rcall	Show

	ldi		ZL, lo8(SY_ee)
	ldi		ZH, hi8(SY_ee)
	rcall	Show

	ldi		ZL, lo8(SY_ll)
	ldi		ZH, hi8(SY_ll)
	rcall	Show

	ldi		ZL, lo8(SY_tt)
	ldi		ZH, hi8(SY_tt)
	rcall	Show

	ldi		ZL, lo8(SY_sign)
	ldi		ZH, hi8(SY_sign)
	rcall	Show

	rjmp	Main

;subroutine
Show:
	ldi		XH, 4		; X for a Letter-Loop
	ldi		XL, 0
LetterLoop:
	push	Z
ByteLoop:
	lpm					; r0 :=(Z)
	mov 	I, r0
	cpi		I, 0xFF		; Last LED?
	breq	MakeLLoop	; Make a Letter-Loop Descission
	out		PORTB, I	; else Show	
	adiw	Z, 1		; next LED on address Z := Z+1
	rjmp	ByteLoop
MakeLLoop:
	pop		Z
	sbiw	X, 1
	brne	LetterLoop
	rcall	OffTick
	ret

;subroutine
OffTick:
	ldi		I, 0
	out		PORTB, I
	ldi		XH, 32
	ldi		XL, 0
WL:	sbiw	X, 1
	brne	WL
	ret


.include "symbols.h"
