;----------------------------------------------------------------------
; ADC-Testprogramm mit ATtiny13
; Erläuterungen: www.schramm-software.de/tipps
;----------------------------------------------------------------------
; Prozessor : ATTiny13
; Takt      : 4,8 MHz
; Sprache   : Assembler
; Version   : 1.0
; Autor     : Dr. Michael Schramm
; Datum     : 10.2009
;----------------------------------------------------------------------
; Portbelegung:
; PB0,PB1:   O  Tonsignal (Piezo-Piepser oder Lautspr. über R-C)
; PB2 - PB5: I ADC-Eingänge
; PB4,PB3:   I bei Start, bestimmen Verzögerung vor Messung:
;   0 0:  10 ms
;   0 1:   1 ms
;   1 0: 0,1 ms
;   1 1:   0 ms (so kurz wie möglich)
;----------------------------------------------------------------------
.include "tn13def.inc"
.include "makros.inc"
;----------------------------------------------------------------------
.DEF nullreg = r15 ; bleibt konstant 0
.DEF adcport = r24 ; durchläuft ADC-Portnr. 1,2,3,0
.DEF pbinit  = r25 ; hält digitalen Startwert an PB fest (für PB3,PB4)
;----------------------------------------------------------------------
.DSEG ;SRAM-Belegung
dezzahl:  .byte 6
tmp_word: .byte 2
;----------------------------------------------------------------------
.CSEG
;Reset- und Interruptvektoren
  rjmp start ;0 RESET, Brown-out Reset, Watchdog Reset
  reti       ;1 INT0 External Interrupt Request 0
  reti       ;2 PCINT0 Pin Change Interrupt Request 0
  reti       ;3 TIM0_OVF Timer/Counter Overflow
  reti       ;4 EE_RDY EEPROM Ready
  reti       ;5 ANA_COMP Analog Comparator
  reti       ;6 TIM0_COMPA Timer/Counter Compare Match A
  reti       ;7 TIM0_COMPB Timer/Counter Compare Match B
  reti       ;8 WDT Watchdog Time-out
  rjmp adcint;9 ADC ADC Conversion Complete
;----------------------------------------------------------------------
zehnerpot: ;Zehnerpotenzen als 2-Byte-Zahlen für Funktion bin2dec
; Tabelle muss im Anfangsbereich des Speichers stehen, damit das
; High-Byte der Adresse 0 ist
.db 16,39  ;10.000
.db 232,3  ;1.000
.db 100,0  ;100
.db 10,0   ;10
.db 1,0    ;1

start:
  out_i PORTB, 0b111111 ;zunächst alle Pull-Up-Wid. schalten
  sbi ACSR,ACD          ;Analog-Comparator ausschalten
  out_i SPL,low(RAMEND) ;Stackpointer setzen, 8bit-Pointer bei Tiny13
; Achtung: bei größeren Controllern ggf. auch SPH setzen!
  in pbinit,PINB ;Inputwerte an Port B beim Start festhalten
  lsr pbinit ;PB4 + PB3 sind von Interesse,
  lsr pbinit ;diese Bits ganz nach rechts shiften
  lsr pbinit
  andi pbinit,3 ;nur die untersten beiden Bits interessieren
; Stromsparmaßnahmen und ADC-Initialisierung
  out_i DIDR0,0b111111  ;Port-B-Input-Buffer ausschalten
  out_i DDRB, 0b000011  ;Datenrichtung von Port B
  clr nullreg
  out PORTB,nullreg ;sämtliche Pull-Up-Wid. deaktivieren
  rcall wait1sek ;zunächst 1 Sekunde warten
  mov r0,pbinit ;zur Kontrolle den PB4-PB3-Zustand signalisieren
  rcall zifferton
; ADC einschalten mit Interrupt und Vorteiler 64
  out_i ADCSRA,(1<<ADEN)+(1<<ADIE)+(1<<ADPS2)+(1<<ADPS1)
  sei ;Interrupts erlauben

