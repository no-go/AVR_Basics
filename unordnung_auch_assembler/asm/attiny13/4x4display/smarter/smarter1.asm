.include "myTiny13.h"

.equ SCROLLSPEED, 230

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
U = 21
D = 22
; Like up- and down-Byte, but used for a LetterMix
H = 23
L = 24

Main:
;initial values
	ldi		A, 0b00011111	; up , down / 7 - 0 
	out		DDRB, A

	ldi		ZL, lo8(SY_74)
	ldi		ZH, hi8(SY_74)
	rcall	Preload
	rcall	MixIt

	ldi		ZL, lo8(SY_111)
	ldi		ZH, hi8(SY_111)
	rcall	Preload
	rcall	MixIt

	ldi		ZL, lo8(SY_99)
	ldi		ZH, hi8(SY_99)
	rcall	Preload
	rcall	MixIt
	
	ldi		ZL, lo8(SY_104)
	ldi		ZH, hi8(SY_104)
	rcall	Preload
	rcall	MixIt

	ldi		ZL, lo8(SY_101)
	ldi		ZH, hi8(SY_101)
	rcall	Preload
	rcall	MixIt

	ldi		ZL, lo8(SY_110)
	ldi		ZH, hi8(SY_110)
	rcall	Preload
	rcall	MixIt
	
	ldi		ZL, lo8(SY_32)
	ldi		ZH, hi8(SY_32)
	rcall	Preload
	rcall	MixIt

	rjmp	Main

;subroutine +++++++++++++++++++++++++++++++++++++++++++++++++
; Example Byte U and H
;     <<
; 7654  7654
; 3210  3210
; D     L

MixIt:

; make a single clear spaceline
	lsl		U				; result Letter(Up Byte) move left
	lsl		D				; result Letter(down Byte) move left
	cbr		U,0b00010000	; clear U(0)
	cbr		D,0b00010000	; clear D(0)
	rcall	Show

	ldi		N,4				; loop through 4 columns
NextStep:
	ldi		A,0b10000000	; routine for U(3) := H(7)
	and		A,H				; if Zero, then the bit was set!
	brne	SetU3
	cbr		U,0b00001000	; clear U(3)
	rjmp	U3Ready
SetU3:
	sbr		U,0b00001000
U3Ready:
	lsl		U				; result Letter(Up Byte) move left
	lsl		H				; source Letter(Up Byte) move left

	ldi		A,0b00010000	; routine for U(0) := H(4)
	and		A,H				; if Zero, then the bit was set!
	brne	SetU0
	cbr		U,0b00000001	; clear U(0)
	rjmp	U0Ready
SetU0:
	sbr		U,0b00000001
U0Ready:

; and now :-/ the same for the 2nd byte

	ldi		A,0b10000000	; routine for D(3) := L(7)
	and		A,L				; if Zero, then the bit was set!
	brne	SetD3
	cbr		D,0b00001000	; clear D(3)
	rjmp	D3Ready
SetD3:
	sbr		D,0b00001000
D3Ready:
	lsl		D				; result Letter(down Byte) move left
	lsl		L				; source Letter(down Byte) move left

	ldi		A,0b00010000	; routine for D(0) := L(4)
	and		A,L				; if Zero, then the bit was set!
	brne	SetD0
	cbr		D,0b00000001	; clear D(0)
	rjmp	D0Ready
SetD0:
	sbr		D,0b00000001
D0Ready:

; now its time to show mix
	push	N		; save
	rcall	Show
	pop		N		; restore
	dec		N
	brne	NextStep
	ret

;subroutine +++++++++++++++++++++++++++++++++++++++++++++++++
Preload:
	lpm
	mov		H,r0
	adiw	Z, 1
	lpm
	mov		L,r0
	ret

;subroutine +++++++++++++++++++++++++++++++++++++++++++++++++
Show:
	ldi		X, SCROLLSPEED	; X for a Letter-Loop (scrollspeed)
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

; Letters +++++++++++++++++++++++++++++++++++++
.org 0x0150
LETTERS:
.string "Jochen²"

.include "symbols_all.h"
