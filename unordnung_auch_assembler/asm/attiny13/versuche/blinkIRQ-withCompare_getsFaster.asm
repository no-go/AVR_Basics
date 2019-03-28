.include "myTiny13.h"

;irq Vector
.org 0x0000
	rjmp	OnReset
.org 0x0006
	rjmp	TimerComp ; Timer-Compare Interrupt

.org 0x0010
TimerComp:
	ldi		A, 0b00010000 ; toggle Bit No. 4
	in		B, PINB
	eor		A, B
	out		PORTB, A
	dec		N			; N = N-1
	brne	TcEnd		; IF N == 0 then N = 255
	ser		N
TcEnd:
	out		OCR0A, N	; set N as new Compare for Timer IRQ
	reti

.org 0x0030
OnReset:
	sbi		DDRB, 4			; PortB4 is output
	ldi		A, 0b01000010	; CTC - Clear Timer on Compare Mode
	out		TCCR0A, A
	ldi		A, 0b00000101	; timer: count on every 1024 clock-ticks
	out		TCCR0B, A
	ldi		A, 0b00000100	; enable timer-compare IRQ
	out		TIMSK0, A
	sei						; IRQ allow

MainLoop:
	nop
	rjmp	MainLoop

