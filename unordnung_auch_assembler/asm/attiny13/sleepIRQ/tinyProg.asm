.include "myTiny13.h"

; switch between 250 nA / 8 mA

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

.org 0x0020
Main:
	sbi		DDRB,LED		; output
	cbi		DDRB,TASTER		; input
	; 00x00000 Set Sleep enable
	; 000xx000 configure Sleepmode to power-down mode: SM[1:0] = 10
	; 000000xx INTO IRQ on logical low-lewel ISC0[1:0] = 00
	ldi		A,0b00110000
	out		MCUCR,A
	; Enable int0 IRQ
	ldi		A,0b01000000
	out		GIMSK,A
	sei
	
mainLoop:
	sleep
	rjmp	mainLoop
