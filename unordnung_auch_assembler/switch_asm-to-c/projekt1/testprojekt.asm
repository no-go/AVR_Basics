;	--------------------------------------------------
;	Test-Projekt: ATmega8 - blinkende LED an Port PB0,
;	bei 4 MHz ergibt sich eine Frequenz von ca. 1 Hz
;	--------------------------------------------------
;
.include "m8def.inc"			;Definitionsdatei laden
.cseg					;Beginn eines Code-Segmentes
.org 0					;Startadresse = 0
;
start:	ldi	r16,low(ramend)
	ldi	r17,high(ramend)	;Adresse vom RAM-Ende laden
	out	spl,r16			;Stackpointer auf
	out	sph,r17			;RAM-Ende setzen
	ldi	r16,0b00000001		;PortB: PB0 auf Ausgang
	out	ddrb,r16		;setzen
	clr	r16			;Datenwert für Ausgabe setzen
;
loop:	out	portb,r16		;Daten an PortB ausgeben
	rcall	wait			;Warteschleife aufrufen
	inc	r16			;Datenwert erhöhen
	rjmp	loop			;Programmschleife neu beginnen
;
;	Warteschleife (ungefähr 500ms)
;
wait:	ldi	r19,10			;r19,r18,r17 -> 3-Byte-Zähler
	clr	r18			;höchstes Byte = 10, restliche
	clr	r17			;Bytes = 0
wait1:	dec	r17			;niedrigstes Byte -1
	brne	wait1			;0 erreicht? nein -> Schleife
	dec	r18			;mittleres Byte -1
	brne	wait1			;0 erreicht? nein -> Schleife
	dec	r19			;höchstes Byte -1
	brne	wait1			;0 erreicht? nein -> Schleife
	ret				;Schleifenende, Rückkehr
;
.eseg					;Beginn eines EEPROM-Segmentes
;
data:	.db	"1234567890"		;einige Daten für das EEPROM
;
