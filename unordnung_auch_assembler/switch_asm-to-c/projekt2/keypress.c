#define F_CPU 12000000UL
#include <avr/io.h>
#include <util/delay.h>


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

int main(void) {
	DDRB = 0b00000111; // LED: gelb, blau, weiss
	DDRC = 0b0011111;  // LED: Rot (c5 = Poti input)
	DDRD = 0b10000000; // Speaker (d2 = Taster input)
	
	//uint8_t mini = 200;
	//uint8_t maxi = 250;
	
	uint8_t richtung = 1;
	PORTC = 1;
	
	while(1) {
		if(key_pressed(&PIND, PIND2))
			PORTB = 2;
		else
			PORTB = 0;
		
		if((PORTC == 31) && richtung==1) {
			richtung = 0;
		}
		if((PORTC == 0) && richtung==0) {
			richtung = 1;
		}
		
		if(richtung==0) {
			PORTC = PORTC - 1;
		} else {
			PORTC = PORTC + 1;
		}
		_delay_ms(100);
	}
	return 0;
}
