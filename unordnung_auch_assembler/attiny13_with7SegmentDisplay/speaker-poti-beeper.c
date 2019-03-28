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

uint16_t getadc(void) {
	uint16_t poti10bit;
	ADCSRA |= (1<<ADSC);
	while ( !(ADCSRA & (1<<ADIF)) ) ;
	poti10bit = ADCL | (ADCH<<8);
	// normierung 5k poti + 3,9 k
	poti10bit = poti10bit/84 - 5;
	return poti10bit;
}
void sound(const uint8_t w, const uint8_t d) {
	uint8_t i;
	for(i=0; i<d; i++) {
		delayms(2);
		// xor to toggle a bit
		PORTB ^= (1 << PB4);
		delayms(w+1);
		PORTB ^= (1 << PB4);
	}
}

int main(void) {
	// reset, speaker, poti ADC3, 3bits fuer 7segAnzeige
	DDRB = 0b010111;
	adc_init(3);
	uint16_t poti;

	while(1) {
		PORTB = getadc();
		delayms(100);
		sound(PORTB, 10);
	}
	return 0;
}
