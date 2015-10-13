.model small

.stack 100H

.data 

	STR_EMBARCACAO DB "Embarcacao$"
	STR_SIMBOLO DB "Simbolo$"
	STR_TAMANHO DB "Tamanho$"
	STR_SEPARADOR_TABELA DB "------------------------------------------------$"
	STR_PORTAAVIOES DB "Porta Avioes$"
	STR_NAVIOGUERRA DB "Navio de Guerra$"
	STR_SUBMARINO DB "Submarino$"
	STR_DESTROYER DB "Destroyer$"
	STR_PATRULHA DB "Barco Patrulha$"
	STR_DIGITE_POSICAO DB "Digite a posicao do $"
	
	SIMB_PORTAAVIOES EQU 'A'
	SIMB_NAVIOGUERRA EQU 'B'
	SIMB_SUBMARINO EQU 'S'
	SIMB_DESTROYER EQU 'D'
	SIMB_PATRULHA EQU 'P'
	
	CHR_HORIZONTAL EQU 'H'
	CHR_VERTICAL EQU 'V'
	
	TAM_PORTAAVIOES EQU 5
	TAM_NAVIOGUERRA EQU 4
	TAM_SUBMARINO EQU 3
	TAM_DESTROYER EQU 3
	TAM_PATRULHA EQU 2
	TAM_MATRIZ EQU 10
	
	MATRIZ_JOGADOR DB 100 DUP (' ')
	
