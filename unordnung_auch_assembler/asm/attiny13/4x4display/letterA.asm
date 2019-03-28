.include "myTiny13.h"

; 0 1 2 3 up
; 4 5 6 7
; 4 5 6 7 down 
; 0 1 2 3

; Positions
; ---------------------
; .byte 11,10, 9, 8
; .byte 15,14,13,12
; .byte 23,22,21,20
; .byte 19,18,17,16

Main:
;initial values
			;   down  up
			;       \/		; Werte: 8-23
	ldi		A, 0b00011111	; up- , down- / 7 6 5 4 / 3 2 1 0 
	out		DDRB, A

	ldi		ZL, lo8(SYMBOL)
	ldi		ZH, hi8(SYMBOL)
	
Loop:
	lpm				; r0 :=(Z)
					; load the value from 30:31 16bit
					; Register Z Adress to r0
Waits:
	;rcall	Waiter
	dec		B		; 0-1 => 255
	brne	Waits
	
	mov 	A, r0
	cpi		A, 0xFF		; Last LED?
	breq	Main		; then restart
	out		PORTB, A	; else Show
	
	adiw	Z, 1		; next LED on address Z := Z+1
	rjmp	Loop

;subroutine
Waiter:
	ldi		A, 100
WL1:
	dec		A
	brne	WL1
	ret

;Memory
SYMBOL:
.byte  0,10, 0, 0
.byte 15, 0,13, 0
.byte 23,22,21, 0
.byte 19, 0,17, 0
.byte 0xFF
