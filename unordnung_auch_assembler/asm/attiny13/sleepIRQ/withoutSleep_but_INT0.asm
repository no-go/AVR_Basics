.include "myTiny13.h"

.equ LED,0
.equ TASTER,1

;irq Vector
.org 0x0000
	rjmp	Main
	rjmp 	EXT_INT0 ; IRQ0 Handler

; IRQ routine -----------------
.org 0x0010
EXT_INT0:
	; toggleLED
	sbis	PORTB,LED		; if LED = 1 then
	rjmp	setLED
	cbi		PORTB,LED		; LED := 0; return;
	reti
setLED:						; else
	sbi		PORTB,LED		; LED := 1; return;
	reti

.org 0x0030
Main:
	sbi		DDRB,LED		; output
	cbi		DDRB,TASTER		; input
	; configure Sleepmode to power-down mode: SM[1:0] = 10
	; INTO on logical change ISC0[1:0] = 01
	ldi		A,0b00010001
	out		MCUCR,A
	; Enable int0 IRQ
	ldi		A,0b01000000
	out		GIMSK,A
	sei
	
mainLoop:
	;sbis	PORTB,LED		; if LED = 1 skip sleep
	;sleep
	rjmp	mainLoop
