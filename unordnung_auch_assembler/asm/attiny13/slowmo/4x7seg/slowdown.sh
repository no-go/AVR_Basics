#!/bin/bash
# 6B make a 128   kHz / 8 = 16    kHz CPU Clock 
#           131072 Hz / 8 = 16384  Hz CPU clock
#avrdude -B 1000 -c usbasp -p t13 -U lfuse:w:0x6B:m

# 7B make a 128   kHz / 1 = 128   kHz CPU Clock 
avrdude -B 1000 -c usbasp -p t13 -U lfuse:w:0x7B:m

