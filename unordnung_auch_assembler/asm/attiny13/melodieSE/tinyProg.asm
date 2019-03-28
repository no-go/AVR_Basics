.include "myTiny13.h"

; r1 => has Tone
; r2 => has ToneLength

;irq Vector
.org 0x0000
	rjmp	OnReset
.org 0x0006
	rjmp	TimerComp ; Timer-Compare Interrupt

.org 0x0010
TimerComp:
	lpm		r1,Z+

	push	ZL		; save Z
	push	ZH
	mov		ZL,YL	; load Y into Z
	mov		ZH,YH
	lpm		r2,Z+	; get value from Z into r2 and make +1
	mov		YL,ZL	; store new Z into Y (where it komes from)
	mov		YH,ZH
	pop		ZH		; restore old Z
	pop		ZL
	
	out		OCR0A,r2	; set r2 as new Compare for Timer IRQ	
	reti

.org 0x0030
OnReset:
	ldi		A,0b00010000
	out		DDRB, A
	ldi		A, 0b01000010	; CTC - Clear Timer on Compare Mode
	out		TCCR0A, A
	ldi		A, 0b00000101	; timer: count on every .. clock-ticks
	out		TCCR0B, A
	ldi		A, 0b00000100	; enable timer-compare IRQ
	out		TIMSK0, A
	; Load startaddresses into Z/Y
	ldi		ZL, lo8(TONE)
	ldi		ZH, hi8(TONE)
	lpm		r1,Z+
	
	push	ZL
	push	ZH
	
	ldi		ZL, lo8(LENG)
	ldi		ZH, hi8(LENG)
	lpm		r2,Z+
	mov		YL,ZL
	mov		YH,ZH
	
	pop		ZH
	pop		ZL

	out		OCR0A,r2		; set r2 as new Compare for Timer IRQ	
	sei						; IRQ allow

MainLoop:
	ldi		A, 0b00010000	; toggle Bit No. 4
	in		B, PORTB
	eor		A, B
	out		PORTB, A
	mov		A,r1
	cpi		A,0xFF		; Last Tone?
	breq	OnReset		; than Restart
	rcall	WaiterR1
	rjmp	MainLoop

; subroutine
WaiterR1:
	push	A
	mov		A,r1
wr1Loop:
	dec		A
	brne	wr1Loop
	pop		A
	ret
	
;       C   D   E   F   G   A  H   C   D   E   F
;.byte 146,128,109,101,89, 78, 72, 62, 55, 47, 45 ,0xFF
TONE:
.byte 146,109,78,109, 89,  72,78,89,101
.byte 109,89,146,109, 101, 78
.byte 78,78,78,            72,72,78
.byte 89,89,101,109,  101
.byte 0xFF

LENG:
.byte 25,20,20,20,    40, 10,10,10,10
.byte 20,20,25,20,    40, 40
.byte 40,   20,20,    40,   20,20
.byte 20,20,20,20,    80
