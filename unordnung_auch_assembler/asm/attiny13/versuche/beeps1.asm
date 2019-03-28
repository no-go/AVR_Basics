; atTINY 13 - Board without 7seg display
.equ PORTB, 0x18
.equ DDRB, 0x17

; set Port-direction
Start:
	ldi		r16, 0b010000	; Pin 4 is output
	out		DDRB, r16

Main:
	ldi		r24, 0xFF		; for the tonefreq
	ldi		r25, 0x50		; tone lengh
	rcall 	Tone			; make a tone
	rcall	Waiter			; wait r24 times
	rjmp 	Main			; rerun

; Subroutine Tone(r25 = tone lenght, r24 = tonefreq)
Tone:
	push	r24				; save register
	push	r25
ToneLoop:
	sbi		PORTB, 4		; set spk on
	rcall	Waiter			; go to wait loop
	cbi		PORTB, 4		; set spk off
	rcall	Waiter			; go to wait loop
	dec		r25
	brne	ToneLoop
	pop		r25				; restore register
	pop		r24
	ret

; Subroutine Waiter(r24 = how long it is waiting)
Waiter:
	push	r24				; save register
WaiterLoop:
	dec		r24				; r24 := r24 - 1
	brne	WaiterLoop		; make loop, if not finish: Z != 0
	pop		r24				; restore register
	ret						; return from subroutine

