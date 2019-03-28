#define F_CPU 16000000L

#include <avr/io.h>
#include <util/delay.h>


/* from 9,6 MHz to 16 MHz
 * set frequency higher in steps -> 69 = 166% (16MHz)
 * 40 = 150%
 * 7F = 200%
 */
void setFreq(void) {
	while(OSCCAL < 0x7d) OSCCAL++;
}

int main(void) {
	DDRB |= 1<<PB3; /* set PB3 to output */
	setFreq();
	while(1) {
		PORTB = 0;
		_delay_ms(500);
		PORTB = 8;
		_delay_ms(500);
	}
	return 0;
}

