.include "myTiny13.h"

;irq Vector
.org 0000
	rjmp	OnReset
.org 0003
	rjmp	TimerOVF

.org 0010
TimerOVF:
	; toggle
	ldi		A, 0b00010000
	in		B, PINB
	eor		A, B
	out		PORTB, A
	reti

.org 0030
OnReset:
	sbi		DDRB, 4			; PortB4 is output
	ldi		A, 0b00000101	; timer auf clock/1024
	out		TCCR0B, A
	ldi		A, 0b00000010	; enable timer-overfl IRQ
	out		TIMSK0, A
	sei						; IRQ allow

MainLoop:
	nop
	rjmp	MainLoop

