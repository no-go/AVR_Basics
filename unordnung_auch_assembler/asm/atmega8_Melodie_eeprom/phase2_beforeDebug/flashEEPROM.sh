#!/bin/bash

# atmega8 only 512 Bytes !!!

# asm -> o -> elf -> hex -> avrdude/atmega

avr-as -mmcu=atmega8 eeprom.asm -o eeprom.o
avr-ld eeprom.o -o eeprom.elf
avr-objcopy -O ihex eeprom.elf eeprom.hex
avrdude -c usbasp -p m8 -B 200 -U eeprom:w:eeprom.hex:i
rm eeprom.o eeprom.elf 
rm eeprom.hex