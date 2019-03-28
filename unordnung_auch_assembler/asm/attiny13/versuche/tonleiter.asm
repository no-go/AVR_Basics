; atTINY 13 - Board without 7seg display
.equ PORTB, 0x18
.equ DDRB, 0x17
.equ PINB, 0x16
.equ TCCR0B, 0x33
.equ TCNT0, 0x32

Z = 30
ZH = 31
ZL = 30

.section .text
			ldi		r16, 0b00010000	; Pin 4 is output
			out		DDRB, r16
			
Start:		ldi		ZL, lo8(TTTT)
			ldi		ZH, hi8(TTTT)
			lpm						; r0 :=(Z)
			
Next:		mov 	r17, r0 		; copy r0 to tonefreq register = r17
			cpi		r17, 0xFF		; Last Tone?
			breq	Start
			rcall	Tone1
			adiw	Z, 1			; next toneon address Z := Z+1
			lpm						; load the value from 30:31 16bit Register Z Adress to r0
			rjmp	Next

; Subroutine
Tone1:
	push	r16
	ldi		r16, 30
LL:	rcall	Tone
	dec		r16
	brne	LL
	pop		r16
	ret

; Subroutine
Tone:
			push	r17
			push	r16
			ldi		r16, 201		; dauer
			sub		r16, r17		; dauer = 90 - ton(30 bis 80)	
Lenght:		rcall	Toggle
			rcall	Waiter
			dec		r16
			brne    Lenght
			pop		r16				; wiederherstellen
			pop		r17
			ret

; Subroutine
Waiter:
			push	r17
WLoop:		dec		r17				; zeit zwischen toggles = ton
			brne	WLoop
			pop		r17
			ret

; Subroutine Toggle() toggles a bit
Toggle:
			push	r17
			push	r18
			ldi		r18, 0b00010000	; bitmask
			in		r17, PORTB
			eor		r18, r17		; r18 := r18 XOR r17
			out		PORTB, r18
			pop		r18
			pop		r17
			ret

TTTT:
.byte 106,101,89,78,72,62,55,47,45,0xFF
;.byte 45,47,55,62,72,78,89,101,108,0xFF
