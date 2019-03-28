#define F_CPU 1000000UL
#include <avr/io.h>
#include <util/delay.h>

void delayms(uint16_t millis) {
	while(millis) {
		_delay_ms(1);
		millis--;
	}
}

int main(void) {
	DDRB = 0b000111;
	int8_t dire = 1;	

	PORTB = 0;
	while(1) {
		delayms(400);
		if(PORTB == 7) dire = -1;
		if(PORTB == 0) dire =  1;
		
		PORTB = PORTB + dire;
	}
	return 0;
}
