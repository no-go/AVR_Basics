; atTINY 13 - Board without 7seg display
.equ PORTB, 0x18
.equ DDRB, 0x17
.equ PINB, 0x16
.equ TCCR0B, 0x33
.equ TCNT0, 0x32

; 16 bit register
Z = 30
ZH = 31
ZL = 30

Y = 28
YH = 29
YL = 28

		ldi		r16, 0b00000001	; Pin 0 is output
		out		DDRB, r16
			
; Plays "3x3 ist neune, ..." Pipilangstrumpf Titlesound ==============

Start:	ldi		ZL, lo8(TONE)
		ldi		ZH, hi8(TONE)
		ldi		YL, lo8(LENG)
		ldi		YH, lo8(LENG)
		lpm						; r0 :=(Z)
Next:	ldi		r16, 40			; wait a bit to play next tone
LL:		dec		r16
		brne	LL
		mov 	r17, r0 		; copy r0 to tonefreq register = r17
		cpi		r17, 0xFF		; Last Tone?
		breq	Start
		push	Z				; set Z on Stack to use Z register for Y (XX)
		mov		Z, Y
		lpm
		mov		r16, r0			; length is in r16
		inc		Y				; incrase Y adress
		pop		Z				; restore Z from stack (XX)
		rcall	PlyTon
		adiw	Z, 1			; next tone on address Z := Z+1
		lpm						; load the value from 30:31 16bit
								; Register Z Adress to r0
		rjmp	Next

; Subroutine
PlyTon:	push	r16				; save register
LLL:	rcall	Ton				; loop, to play tone via length in r16
		dec		r16
		brne	LLL
		pop		r16				; restore register
		ret

; Subroutine
Ton:	push	r17				; save register
		push	r16
								; normierung der Tonlaenge
		ldi		r16, 200		; dauer
		sub		r16, r17		; dauer = 200 - ton(45 bis 150)	
Lenght:	rcall	Toggle
		rcall	Waiter
		dec		r16
		brne    Lenght
		pop		r16				; restore register
		pop		r17
		ret

; Subroutine
Waiter:	push	r17				; save register
WLL:	dec		r17				; time between toggles create tone freq
		brne	WLL
		pop		r17				; restore register
		ret

; Subroutine Toggle() toggles a bit
Toggle:	push	r17				; save register
		push	r18
		ldi		r18, 0b00000001	; bitmask
		in		r17, PORTB
		eor		r18, r17		; r18 := r18 XOR r17
		out		PORTB, r18
		pop		r18				; restore register
		pop		r17
		ret

;       C   D   E   F   G   A  H   C   D   E   F
;.byte 146,128,109,101,89, 78, 72, 62, 55, 47, 45 ,0xFF
TONE:
.byte 146,109,78,109, 89,  72,78,89,101
.byte 109,89,146,109, 101, 78
.byte 146,109,78,109, 89,  72,78,89,101
.byte 109,89,146,109, 101
.byte 78,78,78,            72,72, 72,78
.byte 89,89,89,89, 101,101, 109,101, 89
.byte 78,78,78,            72,72, 78
.byte 89,89,   101,109,101
.byte 0xFF

LENG:
.byte 13,10,10,10,    20, 5,5,5,5
.byte 10,10,13,10,    20, 20
.byte 13,10,10,10,    20, 5,5,5,5
.byte 10,10,13,10,    40
.byte 20,   10,10,    20,    10,5,5
.byte 10,5,5,   10,5,5,  10,10,20
.byte 20,   10,10,    20,   10,10
.byte 10,10,10,10,    40

