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
	TAM_DIVISOR EQU 12
	
	DIST_MATRIZ_COR EQU 100
	
	PIPE EQU 124
	QUADRADO EQU 254
	
	ACERTOU EQU 1
	ERROU EQU 0
	
	COR_VERDE EQU 0F2H
	COR_PRETO EQU 0F0H
	COR_VERMELHO EQU 0FCH
	COR_CINZA EQU 0F0H
	
	VET_STR_BARCOS DB OFFSET STR_PORTAAVIOES, OFFSET STR_NAVIOGUERRA, OFFSET STR_SUBMARINO, OFFSET STR_DESTROYER, OFFSET STR_PATRULHA
	VET_SIMB_BARCOS DB SIMB_PORTAAVIOES, SIMB_NAVIOGUERRA, SIMB_SUBMARINO, SIMB_DESTROYER, SIMB_PATRULHA
	VET_TAM_BARCOS DB TAM_PORTAAVIOES, TAM_NAVIOGUERRA, TAM_SUBMARINO, TAM_DESTROYER, TAM_PATRULHA
	VET_TAM_BARCOS_AFUNDADOS DB TAM_PORTAAVIOES, TAM_NAVIOGUERRA, TAM_SUBMARINO, TAM_DESTROYER, TAM_PATRULHA
	
	MATRIZ_JOGADOR DB 100 DUP (' ')
	MATRIZ_JOGADOR_COR DB 100 DUP (COR_PRETO) ; 02H = verde
	MATRIZ_TIROS DB 100 DUP (QUADRADO) ; quadrado
	MATRIZ_TIROS_COR DB 100 DUP (COR_VERDE) ; 02H = verde
	
	ULT_TIRO DB ESPACO, ESPACO
	QTDE_AFUND DB 0
	QTDE_TIROS DB 0
	QTDE_ACERTO DB 0
	
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
			MOV [BX], DL
			ADD BX, DIST_MATRIZ_COR		; coloca a cor do caractere
			MOV BYTE PTR [BX], COR_CINZA			
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
			MOV BYTE PTR [BX], COR_CINZA			; 07H = cinza
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
                           
    VER_POSICAO_OCUPADA_VER PROC ; BX , posicao matriz + posicao digitada , CX , tamanho do barco
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
                           
    VER_POSICAO_OCUPADA_HOR PROC ; BX , posicao matriz + posicao digitada , CX , tamanho do barco
        PUSH CX
        PUSH BX
        
        XOR AX, AX

        LOOP_POSICAO_OCUPADA_HOR:
            MOV AL, [BX]
            
            CMP AL, ' '
            JNZ POSICAO_OCUPADA_HOR_INVALIDA
            
            INC BX
        LOOPNZ LOOP_POSICAO_OCUPADA_HOR
        
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
    
    	CMP DL, CHR_HORIZONTAL
    	JZ VER_POS_HOR
		;VER_POS_VER:
			; verificar se tem alguma coisa nas posicoes
			POP AX ; recupera AX original
			POP BX ; recupera BX original para a funcao
			PUSH BX		
			PUSH AX ; joga AX original pra pilha denovo
				
			CALL VER_POSICAO_OCUPADA_VER ;
										 ; retorna AX, 1 , valida, 0 , invalida

			CMP AX, 0
			JZ POSICAO_INVALIDA_OCUPADA
				
			; verificar se eh uma posicao valida
			; vertical , soma tamanho - 1 * 10 na posicao
			; tem que ser menor que 90 + coluna
			DEC CX
			XOR AX, AX
			MOV AX, CX
			MUL DH
			MOV CX, AX
			POP AX ; recupera posicao original
			PUSH AX
			DIV DH ; AL , linha, AH , coluna
			MOV BX, AX ; BL , linha, BH, coluna
			POP AX
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
            JZ POSICAO_INVALIDA_OCUPADA
            
            ; verificar se eh uma posicao valida
			; horizontal , soma tamanho - 1 na posicao 
			; tem que ser menor que linha * 10 + 9
			DEC CX
			POP AX
			PUSH AX
			DIV DH ; AL , linha, AH , coluna
			MOV BX, AX ; BL , linha, BH, coluna
			
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
    	
		POSICAO_INVALIDA_OCUPADA:
			POP AX
		
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
		
		MOV AX, 0600H    
		MOV BH, COR_CINZA
		MOV CX, 0000H   ;inicio
		MOV DX, 0FFFFH  ;fim
		INT 10H        	
		
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
		PUSH BX
		PUSH CX
		
		
		ADD AL, CS_COL_BASIC_INFO
		
		CALL NOVALINHA_CURSOR
		
		MOV DX, OFFSET STR_TIROS
		CALL PRINTFS
		
		MOV CX, AX ; salva ax
		XOR AX, AX
		MOV BX, OFFSET QTDE_TIROS
		MOV AL, [BX]
		CALL ESC_UINT16

		MOV AX, CX
		
		CALL NOVALINHA_CURSOR
		
		MOV DX, OFFSET STR_ACERTOS
		CALL PRINTFS
		
		MOV CX, AX ; salva ax
		XOR AX, AX
		MOV BX, OFFSET QTDE_ACERTO
		MOV AL, [BX]
		CALL ESC_UINT16
		MOV AX, CX
		
		CALL NOVALINHA_CURSOR
		
		MOV DX, OFFSET STR_AFUNDADOS
		CALL PRINTFS
		
		MOV CX, AX ; salva ax
		XOR AX, AX
		MOV BX, OFFSET QTDE_AFUND
		MOV AL, [BX]
		CALL ESC_UINT16
		MOV AX, CX
		
		SUB AL, CS_COL_BASIC_INFO
		CALL NOVALINHA_CURSOR
		
		POP CX
		POP BX
		POP DX
		RET
	ENDP
	
	PRINT_ULT_TIRO PROC
		PUSH BX
		PUSH DX
		
		MOV BX, OFFSET ULT_TIRO
		MOV DL, [BX]
		CALL ESC_CHAR
		INC BX
		MOV DL, [BX]
		CALL ESC_CHAR
				
		POP DX
		POP BX
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
		CALL PRINT_ULT_TIRO
		
		SUB AL, CS_COL_BASIC_INFO
		CALL NOVALINHA_CURSOR
		
		MOV DX, OFFSET STR_SEPARADOR_PLACAR
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
	
	VERIFICA_AFUNDADO PROC 			; Recebe a posicao em BX,
		PUSH CX
		PUSH AX
		PUSH BX
		
		XOR AX, AX
		
		MOV AL, [BX]						;move para AX valor do navio acertado
		MOV BX, OFFSET VET_SIMB_BARCOS		; move de simbolos
		MOV CX, TAM_VET_NAVIOS				; move para ultima posicao do vetor
		VA_LOOP:
			CMP BYTE PTR [BX], AL			; compara simbolo com a posicao acertada
			JZ VA_FIM_LOOP
			INC BX
			LOOP VA_LOOP
			
		VA_FIM_LOOP:
			SUB BX, OFFSET VET_SIMB_BARCOS		
			ADD BX, OFFSET VET_TAM_BARCOS_AFUNDADOS	; pega o vetor dos afundados e diminui um tiro
			DEC BYTE PTR [BX]
			CMP BYTE PTR [BX], 0
			JZ VA_SOMAR_AFUNDADO
			JMP VA_FIM
		
		VA_SOMAR_AFUNDADO:
			MOV BX, OFFSET QTDE_AFUND
			INC BYTE PTR [BX]
			
		VA_FIM:
		POP BX
		POP AX
		POP CX
		RET
	ENDP
	
	ATIRA_MATRIZ_NAVIOS PROC				; recebe posicao em AX, retorna em DX se acertou
		PUSH BX
		
		MOV DX, ERROU
		
		MOV BX, OFFSET MATRIZ_JOGADOR_COR	; pega o offset da matriz
		ADD BX, AX							; e adiciona a posicao digitada
		
		CMP BYTE PTR [BX], COR_VERMELHO		; verifica se ja foi dado o tiro
		JZ AMN_FIM
		
		MOV BYTE PTR [BX], COR_VERMELHO		; pinta de vermelho caracter na tela
		
		SUB BX, DIST_MATRIZ_COR
		
		CMP BYTE PTR [BX], ' '				;verifica se tem um barco
		JNZ AMN_ACERTOU
		
		MOV BYTE PTR [BX], QUADRADO			; coloca um quadrado se nao houver barco
		JMP AMN_FIM
		
		AMN_ACERTOU:
			MOV DX, ACERTOU
			CALL VERIFICA_AFUNDADO
		
		AMN_FIM:
			POP BX
		RET
	ENDP
	
	ATIRA_MATRIZ_TIRO PROC					; recebe posicao em AX, se acertou ou errou em DX
		PUSH BX
		
		MOV BX, OFFSET MATRIZ_TIROS			; pega o offset da matriz
		ADD BX, AX							; e adiciona a posicao digitada
		
		CMP BYTE PTR [BX], QUADRADO			; verifica se ja foi dado o tiro
		JNZ AMT_FIM
		
		CMP DX, ACERTOU
		JZ AMT_ACERTOU
		
		MOV BYTE PTR [BX], 'x'
		ADD BX, DIST_MATRIZ_COR
		MOV BYTE PTR [BX], COR_VERMELHO
		SUB BX, DIST_MATRIZ_COR
		JMP AMT_FIM
		
		AMT_ACERTOU:
			MOV BYTE PTR [BX], 'o'
			MOV BX, OFFSET QTDE_ACERTO
			INC BYTE PTR [BX]
		
		AMT_FIM:
			POP BX
		RET
	ENDP
	
	GET_POSICAO_TIRO PROC	;retorna em AX a posicao na matriz que o barco será inserido
		PUSH DX
		PUSH BX
		PUSH CX
		
		XOR AX, AX
		XOR DX, DX
		MOV BX, OFFSET ULT_TIRO
		
		CALL LER_DIGITO			; le a linha
		MOV CL, AL
		
		MOV BYTE PTR [BX], AL	; grava ultimo tiro
		ADD BYTE PTR [BX], '0'
		INC BX
		
		CALL LER_DIGITO			; le a coluna
		MOV DL, AL
		MOV BYTE PTR [BX], AL	; grava ultimo tiro
		ADD BYTE PTR [BX], '0'
		
		MOV AL, TAM_MATRIZ
		MUL CL					; resultado = (tamanho da linha da matriz * nro da linha) + nro da coluna
		ADD AX, DX				; AL = (TAM_MATRIZ * CL) + DL
		
		POP CX
		POP BX
		POP DX
		RET
	ENDP
	
	ATIRAR PROC
		PUSH AX
		PUSH DX
		PUSH BX
		
		CALL GET_POSICAO_TIRO		
		CALL ATIRA_MATRIZ_NAVIOS 
		CALL ATIRA_MATRIZ_TIRO 
		MOV BX, OFFSET QTDE_TIROS
		INC BYTE PTR [BX]
		
		POP BX
		POP DX
		POP AX
		RET
	ENDP
	
	TELA_JOGO PROC
		PUSH BX
		PUSH DX
		PUSH AX
		
		TJ_LACO:
		
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
			
			CALL NOVALINHA
			CALL NOVALINHA
			
			MOV DX, OFFSET STR_POSICAO
			CALL PRINTFS
			
			CALL ATIRAR
			CALL CLEAR
			
			MOV BX, OFFSET QTDE_AFUND
			CMP BYTE PTR [BX], 2
			JNZ TJ_LACO
		
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
		
		FIM_INI:
			MOV AH, 04CH
			INT 21H		
             
end INICIO
