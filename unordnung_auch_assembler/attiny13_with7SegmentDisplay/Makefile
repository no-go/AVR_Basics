# 9.6 MHz / 8 = 1.2 MHz
#avrdude -B 800 -c usbasp -p t13 -U hfuse:w:0xFF:m -U lfuse:w:0x6A:m

CC=avr-gcc
CFLAGS=-g -Os -Wall -mcall-prologues -mmcu=attiny13
OBJ2HEX=avr-objcopy 
UISP=avrdude 
TARGET=tinyProg

program: $(TARGET).hex
	$(UISP) -c usbasp -p t13 -B 60 -U flash:w:$(TARGET).hex:i

fuse:
	$(UISP) -c usbasp -p t13 -B 800 -U hfuse:w:0xFF:m -U lfuse:w:0x6A:m

%.obj: %.o
	$(CC) $(CFLAGS) $< -o $@

%.hex: %.obj
	$(OBJ2HEX) -R .eeprom -O ihex $< $@

clean:
	rm -f *.hex *.obj *.o
