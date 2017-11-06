EOF=065
DATA SEGMENT
    INTXT DB 'IN.TXT',0
    OUTTXT DB 'OUT.TXT',0
    INHANDLE DW 0000H
    OUTHANDLE DW 0000H
    ERROR1 DB 'File not found',07h,0
    ERROR2 DB 'error',07H,0
    BUFFER DB 0
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
START:
    MOV AX,DATA
    MOV DS,AX
    
    CALL INPUTCH
    CMP AL,'S'  ;������ַ���'s'����ʼ���г���
    JZ OPEN
    JMP OVER
    
    ;�������ļ�
OPEN:
    MOV DX,OFFSET INTXT
    MOV AX,3D00H
    INT 21H
    JNC OPENIN_OK   ;�򿪳ɹ�������ת
    MOV SI,OFFSET ERROR1    ;�򿪲��ɹ�����ʾ��Ϣ
    CALL DMESS
    JMP OVER
OPENIN_OK:
    MOV INHANDLE,AX
    ;������ļ�
    MOV DX,OFFSET OUTTXT
    MOV AX,3D01H
    INT 21H
    JNC OPENOUT_OK  ;�򿪳ɹ�������ת
    MOV SI,OFFSET ERROR1    ;�򿪲��ɹ�����ʾ��Ϣ
    CALL DMESS
    JMP OVER
OPENOUT_OK: MOV OUTHANDLE,AX

CONT:CALL READCH    ;���ļ��ж�һ���ַ�
    JC ERR  ;���������ת
    CMP AL,EOF  ;�����ļ���������
    JZ TYPE_OK  ;�ǣ�����ת
    CALL WRITECH    ;����д�������ַ�
    JC ERR  ;���������ת
    JMP CONT    ;�������ַ�
ERR:MOV SI,OFFSET ERROR2
    CALL DMESS  ;���ɹ�����ʾ��Ϣ

TYPE_OK:
    ;�ر������ļ�
    MOV BX,INHANDLE
    MOV AX,3EH  ;�ر��ļ�
    INT 21H
    ;�ر�����ļ�
    MOV BX,INHANDLE
    MOV AH,3EH  ;�ر��ļ�
    INT 21H
OVER:
    MOV AH,4CH
    INT 21H
    
;���ַ��ӳ���
READCH PROC
    MOV BX,INHANDLE
    MOV CX,1
    MOV DX,OFFSET BUFFER
    MOV AH,3FH
    INT 21H
    JC READCH2
    CMP AX,CX
    MOV AL,EOF
    JB READCH1
    MOV AL,BUFFER
READCH1:CLC
READCH2:RET
READCH ENDP

;д�ַ��ӳ���
WRITECH PROC
    MOV BX,OUTHANDLE
    MOV CX,1
    MOV DX,OFFSET BUFFER
    MOV AH,40H
    INT 21H
    JC WRITECH2
    CMP AX,CX
    MOV AL,EOF
    JB WRITECH1
    MOV AL,BUFFER
WRITECH1:CLC
WRITECH2:RET
WRITECH ENDP

DMESS PROC  ;��ӡ�ַ����ӳ���
DMESS1:  
MOV DI,[SI]
    INC SI
    OR DL,DL
    JZ DMESS2
    MOV AH,2
    INT 21H
    JMP DMESS1
DMESS2:RET
DMESS ENDP

;��ӡ�ַ��ӳ���
PUTCH PROC
    PUSH DX
    MOV DL,AL
    MOV AH,2
    INT 21H
    POP DX
    RET
PUTCH ENDP

;���������ַ��ӳ���
INPUTCH PROC
    PUSH DX
    MOV AH,01H
    INT 21H
    POP DX
    RET
INPUTCH ENDP

CODE ENDS
    END START
    
