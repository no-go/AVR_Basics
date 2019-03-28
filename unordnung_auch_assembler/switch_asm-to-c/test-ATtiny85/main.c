#define F_CPU   12000000L

#include <avr/io.h>
#include <util/delay.h>

void delayms(uint16_t millis) {
	while(millis) {
		_delay_ms(1);
		millis--;
	}
}

int main(void) {
	DDRB |= 1<<PB3; /* set PB3 to output */
	while(1) {
		PORTB &= ~(1<<PB3); /* LED on */
		delayms(100);
		PORTB |= 1<<PB3; /* LED off */
		delayms(900);
	}
	return 0;
}