; atTINY 13 - Board without 7seg display
.equ PORTB, 0x18
.equ DDRB, 0x17
.equ PINB, 0x16

; Status Register
.equ SREG, 0x3F

; Timer-config register
.equ TCCR0A, 0x2F
.equ TCCR0B, 0x33

; Timer/Counter 8bit
.equ TCNT0, 0x32

; Timer/counter compare registers
.equ OCR0A, 0x36
.equ OCR0B, 0x29

; Timer IRQ Mask
.equ TIMSK0, 0x39

; Timer IRQ Flag
.equ TIFR0, 0x38

; Frequency calibration
.equ OSCCAL, 0x31

; ADC Analoge-Digital-Converter Register
.equ ACSR,  0x08
.equ ADMUX, 0x07
.equ ADCSRA,0x06
.equ ADCH,  0x05
.equ ADCL,  0x04
.equ ADCSRB,0x06

; EEPROM Registers
.equ EEARL, 0x1E
.equ EEDR,  0x1D
.equ EECR,  0x1C

; MCU Control and status Register
.equ MCUCR, 0x35
.equ MCUSR, 0x34
.equ GIMSK, 0x3B ; General Interrupt Mask (Enabling PCINTx and/or INT0)
.equ PCMSK, 0x15

; 8bit Accu and index register
A = 16
B = 17
C = 18

N = 19
I = 20

; 16bit register
X = 26
XH = 27
XL = 26

Y = 28
YH = 29
YL = 28

Z = 30
ZH = 31
ZL = 30

