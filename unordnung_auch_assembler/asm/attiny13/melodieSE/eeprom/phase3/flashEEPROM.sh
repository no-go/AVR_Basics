#!/bin/bash

# attiny13 only 64 Bytes !!!

# asm -> o -> elf -> hex -> avrdude/attiny

avr-as -mmcu=attiny13 eeprom.asm -o eeprom.o
avr-ld eeprom.o -o eeprom.elf
avr-objcopy -O ihex eeprom.elf eeprom.hex
avrdude -c usbasp -p t13 -B 200 -U eeprom:w:eeprom.hex:i
rm eeprom.o eeprom.elf 
#rm eeprom.hex