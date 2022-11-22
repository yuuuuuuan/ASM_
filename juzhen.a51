	P4     DATA   0C0H  ; 端口寄存器的地址
P5     DATA   0C8H
P0M1    DATA    0x93    ; 
P0M0    DATA    0x94    ;        
P3M1	DATA	0xB1	; 设置端口模式寄存器的地址
P3M0	DATA	0xB2
P4M1	DATA	0xB3	
P4M0	DATA	0xB4	
P5M1	DATA	0xC9	
P5M0	DATA	0xCA
;*************	IO口定义	**************
HC595_SER      BIT  P4.0	           ;   串行数据输入引脚
HC595_RCLK    BIT  P5.4            ;   锁存时钟
HC595_SRCLK  BIT  P4.3            ;   移位时钟
STACK_P	EQU    0D0H           ;   堆栈开始地址
DIS_BLACK	EQU    10H              ;   消隐的索引值
;*************       本地变量声明	       ***********
LED8	DATA    30H             ;   显示缓冲 30H ~ 37H
disp_index	DATA    38H             ;   显示位索引
KEY_NUM8 DATA 60H
SCANCODE DATA 44H
KEY_index DATA 45H	
	ORG 0000H
	LJMP START
	ORG 0100H

START:
CLR      A
		  MOV   P0M1, A 	;设置为准双向口
 	      MOV   P0M0, A
	      MOV   P3M1, A 	;设置为准双向口
 	      MOV   P3M0, A
	      MOV   P4M1, A 	 
 	      MOV   P4M0, A
	      MOV   P5M1, A 	
 	      MOV   P5M0, A
	      MOV   SP, #STACK_P
	      MOV   disp_index, #0	
MOV   SCANCODE,#00H
	MOV   disp_index,  #0                        
    MOV   R0, #LED8 
	MOV	  R1, #50
    MOV   R2, #8
MOV KEY_NUM8+0,#16
		MOV KEY_NUM8+1,#16
		MOV KEY_NUM8+2,#16
		MOV KEY_NUM8+3,#16
		MOV KEY_NUM8+4,#16
		MOV KEY_NUM8+5,#16
		MOV KEY_NUM8+6,#16
		MOV KEY_NUM8+7,#16
MOV   SCANCODE,#00H
		MOV   KEY_index,#0         
   		MOV	R0, #LED8

ClearLoop: MOV	@R0, #DIS_BLACK  
	              INC	 R0
	              DJNZ	R2,  ClearLoop	
				  
Key_loop:
		DJNZ	R1,Key_loop1	
		LCALL   KeyScan
		MOV		R1,#50		;50ms扫描一次
Key_loop1:
					LCALL   delay_ms1	
	                LCALL   KeyScan
		LCALL   Key_DispScan
	                LJMP    Key_loop        
	

	 KeyScan:
  		SETB P4.6
		MOV P0,#0FFH
		
		MOV P0,#0EFH
		MOV A,P0
		ANL A,#0FH
		ADD A,#0E0H
		CJNE A,#0EFH,ON
		
		MOV P0,#0FFH
		
		MOV P0,#0DFH
		MOV A,P0
		ANL A,#0FH
		ADD A,#0D0H
		CJNE A,#0DFH,ON  
		
		MOV P0,#0FFH
		
		MOV P0,#0BFH
		MOV A,P0
		ANL A,#0FH
		ADD A,#0B0H
		CJNE A,#0BFH,ON
		
		MOV P0,#0FFH
			
		MOV P0,#7FH
		MOV A,P0
		ANL A,#0FH
		ADD A,#70H
		CJNE A,#7FH,ON
		RET
		
		ON:MOV SCANCODE,A
		WAIT:	MOV P0,#0FFH
		LCALL delay_ms1
		MOV A,P0
		CJNE A,#0FFH,WAIT
		LJMP KEYLOOP	
   KEYLOOP:
		  
		  MOV DPTR,#KEYCODE
		  MOV  A, KEY_index
          MOVC  A, @A+DPTR
          CJNE  A, SCANCODE, NEXTKEY
		  CLR P4.6
		  MOV	A,KEY_index
		  CJNE	A,KEY_NUM8+0, ZUOYI
		  RET

ZUOYI:		  
		  MOV	KEY_NUM8+7,KEY_NUM8+6		
		  MOV	KEY_NUM8+6,KEY_NUM8+5
		  MOV	KEY_NUM8+5,KEY_NUM8+4
		  MOV	KEY_NUM8+4,KEY_NUM8+3
		  MOV	KEY_NUM8+3,KEY_NUM8+2
		  MOV	KEY_NUM8+2,KEY_NUM8+1
		  MOV	KEY_NUM8+1,KEY_NUM8+0
		  MOV	KEY_NUM8+0,KEY_index
          RET
  NEXTKEY:INC KEY_index
	      LJMP KEYLOOP


Key_DispScan:       
	              
	              MOV	LED8+0, KEY_NUM8+7
				  MOV	LED8+1, KEY_NUM8+6
				  MOV	LED8+2, KEY_NUM8+5
				  MOV	LED8+3, KEY_NUM8+4
				  MOV	LED8+4, KEY_NUM8+3
				  MOV	LED8+5, KEY_NUM8+2
				  MOV	LED8+6, KEY_NUM8+1
				  MOV	LED8+7, KEY_NUM8+0
 	              MOV        R7, #8
	
Key_NEXT:	
			
			MOV	DPTR, #K_COM   
	        MOV	A, disp_index     
	        MOVC	A, @A+DPTR
	        CPL 	A                      
	        LCALL	Send_595	
	        MOV	DPTR, #K_Disp 
	        MOV	A, disp_index
	        ADD	A, #LED8
	        MOV	R0, A
	        MOV	A, @R0
MOVC	A, @A+DPTR
LCALL	Send_595	
CLR	 HC595_RCLK	
SETB	HC595_RCLK

INC	 disp_index     
DJNZ    R7, Key_NEXT
MOV	disp_index, #0 
RET

Send_595:   MOV   R2, #8
Send_Loop: RLC      A
	                  MOV  HC595_SER, C
	                  CLR    HC595_SRCLK 
                      SETB  HC595_SRCLK  ; 产生移位脉冲
	                  DJNZ  R2, Send_Loop
	                  RET

	   
delay_ms1: MOV      R7,#100    

       DJNZ     R7,$

       RET
	
	
KEYCODE:DB 0EEH,0EDH,0EBH,0E7H,0DEH,0DDH,0DBH,0D7H
	DB 0BEH,0BDH,0BBH,0B7H,07EH,07DH,07BH,77H
	
K_Disp:DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH,77H,7CH,39H,5EH,79H,71H,00H

K_COM: DB 01H,02H,04H,08H
       DB 10H,20H,40H,80H
				   
		
				END