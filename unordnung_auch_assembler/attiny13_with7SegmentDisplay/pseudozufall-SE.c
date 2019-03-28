#define F_CPU 1000000UL
#include <avr/io.h>
#include <util/delay.h>

void delayms(uint32_t millis) {
	while(millis) {
		_delay_ms(1);
		millis--;
	}
}

void adc_init(uint8_t kanal) {
	ADMUX = kanal;
	ADCSRA = (1<<ADEN)|(1<<ADPS2)|(1<<ADPS1);
}

uint8_t getadc(void) {
	uint16_t poti10bit;
	ADCSRA |= (1<<ADSC);
	while ( !(ADCSRA & (1<<ADIF)) ) ;
	poti10bit = ADCL | (ADCH<<8);
	// normierung 5k poti + 3,9 k
	poti10bit = poti10bit/84 - 5;
	return poti10bit;
}

void sound(const uint8_t w) {
	uint8_t i,dauer;
	dauer = 100/w;
	for(i=0; i<dauer; i++) {
		delayms(w);
		// ^ = xor to toggle a bit
		PORTB |= (1 << PB4);
		delayms(w);
		PORTB &= ~(1 << PB4);
	}
}

uint32_t zufall(const uint8_t max) {
	static uint32_t x = 314159265;
	x ^= x << 13;
	x ^= x >> 17;
	x ^= x << 5;
	return x%max;
}

int main(void) {
	// reset, speaker, poti ADC3, 3bits fuer 7segAnzeige
	DDRB = 0b010111;
	uint8_t poti, z;
	adc_init(3);

	while(1) {
		poti = getadc();
		z = zufall(8);
		PORTB = z;
		delayms(poti*20 + 20);
		sound(z+1);
	}
	return 0;
}

