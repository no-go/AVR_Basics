.include "myTiny13.h"

; alarm-system:
; - einschalten
; - ein paar sekunden zeit haben um GND mit ALARMPIN zu verbinden
;   -> du kommst & unterbrichst: ein paar sekunden, ums system aus zu stellen
;   -> einbrecher unterbricht: nach paar sekunden geht sierene los
;   -> GND + ALARMPIN nach unterbrechung -> egal, sirene geht trotzdem!
; todo: sleep & extern IRQ

.equ DAUER,100
.equ SOUNDBIT,0b00010000
.equ ALARMPIN,0

;irq Vector
.org 0x0000
	rjmp	OnReset
.org 0x0006
	rjmp	TimerComp ; Timer-Compare Interrupt

.org 0x0010
TimerComp:
	ldi		C,1				; Alarm on
	reti

.org 0x0020
OnReset:
	ldi		C,0				; Alarm off
	ldi		N,0				; 0 = Cable Connected

	ldi		A,SOUNDBIT
	out		DDRB,A
	ldi		A,0b01000010	; CTC - Clear Timer on Compare Mode
	out		TCCR0A,A
	ldi		A,0b00000101	; timer: count on every 1024 clock-ticks
	out		TCCR0B,A
	ldi		A,0b00000100	; enable timer-compare IRQ
	out		TIMSK0,A
	
	ldi		A,DAUER			; "time" to set Alarm on	
	out		OCR0A,A			; set Compare for Timer IRQ
	sei						; IRQ allow

MainLoop:
	; sleep
	cpi		C,0
	breq	MainLoop		; alarm still off (first time)
	
	sbic	PINB,ALARMPIN	; skip Cable Not Conected, if PB0 = gnd = clear
	ldi		N,1
	
	cpi		N,0
	breq	MainLoop		; alarm active (C=1) but Cable still connected
	
Alarm:
	; set timer to startvalue
	ldi		A,DAUER			; "time" to set Alarm on	
	out		OCR0A,A			; set Compare for Timer IRQ
	ldi		C,0
	
AlarmLoop:
	cpi		C,0
	breq	AlarmLoop		; alarm on but no sound
	
	ldi		I,30			; the tone
	rcall	BeepI
	rjmp	AlarmLoop

; subroutine ----------------------
BeepI:
	; toggle Sound-Bit
	ldi		A,SOUNDBIT
	in		B,PORTB
	eor		B,A
	out		PORTB,B
	mov		A,I			; make different Tones -> Sirene
beepIWait:
	dec		A
	brne	beepIWait
	dec		I
	brne	BeepI
	ret
