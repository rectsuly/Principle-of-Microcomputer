DATA SEGMENT
	BUF DB 1025 DUP (0)
	NUM DW 256 DUP (0)
	LANUM DW 256 DUP (0)
	RESULT DB 5 DUP (0)
	ERRORINFO DB 0AH,0DH, 'ERROR!', '$'
	RANGE DW 0
	NUMBER DW 0
DATA ENDS

CODE SEGMENT
	ASSUME CS:CODE, DS:DATA
	START:
	MOV AX, DATA
	MOV DS, AX
	
	MOV SI, 0
	INPUT:                  ;������ֻ�������֡�+��-�����������س�
	MOV AH, 1
	INT 21H
	CMP AL, 0DH             ;��Ϊ�س�����ȡ�����ַ���������ת
	JE CON
	CMP AL, 28H             ;����0DH(�س�)~28H('(')�м������ַ�����ת����
	JB ERROR
	CMP AL, 2AH             ;����2AH('*')����ת����
	JE ERROR
	CMP AL, 2CH             ;����2CH(',')����ת����
	JE ERROR
	CMP AL, 2EH             ;����2EH('.')����ת����
	JE ERROR
	CMP AL, 2FH             ;����2FH('/')����ת����
	JE ERROR
	CMP AL, 39H             ;������39H('9')����ת����
	JA ERROR
	MOV BUF[SI], AL         ;����ȷ���ַ��ŵ�BUF������
	INC SI                  ;�±�SI����
	CMP SI, 1024            ;�����Ÿ����������������1024��û���س���������
	JB INPUT
	
	CON:                    ;��ȡ�������
	MOV RANGE, SI           ;��¼�������ַ���
	MOV SI, 0               ;��ʼ���������±�
	MOV DI, 0               ;��ʼ¼�������±�
	CHCKIN:
	MOV BL, BUF[SI]
	XOR BH, BH              ;�������ָ���BX
	CMP BUF[SI], 30H        ;�ж��Ƿ�Ϊ�����
	JB OPR                ;С��30H,�����������ת
	MOV AX, NUM[DI]         ;�����������ʮ¼��
	MOV CX, 10
	MUL CX
	MOV NUM[DI], AX
	SUB BL, 30H             
	ADD NUM[DI], BX 
	CMP BUF[SI+1], 30H      ;����������һ�����ź�30H�Ƚ�
	JB ADDON                ;С����ת
	JMP FORW                ;������ת
	OPR: ;���������
	MOV NUM[DI], BX         ;���������ֱ��¼��
	
	JMP ADDON
	ADDON:
	ADD DI, 2               ;¼�������±�����
	FORW:
	INC SI                  ;���������±�����
	CMP SI, RANGE           ;��δ��ȡ�����з��ţ���ת�ؼ�����
	JB CHCKIN
	MOV NUMBER, DI          ;���Ѷ������з��ţ���¼�����������и���
	
	MOV SI, DI
	SEARCHL:
	CMP SI, 0
	JE READEND
	SUB SI, 2
	CMP NUM[SI], '('
	JNE SEARCHL             ;�ҵ����ҵ�һ��������
	MOV NUM[SI], '$'
	MOV DI, SI
	FINDRHT:
	ADD DI, 2
	CMP NUM[DI], ')'
	JNE FINDRHT
	MOV NUM[DI], '$'         ;�ҵ������һ�������Ų����
	CMP SI, 0
	JE SEARCHL
	CMP NUM[SI-2], '('
	JE SEARCHL
	CMP NUM[SI-2], '+'
	JE SEARCHL              ;���ı�Ӽ���
	CMP NUM[SI-2], '-'
	JE CHAN
	CHAN:                   ;����ǰΪ���ţ��ı������ڼӼ���
	MOV BX, SI
	REVERSE:
	ADD BX, 2
	CMP NUM[BX], '+'
	JE CHANADD
	CMP NUM[BX], '-'
	JE CHANSUB
	JMP SEERAN
	CHANADD:                ;�ı�Ӻ�
	MOV NUM[BX], '-'
	JMP SEERAN
	CHANSUB:                ;�ı����
	MOV NUM[BX], '+'
	JMP SEERAN
	SEERAN:                 ;��������������������Ƿ�ȫ���ı���
	CMP BX, DI
	JB REVERSE
	JMP SEARCHL
	
	READEND:
	MOV SI, 0
	MOV DI, 0
	SCANIN:                 ;��ʼ��ͷɨ��
	CMP SI, NUMBER
	JE CALCULATE            ;ȫ��ɨ��������������׶�
	CMP NUM[SI], '$'
	JNE SCANF
	ADD SI, 2               ;ɨ�跢��������ţ���������
	JMP SCANIN
	SCANF:                  ;�Ӽ��ţ���NUM�������LANUM����
	MOV BX, NUM[SI]
	MOV LANUM[DI], BX       ;LANUM������ֻ�����ֺͼӼ���
	ADD SI, 2
	ADD DI, 2
	JMP SCANIN
	
	CALCULATE:
	MOV SI, 0
	MOV AX, LANUM[SI]
	CALCU:
	ADD SI, 2
	CMP SI, DI
	JAE PRINT
	CMP LANUM[SI], 2BH      ;���ֺ���Ϊ�Ӻţ�����ӷ�
	JE ADDCAL
	CMP LANUM[SI], 2DH      ;���ֺ���Ϊ�������������
	JE SUBCAL
	ADDCAL:
	ADD AX, LANUM[SI+2]
	ADD SI, 2
	JMP CALCU
	SUBCAL:
	SUB AX, LANUM[SI+2]
	ADD SI, 2
	JMP CALCU  
	
	PRINT:     
	MOV DI,0
	MOV BX,10
	TEST AX,8000H               ;�ж����λ
	JZ P0                       ;����
	PUSH AX                     ;���������'-'
	
	MOV AX,0E0AH                ;CRLF
	INT 10H
	MOV AX,0E0DH
	INT 10H                     
	
	MOV AX,0E2DH                ;'-' ASCII
	INT 10H  
	
	POP AX
	NEG AX
	MOV DI,1
	
	P0:
	MOV DX,0
	XOR CX,CX
	Q0:
	XOR DX,DX
	DIV BX
	XOR DX,0E30H
	PUSH DX
	INC CX
	CMP AX,0
	JNZ Q0
	CMP DI,1
	JE Q1
	
	MOV AX,0E0AH                ;CRLF
	INT 10H
	MOV AX,0E0DH
	INT 10H                     
	
	Q1:
	POP AX
	INT 10H
	LOOP Q1
	JMP ENDF
	
	ERROR:
	MOV DX, OFFSET ERRORINFO
	MOV AH, 9
	INT 21H
	
	ENDF:
	MOV AH, 4CH
	INT 21H
CODE ENDS
END START