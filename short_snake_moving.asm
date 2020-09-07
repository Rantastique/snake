.Model Small
.Stack 100h
.Data
	pos_x DB 8
	pos_y DB 2
	snake_pos_x DB 1, 2, 3, 4, 5, 6, 7, 8
	snake_pos_y DB 2, 2, 2, 2, 2, 2, 2, 2
	iterator DB 8
.Code
	spielfeld_zeichnen PROC
	;Spielfeld erstellen
		;erste Zeile
		MOV AH,00
		MOV AL,03		; Textmodus, 80 x 25 Zeichen
		INT 10H			;in textbasierten Grafikmodus wechseln
		
		;Bildschirm fuellen
		MOV AH,6h
		MOV AL,0
		MOV CH,0
		MOV CL,0
		MOV DH,25
		MOV DL,80
		MOV BH,00010000b
		INT 10H			
		
		;Cursor setzen
		MOV AH,02h
		MOV DL,0		;Spalte
		MOV DH,0		;Zeile
		MOV BH,00
		INT 10H	
		
		;erste Reihe fuellen
		MOV AH,0Ah
		MOV BH,00
		MOV AL,'#'
		MOV CX,80
		INT 10H
		
	;Spielfeld vertikal abschliessen
		MOV CX,17h
		MOV DH,1
		MOV DL,0
		PUSH DX
	loop1:
		MOV AH,2h
		POP DX
		MOV DL,0
		INT 10H			;Cursor setzen
		
		MOV AH,0Eh		;Zeichen ausgeben
		INT 10H
		
		MOV AH,2h
		MOV DL,79
		INT 10H			;Cursor setzen
		
		MOV AH,0Eh		;Zeichen ausgeben
		INT 10H
		
		INC DH
		PUSH DX
		DEC CX
		JNZ loop1
		POP	DX			;Stack leer machen
		
		;Spielfeld horizontal abschliessen	
		MOV AH,2h
		MOV DL,0		;Spalte
		INT 10H	
		
		;letzte Reihe fuellen
		MOV AH,0Ah
		MOV CX,80
		INT 10H
		RET
	spielfeld_zeichnen ENDP
	
	print_snake PROC
		MOV SI,OFFSET snake_pos_x
		MOV DI,OFFSET snake_pos_y
		
		;letzte Position leeren
		MOV AH,2h
		MOV AL,0
		MOV DL,[SI]
		MOV DH,[DI]
		MOV BH,00
		INT 10H
		
		MOV AH,09
		MOV AL,' '
		MOV CX,1
		MOV BL,00010111b
		INT 10H
		
		MOV CX, 7
		tausche:
		;nächste Pos laden
		INC SI
		INC DI
		MOV DL,[SI]
		MOV DH,[DI]
		;an Pos davor schreiben
		DEC SI
		DEC DI
		MOV [SI],DL
		MOV [DI],DH
		INC SI
		INC DI
		loop tausche
		;neue Pos an Stelle 8 schreiben
		MOV DL, pos_x
		MOV DH, pos_y
		MOV [SI],DL
		MOV [DI],DH
		
		;schlange ausgeben
		MOV SI,OFFSET snake_pos_x
		MOV DI,OFFSET snake_pos_y
		MOV CX, 8
		print:
		PUSH CX
		MOV AH,2h
		MOV DL,[SI]
		MOV DH,[DI]
		MOV BH,00
		INT 10H
		
		MOV AH,09
		MOV AL,'o'
		MOV CX,1
		MOV BL,01000111b
		INT 10H
		ADD SI,1
		ADD DI,1
		POP CX
		loop print
		RET 4
	print_snake ENDP

start:
	MOV AX,@data
	MOV DS,AX
	NOP
	CALL spielfeld_zeichnen	
;Tasteneingaben
warte:
	MOV AH,86h
	MOV AL,0
	MOV CX,4
	MOV DX,0h
	INT 15h			;wait
	
	MOV AH,0ch
	INT 21H			;flush
	
	CALL print_snake
	
	MOV AH,0h
	MOV AL,0
	INT 16h			; Warteschleife bis Esc
	
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
	SUB pos_y,1
	JMP warte
move_left:
	SUB pos_x,1
	JMP warte
move_right:
	ADD pos_x,1
	JMP warte
move_down:
	ADD pos_y,1
	JMP warte
ende:
	MOV AH,4Ch		;der Anfang vom Ende
	INT 21H
end start