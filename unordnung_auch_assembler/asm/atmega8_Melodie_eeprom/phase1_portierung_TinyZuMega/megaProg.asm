.include "myMega8.h"

; r1 => has Tone
; r2 => has ToneLength

.equ CNT,0 ; Adresse des Zaehlers im EEPROM

;irq Vector
.org 0x000
	rjmp	OnReset
.org 0x006
	rjmp	TimerComp ; Timer/Counter1 Compare Match A

.org 0x020
TimerComp:
	push	A
	sbi		EECR,0			; set bit 0 -> eeprom Read!
	in		r1,EEDR			; load eeprom-data into r1
	cbi		EEARH,0			; 9bit Address-High: zero
	in		A,EEARL
	inc		A	
	out		EEARL,A			; store new EEPROM startAddr in register
	pop		A
	reti

.org 0x040
OnReset:
	ldi		A,0b10000000	; PortD[7] is out
	out		DDRD,A
	ldi		A,0b01000000	; 01 -> toggle OC1A/B
	out		TCCR1A, A
	ldi		A,0b00001101	; CTC; timer: 101 = count on every 1024 clock-ticks
	out		TCCR1B, A
	ldi		A,0b00010000	; enable timer-compare IRQ (OCIE1A)
	out		TIMSK, A
	
	ldi		A, lo8(CNT)	
	out		EEARL,A			; store EEPROM startAddr in register
	cbi		EEARH,0			; 9bit Address-High: zero
	sbi		EECR,0			; set bit 0 -> eeprom Read!
	in		r1,EEDR			; load eeprom-data into r1
	inc		A
	out		EEARL,A			; store next EEPROM startAddr in register
	
	ldi		A,0			; constant tone-length !!!
	out		OCR1AH,A
	ldi		A,250			
	mov		r2,A
	out		OCR1AL,r2		; set r2 as new Compare for Timer IRQ	
	sei						; IRQ allow

MainLoop:
	ldi		A, 0b10000000	; toggle Bit No. 7
	in		B, PORTD
	eor		A, B
	out		PORTD, A
	mov		A,r1
	cpi		A,0xFF		; Last Tone?
	breq	OnReset		; than Restart
	rcall	WaiterR1
	rjmp	MainLoop

.org 0x080
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
