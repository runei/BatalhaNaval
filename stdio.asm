  	CR EQU 13
	LF EQU 10
	TAB EQU 9
	ESPACO EQU 32

	ESC_UINT16 PROC
			PUSH AX
			PUSH BX
			PUSH CX ; Contador
			PUSH DX

			XOR CX, CX ; Zerar variavel															;		 ---
			MOV BX, 10 ; Divisor																;		|'2'|
	LACO:	XOR DX, DX ; Zerar parte alta da divisao DX:AX										;		| 0 |
																								;	SP	|'5'|
			DIV BX ; 16 bits																	;		| 0 |
				   ; DIV BX -> AX = [DX AX] / BX ; "DX = [DX AX] % BX" DX recebe resto			;		|'6'|
				   ; 8 bits																		;		| 0	|
				   ; DIV BL -> AH = AX / BL ; "AH = AX % BL" recebe resto						;		 ---

			ADD DL, '0' ; '0' ? 8 bits, tem que adicionar com um registrador de 8 bits
			PUSH DX
			INC CX
			OR AX, AX
			JNZ LACO
	ESCREVE:POP DX
			CALL ESC_CHAR		;LOOP ESCREVE = DEC CX
			LOOP ESCREVE		;				JNZ ESCREVE

			POP DX
			POP CX
			POP BX
			POP AX
			RET
	ENDP
	
	TOUPPER PROC				; transforma letra em Al em maiuscula
		CMP AL, 'a'
		JB TU_FIM
		CMP AL, 'z'
		JA TU_FIM
		
		SUB AL, 'a'
		ADD AL, 'A'
		
		TU_FIM:	
			RET
	ENDP
	
	LER_DIGITO PROC		; le um digito em AL
		PUSH DX
		
		LD_SOLEITURA:	
			CALL LER_CHAR
			CMP AL, '0'
			JB LD_SOLEITURA
			CMP AL, '9'
			JA LD_SOLEITURA
		
		MOV DL, AL		;	Escreve na 
		CALL ESC_CHAR	;	tela	

		SUB AL, '0'		; 	transforma em num
			
		LD_FIM:
			POP DX
			
		RET
	ENDP
	
	LER_UINT16 PROC
		
		PUSH BX
		PUSH CX
		PUSH DX
		
		XOR CX, CX
		MOV BX, 10
		XOR AX, AX
	PROXCHAR:
		PUSH AX ; SALVAR AX
	SOLEITURA:
		CALL LER_CHAR
		CMP AL, CR
		JZ FIM
		CMP AL, '0'
		JB SOLEITURA
		CMP AL, '9'
		JA SOLEITURA
		
		MOV DL, AL		;	Escreve na 
		CALL ESC_CHAR	;	tela
		
		SUB AL, '0'		; 	transforma em num
		MOV CL, AL
		POP AX
		PUSH AX			;	se der overflow 
		MUL BX
		JO FIM
		ADD AX, CX
		JO FIM
		POP CX			; 	pop pra tirar lixo da pilha
		JMP PROXCHAR
	
	FIM:
		CALL NOVALINHA
		POP AX
		POP DX
		POP CX
		POP BX	
	
		RET
	ENDP
	
	ESC_CHAR PROC ; DL = caracter de entrada
			
		PUSH AX
		MOV AH, 02
		INT 21H
		POP AX
		RET				; small, ip
	ENDP
	
	NOVALINHA PROC
		
		PUSH DX
		
		MOV DL, CR
		CALL ESC_CHAR

		MOV DL, LF
		CALL ESC_CHAR
		
		POP DX
		
		RET
	ENDP
	
	PRINTTAB PROC	; imprime tab na tela
		PUSH DX
		MOV DL, TAB
		CALL ESC_CHAR
		POP DX
		RET
	ENDP
	
	PRINTESPACO PROC	; imprime tab na tela
		PUSH DX
		MOV DL, ESPACO
		CALL ESC_CHAR
		POP DX
		RET
	ENDP

	LER_CHAR PROC
	
		MOV AH, 07
		INT 21H
	
		RET
	ENDP
	
