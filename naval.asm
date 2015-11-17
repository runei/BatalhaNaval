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
	STR_DIGITE_NOVAMENTE DB "Digite novamente$"
	STR_VOCE DB "Voce$"
	STR_TIROS DB "Tiros:$"
	STR_ACERTOS DB "Acertos:$"
	STR_AFUNDADOS DB "Afundados:$"
	STR_ADVERSARIO DB "Adversario$"
	STR_ULTIMO_TIRO DB "Ultimo Tiro:$"
	STR_PORTA_SERIAL DB "Porta Serial:$"
	STR_IN DB "In:$"
	STR_OUT DB "Out:$"
	STR_POSICAO DB "Posicao:$"
	STR_MENSAGENS DB "Mensagens:$"
	STR_SEPARADOR_PLACAR DB "--------------------$"
	
	
	SIMB_PORTAAVIOES EQU 'A'
	SIMB_NAVIOGUERRA EQU 'B'
	SIMB_SUBMARINO EQU 'S'
	SIMB_DESTROYER EQU 'D'
	SIMB_PATRULHA EQU 'P'
	
	CHR_HORIZONTAL EQU 'H'
	CHR_VERTICAL EQU 'V'
	
	CS_LINHA_INI EQU 02H
	CS_COL_BASIC_INFO EQU 04H
	
	TAM_PORTAAVIOES EQU 5
	TAM_NAVIOGUERRA EQU 4
	TAM_SUBMARINO EQU 3
	TAM_DESTROYER EQU 3
	TAM_PATRULHA EQU 2
	TAM_MATRIZ EQU 10
	TAM_VET_NAVIOS EQU 5
	TAM_DIVISOR EQU 14
	
	DIST_MATRIZ_COR EQU 100
	
	PIPE EQU 124
	
	VET_STR_BARCOS DB OFFSET STR_PORTAAVIOES, OFFSET STR_NAVIOGUERRA, OFFSET STR_SUBMARINO, OFFSET STR_DESTROYER, OFFSET STR_PATRULHA
	VET_SIMB_BARCOS DB SIMB_PORTAAVIOES, SIMB_NAVIOGUERRA, SIMB_SUBMARINO, SIMB_DESTROYER, SIMB_PATRULHA
	VET_TAM_BARCOS DB TAM_PORTAAVIOES, TAM_NAVIOGUERRA, TAM_SUBMARINO, TAM_DESTROYER, TAM_PATRULHA
	
	MATRIZ_JOGADOR DB 100 DUP (' ')
	MATRIZ_JOGADOR_COR DB 100 DUP (00H) ; 02H = verde
	MATRIZ_TIROS DB 100 DUP (254)
	MATRIZ_TIROS_COR DB 100 DUP (02H) ; 02H = verde
	
