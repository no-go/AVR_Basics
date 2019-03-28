; atTINY 13 - Board without 7seg display
.equ PORTB, 0x18
.equ DDRB, 0x17
.equ PINB, 0x16

; set Port-direction
Start:
	ldi		r16, 0b010000	; Pin 4 is output
	out		DDRB, r16

Main:
	ldi		r31, hi8(mtab)	; set 16bit register to memfield
	ldi		r30, lo8(mtab)
	rcall	BeginnMelody
	rjmp 	Main			; re-run

; Subroutine Tone(r25 = tone length, r24 = tonefreq)
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
	ret					

; Toene
mtab:
.byte 61,30,40,89,41,10,17,5,10,3,12,13,2,50,85,80,38,0,55,90,5,0
.byte 0,0xFF

BeginnMelody:
	sbiw 	r30,1			; next tone
	lpm						; load the value from 30:31 16bit Register Adress to r0
	mov 	r24, r0 		; copy r0 to tonefreq register = r24
	ldi		r25, 0x50		; constant tone length
	rcall	Tone
	rcall	Waiter			; wait r24 times between tones
	cpi		r24, 0xFF		; Last Tone?
	brne 	BeginnMelody	; if not last tone, then re-run
	ret

