; atTINY 13 - Board without 7seg display
.equ PORTB,0x18
.equ DDRB,0x17

Start:
	ldi		r16, 0b010000	; Pin 4 is output
	out		DDRB, r16
	ldi		r24, 0xFF		; initial for the wait loop
	ldi		r16, 0			; direction 0 = Up / 1 = Down

Loop:
	sbi		PORTB, 4		; set spk on
	rcall	R24wait			; go to wait loop
	cbi		PORTB, 4		; set spk off
	rcall	R24wait			; go to wait loop

	; reduce or enlarge waittime to change tone
	tst		r16				; if r16 Direction = 0
	breq	makeToneHigher
	rjmp	makeToneLower	; <- else

makeToneHigher:
	dec		r24				; r24 := r24 - 1
	breq	SetDown			; if to hight (0 = 1 -1), make now Direction down
	rjmp	Loop			; <- else

makeToneLower:
	inc		r24				; r24 := r24 + 1	
	breq	SetUp			; if to low (0 = 255 +1), make now Direction up
	rjmp	Loop			; <- else

SetUp:
	ldi		r24, 255		; start count down
	ldi		r16, 0
	rjmp 	Loop

SetDown:
	ldi		r24, 0			; start count up
	ldi		r16, 1
	rjmp 	Loop

R24wait:
	push	r24				; save register

R24waitLoop:
	dec		r24				; r24 := r24 - 1
	brne	R24waitLoop		; make loop, if not finish: Z != 0
	pop		r24				; restore register
	ret						; return from subroutine

