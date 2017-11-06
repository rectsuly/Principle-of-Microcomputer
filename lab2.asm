DATA SEGMENT
	FILE DB '2.TXT', 0               ;�ļ���
	BUF DB 0
	ARRAY DW 1024 DUP (0)            ;���ݿռ�
	RANGE DW 22
	ERRORINFO DB 0AH, 'ERROR!', '$'  ;���������Ϣ
	HANDLE DW ?
DATA ENDS

STACK SEGMENT
	DW 64 DUP (?)
STACK ENDS

CODE SEGMENT
	ASSUME CS:CODE, DS:DATA, SS:STACK
	START:
		MOV AX, DATA
		MOV DS, AX
		
		MOV DX, OFFSET FILE
		MOV AX,3D00H
		INT 21H                     ;���ļ�
		
		MOV HANDLE, AX              ;ת���ļ�����
		MOV BX, AX
		MOV SI, 0                   ;�������±�
		READFILE:
		MOV CX, 1
		LEA DX, BUF
		MOV AH, 3FH
		INT 21H                     ;��ȡһ���ֽ�
		CMP BUF, 0DH
		JE READFILE                 ;�����س�ֱ�����¶�
		CMP BUF, 0AH
		JE READNEW                  ;�������з���ʼ����һ����
		MOV AX, ARRAY[SI]
		MOV CX, 10
		MUL CX
		MOV ARRAY[SI], AX           ;������ֵ��10
		MOV CL, BUF
		SUB CL, 30H
		XOR CH, CH                  ;�������ֽ�ת������
		ADD ARRAY[SI], CX           ;���뵽����ֵ
		JMP READFILE                ;��������һ�ֽ�
		READNEW:
		ADD SI, 2                   ;���±��һ
		CMP SI, RANGE
		JB READFILE                 ;��û�����������
		
		MOV DI, 0
		BUBBLE:
		MOV SI, 0
		MOV AX, RANGE
		SUB AX, DI
		SUB AX, 2
		SORT:
		MOV BX, SI
		ADD BX, 2
		MOV CX, ARRAY[BX]
		CMP ARRAY[SI], CX
		JB RECY                     ;����������ǰ��С�ں��ߣ���ת
		MOV DX, ARRAY[SI]           ;���򣬽�������λ��
		MOV CX, ARRAY[BX]
		MOV ARRAY[SI], CX
		MOV ARRAY[BX], DX

		RECY:
		ADD SI, 2
		CMP SI, AX
		JB SORT
		ADD DI, 2
		CMP DI, RANGE
		JB BUBBLE
		
		MOV SI, 0                   ;��ʼȡ���������±�
		OUTPUT:
		MOV DI, 0                   ;��λ
		MOV BX, 100                 ;��ʼȡλֵ
		PRINT:
		MOV AX, ARRAY[SI]
		XOR DX, DX                  ;�������ݵ�DX-AX
		CMP DI, 0                   ;����һ��ȡλ
		JE LIMP
		MOV AX, CX                  ;���ǵ�һ��ȡλ�������Ϊ֮ǰȡλ�õ�������
		LIMP:
		PUSH AX 
		PUSH DX                     ;������ջ
		CMP DI, 0
		JE GETSIN
		MOV AX, BX
		XOR DX, DX                  ;��ȡλֵ���뵽DX-AX
		MOV CX, 10
		DIV CX 
		MOV BX, AX                  ;ÿ��ȡλ��10
		GETSIN:
		POP DX
		POP AX                      ;��������ջ
		DIV BX                      ;ȡλ��λ���̷���AX����������DX
		MOV CX, DX                  ;�Ĵ�����
		ADD AL, 30H	
		MOV DL, AL
		CMP DL,30H
		JE NUL
		
		CONT:
		MOV AH, 2
		INT 21H                     ;��ӡÿһλ
		ADD DI, 1                   ;��ӡһ�μ�λ��һ
		CMP DI, 2                   ;ȡ�����һλ
		JE PRGE
		JMP PRINT
		PRGE:
		ADD CL, 30H	
		MOV DL, CL
		MOV AH, 2
		INT 21H                     ;��ӡ��λ
		ADD SI, 2                   ;һ������ӡ���ת����һ��
		MOV DL, 0AH
		MOV AH, 2
		INT 21H                     ;����
		MOV DL, 0DH
		MOV AH,2
		INT 21H                     ;�س�
		CMP SI, RANGE
		JE CLOSE                    ;���Ѷ������˳�
		JMP OUTPUT
		
		CLOSE:
		MOV BX, HANDLE
		MOV AH, 3EH
		INT 21H                     ;�ر��ļ�
		JNC ENDF
		
		ERROR:
		MOV DX, OFFSET ERRORINFO
		MOV AH, 9
		INT 21H
		
		ENDF:
		MOV AH, 4CH
		INT 21H  
		
		NUL:
		ADD DI, 1
		CMP DI, 2
		JE PRGE
		JMP PRINT
		
CODE ENDS
END START
