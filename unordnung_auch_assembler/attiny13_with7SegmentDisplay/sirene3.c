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
	int8_t i=0, z=1;

	while(1) {
		i = i+z;
		if (z== 1 && i == 10) z=-1;
		if (z==-1 && i == 0) z=1;
		
		sound(i+1, 1);
	}
	return 0;
}

