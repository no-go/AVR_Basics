.include "myTiny13.h"

; this program ticks every 1 sec the x Bit ob/off on a CPU Clock of "16kHz"

Main:
;initial values
			;       TRx
	ldi		A, 0b00010100
	out		DDRB, A
	ldi		A, 0b00000100
	mov		r1, A			; r1 = constant bitmask to toggle PORT-Bits
Loop:
	eor		A, r1
	out		PORTB, A
	rcall	Waiter
	rjmp	Loop

Waiter:
	ldi		XH,	0x10	; X= 16384 /4 = 4096 (16 kHz using 1024 as kilo)
	ldi		XL, 0x00
WLop:
	sbiw	X,1			; 2 clocks
	brne	WLop		; 2 clocks (compare & jump)
	ret