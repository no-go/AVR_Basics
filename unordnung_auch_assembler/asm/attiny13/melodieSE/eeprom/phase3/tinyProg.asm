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
	in		r3,EEDR			; load eeprom-data into r3
	in		A,EEARL
	inc		A	
	out		EEARL,A			; store new EEPROM startAddr in register

	; LoadR2
	ldi		A,0b00000111	; Tone-length is the lower 3 bits
	mov		r2,A
	and		r2,r3
	ldi		ZL, lo8(TONE_LENG)
	ldi		ZH, hi8(TONE_LENG)
	; start r2 = (Z+r2)
	add		ZL,r2			; ZL = ZL+r2 & set carry
	clr		r2
	adc		ZH,r2			; ZH = ZH +0 +Carry
	lpm		r2,Z			; r2 = (Z)
	; end r2 = (Z+r2)
	out		OCR0A,r2		; set r2 as new Compare for Timer IRQ	

	pop		A
	reti

.org 0x0050
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
	in		r3,EEDR			; load eeprom-data into r3
	inc		A
	out		EEARL,A			; store next EEPROM startAddr in register
	
	; loadR2
	ldi		A,0b00000111	; Tone-length is the lower 3 bits
	mov		r2,A
	and		r2,r3
	ldi		ZL, lo8(TONE_LENG)
	ldi		ZH, hi8(TONE_LENG)
	; start r2 = (Z+r2)
	add		ZL,r2			; ZL = ZL+r2 & set carry
	clr		r2
	adc		ZH,r2			; ZH = ZH +0 +Carry
	lpm		r2,Z			; r2 = (Z)
	; end r2 = (Z+r2)
	out		OCR0A,r2		; set r2 as new Compare for Timer IRQ
	
	sei						; IRQ allow

MainLoop:
	mov		A,r1
	cpi		A,0xFF		; Last Tone?
	breq	OnReset		; than Restart
	rcall	LoadR1
	rcall	WaiterR1

	mov		A,r1
	cpi		A,0			; 0 is not a tone!
	breq	MainLoop

	ldi		A, 0b00010000	; toggle Bit No. 4
	in		B, PORTB
	eor		A, B
	out		PORTB, A

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

;subroutine
LoadR1:
	mov		r1,r3
	lsr		r1
	lsr		r1
	lsr		r1		; need bits 7 till 3 (the tone-index)
	ldi		ZL, lo8(TONES)
	ldi		ZH, hi8(TONES)
	; start r1 = (Z+r1)
	add		ZL,r1			; ZL = ZL+r1 & set carry
	clr		r1
	adc		ZH,r1			; ZH = ZH +0 +Carry
	lpm		r1,Z			; r1 = (Z)
	; end r1 = (Z+r1)
	ret

TONES:
.byte 0,146,128,109,101, 89, 78, 72, 62, 55, 47, 45
.byte     139,119,106, 95, 83, 75, 67, 59, 51, 46, 43

TONE_LENG:
.byte 200, 100, 40, 20,  5,      2,2,2
