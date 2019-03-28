.include "myTiny13.h"

;irq Vector
.org 0x0000
	rjmp	OnReset
.org 0x0006
	rjmp	TimerComp ; Timer-Compare Interrupt

.org 0x0010
TimerComp:
	adiw	Z,1	; next tone on address Z := Z+1	
	lpm			; r0 :=(Z)
	; N -> Tone length
	ldi		N,20
	out		OCR0A, N	; set N as new Compare for Timer IRQ
	reti

.org 0x0030
OnReset:
	ldi		A,0b00010000
	out		DDRB, A
	;ldi		A, 0b01000010	; CTC - Clear Timer on Compare Mode
	;out		TCCR0A, A
	;ldi		A, 0b00000101	; timer: count on every .. clock-ticks
	;out		TCCR0B, A
	;ldi		A, 0b00000100	; enable timer-compare IRQ
	;out		TIMSK0, A
	; Load startaddress into Z
	ldi		ZL, lo8(TONE)
	ldi		ZH, hi8(TONE)
	lpm
	;sei						; IRQ allow

.org 0x0050
MainLoop:
	ldi		A, 0b00010000	; toggle Bit No. 4
	in		B, PINB
	eor		A, B
	out		PORTB, A
	;mov		A,r0
	;cpi		A,0xFF		; Last Tone?
	;breq	OnReset		; than Restart
	rcall	WaiterR0
	rjmp	MainLoop

.org 0x0080
; subroutine
WaiterR0:
	push	A
	;mov		A,r0
	ldi		A,250
wr0Loop:
	dec		A
	brne	wr0Loop
	pop		A
	ret
	
.org 0x0100
TONE:
.byte 146,109,78,109,0xFF