.code

	include stdio.asm

	PRINTFS PROC	; printa strings com o offset em DX
		PUSH AX
		MOV AH, 09H
		INT 21H
		POP AX
		RET
	ENDP

	PRINT_LINHA_TABELA_EMBARC PROC				; imprime uma linha da tabela de embarcacoes
		PUSH DX									; CX = pos vetores
		PUSH AX
		PUSH BX
						
		XOR AX, AX
		XOR DX, DX
			
		MOV BX, OFFSET VET_STR_BARCOS
		ADD BX, CX
		MOV DL, [BX]
		CALL PRINTFS					
		CALL PRINTTAB
		
		MOV BX, OFFSET VET_SIMB_BARCOS
		ADD BX, CX
		MOV DL, [BX]
		CALL ESC_CHAR							; char imprime em DX
		CALL PRINTTAB
		CALL PRINTTAB    
		
		MOV BX, OFFSET VET_TAM_BARCOS
		ADD BX, CX
		MOV AL, [BX]
		CALL ESC_UINT16							; int imprime em AX
		
		CALL NOVALINHA
		
		POP BX
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
		
		MOV CX, TAM_VET_NAVIOS
		MOV BX, 0				
		POLTE_LOOP:
			PUSH CX
			MOV CX, BX
			CALL PRINT_LINHA_TABELA_EMBARC
			INC BX
			POP CX
			LOOP POLTE_LOOP
				
		
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
		PUSH AX							; AX = pos cursor
		PUSH DX
		
		MOV DX, AX
		CALL SET_CURSOR
		
		CALL PRINTESPACO  
		CALL PRINTESPACO
		
		XOR AX, AX
		
		PPLM_LOOP:					
			CALL PRINTESPACO
			; CALL PRINTESPACO
			CALL ESC_UINT16
			INC AX
			CMP AX, TAM_MATRIZ
			JNZ PPLM_LOOP
			
		POP DX
		POP AX
		
		INC AH						; incrementa linha(enter)
		
		RET
	ENDP
	
	SET_CURSOR PROC		;coloca o cursor na posicao DH = linha, DL = coluna
		PUSH AX
		PUSH BX
		
		MOV AH, 02H
		MOV BH, 00H		; numero da pagina
		INT 10H
		
		POP BX
		POP AX
		RET
	ENDP
	
	GET_CURSOR PROC		; retorna a posicao do cursor DH = linha, DL = coluna
		PUSH AX
		PUSH BX
		PUSH CX
		
		MOV AH, 03H
		MOV BH, 00H		; numero da pagina
		INT 10H
		
		POP CX
		POP BX
		POP AX
		RET
	ENDP
	
	ESC_CHAR_COLORED PROC		;printa char colorido
		PUSH AX					; BX = endereco matriz
		PUSH BX
		PUSH CX
		PUSH DX

		MOV AH, 09H				; tipo da int pra printa o char, mas ele não move o cursor
		MOV AL, DL				; AL = char
		
		ADD BX, DIST_MATRIZ_COR	; 100 é a distancia para a matriz de cores
		MOV DX, [BX]			; isso é um mero gambito
		
		MOV BH, 00H				; BH = page number
		MOV BL, DL				; BL = cor 
		MOV CX, 01H				; CL = qtde de char que vai imprimir
		INT 10H
		
		CALL GET_CURSOR
		
		INC DL					; incrementa a coluna do cursor
		
		CALL SET_CURSOR
		
		POP DX
		POP CX
		POP BX
		POP AX
		RET
	ENDP
	
	PRINT_MATRIZ PROC						; imprime uma matariz com offset em BX
		PUSH AX								; AX = pos cursor
		PUSH BX
		PUSH CX
		PUSH DX
		
		CALL PRINT_PRIMEIRA_LINHA_MATRIZ	; imprime a primeira linha da matriz
											; matriz = vetor de nxm prosicoes
		XOR CX, CX					
		XOR DX, DX
		
		PM_LOOP1:
			MOV DX, AX
			CALL SET_CURSOR
			PUSH AX
			CALL PRINTESPACO
			MOV AX, CX						; CX conta as linhas
			CALL ESC_UINT16      
			PUSH CX							; empilha CX e
			MOV CX, TAM_MATRIZ				; recomeca a contar para as colunas
			PM_LOOP2:            			; loop das colunas
				CALL PRINTESPACO 
				; CALL PRINTESPACO
				MOV DX, [BX]				; BX é o endereço da posição na MEM
				CALL ESC_CHAR_COLORED
				INC BX
				LOOP PM_LOOP2
			POP CX							; desempilha CX quando acaba as colunas
			INC CX
			POP AX
			INC AH							;incrementa linha(AH)
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
		PUSH CX							; CX = pos no vetor de barcos
		PUSH DX							
		PUSH AX
		
		MOV AX, BX
		
		MOV BX, OFFSET VET_SIMB_BARCOS	; pega o valor a ser colocado
		ADD BX, CX
		MOV DL, [BX]
		
		MOV BX, OFFSET VET_TAM_BARCOS	; pega o tamanho do barco
		ADD BX, CX
		XOR CX, CX
		MOV CL, [BX]
		
		MOV BX, AX		
		
		CBH_LOOP1:
			MOV [BX], Dl
			ADD BX, DIST_MATRIZ_COR		; coloca a cor do caractere
			MOV [BX], 07H				; 07H = cinza
			SUB BX, DIST_MATRIZ_COR
			INC BX
			LOOP CBH_LOOP1
			
		POP AX
		POP DX
		POP CX
		POP BX
		RET
	ENDP
	
	COLOCA_BARCO_VERT PROC				; coloca um barco na posicao vertical
		PUSH BX							; BX = posicao inicial  em que será colocado
		PUSH CX							; CX = pos no vetor de barcos
		PUSH DX							
		PUSH AX
		
		MOV AX, BX
		
		MOV BX, OFFSET VET_SIMB_BARCOS	; pega o valor a ser colocado
		ADD BX, CX
		MOV DL, [BX]
		
		MOV BX, OFFSET VET_TAM_BARCOS	; pega o tamanho do barco
		ADD BX, CX
		XOR CX, CX
		MOV CL, [BX]
		
		MOV BX, AX
		
		CBV_LOOP1:
			MOV [BX], DL
			ADD BX, DIST_MATRIZ_COR		; coloca a cor do caractere
			MOV [BX], 07H				; 07H = cinza
			SUB BX, DIST_MATRIZ_COR
			ADD BX, TAM_MATRIZ
			LOOP CBV_LOOP1
		
		POP AX
		POP DX	
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
                           
    VER_POSICAO_OCUPADA_VER PROC ; BX , posicao matriz + posicao digitada , CX , tamanho do barco - 1
        PUSH CX
        PUSH BX
        
        XOR AX, AX
        
        LOOP_POSICAO_OCUPADA_VER:
            MOV AL, [BX]
            
            CMP AL, ' '
            JNZ POSICAO_OCUPADA_VER_INVALIDA
            
            ADD BX, 10
        LOOP LOOP_POSICAO_OCUPADA_VER
        
        ; POSICAO_OCUPADA_VER_VALIDA
        MOV AX, 1
        JMP POSICAO_OCUPADA_VER_FIM
        
        POSICAO_OCUPADA_VER_INVALIDA:
        MOV AX, 0
        
        POSICAO_OCUPADA_VER_FIM:
        
        POP BX
        POP CX
        
        RET
    ENDP
                           
    VER_POSICAO_OCUPADA_HOR PROC ; BX , posicao matriz + posicao digitada , CX , tamanho do barco - 1
        PUSH CX
        PUSH BX
        
        XOR AX, AX
        
        LOOP_POSICAO_OCUPADA_HOR:
            MOV AL, [BX]
            
            CMP AL, ' '
            JNZ POSICAO_OCUPADA_HOR_INVALIDA
            
            INC BX
        LOOP LOOP_POSICAO_OCUPADA_HOR
        
        
        ; POSICAO_OCUPADA_HOR_VALIDA:
        MOV AX, 1
        JMP POSICAO_OCUPADA_HOR_FIM
        
        POSICAO_OCUPADA_HOR_INVALIDA:
        MOV AX, 0
        
        POSICAO_OCUPADA_HOR_FIM:
        
        POP BX
        POP CX
        
        RET
    ENDP

	
    VER_POS_VALIDA PROC                     ; recebe DL, direcao, CX, tamanho do barco e AX, posicao , BX, matriz + posicao
    										; retorna em AX, 1 valido e 0, invalido
    	PUSH DX
    	PUSH CX	 
    	PUSH BX
    
		MOV BX, OFFSET VET_TAM_BARCOS		; pega o tamanho do barco
		ADD BX, CX
		XOR CX, CX
		MOV CL, [BX]
	
    	XOR DH, DH
    	MOV DH, 10
    	
    	PUSH AX ; salva posicao original
    
    	DIV DH ; AL , linha, AH , coluna
    	
    	MOV BX, AX ; BL , linha, BH, coluna
    	
    	DEC CX
    	
    	CMP DL, CHR_HORIZONTAL
    	JZ VER_POS_HOR
    	; verificar se tem alguma coisa nas posicoes
    	POP AX ; recupera AX original
        POP BX ; recupera BX original para a funcao
		PUSH BX		
        PUSH AX ; joga AX original pra pilha denovo
            
    	CALL VER_POSICAO_OCUPADA_VER ;
    	                             ; retorna AX, 1 , valida, 0 , invalida
    	CMP AX, 0
        JZ POSICAO_INVALIDA
            
    	; verificar se eh uma posicao valida
    	; vertical , soma tamanho - 1 * 10 na posicao
    	; tem que ser menor que 90 + coluna
    	XOR AX, AX
    	MOV AX, CX
    	MUL DH
    	MOV CX, AX
    	POP AX ; recupera posicao original
		PUSH AX
    	ADD AX, CX 
    	MOV BL, BH
    	XOR BH, BH
    	ADD BL, 90
    	CMP AX, BX
    	JLE POSICAO_VALIDA
    	JMP POSICAO_INVALIDA
    	
    	VER_POS_HOR:
    	    ; verificar se tem alguma coisa nas posicoes
            POP AX ; recupera AX original
            POP BX ; recupera BX original para a funcao  
			PUSH BX
            PUSH AX ; joga AX original pra pilha denovo
            
            CALL VER_POSICAO_OCUPADA_HOR ; 
                                         ; retorna AX, 1 , valida , 0 , invalida
            
            CMP AX, 0
            JZ POSICAO_INVALIDA
            
            ; verificar se eh uma posicao valida
			; horizontal , soma tamanho - 1 na posicao 
			; tem que ser menor que linha * 10 + 9
			
			XOR AX, AX
			XOR BH, BH
			MOV AX, BX
			MUL DH
			ADD AX, 9
			MOV BX, AX
			
			POP AX ; recupera posicao original
			ADD AX, CX
			
			CMP AX, BX
			
			JLE POSICAO_VALIDA
			JMP POSICAO_INVALIDA
    	
    	POSICAO_VALIDA:
			MOV AX, 1
			JMP FIM_VER_POSICAO
    	
    	POSICAO_INVALIDA:
			MOV AX, 0    
    	
    	FIM_VER_POSICAO:
    		
			POP BX
			POP CX
			POP DX    
    	
    	RET
    ENDP
	
	COLOCA_BARCO PROC						; coloca um barco na matriz, em CX o tamanho e BX o offset da string para mensagem
		PUSH DX
		PUSH AX
		PUSH BX
	    PUSH CX
	    
		XOR DX, DX
		
	    MOV DX, OFFSET STR_DIGITE_POSICAO	; imprime a mensagem
		CALL PRINTFS
		MOV BX, OFFSET VET_STR_BARCOS
		ADD BX, CX
		MOV DL, [BX]
		CALL PRINTFS
		MOV DL, ':'
		CALL ESC_CHAR
		CALL NOVALINHA
		
		LACO_LER_BARCO:	
		
			CALL GET_POSICAO_INI_BARCO		; o usuario digita a posicao do barco		
			MOV BX, OFFSET MATRIZ_JOGADOR	; pega o offset da matriz
			ADD BX, AX						; e adiciona a posicao digitada
			CALL LER_DIRECAO_BARCO			; le a direcao do barco (somente H ou V)
			
			CALL VER_POS_VALIDA             ; recebe DL, direcao, CX, tamanho barco , AX, posicao , BX , matriz + posicao
											; retorna em AX, 1 valido, 0 invalido
			CMP AX, 1
			JZ  CONT_COLOCA_BARCO
			
			CALL NOVALINHA
			MOV DX, OFFSET STR_DIGITE_NOVAMENTE
			CALL PRINTFS
			CALL NOVALINHA
			JMP LACO_LER_BARCO
		
		CONT_COLOCA_BARCO:
			CMP DL, CHR_HORIZONTAL
			JZ CB_HOR
			CALL COLOCA_BARCO_VERT
			JMP CB_FIM
			CB_HOR:
				CALL COLOCA_BARCO_HOR
			CB_FIM:
				CALL NOVALINHA
		
		POP CX
		POP BX
		POP AX
		POP DX
		RET
	ENDP
	
	ATUALIZA_TELA_INI PROC
		PUSH BX
		PUSH DX
		PUSH AX
		
		CALL CLEAR
		
		MOV DH, CS_LINHA_INI
		MOV DL, 00H
		CALL SET_CURSOR
		CALL PRINT_TABELA_EMBARC		; printa tabela com os dados de cada embarcacao
		CALL NOVALINHA
		
		CALL GET_CURSOR
		MOV AX, DX
		MOV BX, OFFSET MATRIZ_JOGADOR
		CALL NOVALINHA
		CALL PRINT_MATRIZ
		CALL NOVALINHA		
		CALL NOVALINHA		
		
		POP AX
		POP DX
		POP BX
		RET
	ENDP
	
	CLEAR PROC
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		
		MOV AX,0600H    ;06 TO SCROLL & 00 FOR FULLJ SCREEN
		MOV BH,07H    	;ATTRIBUTE BACKGROUND AND FOREGROUND COLOR (0 - BLACK, 7 - GRAY)
		MOV CX,0000H    ;STARTING COORDINATES
		MOV DX, 0FFFFH  ;ENDING COORDINATES
		INT 10H        	;FOR VIDEO DISPLAY
		
		POP DX
		POP CX
		POP BX
		POP AX
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
		PUSH AX
			
		CALL ATUALIZA_TELA_INI
		
		MOV CX, TAM_VET_NAVIOS
		MOV BX, 0				
		TI_LOOP:
			PUSH CX
			MOV CX, BX
			CALL COLOCA_BARCO_ATUALIZA_TELA
			INC BX
			POP CX
			LOOP TI_LOOP
		
		POP AX
		POP CX
		POP BX
		RET
	ENDP
	
	NOVALINHA_CURSOR PROC				;recebe a linha atual em ax
		PUSH DX
		INC AH
		MOV DX, AX
		CALL SET_CURSOR
		POP DX
		RET
	ENDP
	
	PRINT_PLACARES_BASIC_INFO PROC
		PUSH DX
		
		ADD AL, CS_COL_BASIC_INFO
		
		CALL NOVALINHA_CURSOR
		
		MOV DX, OFFSET STR_TIROS
		CALL PRINTFS
		CALL NOVALINHA_CURSOR
		
		MOV DX, OFFSET STR_ACERTOS
		CALL PRINTFS
		CALL NOVALINHA_CURSOR
		
		MOV DX, OFFSET STR_AFUNDADOS
		CALL PRINTFS
		
		SUB AL, CS_COL_BASIC_INFO
		CALL NOVALINHA_CURSOR
		
		POP DX
		RET
	ENDP
	
	PRINT_PLACARES PROC
		PUSH DX
		PUSH AX
		
		MOV AX, DX
		
		CALL SET_CURSOR
		
		; ===========VOCE==============
		MOV DX, OFFSET STR_VOCE
		CALL PRINTFS
		
		CALL PRINT_PLACARES_BASIC_INFO
		
		MOV DX, OFFSET STR_SEPARADOR_PLACAR
		CALL PRINTFS
		CALL NOVALINHA_CURSOR
		
		; =========ADVERSARIO==========
		MOV DX, OFFSET STR_ADVERSARIO
		CALL PRINTFS
		
		CALL PRINT_PLACARES_BASIC_INFO
		
		ADD AL, CS_COL_BASIC_INFO					; TAB
		MOV DX, AX
		CALL SET_CURSOR
		MOV DX, OFFSET STR_ULTIMO_TIRO
		CALL PRINTFS
		SUB AL, CS_COL_BASIC_INFO
		CALL NOVALINHA_CURSOR
		
		MOV DX, OFFSET STR_SEPARADOR_PLACAR
		CALL PRINTFS
		CALL NOVALINHA_CURSOR
		
		; ========PORTA SERIAL=========
		MOV DX, OFFSET STR_PORTA_SERIAL
		CALL PRINTFS
		
		ADD AL, CS_COL_BASIC_INFO				; TAB
		CALL NOVALINHA_CURSOR
		
		MOV DX, OFFSET STR_IN
		CALL PRINTFS
		CALL NOVALINHA_CURSOR
		
		MOV DX, OFFSET STR_OUT
		CALL PRINTFS
		CALL NOVALINHA_CURSOR
		
		CALL NOVALINHA
		
		POP AX
		POP DX
		RET
	ENDP
	
	PRINT_DIVISOR PROC
		INC DL
		
		PUSH DX
		PUSH CX
		
		MOV CX, TAM_DIVISOR
		PD_LOOP:
			CALL SET_CURSOR
			PUSH DX
			MOV DL, PIPE
			CALL ESC_CHAR
			POP DX
			INC DH
			LOOP PD_LOOP
		
		POP CX 
		POP DX
	
		INC DL
	
		RET
	ENDP
	
	TELA_JOGO PROC
		PUSH BX
		PUSH DX
		PUSH AX
		
		CALL GET_CURSOR 					;pega a posicao do cursor 
		
		MOV AH, CS_LINHA_INI				
		MOV AL, 00H							; posicao inicial 0
		MOV BX, OFFSET MATRIZ_JOGADOR
		CALL PRINT_MATRIZ
		
		CALL GET_CURSOR
		
		MOV DH, CS_LINHA_INI					; coloca o cursor pra cima
		CALL PRINT_DIVISOR						; espaco entre matrizes
	
		MOV AX, DX
		MOV BX, OFFSET MATRIZ_TIROS
		CALL PRINT_MATRIZ
		
		CALL GET_CURSOR
		
		MOV DH, CS_LINHA_INI					; coloca o cursor pra cima
		CALL PRINT_DIVISOR	
		
		MOV DH, CS_LINHA_INI					; coloca o cursor pra cima
		INC DL	
		CALL PRINT_PLACARES
		
		POP AX
		POP DX
		POP BX
		RET
	ENDP
	
	INICIO:
		MOV AX, @DATA
		MOV DS, AX
		
		CALL CLEAR
		CALL TELA_INICIAL
		
		CALL CLEAR
		CALL TELA_JOGO
		
		
		MOV AH, 04CH
		INT 21H		
             
end INICIO
