CC=avr-gcc
CFLAGS=-g -Os -Wall -mcall-prologues -mmcu=attiny13
PROZ=t13
OBJ2HEX=avr-objcopy 
UISP=avrdude
OBJECTS=main.o

all: main.hex

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

.S.o:
	$(CC) $(CFLAGS) -x assembler-with-cpp -c $< -o $@

.c.s:
	$(CC) $(CFLAGS) -S $< -o $@

flash: all
	$(UISP) -c usbasp -p $(PROZ) -B 250 -U flash:w:main.hex:i

fuse:
	# 9.6 MHz -> 4.3 V
	$(UISP) -B 250 -c usbasp -p $(PROZ) -U hfuse:w:0xf9:m -U lfuse:w:0x7a:m

clean:
	rm -f main.hex main.lst main.obj main.cof main.list main.map main.eep.hex main.bin *.o main.s

main.bin: $(OBJECTS)
	$(CC) $(CFLAGS) -o main.bin $(OBJECTS)

main.hex: main.bin
	rm -f main.hex main.eep.hex
	$(OBJ2HEX) -j .text -j .data -O ihex main.bin main.hex

cpp:
	$(CC) $(CFLAGS) -E main.c

prog: all
	$(UISP) -c usbasp -p $(PROZ) -B 250 -U flash:w:main.hex:i 
