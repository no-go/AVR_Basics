.include "myTiny13.h"

; sets Bit0 OFF if timer match 250, makes Bit0 ON if Timer is on TOP

.org 0x0000
	rjmp	Main
.org 0x0006
	rjmp	CompareFits

; fade via tick-length (=255-N)
.org 0x0010
CompareFits:
	; toggle BitNr (stored in C)
	mov		A, C
	in		B, PINB
	eor		A, B
	out		PORTB, A
	ldi		A, 2		; Factor to increment/decrement
	; change compareValue to make IRQ earlier
	cpi		I, 1		; if inverse = false
	breq	Decrement
Increment:
	add		N, A		; N = N+A
	rjmp	CheckDir
Decrement:
	sub		N, A		; N = N-A

CheckDir:				; Ups! Zero! go into inverse Direction now!
	brne	CalcOk
	cpi		I, 1
	breq	UpCount		; if I != 1

DownCount:
	ldi		N, 254		; because we want to count down (Inverse = true)
	ldi		I, 1		; set I = 1 and N = 254
	rjmp	CalcOk
UpCount:
	ldi		N, 2		; because we want to count up
	ldi		I, 0		; else set I = 0 and N=0

CalcOk:
	out		OCR0A, N
	reti
	

.org 0x0050
Main:
	ldi		A, 0b00000111	; PortB0,1,2 is output for IRQ ping
	out		DDRB, A
	; PortB default is all off (set to +=1):
	out		PORTB, A
	; which bit(2) on PortB has to fade?:
	ldi		C, 0b00000101

	; configure irq -------------------
	ldi		A, 0b10000001	; PWM mode 1 (phase correct!!)
	out		TCCR0A, A

	ldi		A, 0b00000011	; timer: count on every 1/  8/ 64/256/1024 clock-ticks
	out		TCCR0B, A		;                     001/010/011/100/101

	ldi		A, 0b00000100	; say timer to make IRQ on a fiting compare
	out		TIMSK0, A
	ldi		N, 0			; default
	ldi		I, 0			; inverse = 0
	sei
Loop:
	rjmp	Loop

