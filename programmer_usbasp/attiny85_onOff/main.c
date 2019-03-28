#define F_CPU   16000000L

#define LED_BIT PB3
#define LED_ON()   (PORTB &= ~_BV(LED_BIT))
#define LED_OFF()  (PORTB |= _BV(LED_BIT))
#define LED_TOGGLE() (PORTB ^= _BV(LED_BIT))
#define LED_INIT() (LED_OFF(), DDRB |= _BV(LED_BIT))

#include <avr/io.h>
//#include <avr/wdt.h>
//#include <avr/interrupt.h>
//#include <avr/pgmspace.h>
#include <util/delay.h>

/*
void delayms(uint16_t millis) {
	while(millis) {
		_delay_ms(1);
		millis--;
	}
}*/

uint8_t key_pressed(volatile uint8_t * inReg, uint8_t inBit) {
	static uint8_t last_state = 0;
	
	// nichts veraendert:
	if(last_state == (*inReg & (1<<inBit)))
		return 0;
		
	// "entprellen"
	_delay_ms(20);
	
	// zustand fuer naechstes mal merken
	last_state = *inReg & (1<<inBit);
	
	return last_state;
}

// Analog/Digital Wandler initialisieren
void adc_init(uint8_t kanal) {
	// externe Referenzspannung und AD-Wandlerkanal x (ADCx) auswaehlen
	ADMUX = kanal;
	
	// AD-Wandler einschalten und Prescaler = 64 einstellen
	// (enstpricht 115 khz Wandlertakt)
	ADCSRA = (1<<ADEN)|(1<<ADPS2)|(1<<ADPS1);
}

uint16_t getadc(void) {
	uint16_t buffer;
	
	// Wandlung starten
	ADCSRA |= (1<<ADSC);
	
	// Warten bis die AD-Wandlung abgeschlossen ist
	while ( !(ADCSRA & (1<<ADIF)) ) ;
	
	/* AD-Wert auslesen.
	ADCH muss als zweites gelesen werden, da nachdem ADCL gelesen wurde
	das ADC-Register gesperrt ist bis ADCH auch ausgelesen wurde. */
	buffer = ADCL | (ADCH<<8);
	
	// oder einfacher: buffer = ADC;
	return buffer;
}

int main(void) {
	LED_INIT();
	// DDRB |= 1<<PB3; // set PB3 to output
	uint8_t buttonHit = 0;

	for(;;) {
		_delay_ms(100);
		
		if (key_pressed(&PINB, PINB4)) {
			if (buttonHit == 1) {
				buttonHit = 0;
				LED_OFF();
			} else {
				buttonHit = 1;
				LED_ON();
			}
		}
	}
	return 0;
}

