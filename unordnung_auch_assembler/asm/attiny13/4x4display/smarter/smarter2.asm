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
	rcall	MixLetter

	ldi		ZL, lo8(SY_111)
	ldi		ZH, hi8(SY_111)
	rcall	Preload
	rcall	MixLetter

	ldi		ZL, lo8(SY_99)
	ldi		ZH, hi8(SY_99)
	rcall	Preload
	rcall	MixLetter

	rjmp	Main

;subroutine +++++++++++++++++++++++++++++++++++++++++++++++++
; Example Byte U and H
;     <<
; 7654  7654
; 3210  3210
; D     L

MixLetter:

; make a single clear spaceline
	lsl		U				; result Letter(Up Byte) move left
	lsl		D				; result Letter(down Byte) move left
	cbr		U,0b00010000	; clear U(0)
	cbr		D,0b00010000	; clear D(0)
	rcall	Show

	ldi		N,4				; loop through 4 columns
	
; mix the 1st byte ---------------
NextStep:
	mov		A,U
	mov		B,H
	rcall	MixBytes ; A & B are parameters
	mov		U,A
	mov		H,B

; and now the same for the 2nd byte ------------
	mov		A,D
	mov		B,L
	rcall	MixBytes ; A & B are parameters
	mov		D,A
	mov		L,B

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

;subroutine Mix A & B +++++++++++++++++++++++++++++++++++++++
MixBytes:
	push	C	; save register
	ldi		C,0b10000000	; routine for A(3) := B(7)
	and		C,B				; if Zero, then the bit was set!
	brne	SetA3
	cbr		A,0b00001000	; clear A(3)
	rjmp	A3Ready
SetA3:
	sbr		A,0b00001000
A3Ready:
	lsl		A				; result Letter(Up Byte) move left
	lsl		B				; source Letter(Up Byte) move left

	ldi		C,0b00010000	; routine for A(0) := B(4)
	and		C,B				; if Zero, then the bit was set!
	brne	SetA0
	cbr		A,0b00000001	; clear A(0)
	rjmp	A0Ready
SetA0:
	sbr		A,0b00000001
A0Ready:	
	pop		C 	; restore register
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
.org 0x0100
LETTERS:
.string "Jochen²"

.include "symbols_all.h"
