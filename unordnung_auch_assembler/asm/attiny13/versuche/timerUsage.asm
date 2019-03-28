; atTINY 13 - Board without 7seg display
.equ PORTB, 0x18
.equ DDRB, 0x17
.equ PINB, 0x16
.equ TCCR0B, 0x33
.equ TCNT0, 0x32



; set Port-direction and timer
; cpuclock/1024 -> 1 Tick in TCNT0. If 256 Tick -> start with zero

Start:	ldi		r16, 0b00010000	; Pin 4 is output
		out		DDRB, r16
		ldi		r16, 0b00000101 ; timer auf clock/1024
		out		TCCR0B, r16

Loop:	clr		r16				; Led off
		out		PORTB, r16
		in		r16, TCNT0		; load timer counter
		cpi		r16, 0
		brne 	Loop			; loop while timer not 0

LedOn:	ldi		r16, 0b00010000	; led on
		out		PORTB, r16
		in      r16, TCNT0		; wait for 0
		cpi     r16, 0
		brne    LedOn			; led the led on
		rjmp    Loop

