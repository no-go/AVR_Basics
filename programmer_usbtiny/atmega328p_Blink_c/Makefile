CC=avr-gcc
CFLAGS=-g -Os -Wall -mcall-prologues -mmcu=atmega328p
PROZ=m328p
OBJ2HEX=avr-objcopy 
UISP=avrdude
OBJECTS = main.o

all: main.hex

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

.S.o:
	$(CC) $(CFLAGS) -x assembler-with-cpp -c $< -o $@

.c.s:
	$(CC) $(CFLAGS) -S $< -o $@

flash: all
	$(UISP) -c usbtiny -p $(PROZ) -U flash:w:main.hex:i

#fuse:
#	$(UISP) -B 200 -c usbtiny -p $(PROZ) -U hfuse:w:0xdf:m -U efuse:w:0xff:m -U lfuse:w:0xe1:m

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
	$(UISP) -c usbtiny -p $(PROZ) -B 80 -U flash:w:main.hex:i 
