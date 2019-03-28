todo: vereinfachung/zusammenfassung
hex->bcd wäre besser :-)

;subroutine (add a 6 on High and Low Bit, neccessary to get DEC instead of Hex)
AddOneToY:
	ldi		A,1
	add		YL,A	; YL = YL +1
	in		A,SREG	; save status
	push	A

CheckLL:
	ldi		A,0x0F
	and		A,YL	; now A has only the lower 4 bit (L)
	cpi		A,0x0A	; is A=10 ?
	breq	Add6LL
	rjmp	CheckLH
Add6LL:
	ldi		A,0x06
	add		YL,A
CheckLH:
	ldi		A,0xF0
	and		A,YL	; now A has only the higher 4 bit (H)
	cpi		A,0xA0	; is A=10 ?
	breq	Add6LH
	rjmp	CheckLend
Add6LH:
	ldi		A,0x60
	add		YL,A
	pop		A
	in		A,SREG	; save status	
	push	A

CheckLend:
	pop		A
	out		SREG,A	; restore status
	ldi		A,0
	adc		YH,A	; YH = YH +0 +Carry

; alles nochmal mit YH ---------------------
CheckHL
	ldi		A,0x0F
	and		A,YH	; now A has only the lower 4 bit (L)
	cpi		A,0x0A	; is A=10 ?
	breq	Add6HL
	rjmp	CheckHH
Add6HL:
	ldi		A,0x06
	add		YH,A
CheckHH:
	ldi		A,0xF0
	and		A,YH	; now A has only the higher 4 bit (H)
	cpi		A,0xA0	; is A=10 ?
	breq	Add6HH
	rjmp	CheckHend
Add6HH:
	ldi		A,0x60
	add		YH,A

CheckHend:
	ret
