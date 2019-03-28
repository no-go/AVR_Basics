.include "myTiny13.h"


; This Programm analysed 2 bytes to make a sequence of numbers
; who represents the LEDs, which have to be ON : 
;
; Positions (0=off)
; ---------------------
; 11,10, 9, 8
; 15,14,13,12
; 23,22,21,20
; 19,18,17,16

; Register to Load up- and down-Byte
U = 19
D = 20

Main:
;initial values
	ldi		A, 0b00011111	; up , down / 7 - 0 
	out		DDRB, A

	ldi		ZL, lo8(SY_W)
	ldi		ZH, hi8(SY_W)
	rcall	Preload
	rcall	Show
	
	ldi		ZL, lo8(SY_ee)
	ldi		ZH, hi8(SY_ee)
	rcall	Preload
	rcall	Show
	
	ldi		ZL, lo8(SY_ll)
	ldi		ZH, hi8(SY_ll)
	rcall	Preload
	rcall	Show

	ldi		ZL, lo8(SY_tt)
	ldi		ZH, hi8(SY_tt)
	rcall	Preload
	rcall	Show

	rjmp	Main

;subroutine +++++++++++++++++++++++++++++++++++++++++++++++++
Preload:
	lpm
	mov		U,r0
	adiw	Z, 1
	lpm
	mov		D,r0
	ret

;subroutine +++++++++++++++++++++++++++++++++++++++++++++++++
Show:
	ldi		XH, 2		; X for a Letter-Loop
	ldi		XL, 0
LetterLoop:
	ldi		I, 0
	ldi		N, 11		; we need N to calculate number for LED
ByteLoop:
	inc 	I
	; if I = 1 : use mov A, RegUP
	; if I = 2 : use mov A, RegDN
	; if I = 3 : Loop The Letter
	cpi		I, 1
	brne	Qis2nd
	mov		A, U
Qis2nd:
	cpi		I, 2
	brne	Qis3rd	
	mov		A, D
Qis3rd:
	cpi		I, 3		; is the final second byte still loaded?
	breq	MakeLLoop	; Make a Letter-Loop Descission
	
; ByteAnalyse START -----------------------------------------
Analyse:
	rol		A			; move highest bit to carry
	brcs	CalcByte	; branch if carry set, else
	ldi		B, 0		; set output to Zero and ...
	out		PORTB, B
	rjmp	LineOne		; .. do not make CalcByte

CalcByte:				; ok, Carry is set so we have to do something
	out		PORTB, N

LineOne:
	cpi		N, 8		; if 8, we have to go to next LED-Line (N=15)
	brne	LineTwo
	ldi		N, 16		; need +1 because of dec
	rjmp	NextBitEnd	; end

LineTwo:
	cpi		N, 12		; if 12, we have to go to next LED-Line (N=23)
	brne	LineThreeFour
	ldi		N, 23
	rjmp	ByteLoop
	
LineThreeFour:
	cpi		N, 16		; if 16, we have the last LED reached
	breq	MakeLLoop	; jump out of the Analyse Loop
	
NextBitEnd:
	dec		N
	rjmp	Analyse
; ByteAnalyse END ------------------------------------------

MakeLLoop:
	sbiw	X, 1
	brne	LetterLoop
	ret

.include "symbols_small.h"
