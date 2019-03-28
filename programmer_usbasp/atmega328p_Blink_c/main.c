#define F_CPU 8000000L

#include <avr/io.h>
//#include <avr/wdt.h>
//#include <avr/eeprom.h>
//#include <avr/interrupt.h>
#include <util/delay.h>
//#include <avr/pgmspace.h>

#define LED_ON  10
#define LED_OFF 20

static volatile uint8_t r = 0;

void update_leds() {
	if (r == LED_ON) {
		PORTB |= (1 << PB5);
		r = LED_OFF;
	} else {
		PORTB &= ~(1 << PB5);
		r = LED_ON;
	}
}

int main(void) {
	DDRB |= (1 << PB5);
	while(1) {
		update_leds();
		_delay_ms(500);
	}
	return 0;
}
