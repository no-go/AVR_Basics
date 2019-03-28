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
	
; fill stack with letters-Adr ???

;----------------------------------------------------------
	ldi		XH, 4			; X = 1024 as Loop counter
	ldi		XL, 0			; Low is Zero after brne
LetterH:
	ldi		ZL, lo8(SYM_H)
	ldi		ZH, hi8(SYM_H)
	rcall	SymbolShow
	sbiw	X, 1			; X = X-1
	brne	LetterH
;----------------------------------------------------------	
	ldi		XH, 4
LetterA:
	ldi		ZL, lo8(SYM_A)
	ldi		ZH, hi8(SYM_A)
	rcall	SymbolShow
	sbiw	X, 1
	brne	LetterA
;----------------------------------------------------------	
	ldi		XH, 8
LetterL:
	ldi		ZL, lo8(SYM_L)
	ldi		ZH, hi8(SYM_L)
	rcall	SymbolShow
	sbiw	X, 1
	brne	LetterL
;----------------------------------------------------------	
	ldi		XH, 4
LetterO:
	ldi		ZL, lo8(SYM_O)
	ldi		ZH, hi8(SYM_O)
	rcall	SymbolShow
	sbiw	X, 1
	brne	LetterO
;----------------------------------------------------------	
	ldi		XH, 4
LetterSig:
	ldi		ZL, lo8(SYM_SIG)
	ldi		ZH, hi8(SYM_SIG)
	rcall	SymbolShow
	sbiw	X, 1
	brne	LetterSig
;----------------------------------------------------------	
	ldi		XH, 4
Waiter:
	sbiw	X, 1
	brne	Waiter

	rjmp	Main

;subroutine
SymbolShow:
	lpm					; r0 :=(Z)
	mov 	I, r0
	cpi		I, 0xFF		; Last LED?
	breq	RetToMain	; then return
	out		PORTB, I	; else Show	
	adiw	Z, 1		; next LED on address Z := Z+1
	rjmp	SymbolShow
RetToMain:
	ret

;Memory
SYM_H:
.byte  0, 0, 0, 0
.byte 15, 0,13, 0
.byte 23,22,21, 0
.byte 19, 0,17, 0
.byte 0xFF

SYM_A:
.byte  0,10, 0, 0
.byte 15, 0,13, 0
.byte 23,22,21, 0
.byte 19, 0,17, 0
.byte 0xFF

SYM_L:
.byte 11, 0, 0, 0
.byte 15, 0, 0, 0
.byte 23, 0, 0, 0
.byte 19,18,17, 0
.byte 0xFF

SYM_O:
.byte  0,10, 0, 0
.byte 15, 0,13, 0
.byte 23, 0,21, 0
.byte  0,18, 0, 0
.byte 0xFF

SYM_SIG:
.byte  0, 0, 9, 0
.byte  0, 0,13, 0
.byte  0, 0, 0, 0
.byte  0, 0,17, 0
.byte 0xFF
