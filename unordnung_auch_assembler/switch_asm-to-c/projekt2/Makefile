CC=avr-gcc
CFLAGS=-g -Os -Wall -mcall-prologues -mmcu=atmega8
OBJ2HEX=avr-objcopy 
UISP=avrdude 
TARGET=blink

program: $(TARGET).hex
	$(UISP) -c usbasp -p m8 -U flash:w:$(TARGET).hex:i

%.obj: %.o
	$(CC) $(CFLAGS) $< -o $@

%.hex: %.obj
	$(OBJ2HEX) -R .eeprom -O ihex $< $@

clean:
	rm -f *.hex *.obj *.o
