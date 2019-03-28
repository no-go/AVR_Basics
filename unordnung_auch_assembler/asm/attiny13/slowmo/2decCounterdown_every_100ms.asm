.include "myTiny13.h"

; this program counts decimal two 7seg-display from 99 to 00 !!!
; in counts every 0,10009 second

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
	ldi		B,50	; B=255-205: prescale makes counter half full -> overflow ca every 1/10 sec
;	ldi		B,128	; B=128: prescale makes counter half full -> overflow every 1/16 sec
	out		TCNT0,B
	pop		B
	reti

.org 0x0030
OnReset:
;initial values
			;      X8421	if X=1 then 10er Digit is on!
	ldi		A,0b00011111
	out		DDRB,A
	ldi		A,0b00000010	; timer auf clock/8 e.g. on 16kHz: tick every 1/2048 sec -> overflow every 1/8 sec
	out		TCCR0B,A
	ldi		A,0b00000010	; enable timer-overfl IRQ
	out		TIMSK0,A

	sei						; IRQ allow
	ldi		A,0x99
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
	ldi		A,0x99
	rjmp	Doit

