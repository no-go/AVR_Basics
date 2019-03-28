COMPI=avr-as
LINKER=avr-ld
FLAGS=-mmcu=attiny13
OBJ2HEX=avr-objcopy 
PRGRM=avrdude 
TARGET=tinyProg

program: $(TARGET).hex
	$(PRGRM) -c usbasp -p t13 -B 200 -U flash:w:$(TARGET).hex:i

%.o: %.asm
	$(COMPI) $(FLAGS) $< -o $@

%.elf: %.o
	$(LINKER) $< -o $@

%.hex: %.elf
	$(OBJ2HEX) -O ihex $< $@

clean:
	rm -f *.hex *.elf *.o
