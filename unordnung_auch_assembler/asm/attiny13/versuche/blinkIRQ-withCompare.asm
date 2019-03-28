.include "myTiny13.h"

;irq Vector
.org 0x0000
	rjmp	OnReset
.org 0x0006
	rjmp	TimerComp ; Timer-Compare Interrupt

.org 0x0010
TimerComp:
	; toggle
	ldi		A, 0b00010000
	in		B, PINB
	eor		A, B
	out		PORTB, A
	reti

.org 0x0030
OnReset:
	sbi		DDRB, 4			; PortB4 is output
	ldi		A, 0b01000010	; CTC - Clear Timer on Compare Mode -WGM210 = 010
	out		TCCR0A, A		; See on Page 69
	ldi		A, 0b00000101	; timer: count on every 1024 clock-ticks
	out		TCCR0B, A
	ldi		A, 0b00000100	; enable timer-compare IRQ
	out		TIMSK0, A
	ldi		A, 80			; set compare register
	out		OCR0A, A
	sei						; IRQ allow

MainLoop:
	nop
	rjmp	MainLoop

