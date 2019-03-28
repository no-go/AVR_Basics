#define F_CPU 1000000UL
#include <avr/io.h>
#include <util/delay.h>

// b3 hat jumper zur roten, 4ten leuchtdiode (ausgang statt eingangs poti)
// An 120 ohm b4 pin wird potential zwischen 1,5k termosensor und GND bzw
// 5,6k ohm und +5v abgegriffen. Warm ist ein niedriger wert!

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
	//poti10bit = poti10bit/128;
	return poti10bit;
}

int main(void) {
	// reset, 120ohm + minus, poti / LED4, 3bits fuer 7segAnzeige
	DDRB = 0b001111;
	uint16_t poti;
	adc_init(2);

	while(1) {
		poti = getadc();
		PORTB = poti;
		delayms(200);
	}
	return 0;
}

