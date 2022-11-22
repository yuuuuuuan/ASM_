STACK_POIRTER	EQU		0D0H
Fosc_KHZ	EQU	22118
P4   DATA 0C0H
P0M1	DATA	0x93	; P0M1.n,P0M0.n 	=00--->Standard,	01--->push-pull
P0M0	DATA	0x94	; 					=10--->pure input,	11--->open drain
P1M1	DATA	0x91	; P1M1.n,P1M0.n 	=00--->Standard,	01--->push-pull
P1M0	DATA	0x92	; 					=10--->pure input,	11--->open drain
P2M1	DATA	0x95	; P2M1.n,P2M0.n 	=00--->Standard,	01--->push-pull
P2M0	DATA	0x96	; 					=10--->pure input,	11--->open drain
P3M1	DATA	0xB1	; P3M1.n,P3M0.n 	=00--->Standard,	01--->push-pull
P3M0	DATA	0xB2	; 					=10--->pure input,	11--->open drain
P4M1	DATA	0xB3	; P4M1.n,P4M0.n 	=00--->Standard,	01--->push-pull
P4M0	DATA	0xB4	; 					=10--->pure input,	11--->open drain
P5M1	DATA	0xC9	; P5M1.n,P5M0.n 	=00--->Standard,	01--->push-pull
P5M0	DATA	0xCA	; 					=10--->pure input,	11--->open drain
P6M1	DATA	0xCB	; P6M1.n,P6M0.n 	=00--->Standard,	01--->push-pull
P6M0	DATA	0xCC	; 					=10--->pure input,	11--->open drain
P7M1	DATA	0xE1	;
P7M0	DATA	0xE2	;
LED7 EQU P1.7
LED8 EQU P1.6
LED9 EQU P4.7
LED10 EQU P4.6
key17 EQU P3.2
key18 EQU P3.3

ORG 0000H
LJMP F_main
ORG 0100H
F_Main:
	CLR		A
	MOV		P0M1, A 	;设置为准双向口
 	MOV		P0M0, A
	MOV		P1M1, A 	;设置为准双向口
 	MOV		P1M0, A
	MOV		P2M1, A 	;设置为准双向口
 	MOV		P2M0, A
	MOV		P3M1, A 	;设置为准双向口
 	MOV		P3M0, A
	MOV		P4M1, A 	;设置为准双向口
 	MOV		P4M0, A
	MOV		P5M1, A 	;设置为准双向口
 	MOV		P5M0, A
	MOV		P6M1, A 	;设置为准双向口
 	MOV		P6M0, A
	MOV		P7M1, A 	;设置为准双向口
 	MOV		P7M0, A
	MOV		SP, #STACK_POIRTER
	MOV		PSW, #0		;选择第0组R0~R7
main:
	CLR LED7
	CLR LED8
	CLR LED9
	CLR LED10
	MOV		A, #250
	LCALL	F_delay_ms		;延时250ms
	LCALL	F_delay_ms		;延时250ms
	SETB LED7
	SETB LED8
	SETB LED9
	SETB LED10
	MOV		A, #250
	LCALL	F_delay_ms		;延时250ms
	LCALL	F_delay_ms		;延时250ms

	JNB key17,K1
	JNB key18,K2
	SJMP main
jmp1:
	jmp main	
K1:

	CLR LED7
	MOV		A, #250
	LCALL	F_delay_ms		;延时250ms
	LCALL	F_delay_ms		;延时250ms
	SETB LED7

	CLR LED8
	MOV		A, #250
	LCALL	F_delay_ms		;延时250ms
	LCALL	F_delay_ms		;延时250ms
	SETB LED8

	CLR LED9
	MOV		A, #250
	LCALL	F_delay_ms		;延时250ms
	LCALL	F_delay_ms		;延时250ms
	SETB LED9

	CLR LED10
	MOV		A, #250
	LCALL	F_delay_ms		;延时250ms
	LCALL	F_delay_ms		;延时250ms
	SETB LED10
	
	JNB key17,main
	SJMP K1

K2:

	CLR LED10
	MOV		A, #250
	LCALL	F_delay_ms		;延时250ms
	LCALL	F_delay_ms		;延时250ms
	SETB LED10

	CLR LED9
	MOV		A, #250
	LCALL	F_delay_ms		;延时250ms
	LCALL	F_delay_ms		;延时250ms
	SETB LED9

	CLR LED8
	MOV		A, #250
	LCALL	F_delay_ms		;延时250ms
	LCALL	F_delay_ms		;延时250ms
	SETB LED8

	CLR LED7
	MOV		A, #250
	LCALL	F_delay_ms		;延时250ms
	LCALL	F_delay_ms		;延时250ms
	SETB LED7

	JNB key18,jmp1
	SJMP K2

F_delay_ms:
	PUSH	02H		;入栈R2
	PUSH	03H		;入栈R3
	PUSH	04H		;入栈R4

	MOV		R2,A

L_delay_ms_1:
	MOV		R3, #HIGH (Fosc_KHZ / 13)
	MOV		R4, #LOW (Fosc_KHZ / 13)
	
L_delay_ms_2:
	MOV		A, R4			;1T		Total 13T/loop
	DEC		R4				;2T
	JNZ		L_delay_ms_3	;4T
	DEC		R3
L_delay_ms_3:
	DEC		A				;1T
	ORL		A, R3			;1T
	JNZ		L_delay_ms_2	;4T
	
	DJNZ	R2, L_delay_ms_1

	POP		04H		;出栈R2
	POP		03H		;出栈R3
	POP		02H		;出栈R4
	RET

	END