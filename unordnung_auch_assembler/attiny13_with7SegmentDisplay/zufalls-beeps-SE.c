#define F_CPU 1000000UL
#include <avr/io.h>
#include <util/delay.h>

void delayms(uint32_t millis) {
	while(millis) {
		_delay_ms(1);
		millis--;
	}
}

uint8_t getadc(void) {
	ADCSRA |= (1<<ADSC);    
	while ( !(ADCSRA & (1<<ADIF)) ) ;
	return ADCL|(ADCH<<8);
}

uint8_t zufall(const uint8_t max) {
	uint8_t c;
	uint8_t i;
	for(i=0; i<200; i++) {
		c = c + getadc() % 2;
	}
	c =	c%max;
	return c;
}

void sound(const uint8_t w, const uint8_t d) {
	uint8_t i;
	uint8_t m =d*20 +20;
	for(i=0; i<m; i++) {
		delayms(2);
		PORTB |= (1 << PB4);
		delayms(w);
		PORTB &= ~(1 << PB4);
	}
}

int main(void) {
	// reset, speaker, zufall ADC3, 3bits fuer 7segAnzeige
	DDRB = 0b010111;
	uint32_t thetime;

	ADMUX = 3;
	ADCSRA = (1<<ADEN)|(1<<ADPS2)|(1<<ADPS1);	

	while(1) {
		thetime = zufall(8);
		PORTB = thetime;
		// pause
		thetime = thetime*100 + 100;
		delayms(thetime);

		thetime = zufall(8);
		sound(thetime, zufall(5));
	}
	return 0;
}
