; general device setup
; project contains ADC , pinchange IRQ 
; best viewed with tabs set to 8
.NOLIST                ; Disable listfile generation 
; please uncomment for the desired MC
; ATTiny 25
;.include "tn25def.inc"
; ATTiny 45
;.include "tn45def.inc"
; ATtiny 85
.include "tn85def.inc"
.LIST
; 
; constants 1 Mhz clk (8 mhz /8) , PB 0-1 outputs ,PB 2-4 input
; 
; today : a soldering iron controller 
; the iron is measured by a thermal element. 
; typical voltages are 
; 1 mV @ 20 C
; 12mV @ 340 C
; and so on
; with the ADC set to 1.1 Volt reference and 20 X gain we can expect values around 
; 240 for 350 C
; 20 for 20 C
;
.equ	ROMSTART	= 0x0100
.equ	RAMSTART	= SRAM_START
.equ 	debouncecount	= 0x08
; set to your desired flashrate of the LED
.equ 	blinkenlights    = 0x40
; modes are simply preset temperatures
; 300 C, 350 C, 400 C, 450 C
.equ maxmode = 0x05

; configure the ADC 
.equ 	ADMUXset = 0b10000111 ; data right adjusted, differential input on PB3/PB4 , 20 x gain, 1.1 volt reference
.equ 	ADCSRAset = 0b00010010
.equ 	ADCSRBset = 0b00000000	; no bin mode
.equ 	DIDR0set = 0b00011000
.equ	TCCR0Bset = 0b00000000	; prescaler  / 2  = 64 khz @ 128 khz clk
; hardware ports
.equ	Power	= 0		; output to iron controller
.equ	buttonlo = 1		; temperature dec control switch
.equ	ADinA	= 3		; from temperature diode 
.equ	ADinB	= 4		; in sold. iron
.equ	button = 2		; temperature inc control switch
;register usage
.def	adlo	=r10	; AD value
.def	adhi	=r11	; 
.def	zero	=r12	; offset value from calib routine
.def	temp	=r16	;misc usage, must be in upper regs for IMMED mode
.def	temphi	=r17	;misc usage, higher byte for word access
.def	del	= r18		; delay counter
.def 	bounce	= r19
.def    tlo       =r22		; 10 bit temperature preset
.def    thi       =r23		; 
.def    oldmode   =r24
.def    mode     =r25

; **************   MAIN PROGRAM STARTS HERE *************************
.CSEG 
	.ORG	0x0
 	rjmp 	RESET ; Reset Handler
 	rjmp 	EXT_INT0 ; IRQ0 Handler
 	rjmp 	PC_INT0 ; PCINT0 Handler
 	rjmp 	TIM0_OVF ; Timer0 Overflow Handler
 	rjmp 	EE_RDY ; EEPROM Ready Handler
 	rjmp 	ANA_COMP ; Analog Comparator Handler
 	rjmp 	TIM0_COMPA ; Timer0 CompareA Handler
 	rjmp 	TIM0_COMPB ; Timer0 CompareB Handler
 	rjmp 	WATCHDOG ; Watchdog Interrupt Handler
 	rjmp 	ADC_INT ; ADC Conversion Handler
;
EXT_INT0: 	RETI
; the pinchange irq increments the mode or decrements upon 
; buttons pressed
; contains debounce code for pushbutton
; increment value
PC_INT0:	ldi	bounce,debouncecount	; debouncer
pcirq2:		sbic	pinb,button
		rjmp	pcirq3		; test for other button
		dec	bounce
		brne	pcirq2		; next test for pressed key
		bclr	SREG_I		; passed, disable irq
		inc	mode		; next mode 
		cpi	mode,maxmode	; is limit reached
		brcs	pcirq0		; no , maxmode is still bigger than mode
		ldi	mode,maxmode		; else set to max
pcirq0:		ldi	bounce,debouncecount	; debouncer
pcirq1:		sbis	pinb,button	; check for button release
		rjmp	pcirq0					
		dec	bounce
		brne	pcirq1
		bset	SREG_I		;enable irq
		RETI
; decrement value
pcirq3:		sbic	pinb,buttonlo
		RETI			; was spurious
		dec	bounce
		brne	pcirq3		
		bclr	SREG_I		; passed bounce test
		dec	mode
		cpi	mode,0xff	; check for lower limit
		brne	pcirq4
		ldi	mode,0x00	; set to 0
pcirq4:		ldi	bounce,debouncecount
pcirq5:		sbis	pinb,buttonlo	
		rjmp	pcirq4
		dec	bounce
		brne	pcirq5
		bset	SREG_I
; stubs			
TIM0_OVF: 	
EE_RDY:	 	
ANA_COMP: 	
TIM0_COMPA: 	
TIM0_COMPB: 	
WATCHDOG: 	
ADC_INT:	RETI
;
RESET: 		cli			; first switch off the WD
		wdr	
		in 	temp, MCUSR		; clr the WDRF bit
		andi 	temp, (0xff & (0<<WDRF))
		out 	MCUSR, temp
; Write logical one to WDCE and WDE
; Keep old prescaler setting to prevent unintentional time-out
		in 	temp, WDTCR
		ori 	temp, (1<<WDCE) | (1<<WDE)
		out 	WDTCR, temp
; Turn off WDT
		ldi 	temp, (0<<WDE)
		out 	WDTCR, temp
; init stack
		ldi	temp, low(RAMEND)
		out	SPL, temp
; the Tiny25 doesn't come with SPH
#ifndef _TN25DEF_INC_
		ldi	temphi,high(RAMEND) 
		out	SPH, temphi
