#define F_CPU 12000000UL
#include <avr/io.h>
#include <util/delay.h>

void delayms(uint16_t millis) {
	while(millis) {
		_delay_ms(1);
		millis--;
	}
}

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

// Analog/Digital Wandler initialisieren
void adc_init(uint8_t kanal) {
	// externe Referenzspannung und AD-Wandlerkanal x (ADCx) auswaehlen
	ADMUX = kanal;

	// AD-Wandler einschalten und Prescaler = 64 einstellen
	// (enstpricht 115 khz Wandlertakt)
	ADCSRA = (1<<ADEN)|(1<<ADPS2)|(1<<ADPS1);
}

uint16_t getadc(void) {
	uint16_t buffer;

	// Wandlung starten
	ADCSRA |= (1<<ADSC);
    
	// Warten bis die AD-Wandlung abgeschlossen ist
	while ( !(ADCSRA & (1<<ADIF)) ) ;

	/* AD-Wert auslesen.
	ADCH muss als zweites gelesen werden, da nachdem ADCL gelesen wurde
	das ADC-Register gesperrt ist bis ADCH auch ausgelesen wurde. */
	buffer = ADCL | (ADCH<<8);

	// oder einfacher: buffer = ADC;
	return buffer;
}

int main(void) {
	DDRB = 0b00000111; // LED: gelb, blau, weiss
	DDRC = 0b0011111;  // LED: Rot (c5 = Poti input)
	DDRD = 0b10000000; // Speaker (d2 = Taster input)
	
	adc_init(5);
	
	//uint8_t mini = 200;
	//uint8_t maxi = 250;
	uint16_t Poti;
	
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
		Poti = getadc() / 10;
		delayms(Poti);
	}
	return 0;
}
