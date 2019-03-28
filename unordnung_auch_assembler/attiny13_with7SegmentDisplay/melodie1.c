#define F_CPU 1000000UL
#include <avr/io.h>
#include <util/delay.h>

#define TOENE 13

void delayms(uint32_t millis) {
	while(millis) {
		_delay_ms(1);
		millis--;
	}
}

void sound(uint8_t w, uint8_t dauer) {
	uint8_t i;
	dauer = (dauer+1)*(50/w);
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
	uint8_t i;
	uint8_t ton[TOENE]  = {3,3,5, 3,5,5, 7,6,5,4,3, 2,3};
	uint8_t leng[TOENE] = {4,4,8, 4,4,8, 2,2,2,2,4, 4,8};

	while(1) {
		i++;
		if (i == (TOENE)) i=0;
		sound(ton[i], leng[i]);
	}
	return 0;
}

