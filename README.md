# AVR Basics without Arduino IDE

Hi. Es ist ein **kleiner Anfang** und dieser Code und die Dateien
sind schon etwas älter. Das Ganze sollte natürlich noch etwas besser
beschrieben werden (vor allem auf Englisch).

Das Splitten in Ordner (nach Gerät, Beispiel und dem verwendeten Programmier-Gerät) ist
nicht schön, aber eben ein Anfang.

Ziel ist es, ohne Arduino IDE Chips wie atmega und attiny nur mit:

- einem c oder cpp Code
- den opensource `avr-gcc` Kompiler, Linker und `avr-binutils` (und `avr-libc`)
- `avrdude` zum flashen
- Makefile (im Grunde eine Abfolge von Kommandozeilen-Befehlen)

... zu kompilieren und zu flashen: also auf mit einem Programmer oder nur einer
seriellen/UART Verbindung via USB deinen Code auf den Chip zu spielen.

## Crash Kurs

Eine `main.c` schreiben mit Blink Code:

```
#define F_CPU 8000000L
#include <avr/io.h>
#include <util/delay.h>
#define LED_ON  10
#define LED_OFF 20

static volatile uint8_t r = 0;

void update_leds() {
  if (r == LED_ON) {
    PORTB |= (1 << PB5);
    r = LED_OFF;
  } else {
    PORTB &= ~(1 << PB5);
    r = LED_ON;
  }
}

int main(void) {
  DDRB |= (1 << PB5);
  while(1) {
    update_leds();
    _delay_ms(500);
  }
  return 0;
}
```

Kompilieren für den Chip atmega328p:

```console
avr-gcc -g -Os -Wall -mcall-prologues -mmcu=atmega328p -c main.c -o main.o
```

Die erzeugte Objektdatei main.o Linken, damit sie eine Binary (Ausführbar für den Chip) wird:

```console
avr-gcc -g -Os -Wall -mcall-prologues -mmcu=atmega328p -o main.bin main.o
```

Die `main.bin` kann man aber so nicht mit `avrdude` auf den Chip spielen.
Daher kommen nun die `avr-binutils` ins Spiel, die aus der `.bin` eine `.hex`
Datei machen:

```console
avr-objcopy  -j .text -j .data -O ihex main.bin main.hex
```

Oben im c-Code ist 8MHz angegeben. Nun muss man ein wenig die Anleitung
des Chips lesen, wie man die Fusebits des Chips (wenn das nicht schon korrekt eingestellt ist!!!)
zu setzen hat. Bei meinem atmega328p mit einem 8MHz Quarz und angeschlossen
via usbasp Programmer, sieht das setzen der Fusebits mit avrdude so aus:

```console
avrdude -B 250 -c usbasp -p m328p -U hfuse:w:0xDA:m -U lfuse:w:0xEE:m -U efuse:w:0xFD:m
```

Das `-B 250` ist eine Art Speedangabe, die je nach USB-Kabel Qualität und Chip-Frequenz
durchaus einer spielerischen Änderung bedarf.

## Makefile

Zusätzlich sind in den Makefiles von mir andere Aufrufe hinterlegt, um z.B.
den Chip auf 8,12 oder 16 Mhz zu stellen oder andere Sachen (fuse bits!?)
wovon mir manche Teile selbst schleierhaft sind. So kann man sich z.B.
den Code auch als Assembler (.S Datei) oder sowas ausgeben lassen (!?)

PS: ohne `make clean` gibt es oft nichts zu tun. Kann sein, dass die Makefiles
nicht so sauber sind, wie sie sollten. Ändert sich an der `main.c` nichts, sollte
das Makefile auch nihts tun. Ähm, was wollte ich noch gleich sagen? Sorry, aber
sticke derzeit in ganz anderen Projekten drin ;-)

## USBasp

Mit diesem Programmer kann man ohne Bootlader auf dem AVR/Atmel Microchip
seinen Code einspielen. Anleitungen zum Selbstbau und Verkabelung findet
man im Internet.

## USBtiny bootloader

Diesen Bootloader habe ich mal als hex Datei für atmega chips hinterlegt.
Es kann sein, dass irgendwo in den Makefiles auch steht, wie man diesen
mit USBasp aufspielt.

Der Vorteil: Man kann mit einem billigen Seriellen USB-UART Chip seinen
AVR/Atmel Microchip direkt programmieren! Einige (speziell Adafruit oder
Arduino pro mini) Boards werden bereits mit so einem Bootloader ausgeliefert.

So einen Bootloader gibt es auch für den attiny85 mit der Eigenschaft,
dass sogar die serielle Schnittstelle eingespart werden kann. Programmieren
tut man dann mit *USBtinyISP*

Mehr dazu: https://github.com/no-go/ATtiny85-Bootloader

# Achtung

Speziell die Sache mit den Fusebits kann euren Chip zum Teil unprogrammierbar machen!
Dort ist Vorsicht geboten! Ein High-Level Programmer kann dann nur noch
eine Lösung bieten.

