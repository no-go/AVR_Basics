#define F_CPU 12000000UL
#include <avr/io.h>
#include <util/delay.h>

void delayms(uint16_t millis) {
	while(millis) {
		_delay_ms(1);
		millis--;
	}
}

int main(void) {
	DDRB = 0b00000111; // LED: gelb, blau, weiss
	DDRC = 0b0011111;  // LED: Rot (c5 = Poti input)
	DDRD = 0b10000000; // Speaker (d2 = Taster input)
	
	uint8_t richtung = 1;
	//uint8_t mini = 200;
	//uint8_t maxi = 250;
	
	while(1) {
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
		delayms(100);
	}
	return 0;
}
