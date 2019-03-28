.include "myMega8.h"

; r3 => has eeprom-Data

; r1 => has Tone
; r2 => has ToneLength

.equ DCNT,0x0000 ; Adresse des Zaehlers im EEPROM

;irq Vector
.org 0x0000
	rjmp	OnReset
.org 0x0006
	rjmp	TimerComp ; Timer/Counter1 Compare Match A

.org 0x0020
TimerComp:
	push	A
	sbi		EECR,0			; set bit 0 -> eeprom Read!
	in		r3,EEDR			; load eeprom-data into r3
	cbi		EEARH,0			; 9bit Address-High: zero
	in		A,EEARL
	inc		A	
	out		EEARL,A			; store new EEPROM startAddr in register

	ldi		A,1
	out		OCR1AH,A		; set a Timer HCompare Byte = 1
	
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
	out		OCR1AL,r2		; set r2 as new Compare for Timer IRQ	
	pop		A
	reti

.org 0x0050
OnReset:
	ldi		A,0b10000000	; PortD[7] is out
	out		DDRD,A
		
	ldi		A,0b01000000	; 01 -> toggle OC1A/B
	out		TCCR1A, A
	ldi		A,0b00001101	; CTC; timer: 101 = count on every 1024 clock-ticks
	out		TCCR1B, A
	ldi		A,0b00010000	; enable timer-compare IRQ (OCIE1A)
	out		TIMSK, A
	
	ldi		A, lo8(DCNT)	
	out		EEARL,A			; store EEPROM startAddr in register
	cbi		EEARH,0			; 9bit Address-High: zero
	sbi		EECR,0			; set bit 0 -> eeprom Read!
	in		r3,EEDR			; load eeprom-data into r3
	inc		A
	out		EEARL,A			; store next EEPROM startAddr in register

	ldi		A,1
	out		OCR1AH,A		; set a Timer HCompare Byte = 1

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
	out		OCR1AL,r2		; set r2 as new Compare for Timer IRQ
	
	sei						; IRQ allow

.org 0x0090
MainLoop:
	mov		A,r3
	cpi		A,0xFF		; Last Data?
	breq	OnReset		; than Restart
	rcall	LoadR1
	
	mov		N,r1
wr1Loop:
	dec		N
	brne	wr1Loop

	mov		A,r1
	cpi		A,0			; 0 is not a tone!
	breq	MainLoop

	ldi		A, 0b10000000 ; toggle Bit No. 7
	in		B, PORTD
	eor		A, B
	out		PORTD, A
	rjmp	MainLoop

.org 0x00C0
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

.org 0x00E0
TONES:
.byte 0,146,128,109,101, 89, 78, 72, 62, 55, 47, 45
; ???     Cis Dis Es  Fis Gis  As  b  Cis Dis  Es Fis
.byte     139,119,106, 95, 83, 75, 67, 59, 51, 46, 43

.org 0x0110
TONE_LENG:
.byte 250, 180, 90, 30,  5,      2,2,2
