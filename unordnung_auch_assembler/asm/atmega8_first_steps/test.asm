.equ PORTD,0x12
.equ DDRD,0x11
.equ PIND,0x10
#.include "m8def.inc"

Start:
	ldi		r16,0b00001111
	out		DDRD,r16

Loop:
	in		r16,PIND
	lsr		r16
	lsr		r16
	lsr		r16
	lsr		r16
	out		PORTD,r16
	rjmp	Loop

