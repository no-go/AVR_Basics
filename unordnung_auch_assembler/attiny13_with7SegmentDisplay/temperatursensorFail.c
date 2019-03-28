#define F_CPU 1000000UL
#include <avr/io.h>
#include <util/delay.h>

void delayms(uint32_t millis) {
	while(millis) {
		_delay_ms(1);
		millis--;
	}
}

void adc_init(uint8_t kanal) {
	ADMUX = kanal;
	ADCSRA = (1<<ADEN)|(1<<ADPS2)|(1<<ADPS1);
}

uint16_t getadc(void) {
	uint16_t poti10bit;
	ADCSRA |= (1<<ADSC);
	while ( !(ADCSRA & (1<<ADIF)) ) ;
	poti10bit = ADCL | (ADCH<<8);
	// normierung 5k poti + 3,9 k
	//poti10bit = poti10bit/128;
	return poti10bit;
}

void left(void) {
	PORTB |= (1 << PB1);
	delayms(200);
	PORTB &= ~(1 << PB1);
}

void forward(void) {
	PORTB |= ((1 << PB0) | (1 << PB1));
	delayms(200);
	// rechter motor is was schlapp daher linken eher ausmachen
	PORTB &= ~(1 << PB1);
	delayms(100);
	PORTB &= ~(1 << PB0);
	
}

void right(void) {
	PORTB |= (1 << PB0);
	delayms(300);
	PORTB &= ~(1 << PB0);
}

int main(void) {
	//termosensor: warm ist niedriger wert
	// reset, termosensor, poti / LED4, 1bit unnuetz, 2bit motoren
	DDRB = 0b001111;
	uint16_t left_t, right_t;
	adc_init(2);

	while(1) {
		PORTB |= (1 << PB3); // rote LED an	

		// links temp testen
		left();
		delayms(300);
		left_t = getadc();

		right(); // gradeaus richten

		// rechts temp testen
		right(); 
		delayms(300);
		right_t = getadc();

		left(); // gradeaus richten

		PORTB &= ~(1 << PB3); // rote LED aus	
		delayms(300);

		if(left_t+10 < right_t) {
			// links ist waermer !!
			left();
			forward();
		} else if(left_t-10 > right_t) {
			// rechts is wohl waermer und da will ich hin
			right();	
			forward();
		} else {
			// gleichwarm (right ist um 10 nahe an left) = gradeaus
			forward();
		}
	}
	return 0;
}

