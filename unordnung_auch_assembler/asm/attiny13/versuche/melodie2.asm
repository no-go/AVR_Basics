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
			rcall	Tone
			rcall	Tone
			rcall	Tone
			rcall	Tone
			adiw	Z, 1			; next toneon address Z := Z+1
			lpm						; load the value from 30:31 16bit Register Z Adress to r0
			rjmp	Next


; Subroutine
Tone:
			push	r17
			push	r16
			ldi		r16, 81			; dauer
			sub		r16, r17		; dauer = 90 - ton(30 bis 80)
			lsl		r16				; *2	
			lsl		r16				; *2	
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
.byte 10,80,20,70,30,60,40,50,0xFF
