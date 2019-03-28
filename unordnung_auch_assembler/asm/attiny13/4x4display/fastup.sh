#!/bin/bash
# make a 9,6 MHz CPU Clock 
#avrdude -B 800 -c usbasp -p t13 -U lfuse:w:0x7A:m
# make 4,8 MHz
#avrdude -B 800 -c usbasp -p t13 -U lfuse:w:0x79:m
# make 1,2 MHz
#avrdude -B 800 -c usbasp -p t13 -U lfuse:w:0x6A:m
# make 600 kHz
avrdude -B 800 -c usbasp -p t13 -U lfuse:w:0x69:m

