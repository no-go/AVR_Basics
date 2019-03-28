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
		
	PORTB = 0;
	while(1) {
		delayms(400);
		PORTB = PORTB +1;		
	}
	return 0;
}
