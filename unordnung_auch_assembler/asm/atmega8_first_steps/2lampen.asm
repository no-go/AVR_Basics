.equ PORTD,0x12
.equ DDRD,0x11

;.org 0x00

Start:
	ldi		r16,0b00001111
	out		DDRD,r16
	ldi		r16,0b00000101
	out		PORTD,r16

Loop:
	rjmp	Loop

