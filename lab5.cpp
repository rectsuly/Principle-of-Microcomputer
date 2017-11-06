#include <stdio.h>

int error = 1;
double MATHCAL(double a1, double a2, double a3, double x){
	double result = 0;
	short temp;
	__asm {
		FLD x //װ��x
		FTST //��0�Ƚ�
		FSTSW AX //ȡ��״̬�Ĵ���
		AND AX, 4500H //��C3��C2��C0��ȫ����
		CMP AX, 100H //�Ƚ��Ƿ�С��0��C3=0��C2=0��C0=1��
		JE UNDERZERO //С�������������� 
		FSQRT //��x��ƽ��
		FLD a1 //װ��a1
		FMULP ST(1), ST //��a1�����x��� 
		FSTP result //�ѽ������result

		FLD x 
		FLDL2E //װ��log2E
		FMULP ST(1), ST //�õ�xlog2E
		FST ST(1) //���ƽ��
		FSTCW temp //ȡ�����ƼĴ���
		MOV	AX, temp 
		PUSH AX //����ԭ����
		OR AX, 0C00H //���������RC��Ϊ11=��Ϊ0
		MOV temp, AX 
		FLDCW temp //װ���޸ĺ�Ŀ���
		FRNDINT //���������
		POP AX
		MOV temp, AX 
		FLDCW temp //��ԭ����
		FXCH //�����������ջ��
		FSUB ST, ST(1) //�õ�С������
		F2XM1 //����2^(С������)-1
		FLD1 //��1
		FADD 
		FSCALE //����2^(��������)
		FLD a2 //װ��a2
		FMULP ST(1), ST //�õ�a2e^x
		FLD result 
		FADD
		FSTP result //�õ�a1x^0.5+a2e^x
		FCOMP //����

		FLD x 
		FSIN //����x������
		FLD a3 //װ��a3
		FMULP ST(1), ST //�õ�a3sinx 
		FLD result 
		FADD 
		FSTP result //�õ�a1x^0.5+a2e^x+a3sinx

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