; nun beginnt die Messreihe ADC1,2,3,0
  ldi adcport,1 ;Nr. des ADC-Eingangs von 1,2,3,0
  msg_je_port:
    rcall wait1sek ;vor jeder 2er-Messung 1 Sek. Pause
    out ADMUX,adcport
    cpi pbinit,0b11 ;waren beim Start PB4 und PB3 auf 1 (bzw. offen)?
	breq mess_lp ;dann Warteschleife überspringen
    ldi r16,10
	cpi pbinit,0b01
	breq wait_lp ;bei 01: 1 ms warten
    ldi r16,100
	brcs wait_lp ;bei 00: 10 ms warten
    ldi r16,1 ;bei 10: 0,1 ms warten
	wait_lp: ;nun entsprechend warten
      rcall wait100
    next_down r16,wait_lp
	mess_lp:
	for r19,2,messung ;2 Messungen an jedem Port durchführen
      out_i MCUCR,(1<<SE)+(1<<SM0) ;ADC-Noise-Reduction-Modus
;     in diesem Modus stößt sleep eine einzelne ADC-Umwandlung an
      sleep ;schlafen, bis ADC-Ergebnis vorliegt (in R3:R2)
;     das Ergbnis "gemorst" als Tonsignal an PB1 ausgeben
      ldi_hl x,2 ;Adresse von R2
      ldi_hl y,dezzahl ;Speicherbereich für Dezimalzahl-Ergebnis
      rcall bin2dec
	  tst r18 ;Sonderfall 0 berücksichtigen
	  brne ziff_ausg
	  st y,r18 ;Dezimalziffer 0 schreiben
	  inc r18 ;1 Ziffer ausgeben, also 0
      ziff_ausg: ;R18 Ziffern ab (Y) ausgeben
        ld r0,y+
        rcall zifferton
      next_down r18,ziff_ausg
      ldi r17,8
      rcall waitr17 ;nach jeder Messung zusätzlich 800 ms Pause
    next_down r19,messung
    tst adcport
	breq fertig ;letzte Messung wird mit ADC0 durchgeführt
    inc adcport ;nächster ADC-Kanal
    andi adcport,3 ;da Reihenfolge 1,2,3,0
  rjmp msg_je_port ;weiter mit Messung am nächsten ADC-Kanal

  fertig: ;Ende der Messungen
    out_i ADCSRA,0 ;ADC ausschalten
    out_i MCUCR,(1<<SE)+(1<<SM1) ;Power-down-Modus
    sleep ;Tiefschlaf, warten auf Reset-Signal
;----------------------------------------------------------------------

; ******************* Unterprogramme / Funktionen *******************

tonsignal: ; *** Tonsignal an PB0/PB1 ausgeben
; (schlichte Realisierung über Zählschleife)
; R16: Periodenlänge als Vielfaches von 100 µs
; R17: 1/10 der Anzahl der zu erzeugenden Perioden
; R2, R20, XL, XH werden verändert
  ldi xl,1
  out PORTB,xl ;Startzustand der Ports B0 und B1
  ldi r20,10
ton_10per: ;10 Perioden erzeugen
  ldi xh,2 ;für die beiden halben Perioden
ton_period: ;1 Periode erzeugen
  mov r2,r16
wt_halb_per:
  ldi xl,78
wt50lp: ;50 µs warten (bei Taktfrequenz 4,8 MHz)
  dec xl
  brne wt50lp
  dec r2
  brne wt_halb_per
  ldi xl,3
  out PINB,xl ;Ports B0 und B1 umschalten
  dec xh
  brne ton_period
  dec r20
  brne ton_10per
  dec r17
  brne tonsignal
ret
;----------------------------------------------------------------------
zifferton: ; *** R0 als Tonsignalfolge ausgeben
; Inhalte von R0, R16, R17 gehen verloren,
; außerdem: siehe tonsignal
  tst r0
  brne ziff_pieps
  ldi r16,20 ;500 Hz für die Ziffer 0
  ldi r17,25 ;250 Perioden = 1/2 Sekunde
  inc r0 ; damit die folgende Schleife 1mal durchlaufen wird
  rjmp ausg_ziff_ton ;Sprung in die Schleife ...
  ziff_pieps: ;R0 Piepser für eine Dezimalziffer
    ldi r16,10 ;1 kHz
    ldi r17,25 ;250 Perioden = 1/4 Sekunde
    ausg_ziff_ton:
    rcall tonsignal
    ldi r17,3
    rcall waitr17 ;nach jedem Pieps 300 ms warten
  next_down r0,ziff_pieps
  ldi r17,6
  rcall waitr17 ;nach jeder Ziffer zusätzlich 600 ms Pause
