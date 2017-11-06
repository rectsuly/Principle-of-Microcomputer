DATA SEGMENT
	BUB DB 20 DUP (0)            ;大小为20的数组，存放长整型结果
	RANGE DB 0                   ;阶乘数
	PLUS DW 0                    ;存放进位
DATA ENDS

CODE SEGMENT
	ASSUME CS:CODE, DS:DATA
	
	START:
	MOV AX, DATA
	MOV DS, AX
	
	MOV AH, 1                    ;读取字符
	INT 21H
	SUB AL, 30H                  ;转换ASCII为数字
	MOV BL, AL
	MOV RANGE, BL                ;将数字放入RANGE中
	MOV AH, 1                    ;继续读字符
	INT 21H
	CMP AL, 30H                  ;第二次输入字符和0的ASCII码比较
	JB RMUL                      ;若为其他控制字符，跳转
	SUB AL, 30H                  ;否则，转换成数字
	MOV DL, AL
	MOV AL, BL                   
	MOV CL, 10
	MUL CL                       ;第一个数字乘10，转换成十位
	MOV RANGE, AL
	ADD RANGE, DL                ;十位数和个位数相加，得到两位阶乘数
	MOV AH, 1                    ;读取最后一个控制字符，不作处理
	INT 21H
	
	RMUL:                        ;阶乘标号入口
	MOV BUB[0], 1                ;数组第一个数为1
	MOV CL, 1                    ;CL为1
	MULTI:
	MOV SI, 0                    ;SI为0
	CER:
	MOV AL, BUB[SI]
	MUL CL                       ;初始时AL=1*1
	ADD AX, PLUS                 ;加上上一位乘阶的进位
	CMP AL, 10                   
	JAE GETP                     ;AL大于等于10则跳转
	MOV BUB[SI], AL
	MOV PLUS, 0
	JMP NOSFT
	GETP:                        ;若AL大于10，则除以10，余数放回原数组，商作为进位存进PLUS中
	MOV BL, 10
	DIV BL
	MOV BUB[SI], AH
	XOR AH, AH
	MOV PLUS, AX
	NOSFT:                       ;AL不大于10的跳转入口
	ADD SI, 1                    ;SI=SI+1
	CMP SI, 20
	JB CER                       ;SI小于20则跳回CER标号
	ADD CL, 1                    ;CL=CL+1
	CMP CL, RANGE                ;若CL不大于阶乘数，则继续执行
	JBE MULTI
	
	MOV BL, 0
	MOV SI, 20
	PRINT:                       ;输出结果
	CMP BUB[SI-1], 0
	JNE PRINTB                   ;若该位不是0，输出该数字
	CMP BL, 0                    ;若该位是0，处理下一位
	JE NEXT
	PRINTB:
	MOV BL, 1
	MOV DL, BUB[SI-1]
	ADD DL, 30H                  ;转换成ASCII码输出该位
	MOV AH, 2
	INT 21H
	NEXT:                        ;处理下一位
	SUB SI, 1
	CMP SI, 1
	JAE PRINT
	
	MOV AH, 4CH                  ;结束返回
	INT 21H 
CODE ENDS
END START