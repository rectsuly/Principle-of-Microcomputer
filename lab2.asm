DATA SEGMENT
	FILE DB '2.TXT', 0               ;文件名
	BUF DB 0
	ARRAY DW 1024 DUP (0)            ;数据空间
	RANGE DW 22
	ERRORINFO DB 0AH, 'ERROR!', '$'  ;定义错误信息
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
		INT 21H                     ;打开文件
		
		MOV HANDLE, AX              ;转存文件代号
		MOV BX, AX
		MOV SI, 0                   ;读入数下标
		READFILE:
		MOV CX, 1
		LEA DX, BUF
		MOV AH, 3FH
		INT 21H                     ;读取一个字节
		CMP BUF, 0DH
		JE READFILE                 ;读到回车直接往下读
		CMP BUF, 0AH
		JE READNEW                  ;读到换行符开始读下一个数
		MOV AX, ARRAY[SI]
		MOV CX, 10
		MUL CX
		MOV ARRAY[SI], AX           ;数基本值乘10
		MOV CL, BUF
		SUB CL, 30H
		XOR CH, CH                  ;将读入字节转成数字
		ADD ARRAY[SI], CX           ;加入到基本值
		JMP READFILE                ;继续读下一字节
		READNEW:
		ADD SI, 2                   ;数下标加一
		CMP SI, RANGE
		JB READFILE                 ;若没读完则继续读
		
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
		JB RECY                     ;若相邻两数前者小于后者，跳转
		MOV DX, ARRAY[SI]           ;否则，交换两数位置
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
		
		MOV SI, 0                   ;初始取数的数组下标
		OUTPUT:
		MOV DI, 0                   ;记位
		MOV BX, 100                 ;初始取位值
		PRINT:
		MOV AX, ARRAY[SI]
		XOR DX, DX                  ;读入数据到DX-AX
		CMP DI, 0                   ;若第一次取位
		JE LIMP
		MOV AX, CX                  ;若非第一次取位则把数记为之前取位得到的余数
		LIMP:
		PUSH AX 
		PUSH DX                     ;把数入栈
		CMP DI, 0
		JE GETSIN
		MOV AX, BX
		XOR DX, DX                  ;把取位值读入到DX-AX
		MOV CX, 10
		DIV CX 
		MOV BX, AX                  ;每次取位除10
		GETSIN:
		POP DX
		POP AX                      ;把数读出栈
		DIV BX                      ;取位的位即商放在AX，余数放在DX
		MOV CX, DX                  ;寄存余数
		ADD AL, 30H	
		MOV DL, AL
		CMP DL,30H
		JE NUL
		
		CONT:
		MOV AH, 2
		INT 21H                     ;打印每一位
		ADD DI, 1                   ;打印一次记位加一
		CMP DI, 2                   ;取到最后一位
		JE PRGE
		JMP PRINT
		PRGE:
		ADD CL, 30H	
		MOV DL, CL
		MOV AH, 2
		INT 21H                     ;打印个位
		ADD SI, 2                   ;一个数打印完成转到下一个
		MOV DL, 0AH
		MOV AH, 2
		INT 21H                     ;换行
		MOV DL, 0DH
		MOV AH,2
		INT 21H                     ;回车
		CMP SI, RANGE
		JE CLOSE                    ;若已读完则退出
		JMP OUTPUT
		
		CLOSE:
		MOV BX, HANDLE
		MOV AH, 3EH
		INT 21H                     ;关闭文件
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
