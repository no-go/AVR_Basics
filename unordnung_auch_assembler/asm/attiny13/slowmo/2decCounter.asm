.include "myTiny13.h"

; this program counts decimal two 7seg-display from 00 to 99 !!!
; it is near to 1sec on a 16kHz clock!

;irq Vector
.org 0x0000
	rjmp	OnReset
.org 0x0003
	rjmp	TimerOVF


.org 0x0010
TimerOVF:
	; Count on every overflow
	push	B		; 2 clocks
	inc		A		; 1 clock
	ldi		B,234	; 1 clock ; Timer prevalue = 255-16 -5 
	out		TCNT0,B	; 1 clock
	pop		B
	reti

.org 0x0030
OnReset:
;initial values
			;      X8421	if X=1 then 10er Digit is on!
	ldi		A,0b00011111
	out		DDRB,A
	
	ldi		A,0b00000101	; timer auf clock/1024 e.g. on 16kHz: 16 ticks/sec
	out		TCCR0B,A
	ldi		A,0b00000010	; enable timer-overfl IRQ
	out		TIMSK0,A

	ldi		A,239			; Timer prevalue = 255-16
	out		TCNT0,A
	sei						; IRQ allow
	clr		A
	out		PORTB,A

MainLoop:
	; show number ---------
	mov		B,A				; B := A
	cpi		B,0x9A			; hex99 +1
	breq	SetZero
	mov		C,B				; load "decimal" into C
	LSR		C
	LSR		C
	LSR		C
	LSR		C				; C := C/16 -> move 10er Digit to 1er Digit
	push	C
	sbr		C,0b00010000	; 10er  = set bit4
	out		PORTB,C
	pop		C
	LSL		C
	LSL		C
	LSL		C
	LSL		C				; C := C*16 -> lost the 1er potence!
	sub		B,C
	cpi		B,0xA
	breq	SetNo0A
	cbr		B,0b00010000	; 1er  = clear bit4
	out		PORTB,B		
	rjmp	MainLoop

SetNo0A:
	subi	A,-6			; BCD code to make hex to decimal
	rjmp	MainLoop

SetZero:
	ldi		A,0
	rjmp	MainLoop
