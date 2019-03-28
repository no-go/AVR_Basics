.include "myTiny13.h"

.equ TASTER,3
.equ LEDB,1

;irq Vector
.org 0x0000
	rjmp	RESET
	nop
	rjmp	PCINT0

.org 0x0010
RESET:
	sbi		DDRB,LEDB		; output
	cbi		DDRB,TASTER		; input
	
	ldi		A,0b00100000	; IRQ react on PCINT
	out		GIMSK,A
	sbi		PCMSK,TASTER	; set PCINT on TASTER IRQ
	
	sei
	
mainLoop:
	rjmp	mainLoop

.org 0x0030
PCINT0:
	sbic	PINB,TASTER		; IF tester clear
	rjmp	bitSet
	cbi		PORTB,LEDB		; then clear LED
	reti
bitSet:
	sbi		PORTB,LEDB		; ELSE set bit
	reti
