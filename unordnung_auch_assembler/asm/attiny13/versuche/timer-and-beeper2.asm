; atTINY 13 - Board without 7seg display
.equ PORTB, 0x18
.equ DDRB, 0x17
.equ PINB, 0x16
.equ TCCR0B, 0x33
.equ TCNT0, 0x32

; set Port-direction and timer
; cpuclock/1024 -> 1 Tick in TCNT0. If 256 Tick -> start with zero

Start:		ldi		r16, 0b00010000	; Pin 4 is output
			out		DDRB, r16
			ldi		r16, 0b00000101 ; timer auf clock/1024
			out		TCCR0B, r16

			ldi		r17, 5			; startton

Loop:		in		r18, TCNT0		; load timer counter
			cpi		r18, 100
			brlo 	Loop			; loop while timer is lower 100
			clr		r18
			out		TCNT0, r18

			inc		r17				; +1 change tone
			rcall	Tone
			rjmp	Loop

Tone:
			push	r16
			push	r17
			ldi		r16, 10			; dauer
			sub		r16, r17		; dauer = 265 - ton	
Lenght:		rcall	Toggle
			rcall	Waiter
			dec		r16
			brne    Lenght
			pop		r17
			pop		r16
			ret
		
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

