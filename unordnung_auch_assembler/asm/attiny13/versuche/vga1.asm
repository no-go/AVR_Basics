.include "myTiny13.h"

.equ XPIX, 8
.equ YPIX, 6

WIDTH = 16
LINES = 17
       
			;         HV
Main:		;           RGB
	ldi		r16, 0b00011111	; H: new line, V: new frame, Red Green Blue
	out		DDRB, r16
	out		PORTB, r16
	ldi		WIDTH, XPIX
	ldi		LINES, YPIX
	
Loop:
	rcall	ColorCycle
	dec		WIDTH
	breq	LineReady
	rjmp	Loop

LineReady:
	ldi		WIDTH, XPIX
	dec		LINES
	breq	FrameReady
	rcall	NewLine
	rjmp	Loop

FrameReady:
	ldi		LINES, YPIX
	rcall	NewFrame
	rjmp	Loop

; subroutine
NewLine:
	rcall	Waiter
	cbi		PORTB, 4	; 4 = H ticks down, V still positive
	rcall	Waiter
	sbi		PORTB, 4	; H ticks up - New Line starts
	ret

; subroutine
NewFrame:
	rcall	Waiter
	cbi		PORTB, 3	; H & V ticks down
	rcall	Waiter
	cbi		PORTB, 4
	rcall	Waiter
	sbi		PORTB, 4	; H ticks up
	rcall	Waiter
	sbi		PORTB, 3	; V ticks up - New Frame starts
	rcall	Waiter
	ret

;subroutine
Waiter:
	push	r16
	ldi		r16, 30
WL: dec		r16
	brne	WL
	pop		r16
	ret

; Subroutine
ColorCycle:
	push	r17 
	push	r18 
	ldi		r18, 0b00000101	; bitmask = Black or Mangenta
	in		r17, PORTB
	eor		r18, r17		; r18 := r18 XOR r17
	out		PORTB, r18 
	pop		r18 
	pop		r17 
	ret

