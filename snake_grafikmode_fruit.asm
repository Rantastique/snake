.Model Small
.Stack 100h
.Data
	pos_x DW 20
	pos_y DW 20
	snake_pos_x DW 10, 500 DUP (?)
	snake_pos_y DW 20, 500 DUP (?)
	
	game_over_string DB " Game Over! $"
	richtung DB 64h
	it DB 0
	laenge DB 1
	snack_pos_x DW 60
	snack_pos_y DW 60
	random1 DW 1234h
	random2 DW 5678h

.Code
	put_pixel PROC 
		;Position und Farbe werden vor Aufruf festgelegt
		MOV AH,0Ch
		MOV BH,0
		INT 10h
		RET
	put_pixel ENDP

	zeichne_quadrat PROC
		;Position und Farbe werden vor Aufruf festgelegt
		MOV SI,10
		square_loop1:
		MOV DI,10
		INC CX
		square_loop2:
		CALL put_pixel
		INC DX
		DEC DI
		JNZ square_loop2
		SUB DX,10
		DEC SI
		JNZ square_loop1
		SUB CX,10			;CX zuruecksetzen
		RET
	zeichne_quadrat ENDP
	
	put_snack PROC
		;pruefen ob pos bereits von schlange belegt
		CALL random_x
		CALL random_y
		MOV CX,snack_pos_x
		MOV DX,snack_pos_y	
		MOV AL,00000101b
		CALL zeichne_quadrat
		RET
	put_snack ENDP
	
	random_x PROC
		MOV AX,random1
		ADD AX,2345h
		XOR DX,DX
		MOV BX,62
		MOV random1,AX
		DIV BX
		MOV AX,DX
		MOV BX,10
		MUL BX
		ADD AX,10
		MOV snack_pos_x,AX
		RET
	random_x ENDP
	
	random_y PROC
		MOV AX,random2
		ADD AX,6543h
		XOR DX,DX
		MOV BX,43
		MOV random2,AX
		DIV BX
		MOV AX,DX
		MOV BX,10
		MUL BX
		ADD AX,10
		MOV snack_pos_y,AX
		RET
	random_y ENDP

	spielfeld_zeichnen PROC
		;VGA, 640x480 Pixel
		MOV AH,00
		MOV AL,12h
		INT 10H
		
		;Spielfeld oben abschliessen
		MOV AL,00001110b
		MOV BL,0Ch
		MOV DX,0h
		MOV CX,0h
		MOV it,64
		horizontal:
		CALL zeichne_quadrat
		ADD CX,10
		DEC it
		JNZ horizontal
		
		;Spielfeld vertikal abschliessen
		MOV DX,0h
		MOV it,46
		vertikal:
		MOV CX,0h
		ADD DX,10
		CALL zeichne_quadrat
		MOV CX,630
		CALL zeichne_quadrat
		DEC it
		JNZ vertikal
		
		MOV DX,470
		MOV CX,0h
		MOV it,64
		horizontal2:
		CALL zeichne_quadrat
		ADD CX,10
		DEC it
		JNZ horizontal2
		RET
	spielfeld_zeichnen ENDP
	
	print_snake PROC
		;letzte Position überschreiben
		MOV AL,0
		MOV SI,OFFSET snake_pos_x
		MOV DI,OFFSET snake_pos_y
		
		PUSH SI
		PUSH DI
		MOV CX,[SI]
		MOV DX,[DI]
		MOV BH,00
		CALL zeichne_quadrat
		
		;wurde snack gegessen?
		MOV CX,snack_pos_x
		CMP CX,pos_x
		JNZ still_hungry
		MOV DX,snack_pos_y
		CMP DX,pos_y
		JNZ still_hungry 
		CALL put_snack
		INC laenge
		
		still_hungry:
		POP DI
		POP SI
		MOV AH,laenge
		tausche:
		CMP AH,1
		JBE print
		PUSH AX
		;tausche durch
		;nächste Pos laden
		ADD SI,2
		ADD DI,2
		MOV CX,[SI]
		MOV DX,[DI]
		;an Pos davor schreiben
		SUB SI,2
		SUB DI,2
		MOV [SI],CX
		MOV [DI],DX
		ADD SI,2
		ADD DI,2
		POP AX
		DEC AH
		JMP tausche

		print:
		;neue Position einfügen
		MOV CX,pos_x
		MOV DX,pos_y
		MOV [SI],CX
		MOV [DI],DX
		
		;ausgeben (es reicht eigentlich, das neue Quadrat zu drucken
		;und die alte letzte Position zu ueberschreiben
		;vorteil: schnell, weil kein loop
		;nachteil: kleiner hack noetig weil eine undefined pos im array ist
		;wenn laenge erhoeht wird (0,0) wird schwarz gefärbt
		MOV AL,00000010b
		CALL zeichne_quadrat
		
		;hack vertuschen (billiger als loop):
		MOV CX,0
		MOV DX,0
		MOV AL,00001110b
		CALL zeichne_quadrat
		RET
	print_snake ENDP
	
	is_it_touchy PROC
		MOV SI,OFFSET snake_pos_x
		MOV DI,OFFSET snake_pos_y
		MOV CX, pos_x
		MOV DX, pos_y
		MOV AL,laenge

		CMP CX,[SI]
		JNE loop2
		CMP DX,[DI]
		JE cant_touch_this			;aka hack weil es sonst einen memory fehler gibt
		loop2:
		CMP AL,0 
		JZ all_fine
		DEC AL
		ADD SI,2
		ADD DI,2
		CMP CX,[SI]
		JNE loop2
		CMP DX,[DI]
		JNE loop2
		cant_touch_this:
		JMP ende
		RET
		all_fine:
		RET
	is_it_touchy ENDP
	
	game_over PROC
		CALL spielfeld_zeichnen
		MOV SI,OFFSET game_over_string
		MOV CX,12 
		;Cursor setzen
		MOV AH,02h
		MOV DL,30 		;Spalte
		MOV DH,13 		;Zeile
		MOV BH,00
		INT 10H	
		
		print_str:
		PUSH CX
		MOV AH,09
		MOV AL,[SI]
		MOV CX,1
		MOV BL,01000111b
		INT 10H
		
		POP CX
		INC DL
		INC SI
		MOV AH,02h
		INT 10H	
		loop print_str
		
		;Cursor aus dem Fenster raus setzen
		MOV AH,02h
		MOV DL,0		;Spalte
		MOV DH,50 		;Zeile
		MOV BH,00
		INT 10H	
		RET
	game_over ENDP
	
start:
	MOV AX,@data
	MOV DS,AX
	NOP
	CALL spielfeld_zeichnen	
	CALL put_snack
;Tasteneingaben
warte:
	CMP pos_x,0
	JE ende
	CMP pos_x,630
	JE ende
	CMP pos_y,0
	JE ende
	CMP pos_y,470
	JE ende
	MOV AH,86h
	MOV AL,0
	MOV CX,4
	MOV DX,0h
	INT 15h			;wait
	
	CALL is_it_touchy
	CALL print_snake
	
	MOV AH,01h
	INT 16H
	JZ cont				;keine Taste wurde gedrückt
	MOV AH,0h
	INT 16H
	MOV richtung,AL
	MOV AH,0ch
	MOV AL,0
	INT 21H
	
	cont:
	MOV AL,richtung
	; Warteschleife bis Esc
	CMP AL,77h		;W
	JE move_up
	CMP AL,61h		;A
	JE move_left
	CMP AL,73h		;S
	JE move_down
	CMP AL,64h		;D
	JE move_right
	CMP AL,1Bh
	JNE warte
	JMP ende
move_up:
	SUB pos_y,10
	JMP warte
move_left:
	SUB pos_x,10
	JMP warte
move_right:
	ADD pos_x,10
	JMP warte
move_down:
	ADD pos_y,10
	JMP warte
ende:
	CALL print_snake
	MOV AH,86h
	MOV AL,0
	MOV CX,4
	MOV DX,0h
	INT 15h			;wait
	CALL game_over
	letzte_worte:
	MOV AH,01h
	INT 16H				;keine Taste wurde gedrückt
	CMP AL,1Bh
	JNE letzte_worte
	;paint it black!
	MOV AH,06h
	MOV AL,0
	MOV CX,0
	MOV DH,40
	MOV DL,80
	INT 10h
	
	;Cursor setzen
	MOV AH,02h
	MOV DL,0	;Spalte
	MOV DH,0 		;Zeile
	MOV BH,00
	INT 10H	
	
	MOV AH,4Ch		;der Anfang vom Ende
	INT 21H
end start