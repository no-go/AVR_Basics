COMPI=avr-as
LINKER=avr-ld
FLAGS=-mmcu=atmega8
OBJ2HEX=avr-objcopy 
PRGRM=avrdude 
TARGET=megaProg

program: $(TARGET).hex
	$(PRGRM) -c usbasp -p m8 -B 200 -U flash:w:$(TARGET).hex:i
	rm $(TARGET).hex

%.o: %.asm
	$(COMPI) $(FLAGS) $< -o $@

%.elf: %.o
	$(LINKER) $< -o $@

%.hex: %.elf
	$(OBJ2HEX) -O ihex $< $@

clean:
	rm -f *.hex *.elf *.o
