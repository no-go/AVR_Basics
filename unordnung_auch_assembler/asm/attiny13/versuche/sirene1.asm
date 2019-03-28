; atTINY 13 - Board without 7seg display
.equ PORTB,0x18
.equ DDRB,0x17

Start:
	ldi		r16, 0b010000	; Pin 4 is output
	out		DDRB, r16
	ldi		r24, 0xFF		; initial for the wait loop

Loop:
	sbi		PORTB, 4		; set spk on
	rcall	R24wait			; go to wait loop
	cbi		PORTB, 4		; set spk off
	rcall	R24wait			; go to wait loop

	; reduce wait now and make tone higher
	dec		r24				; r24 := r24 - 1
	brne	Loop			; make loop, if not finish: Z != 0
	ldi		r24, 0xFF		; set initial and restart
	rjmp	Loop

R24wait:
	push	r24				; save register

R24waitLoop:
	dec		r24				; r24 := r24 - 1
	brne	R24waitLoop		; make loop, if not finish: Z != 0
	pop		r24				; restore register
	ret						; return from subroutine

