.include "myTiny13.h"

;irq Vector
.org 0x0000
	rjmp	OnReset
.org 0x0003
	rjmp	TimerOVF


.org 0x0010
TimerOVF:

	inc		I
	cpi		I,50
	brge	SkipIt
	out		TCNT0,I
SkipIt:
	rol		N	
	mov		A,N
	andi	A,0b00000001		
	breq	WasZero
	sbi		PORTB,1
	rjmp	ClkTick
WasZero:
	cbi		PORTB,1
ClkTick:
	sbi		PORTB,0
	cbi		PORTB,0
	reti

.org 0x0040
OnReset:
	;initial values
			;         .-Data 
			;         |.-Clk
	ldi		A,0b00011111
	out		DDRB,A
	ldi		A,0b00000010
	out		TCCR0B,A
	ldi		A,0b00000010	; enable timer-overfl IRQ
	out		TIMSK0,A
	ldi		I,130
	out		TCNT0,I
	sei						; IRQ allow
	
	; the 6LED looper starts at (stored in N)
	ldi		N,0b00000001
	cbi		PORTB,1

MainLoop:
	rjmp	MainLoop
