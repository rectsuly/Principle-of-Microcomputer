#include <stdio.h>

int error = 1;
double MATHCAL(double a1, double a2, double a3, double x){
	double result = 0;
	short temp;
	__asm {
		FLD x //装载x
		FTST //与0比较
		FSTSW AX //取出状态寄存器
		AND AX, 4500H //除C3、C2、C0外全清零
		CMP AX, 100H //比较是否小于0（C3=0、C2=0、C0=1）
		JE UNDERZERO //小于零则跳到报错 
		FSQRT //把x开平方
		FLD a1 //装载a1
		FMULP ST(1), ST //把a1与根号x相乘 
		FSTP result //把结果置于result

		FLD x 
		FLDL2E //装载log2E
		FMULP ST(1), ST //得到xlog2E
		FST ST(1) //复制结果
		FSTCW temp //取出控制寄存器
		MOV	AX, temp 
		PUSH AX //保存原控制
		OR AX, 0C00H //把舍入控制RC置为11=截为0
		MOV temp, AX 
		FLDCW temp //装载修改后的控制
		FRNDINT //舍入成整数
		POP AX
		MOV temp, AX 
		FLDCW temp //还原控制
		FXCH //将结果交换到栈顶
		FSUB ST, ST(1) //得到小数部分
		F2XM1 //计算2^(小数部分)-1
		FLD1 //加1
		FADD 
		FSCALE //乘上2^(整数部分)
		FLD a2 //装载a2
		FMULP ST(1), ST //得到a2e^x
		FLD result 
		FADD
		FSTP result //得到a1x^0.5+a2e^x
		FCOMP //弹出

		FLD x 
		FSIN //计算x的正弦
		FLD a3 //装载a3
		FMULP ST(1), ST //得到a3sinx 
		FLD result 
		FADD 
		FSTP result //得到a1x^0.5+a2e^x+a3sinx

		JMP OVER
		UNDERZERO :
		MOV error, 0
		OVER :
	}
	return result;
}

int main(void){
	double a1, a2, a3, x, result;

	printf("a1*x^0.5+a2*e^x+a3*sin(x)\n");
	printf("a1=");
	scanf("%lf", &a1);
	printf("a2=");
	scanf("%lf", &a2);
	printf("a3=");
	scanf("%lf", &a3);
	printf("x=");
	scanf("%lf", &x);

	result = MATHCAL(a1, a2, a3, x);
	if (error)
		printf("%lf", result);
	else
		printf("Error:x<0!\n");
}


