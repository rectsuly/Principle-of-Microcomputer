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
	INPUT:                  ;输入中只能有数字、+、-、（、）、回车
	MOV AH, 1
	INT 21H
	CMP AL, 0DH             ;若为回车，读取所有字符结束，跳转
	JE CON
	CMP AL, 28H             ;若是0DH(回车)~28H('(')中间任意字符，跳转错误
	JB ERROR
	CMP AL, 2AH             ;若是2AH('*')，跳转错误
	JE ERROR
	CMP AL, 2CH             ;若是2CH(',')，跳转错误
	JE ERROR
	CMP AL, 2EH             ;若是2EH('.')，跳转错误
	JE ERROR
	CMP AL, 2FH             ;若是2FH('/')，跳转错误
	JE ERROR
	CMP AL, 39H             ;若大于39H('9')，跳转错误
	JA ERROR
	MOV BUF[SI], AL         ;将正确的字符放到BUF数组中
	INC SI                  ;下标SI自增
	CMP SI, 1024            ;若符号个数不超过最大限制1024且没按回车，继续读
	JB INPUT
	
	CON:                    ;读取结束标号
	MOV RANGE, SI           ;记录总输入字符数
	MOV SI, 0               ;初始输入数组下标
	MOV DI, 0               ;初始录入数组下标
	CHCKIN:
	MOV BL, BUF[SI]
	XOR BH, BH              ;将输入字赋给BX
	CMP BUF[SI], 30H        ;判断是否为运算符
	JB OPR                ;小于30H,是运算符，跳转
	MOV AX, NUM[DI]         ;不是运算符乘十录入
	MOV CX, 10
	MUL CX
	MOV NUM[DI], AX
	SUB BL, 30H             
	ADD NUM[DI], BX 
	CMP BUF[SI+1], 30H      ;输入数组下一个符号和30H比较
	JB ADDON                ;小于跳转
	JMP FORW                ;否则跳转
	OPR: ;运算符处理
	MOV NUM[DI], BX         ;是运算符则直接录入
	
	JMP ADDON
	ADDON:
	ADD DI, 2               ;录入数组下标自增
	FORW:
	INC SI                  ;输入数组下标自增
	CMP SI, RANGE           ;若未读取完所有符号，跳转回继续读
	JB CHCKIN
	MOV NUMBER, DI          ;若已读完所有符号，记录输入数组所有个数
	
	MOV SI, DI
	SEARCHL:
	CMP SI, 0
	JE READEND
	SUB SI, 2
	CMP NUM[SI], '('
	JNE SEARCHL             ;找到最右的一个左括号
	MOV NUM[SI], '$'
	MOV DI, SI
	FINDRHT:
	ADD DI, 2
	CMP NUM[DI], ')'
	JNE FINDRHT
	MOV NUM[DI], '$'         ;找到最近的一个右括号并标记
	CMP SI, 0
	JE SEARCHL
	CMP NUM[SI-2], '('
	JE SEARCHL
	CMP NUM[SI-2], '+'
	JE SEARCHL              ;不改变加减号
	CMP NUM[SI-2], '-'
	JE CHAN
	CHAN:                   ;括号前为减号，改变括号内加减号
	MOV BX, SI
	REVERSE:
	ADD BX, 2
	CMP NUM[BX], '+'
	JE CHANADD
	CMP NUM[BX], '-'
	JE CHANSUB
	JMP SEERAN
	CHANADD:                ;改变加号
	MOV NUM[BX], '-'
	JMP SEERAN
	CHANSUB:                ;改变减号
	MOV NUM[BX], '+'
	JMP SEERAN
	SEERAN:                 ;检验括号内所有运算符是否全部改变完
	CMP BX, DI
	JB REVERSE
	JMP SEARCHL
	
	READEND:
	MOV SI, 0
	MOV DI, 0
	SCANIN:                 ;开始从头扫描
	CMP SI, NUMBER
	JE CALCULATE            ;全部扫描结束，进入计算阶段
	CMP NUM[SI], '$'
	JNE SCANF
	ADD SI, 2               ;扫描发现配对括号，跳过括号
	JMP SCANIN
	SCANF:                  ;加减号，将NUM数组放入LANUM数组
	MOV BX, NUM[SI]
	MOV LANUM[DI], BX       ;LANUM数组中只含数字和加减号
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
	CMP LANUM[SI], 2BH      ;数字后面为加号，进入加法
	JE ADDCAL
	CMP LANUM[SI], 2DH      ;数字后面为减法，进入减法
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
	TEST AX,8000H               ;判断最高位
	JZ P0                       ;正数
	PUSH AX                     ;负数，输出'-'
	
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