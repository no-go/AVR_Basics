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
	DDRC = 0x1F; //  R01 1111 - R = Reset / Rot
	
	uint8_t richtung = 1;
	PORTC = 0x01;
	while(1) {
		if((PORTC & 0x10) && richtung==1) {
			richtung = 0;
		}
		if((PORTC & 0x01) && richtung==0) {
			richtung = 1;
		}
		
		if(richtung==0) {
			PORTC = PORTC / 2;
		} else {
			PORTC = PORTC * 2;
		}
		delayms(100);
	}
	return 0;
}
