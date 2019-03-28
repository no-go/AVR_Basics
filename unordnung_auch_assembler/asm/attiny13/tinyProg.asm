.include "myTiny13.h"

; 320x240 Pixel
.equ PiXh, 1 ; width high byte
.equ PiXl, 64 ; width low byte

.equ PiYh, 0 ; height high byte
.equ PiYl, 240 ; height low byte

; Register X has line-width, register Y has image-hight

Main:

; set frequency higher in steps -> 69 = 166% (16MHz)  / 40 = 150% (7F = 200%)
	ldi		A, 0x00
SetFreq:
	inc		A
	out		OSCCAL, A
	cpi		A, 0x69
	brne	SetFreq
; now, we have a higher frequency!!

;initial values
	ldi		A, 0b00011111	; H: new line, V: new frame, Red Green Blue
	out		DDRB, A
	out		PORTB, A
	ldi		XH, PiXh
	ldi		XL, PiXl
	ldi		YH, PiYh
	ldi		YL, PiYl
	
Loop:
	; colorCycle
	ldi		A, 0b00000101	; bitmask = Black or Mangenta
	in		N, PINB
	eor		A, N		; A := A XOR N
	out		PORTB, A

	; next pixel is 0 -> Line is ready?
	sbiw	X, 1		; substact immediate from word X = X-1
	breq	LineReady
	rjmp	Loop

LineReady:
	ldi		XH, PiXh
	ldi		XL, PiXl
	sbiw	Y, 1		; substact immediate from word Y = Y-1
	breq	FrameReady
	; NewLine
	cbi		PORTB, 4	; 4 = H ticks down, V still positive
	rcall	Wait1
	sbi		PORTB, 4	; H ticks up - New Line starts	
	rjmp	Loop

FrameReady:
	ldi		YH, PiYh
	ldi		YL, PiYl
	; NewFrame
	ldi		A, 0
	out		PORTB, A	; RGB, H & V ticks down
	rcall	Wait1
	rcall	Wait1
	sbi		PORTB, 3	; V ticks up - New Frame starts
	rjmp	Loop


;subroutine
Wait1:
	ldi		N, 250
WL1:
	dec		N
	brne	WL1
	ret

