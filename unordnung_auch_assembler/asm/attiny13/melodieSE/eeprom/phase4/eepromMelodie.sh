#!/bin/bash

# attiny13 only 64 Bytes !!!

# asm -> o -> elf -> hex -> avrdude/attiny
if [ $1 -z ]
then
	echo Input-Datei fehlt!
	exit
fi

avr-as -mmcu=attiny13 $1 -o eeprom.o
avr-ld eeprom.o -o eeprom.elf
avr-objcopy -O ihex eeprom.elf eeprom.hex
avrdude -c usbasp -p t13 -B 200 -U eeprom:w:eeprom.hex:i
rm eeprom.o eeprom.elf 
rm eeprom.hex