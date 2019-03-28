#define F_CPU 1000000UL
#include <avr/io.h>
#include <util/delay.h>

void delayms(uint32_t millis) {
	while(millis) {
		_delay_ms(1);
		millis--;
	}
}

void sound(uint8_t w, uint8_t dauer) {
	uint8_t i;
	dauer = (dauer+1)*(10/w);
	for(i=0; i<dauer; i++) {
		delayms(1);
		// ^ = xor to toggle a bit
		PORTB |= (1 << PB4);
		delayms(w);
		PORTB &= ~(1 << PB4);
	}
}

int main(void) {
	// reset, speaker, poti ADC3, 3bits fuer 7segAnzeige
	DDRB = 0b010111;
	uint8_t i=0,j;

	while(1) {
		i++;
		if (i == 5) i=0;
		PORTB = i;
		for(j=2;j<10;j++) sound(j, i);
	}
	return 0;
}