ret
;----------------------------------------------------------------------
wait100: ; *** bei Taktfrequenz 4,8 MHz 100 µs warten
; (schlichte Realisierung über Zählschleife)
; Register XL wird verändert
  for xl,131,wt01lp
  next_down xl,wt01lp
ret

wait1ms: ; *** 1 ms warten
; Register XL, XH werden verändert
  for xh,10,wt1lp
    rcall wait100
  next_down xh,wt1lp
ret

wait1sek: ; ***  1 Sekunde warten
  ldi r17,10
waitr17: ;  *** R17 * 100 Millisekunden warten
; Inhalte von R16, R17, X gehen verloren
  for r16,100,wt100lp
    rcall wait1ms
  next_down r16,wt100lp
next_down r17,waitr17
ret
;----------------------------------------------------------------------
bin2dec: ; *** Dezimaldarstellung einer 2-Byte-Binärzahl berechnen
; Input:  X zeigt auf Beginn der Binärzahl (LSB) im SRAM
;         Y zeigt auf Beginn des SRAM-Speicherbereichs der Dezimalzahl
; Output: Dezimalzahl ab (Y), eine Dez.ziffer pro Byte, Start mit MSD
;         R18 = Anzahl der Dezimalziffern (0 bei 0)
  clr r18
  mov r11,xl ;R11 = Kopie von XL
  ldi_hl z,(zehnerpot*2) ;mal 2 wegen wortweiser Adressierung im Flash
  for r16,5,b2d_nxt_ziff ; R16 = Abwärtzzähler für Zehnerpotenzen
    clr r10 ;R10 = aktuelle Ziffer
    push yl
    ldi yl,low(tmp_word)
    for r17,2,b2d_pot_copy
	  lpm r0,z+ ; Zehnerpotenz vom Flash ins SRAM kopieren
	  st y+,r0
    next_down r17,b2d_pot_copy
	mov xl,r11
	adiw x,2
   b2d_nxt_test:
    for r17,2,b2d_compare
	  ld r0,-y ;Zehnerpotenz
	  ld r1,-x ;Rest der Ausgangszahl
	  cp r1,r0
      brcs b2d_ziff_ok ;kein weiterer Abzug möglich
      brne b2d_subtract
    next_down r17,b2d_compare
   b2d_subtract:
	mov xl,r11
    ldi yl,low(tmp_word)
    rcall x_min_y
	inc r10
	rjmp b2d_nxt_test
   b2d_ziff_ok:
    pop yl
	tst r18
	brne b2d_st_ziff
	tst r10
	breq b2d_ziff_fertig
   b2d_st_ziff:
	st y+,r10
	inc r18
 b2d_ziff_fertig:
  next_down r16,b2d_nxt_ziff
  sub yl,r18 ; Y wieder auf Dezimalzahlbeginn
ret
;----------------------------------------------------------------------
x_min_y: ; *** Subtraktion, 2-Byte-Integer (X) <- (X) - (Y)
; r0, r1 werden verändert
; x und y zeigen anschließend hinter die Zahlen, sind also um 2 erhöht
  push r17
  clc
  for r17,2,xminy_lp
    ld r0,x
	ld r1,y+
	sbc r0,r1
	st x+,r0
  next_down r17,xminy_lp
;  sbiw x,2
;  sbiw y,2
  pop r17
ret
;----------------------------------------------------------------------

; ************************ Interrupt-Routinen ************************

adcint: ;ADC-Ergebnis liegt vor
  in r2,ADCL
  in r3,ADCH
reti
; ******************************* ENDE *******************************
