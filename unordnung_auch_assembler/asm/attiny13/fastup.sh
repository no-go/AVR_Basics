#!/bin/bash

# 6B make a 128   kHz / 8 = 16    kHz CPU Clock 
#           131072 Hz / 8 = 16384  Hz CPU clock
#avrdude -B 1000 -c usbasp -p t13 -U lfuse:w:0x6B:m

# 7B make a 128   kHz / 1 = 128   kHz CPU Clock 
#avrdude -B 1000 -c usbasp -p t13 -U lfuse:w:0x7B:m

# make a 9,6 MHz CPU Clock 
#avrdude -B 800 -c usbasp -p t13 -U lfuse:w:0x7A:m

# make 4,8 MHz
#avrdude -B 800 -c usbasp -p t13 -U lfuse:w:0x79:m

# make 1,2 MHz
#avrdude -B 800 -c usbasp -p t13 -U lfuse:w:0x6A:m

# make 600 kHz
avrdude -B 800 -c usbasp -p t13 -U lfuse:w:0x69:m