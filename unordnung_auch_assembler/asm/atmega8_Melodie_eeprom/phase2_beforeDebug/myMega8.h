; atMega8 ----------------------------
.equ PORTB, 0x18
.equ DDRB,  0x17
.equ PINB,  0x16

.equ PORTC, 0x15
.equ DDRC,  0x14
.equ PINC,  0x13

.equ PORTD, 0x12
.equ DDRD,  0x11
.equ PIND,  0x10

; Status Register
.equ SREG, 0x3F

; Timer-config register
.equ TCCR1A, 0x2F
.equ TCCR1B, 0x2E

; Timer/Counter 16bit
.equ TCNT1H, 0x2D
.equ TCNT1L, 0x2C

; Timer/counter compare registers
.equ OCR1AH, 0x2B
.equ OCR1AL, 0x2A

; Timer IRQ Mask
.equ TIMSK, 0x39

; Timer IRQ Flag
.equ TIFR, 0x38

; Frequency calibration
.equ OSCCAL, 0x31

; ADC Analoge-Digital-Converter Register
.equ ACSR,  0x08
.equ ADMUX, 0x07
.equ ADCSRA,0x06
.equ ADCH,  0x05
.equ ADCL,  0x04

; EEPROM Registers
.equ EEARH, 0x1F
.equ EEARL, 0x1E
.equ EEDR,  0x1D
.equ EECR,  0x1C

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

