MCU        = attiny85
PROZ       = t85
PROGRAMMER = usbasp
SPEEDFLAG  = -B 100
CC         = avr-gcc
CFLAGS     = -g -Os -Wall -mcall-prologues -mmcu=$(MCU)
OBJ2HEX    = avr-objcopy 
UISP       = avrdude

OBJECTS = main.o

all: main.hex

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

.S.o:
	$(CC) $(CFLAGS) -x assembler-with-cpp -c $< -o $@

.c.s:
	$(CC) $(CFLAGS) -S $< -o $@

flash: all
	$(UISP) -c $(PROGRAMMER) -p $(PROZ) -U flash:w:main.hex:i

# 16 MHz
fuse:
	$(UISP) $(SPEEDFLAG) -c $(PROGRAMMER) -p $(PROZ) -U hfuse:w:0xdf:m -U efuse:w:0xff:m -U lfuse:w:0xe1:m

clean:
	rm -f main.hex main.lst main.obj main.cof main.list main.map main.eep.hex main.bin main.s *.o

main.bin: $(OBJECTS)
	$(CC) $(CFLAGS) -o main.bin $(OBJECTS)

main.hex: main.bin
	rm -f main.hex main.eep.hex
	$(OBJ2HEX) -j .text -j .data -O ihex main.bin main.hex

cpp:
	$(CC) $(CFLAGS) -E main.c

prog: all
	$(UISP) -c $(PROGRAMMER) -p $(PROZ) $(SPEEDFLAG) -U flash:w:main.hex:i 
