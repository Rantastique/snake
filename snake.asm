.Model Small
.Stack 100h
.Data
	pos_x DB 1h
	pos_y DB 1h
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
	MOV AH,2h
	MOV DL,0		;Spalte
	MOV DH,0		;Zeile
	MOV BH,00
	INT 10H	
	
	;erste Reihe fuellen
	MOV AH,09
	MOV BH,00
	MOV AL,'#'
	MOV CX,80
	MOV BL,01000111b
	INT 10H
	
;Spielfeld vertikal abschliessen
	MOV CX,16h
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
	MOV AH,09
	MOV CX,80
	MOV BL,01000111b
	INT 10H
	RET 4
spielfeld_zeichnen ENDP


start:
	CALL spielfeld_zeichnen


	MOV AH,4Ch		;der Anfang vom Ende
	INT 21H
end start