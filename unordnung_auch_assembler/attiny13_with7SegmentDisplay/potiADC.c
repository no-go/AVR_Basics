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

int main(void) {
	// reset, frei, poti ADC3, 3bits fuer 7segAnzeige und 0 als speaker
	DDRB = 0b000111;
	adc_init(3);

	while(1) {
		PORTB = getadc();
		delayms(100);
	}
	return 0;
}