#endif
; variable init
		ldi	mode,0x0		; initial temperature
		mov	zero,mode		; clr offset
; hardware init
		rcall	init_ports		; initialize	
		sbi	PORTB,Power		; initially switch iron off
; initialize Pinchange IRQ
		ldi	temp,0b00000110	; mask the buttons
		out	PCMSK,temp		
		ldi	temp,0b00100000	; enable pinchange irq
		out	GIMSK,temp
		bset	SREG_I		; enable global irq's
;MAIN program does the iron controlling by first measuring the temperature
; and then set Power according to state
; compare the actual temp in adlo and adhi with preset in tlo and thi
newmode:	rcall	getpreset	; get our preset
		mov	oldmode,mode	; update modechange function		
main:
		rcall	getadc		; read the current temperature
		clc			; math ahead
; check for actual temp against preset
		sbc	adlo,tlo	; subtract AD value - preset
		sbc	adhi,thi	; and the high byte
		brcs	powerhi		; heat too low
powerlo:	sbi	PORTB,Power	; high = iron off
		rjmp	ma1		
powerhi:	cbi	PORTB,Power	; iron = on
; serial output of AD value
ma1:		mov	temp,adhi	; high byte
		mov	temp,adlo	; lo byte
;		rcall	bitbang
		ldi	del,0x28	; wait before next loop
		rcall	wozwait
		cp	mode,oldmode
		breq	main
; we have a mode change
		mov	temp,mode	; blink with the mode number + 1
		inc	temp
ma2:		cbi	PORTB, Power	; lamp = iron = on
		ldi	del,blinkenlights	; delay time
		rcall	wozwait
		sbi	PORTB, Power	; lamp off
		ldi	del,blinkenlights	; delay time
		rcall	wozwait
		dec	temp
		brne	ma2
		rjmp	newmode		; refresh preset
;-----------------------------------------------------------------
; does a single conversion and returns the result in adlo/hi 
; 10 bit conversion right aligned
; the ADC is already initialized
getadc:	sbi	ADCSRA,	ADIF	; clr any former conv
	sbi	ADCSRA, ADSC	; start single conversion
getad1:	sbis	ADCSRA, ADIF	; ready signal ? 
	rjmp	getad1
	in	adlo,ADCL	; get data 
	in	temp,ADCH	
	andi	temp,0x03	; mask irreg. values
	mov	adhi,temp
	clc
	sbc	adlo,zero	; subtract offset value
	brcc	getad2
	dec	adhi
getad2:	ret			
;-----------------------------------------------------------------

getpreset:	ldi	ZH,high(temptab << 1)  ; set Z-Register
		ldi	ZL,low(temptab << 1)
		clc
		push	mode			; save mode
		clc	
		rol	mode			; word align (multiply by 2)
		adc	r30,mode		; get table address
		brcc	gettab1
		inc	r31
gettab1:	lpm	tlo,Z+		; load table value to output registers
		lpm	thi,Z
		pop	mode		; get back original mode
		ret
; initialize ports		
init_ports:
	ldi	temp,0b00000001		; PB0 out, PB 1,2,3,4 in
	out	PORTB,temp		; high set
	out	DDRB,temp		; set outputs
	ldi	temp,0b00000110		; preset pullup conf
	out	PortB,temp		; use the pull-ups
	sbi	PORTB,Power		; switch off 
	ldi	del,0x20		; first settle 
	rcall	wozwait
init_adc: 	
	ldi	temp, DIDR0set		; disable digital inputs
	out 	DIDR0, temp
	ldi	temp, ADMUXset		; set AD inputs and amp
	out 	ADMUX, temp
	ldi	temp, ADCSRAset		; set prescaler prescaler and operation
	out	ADCSRA,temp		; poke to register
	ldi	temp, ADCSRBset		; set mode and trigger source 
	out	ADCSRB,temp		; poke 
;	sbi	ADCSRA,ADEN		; enable the ADC
calibadc: 
	ldi	temp, 0b10000101	; set AD inputs both to PB4, 
	out 	ADMUX, temp		; 1.1 V ref and 20 x Gain
	ldi	del,0x10		; settle 
	rcall	wozwait
	sbi	ADCSRA,ADEN		; enable the ADC
	nop
	rcall	getadc			; get value
	rcall	getadc			; get value
	mov	zero, adlo		; get floor level 
	ldi	temp, ADMUXset		; set AD inputs and amp back to normal
	out 	ADMUX, temp
	rcall	getadc			; get value to flush it
	ldi	del,0x10		; settle 
	rcall	wozwait
	ret
; steve wozniak's wait routine - this time for AVR 
; this is the standard routine with del^2 
; anyone willing can increase that by adding another push/pop pair and loop
; input with a value in 'del' 
; this routine was made by Steve Wozniak for the Apple II ROM and handles wide ranges of delay. 
; as a hommage to  Steve i port it to all my uC projects
wozwait: push	del
wwait2:	push	del
wwait1:	subi	del,1	
	brne	wwait1
	pop	del
	subi	del,1
	brne	wwait2
	pop	del
	subi	del,1
	brne	wozwait
	ret

; table for preset temps for j-junction thermoelement
; the amp has a 20x gain, remember 
temptab: .dw	270 	; should be about 13.55 mV  = 250 C
	.dw	326	; should be about 16.3 mV = 300 C
	.dw	380	; 19 mV = 350 C
	.dw	436	; 23.8 mV = 400 C
	.dw	472	; 23.5 mV = 430 C
	.dw	10

; ende der fahnenstange
