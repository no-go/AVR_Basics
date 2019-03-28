.include "myTiny13.h"

; r1 => has Tone
; r2 => has ToneLength

.equ CNT,0x0000 ; Adresse des Zaehlers im EEPROM

;irq Vector
.org 0x0000
	rjmp	OnReset
.org 0x0006
	rjmp	TimerComp ; Timer-Compare Interrupt

.org 0x0010
TimerComp:
	push	A
	sbi		EECR,0			; set bit 0 -> eeprom Read!
	in		r1,EEDR			; load eeprom-data into r1
	in		A,EEARL
	inc		A	
	out		EEARL,A			; store new EEPROM startAddr in register
	pop		A
	reti

.org 0x0030
OnReset:
	ldi		A,0b00010000
	out		DDRB, A
	ldi		A, 0b01000010	; CTC - Clear Timer on Compare Mode
	out		TCCR0A, A
	ldi		A, 0b00000101	; timer: count on every .. clock-ticks
	out		TCCR0B, A
	ldi		A, 0b00000100	; enable timer-compare IRQ
	out		TIMSK0, A
	
	ldi		A, lo8(CNT)	
	out		EEARL,A			; store EEPROM startAddr in register
	sbi		EECR,0			; set bit 0 -> eeprom Read!
	in		r1,EEDR			; load eeprom-data into r1
	inc		A
	out		EEARL,A			; store next EEPROM startAddr in register
	
	ldi		A,20			; constant tone-length !!!
	mov		r2,A
	out		OCR0A,r2		; set r2 as new Compare for Timer IRQ	
	sei						; IRQ allow

MainLoop:
	ldi		A, 0b00010000	; toggle Bit No. 4
	in		B, PORTB
	eor		A, B
	out		PORTB, A
	mov		A,r1
	cpi		A,0xFF		; Last Tone?
	breq	OnReset		; than Restart
	rcall	WaiterR1
	rjmp	MainLoop

; subroutine
WaiterR1:
	push	A
	mov		A,r1
wr1Loop:
	dec		A
	brne	wr1Loop
	pop		A
	ret

; todo:
; 0-31 tone-scala (bits: 7 bis 3)
; 0-7 tone-length skala (bits: 2,1,0)
