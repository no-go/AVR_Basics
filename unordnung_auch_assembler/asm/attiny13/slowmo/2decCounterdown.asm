.include "myTiny13.h"

; this program counts decimal two 7seg-display from 59 to 00 !!!
; near 1sec

;irq Vector
.org 0x0000
	rjmp	OnReset
.org 0x0003
	rjmp	TimerOVF


.org 0x0010
TimerOVF:
	; Countdown on every overflow
	push	B		; 2 clocks
	dec		A		; 1 clock
	ldi		B,239	; 1 clock ; Timer prevalue = 255-16 -5 ?
	out		TCNT0,B	; 1 clock
	pop		B
	reti

.org 0x0030
OnReset:
;initial values
			;      X8421	if X=1 then 10er Digit is on!
	ldi		A,0b00011111
	out		DDRB,A
							; 001,010,011,100,101 / 1,8,64,256,1024 ?	
	ldi		A,0b00000101	; timer auf clock/1024 e.g. on 16kHz: 16 ticks/sec
	out		TCCR0B,A
	ldi		A,0b00000010	; enable timer-overfl IRQ
	out		TIMSK0,A

	ldi		A,239			; Timer prevalue = 255-16
	out		TCNT0,A
	sei						; IRQ allow
	ldi		A,0x59
	out		PORTB,A

MainLoop:
	rcall	Ato2digi
	rjmp	MainLoop

;subroutine show A on the 2 7seg Display ++++++++++++++++++++++
Ato2digi:
	push	B
	push	C
Doit:
	mov		B,A				; B := A
	cpi		B,0xFF			; 255 -1 ?
	breq	SetFull
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
	cpi		B,0xF
	breq	SetNo0F
	cbr		B,0b00010000	; 1er  = clear bit4
	out		PORTB,B
	pop		C
	pop		B		
	ret
SetNo0F:
	subi	A,6				; BCD code to make hex to decimal
	rjmp	Doit
SetFull:
	ldi		A,0x59
	rjmp	Doit

