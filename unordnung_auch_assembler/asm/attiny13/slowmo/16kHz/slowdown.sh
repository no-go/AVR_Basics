#!/bin/bash
# make a 128   kHz / 8 = 16    kHz CPU Clock 
#        131072 Hz / 8 = 16384  Hz CPU clock
avrdude -B 800 -c usbasp -p t13 -U lfuse:w:0x6B:m

