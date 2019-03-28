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

	; 00x00000 Set Sleep enable
	; 000xx000 configure Sleepmode to power-down mode: SM[1:0] = 10
	; 000000xx INTO IRQ on logical low-lewel ISC0[1:0] = 00 (unsused)
	ldi		A,0b00110000
	out		MCUCR,A
	
	sei
	
mainLoop:
	sleep				; unchecked: does sleep realy work???
	rjmp	mainLoop

.org 0x0030
PCINT0:
; Toggle Bit Start ----
	sbis	PORTB,LEDB
	rjmp	bitSet
	cbi		PORTB,LEDB
	reti
bitSet:
	sbi		PORTB,LEDB
	reti
