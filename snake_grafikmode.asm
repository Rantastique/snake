.Model Small
.Stack 100h
.Data
	pos_x DW 90
	pos_y DW 20
	snake_pos_x DW 10, 20, 30, 40, 50, 60, 70, 80
	snake_pos_y DW 20, 20, 20, 20, 20, 20, 20, 20
	game_over_string DB " Game Over! $"
	richtung DB 64h
	it DB 0
.Code
	put_pixel PROC 
	;Position und Farbe werden vor Aufruf festgelegt
	MOV AH,0Ch
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
	
	;letzte Position übermalen
	MOV CX,[SI]
	MOV DX,[DI]
	MOV BH,00
	PUSH SI
	PUSH DI
	CALL zeichne_quadrat
	
	POP DI
	POP SI
	;Positionen tauschen
	MOV it, 7
	tausche:
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
	DEC it
	JNZ tausche
	;neue Pos an Stelle 8 schreiben
	MOV CX,pos_x
	MOV DX,pos_y
	MOV [SI],CX
	MOV [DI],DX

	MOV AL,00001100b
	;schlange ausgeben
	MOV SI,OFFSET snake_pos_x
	MOV DI,OFFSET snake_pos_y
	MOV it,8
	print:
	MOV CX,[SI]
	MOV DX,[DI]
	PUSH SI
	PUSH DI
	CALL zeichne_quadrat
	POP DI
	POP SI
	ADD SI,2
	ADD DI,2
	DEC it
	JNZ print
	RET
	print_snake ENDP
	
	is_it_touchy PROC
		MOV SI,OFFSET snake_pos_x
		MOV DI,OFFSET snake_pos_y
		MOV CX, pos_x
		MOV DX, pos_y
		MOV CX,7
		;an Pos 2 anfangen, da 1 ja geloescht und somit wieder "beruehrt" werden kann
		loop2:
		JCXZ all_fine
		DEC CX
		ADD SI,2
		ADD DI,2
		CMP DL,[SI]
		JNE loop2
		CMP DH,[DI]
		JNE loop2
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
		MOV DL,35		;Spalte
		MOV DH,12 		;Zeile
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
		RET
	game_over ENDP
	
start:
	MOV AX,@data
	MOV DS,AX
	NOP
	CALL spielfeld_zeichnen	
;Tasteneingaben
warte:
	CMP pos_x,0
	JE ende
	CMP pos_x,80
	JE ende
	CMP pos_y,0
	JE ende
	CMP pos_y,25
	JE ende
	MOV AH,86h
	MOV AL,0
	MOV CX,4
	MOV DX,0h
	INT 15h			;wait
	
	;CALL is_it_touchy
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
	MOV AH,4Ch		;der Anfang vom Ende
	INT 21H
end start