DATA SEGMENT
	BUB DB 20 DUP (0)            ;��СΪ20�����飬��ų����ͽ��
	RANGE DB 0                   ;�׳���
	PLUS DW 0                    ;��Ž�λ
DATA ENDS

CODE SEGMENT
	ASSUME CS:CODE, DS:DATA
	
	START:
	MOV AX, DATA
	MOV DS, AX
	
	MOV AH, 1                    ;��ȡ�ַ�
	INT 21H
	SUB AL, 30H                  ;ת��ASCIIΪ����
	MOV BL, AL
	MOV RANGE, BL                ;�����ַ���RANGE��
	MOV AH, 1                    ;�������ַ�
	INT 21H
	CMP AL, 30H                  ;�ڶ��������ַ���0��ASCII��Ƚ�
	JB RMUL                      ;��Ϊ���������ַ�����ת
	SUB AL, 30H                  ;����ת��������
	MOV DL, AL
	MOV AL, BL                   
	MOV CL, 10
	MUL CL                       ;��һ�����ֳ�10��ת����ʮλ
	MOV RANGE, AL
	ADD RANGE, DL                ;ʮλ���͸�λ����ӣ��õ���λ�׳���
	MOV AH, 1                    ;��ȡ���һ�������ַ�����������
	INT 21H
	
	RMUL:                        ;�׳˱�����
	MOV BUB[0], 1                ;�����һ����Ϊ1
	MOV CL, 1                    ;CLΪ1
	MULTI:
	MOV SI, 0                    ;SIΪ0
	CER:
	MOV AL, BUB[SI]
	MUL CL                       ;��ʼʱAL=1*1
	ADD AX, PLUS                 ;������һλ�˽׵Ľ�λ
	CMP AL, 10                   
	JAE GETP                     ;AL���ڵ���10����ת
	MOV BUB[SI], AL
	MOV PLUS, 0
	JMP NOSFT
	GETP:                        ;��AL����10�������10�������Ż�ԭ���飬����Ϊ��λ���PLUS��
	MOV BL, 10
	DIV BL
	MOV BUB[SI], AH
	XOR AH, AH
	MOV PLUS, AX
	NOSFT:                       ;AL������10����ת���
	ADD SI, 1                    ;SI=SI+1
	CMP SI, 20
	JB CER                       ;SIС��20������CER���
	ADD CL, 1                    ;CL=CL+1
	CMP CL, RANGE                ;��CL�����ڽ׳����������ִ��
	JBE MULTI
	
	MOV BL, 0
	MOV SI, 20
	PRINT:                       ;������
	CMP BUB[SI-1], 0
	JNE PRINTB                   ;����λ����0�����������
	CMP BL, 0                    ;����λ��0��������һλ
	JE NEXT
	PRINTB:
	MOV BL, 1
	MOV DL, BUB[SI-1]
	ADD DL, 30H                  ;ת����ASCII�������λ
	MOV AH, 2
	INT 21H
	NEXT:                        ;������һλ
	SUB SI, 1
	CMP SI, 1
	JAE PRINT
	
	MOV AH, 4CH                  ;��������
	INT 21H 
CODE ENDS
END START