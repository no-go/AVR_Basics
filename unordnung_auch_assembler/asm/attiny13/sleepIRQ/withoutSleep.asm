.include "myTiny13.h"

.equ LED,0
.equ TASTER,1

;irq Vector
.org 0x0000
	rjmp	Main

.org 0x0010
Main:
	sbi		DDRB,LED		; output
	cbi		DDRB,TASTER		; input
mainLoop:
	sbic	PINB,TASTER		; skip toggle, if Taster is set
	rcall	ToggleLED
	rjmp	mainLoop		; alarm active (C=1) but Cable still connected
	
; subroutine
ToggleLED:
	ldi		N,200			; make mainLoop slower: via software entprellen
	rcall	WaiterN
	
	sbis	PORTB,LED		; if LED = 1 then
	rjmp	setLED
	cbi		PORTB,LED		; LED := 0; return;
	ret
setLED:						; else
	sbi		PORTB,LED		; LED := 1; return;
	ret
	
;subroutine
WaiterN:
	push	N
wNloop:
	dec		N
	brne	wNloop
	pop		N
	ret