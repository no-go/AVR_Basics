
# extern Quarz
#avrdude -B 800 -c usbasp -p m8 -U lfuse:w:0xFF:m

# intern 1MHz
avrdude -B 800 -c usbasp -p m8 -U lfuse:w:0xF1:m

# intern 2MHz
#avrdude -B 800 -c usbasp -p m8 -U lfuse:w:0xF2:m

# intern 4MHz
#avrdude -B 800 -c usbasp -p m8 -U lfuse:w:0xF3:m

# intern 8MHz
#avrdude -B 800 -c usbasp -p m8 -U lfuse:w:0xF4:m

