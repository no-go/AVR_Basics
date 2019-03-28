#!/bin/bash
avr-as -mmcu=atmega8 -o test.o test.asm
avr-ld -o test.elf test.o
avr-objcopy --output-target=ihex test.elf test.ihex
avrdude -c usbasp -p m8 -U flash:w:test.ihex:i

