;ʵ��һ����1~36����Ȼ������˳�����һ��6*6�Ķ�ά�����У�
;Ȼ���ӡ������������°����ǡ�

DATA SEGMENT	
	ARRAY DB 36 DUP (0)     ;��ʼ��������
DATA ENDS

STACK SEGMENT STACK
	DB 64 DUP (0)           ;����ջ�ռ�
STACK ENDS

CODE SEGMENT
	ASSUME DS:DATA, CS:CODE, SS:STACK

	START:
	MOV AX, DATA            ;��������
	MOV DS, AX

	MOV DI, 0
	MOV AL, 1
	MOV CX, 36              ;CXѭ��������Ϊ36
	GNUM:                   ;ͨ��ѭ����������1~36
	MOV ARRAY[DI], AL
	ADD AL, 1
	ADD DI, 1
	LOOP GNUM 

	MOV DI, 0
	MOV BL, 0

	L1:
	MOV CL, 0
	PUSH DI

	L2:
	MOV AL, ARRAY[DI]       ;�����������ִ���AL��
	XOR AH, AH              ;AH����

	PUSH AX                 ;AX��ջ����
	PUSH BX                 ;BX��ջ����

	MOV BL, 10              ;BLΪ10
	DIV BL                  ;AX���ݳ���BL���ݣ�AL�д�ŵõ����޷��ŵ��̣�������AH��
	MOV BH, AH              ;���������BH,����λ��
	
	CMP AL, 0               ;������̺�0�Ƚ�
	JA LL                   ;�̴���0����ת����AX������Ϊ��λ��
	SUB AL, 10H             ;��Ϊ0����AX������Ϊһλ�����ȼ�ȥ10H���Ϊ-10H
	LL:                     ;����10�����ʮλ
	ADD AL, 30H	            ;ʮλ��ת����ASCII��
	MOV DL, AL              ;AL�е�ʮλ
	MOV AH, 2
	INT 21H                 ;������10�����ʮλ��С��10������ո�
			
	MOV AL, BH              ;��λ������AL��
	ADD AL, 30H			    ;��λ��ת����ASCII��
	MOV DL, AL
	MOV AH, 2
	INT 21H                 ;�����λ
			
	MOV DL, 20H
	MOV AH, 2
	INT 21H                 ;�������ո�
			
	POP BX                  ;����BX
	POP AX                  ;����AX,����������

	ADD CL, 1               ;CL��¼��������1
	ADD DI, 1

	CMP CL, BL
	JBE L2                  ;�������������������Խ��߼��������������

	POP DI

	MOV DL, 10
	MOV AH, 2
	INT 21H                 ;����  
	
	MOV DL, 13
	MOV AH, 2
	INT 21H                 ;�س�

	ADD BL, 1               ;��������
	ADD DI, 6
	CMP DI, 30
	JBE L1                  ;��δ���������������

	MOV AH, 4CH             ;���޴����򷵻�
	INT 21H                 ;����DOS

CODE ENDS  
END START