.code

	include stdio.asm

	PRINTFS PROC	; printa strings com o offset em DX
		PUSH AX
		MOV AH, 09H
		INT 21H
		POP AX
		RET
	ENDP

	PRINT_LINHA_TABELA_EMBARC PROC		; imprime uma linha da tabela de embarcacoes
		PUSH DX							; AX = offset primeira coluna
		PUSH AX
										; BX = offset segunda coluna
		MOV DX, AX						; CX = offset terceira coluna
		CALL PRINTFS					
		CALL PRINTTAB
		MOV DX, BX
		CALL ESC_CHAR					; char imprime em DX
		CALL PRINTTAB
		CALL PRINTTAB
		MOV AX, CX
		CALL ESC_UINT16					; int imprime em AX
		
		CALL NOVALINHA
		
		POP AX
		POP DX
		RET
	ENDP
	
	PRINT_TITULO_TABELA_EMBARC PROC		; imprime a linha do titulo da tabela de embarcacoes
		PUSH DX							
										
		MOV DX, OFFSET STR_EMBARCACAO						
		CALL PRINTFS					
		CALL PRINTTAB
		MOV DX, OFFSET STR_SIMBOLO
		CALL PRINTFS
		CALL PRINTTAB
		CALL PRINTTAB
		MOV DX, OFFSET STR_TAMANHO
		CALL PRINTFS
		
		POP DX
		RET
	ENDP
	
	PRINT_OUTRAS_LINHAS_TABELA_EMBARC PROC	; imprime as outras linhas da tabela de embarcacoes
		PUSH AX								; AX = offset primeira coluna
		PUSH BX								; BX = offset segunda coluna
		PUSH CX								; CX = offset terceira coluna
		
		MOV AX, OFFSET STR_PORTAAVIOES		;imprime porta avioes
		MOV BX, SIMB_PORTAAVIOES			
		MOV CX, TAM_PORTAAVIOES						
		CALL PRINT_LINHA_TABELA_EMBARC		
		
		MOV AX, OFFSET STR_NAVIOGUERRA		;imprime navio de guerra
		MOV BX, SIMB_NAVIOGUERRA		
		MOV CX, TAM_NAVIOGUERRA					
		CALL PRINT_LINHA_TABELA_EMBARC		
		
		MOV AX, OFFSET STR_SUBMARINO		;imprime submarino
		MOV BX, SIMB_SUBMARINO				
		MOV CX, TAM_SUBMARINO					
		CALL PRINT_LINHA_TABELA_EMBARC		
		
		MOV AX, OFFSET STR_DESTROYER		;imprime destroyer
		MOV BX, SIMB_DESTROYER			
		MOV CX, TAM_DESTROYER			
		CALL PRINT_LINHA_TABELA_EMBARC		
		
		MOV AX, OFFSET STR_PATRULHA			;imprime barco patrulha
		MOV BX, SIMB_PATRULHA					
		MOV CX, TAM_PATRULHA					
		CALL PRINT_LINHA_TABELA_EMBARC		
		
		POP CX
		POP BX
		POP AX
		RET
	ENDP
	
	PRINT_TABELA_EMBARC PROC					; imprime tabela de embarcacoes
		PUSH DX
		
		CALL PRINT_TITULO_TABELA_EMBARC			; imprime titulo
		CALL NOVALINHA
		MOV DX, OFFSET STR_SEPARADOR_TABELA	
		CALL PRINTFS
		CALL NOVALINHA
		CALL PRINT_OUTRAS_LINHAS_TABELA_EMBARC	; imprime outras linhas
		
		POP DX
		RET
	ENDP
	
	PRINT_PRIMEIRA_LINHA_MATRIZ PROC	; imprime os numero de 0 e 9 como primeira linha da matriz
		PUSH AX
		
		CALL PRINTESPACO  
		CALL PRINTESPACO
		
		XOR AX, AX
		
		PPLM_LOOP:					
			CALL PRINTESPACO
			CALL PRINTESPACO
			CALL ESC_UINT16
			INC AX
			CMP AX, TAM_MATRIZ
			JNZ PPLM_LOOP
		
		CALL NOVALINHA
		
		POP AX
		RET
	ENDP
	
	PRINT_MATRIZ PROC						; imprime uma matariz com offset em BX
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		
		CALL PRINT_PRIMEIRA_LINHA_MATRIZ	; imprime a primeira linha da matriz
											; matriz = vetor de nxm prosicoes
		XOR CX, CX					
		XOR DX, DX
		
		PM_LOOP1:
			CALL PRINTESPACO
			MOV AX, CX						; CX conta as linhas
			CALL ESC_UINT16      
			PUSH CX							; empilha CX e
			MOV CX, TAM_MATRIZ				; recomeca a contar para as colunas
			PM_LOOP2:            			; loop das colunas
				CALL PRINTESPACO 
				CALL PRINTESPACO
				MOV DX, [BX]				; BX é o endereço da posição na MEM
				CALL ESC_CHAR
				INC BX
				LOOP PM_LOOP2
			CALL NOVALINHA 
			POP CX							; desempilha CX quando acaba as colunas
			INC CX
			CMP CX, TAM_MATRIZ
			JNZ PM_LOOP1			
			
		POP DX
		POP CX
		POP BX
		POP AX
		RET
	ENDP
	
	GET_POSICAO_INI_BARCO PROC	;retorna em AX a posicao na matriz que o barco será inserido
		PUSH DX
		PUSH BX
		
		XOR AX, AX
		XOR DX, DX
		
		CALL LER_DIGITO			; le a linha
		MOV BL, AL
		CALL LER_DIGITO			; le a coluna
		MOV DL, AL
		MOV AL, TAM_MATRIZ
		MUL BL					; resultado = (tamanho da linha da matriz * nro da linha) + nro da coluna
		ADD AX, DX				; AL = (TAM_MATRIZ * BL) + DL
		
		POP BX
		POP DX
		RET
	ENDP
	
	COLOCA_BARCO_HOR PROC				; coloca um barco na posicao horizontal
		PUSH BX							; BX = posicao inicial  em que será colocado
		PUSH CX							; CX = tamanho do barco
		
		CBH_LOOP1:
			MOV [BX], SIMB_PORTAAVIOES
			INC BX
			LOOP CBH_LOOP1
			
		POP CX
		POP BX
		RET
	ENDP
	
	COLOCA_BARCO_VERT PROC				; coloca um barco na posicao vertical
		PUSH BX							; BX = posicao inicial  em que será colocado
		PUSH CX							; CX = tamanho do barco
		
		CBV_LOOP1:
			MOV [BX], SIMB_PORTAAVIOES
			ADD BX, TAM_MATRIZ
			LOOP CBV_LOOP1
			
		POP CX
		POP BX
		RET
	ENDP
	
	LER_DIRECAO_BARCO PROC						; le a direcao em que o barco será posicionado (H = horizontal, V = vertical)
		PUSH AX									; e retorna em DL
		
		LDB_LOOP:	
			CALL LER_CHAR
			CALL TOUPPER
			CMP AL, CHR_HORIZONTAL				; CHR_HORIZONTAL = 'H'
			JZ LDB_FIM
			CMP AL, CHR_VERTICAL				; CHR_VERTICAL = 'V'
			JZ LDB_FIM
			JMP LDB_LOOP
		
		LDB_FIM:
			MOV DL, AL		;	Escreve na 
			CALL ESC_CHAR	;	tela	
			
		
		POP AX
		RET
	ENDP
	
	COLOCA_BARCO PROC						; coloca um barco na matriz, em CX o tamanho e BX o offset da string para mensagem
		PUSH DX
		PUSH AX
		PUSH BX
		
		MOV DX, OFFSET STR_DIGITE_POSICAO	; imprime a mensagem
		CALL PRINTFS
		MOV DX, BX
		CALL PRINTFS
		MOV DL, ':'
		CALL ESC_CHAR
		CALL NOVALINHA
		CALL GET_POSICAO_INI_BARCO			; o usuario digita a posicao do barco		
		MOV BX, OFFSET MATRIZ_JOGADOR		; pega o offset da matriz
		ADD BX, AX							; e adiciona a posicao digitada
		CALL LER_DIRECAO_BARCO				; le a direcao do barco (somente H ou V)
		CMP DL, CHR_HORIZONTAL
		JZ CB_HOR
		CALL COLOCA_BARCO_VERT
		JMP CB_FIM
		CB_HOR:
			CALL COLOCA_BARCO_HOR
		
		CB_FIM:
			CALL NOVALINHA
		
		POP BX
		POP AX
		POP DX
		RET
	ENDP
	
	ATUALIZA_TELA_INI PROC
		PUSH BX
		
		MOV BX, OFFSET MATRIZ_JOGADOR
		CALL NOVALINHA
		CALL PRINT_MATRIZ
		
		POP BX
		RET
	ENDP
	
	COLOCA_BARCO_ATUALIZA_TELA PROC		; coloca um barco na matriz e depois atualiza a tela		
		CALL COLOCA_BARCO				
		
		CALL ATUALIZA_TELA_INI
		
		RET
	ENDP
	
	TELA_INICIAL PROC					; mostra a tela inicial do jogo
		PUSH BX
		PUSH CX
		
		CALL PRINT_TABELA_EMBARC		; printa tabela com os dados de cada embarcacao
		CALL NOVALINHA
			
		CALL ATUALIZA_TELA_INI
		
		MOV BX, OFFSET STR_PORTAAVIOES	; coloca os porta avioes
		MOV CX, TAM_PORTAAVIOES
		CALL COLOCA_BARCO_ATUALIZA_TELA
		
		POP CX
		POP BX
		RET
	ENDP
	
	INICIO:
		MOV AX, @DATA
		MOV DS, AX
		
		CALL TELA_INICIAL
		
		MOV AH, 04CH
		INT 21H		
             
end INICIO
