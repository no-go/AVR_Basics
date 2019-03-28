.include "myTiny13.h"

.equ SENBIT,4
.equ SPEAKER,3

;irq Vector
.org 0x0000
	rjmp	Main

.org 0x0010
Main:
	sbi		DDRB,SPEAKER	; output
	cbi		DDRB,SENBIT		; input
	
mainLoop:
	sbic	PINB,SENBIT
	rcall	Toggle
	rjmp	mainLoop


;subroutine -------------------------------------
Toggle:
	sbis	PORTB,SPEAKER
	rjmp	bitSet
	cbi		PORTB,SPEAKER
	ret
bitSet:
	sbi		PORTB,SPEAKER
	ret
