;实验一：把1~36的自然数按行顺序存入一个6*6的二维数组中，
;然后打印出该数组的左下半三角。

DATA SEGMENT	
	ARRAY DB 36 DUP (0)     ;初始化数据组
DATA ENDS

STACK SEGMENT STACK
	DB 64 DUP (0)           ;定义栈空间
STACK ENDS

CODE SEGMENT
	ASSUME DS:DATA, CS:CODE, SS:STACK

	START:
	MOV AX, DATA            ;传输数据
	MOV DS, AX

	MOV DI, 0
	MOV AL, 1
	MOV CX, 36              ;CX循环变量设为36
	GNUM:                   ;通过循环填入数据1~36
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
	MOV AL, ARRAY[DI]       ;将数组中数字存入AL中
	XOR AH, AH              ;AH清零

	PUSH AX                 ;AX进栈保护
	PUSH BX                 ;BX进栈保护

	MOV BL, 10              ;BL为10
	DIV BL                  ;AX内容除以BL内容，AL中存放得到的无符号的商，余数在AH中
	MOV BH, AH              ;余数存放至BH,即个位数
	
	CMP AL, 0               ;相除的商和0比较
	JA LL                   ;商大于0则跳转，即AX中数字为两位数
	SUB AL, 10H             ;商为0，即AX中数字为一位数，先减去10H结果为-10H
	LL:                     ;大于10，输出十位
	ADD AL, 30H	            ;十位数转换成ASCII码
	MOV DL, AL              ;AL中的十位
	MOV AH, 2
	INT 21H                 ;若大于10则输出十位，小于10则输出空格
			
	MOV AL, BH              ;个位数移入AL中
	ADD AL, 30H			    ;个位数转换成ASCII码
	MOV DL, AL
	MOV AH, 2
	INT 21H                 ;输出个位
			
	MOV DL, 20H
	MOV AH, 2
	INT 21H                 ;输出数间空格
			
	POP BX                  ;弹出BX
	POP AX                  ;弹出AX,即数组数据

	ADD CL, 1               ;CL记录列数，加1
	ADD DI, 1

	CMP CL, BL
	JBE L2                  ;若列数不大于行数（对角线及以左）则继续处理

	POP DI

	MOV DL, 10
	MOV AH, 2
	INT 21H                 ;换行  
	
	MOV DL, 13
	MOV AH, 2
	INT 21H                 ;回车

	ADD BL, 1               ;增加行数
	ADD DI, 6
	CMP DI, 30
	JBE L1                  ;若未满六行则继续处理

	MOV AH, 4CH             ;若无错误则返回
	INT 21H                 ;返回DOS

CODE ENDS  
END START