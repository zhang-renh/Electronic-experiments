`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:24:04 03/25/2017 
// Design Name: 
// Module Name:    shiyan_4 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module 
CLK_SW_7seg_sub( 
input [3:0] NUM, 
output reg[7:0] a_to_g ); 
 
always @(*)  
 
case(NUM) 
0:a_to_g=8'b10000001; 
1:a_to_g=8'b11001111; 
2:a_to_g=8'b10010010; 
3:a_to_g=8'b10000110; 
4:a_to_g=8'b11001100; 
5:a_to_g=8'b10100100; 
6:a_to_g=8'b10100000; 
7:a_to_g=8'b10001111; 
8:a_to_g=8'b10000000; 
9:a_to_g=8'b10000100;
'hA: a_to_g=8'b00001000; 
'hB: a_to_g=8'b01100000; 
'hC: a_to_g=8'b00110001; 
'hD: a_to_g=8'b01000010; 
'hE: a_to_g=8'b00110000; 
'hF: a_to_g=8'b00111000; 
default: a_to_g=8'b10000001;  
endcase 
 
endmodule 
 
 
 
 
 
 
 
 
 
module CLK_SW_7seg_top( 
input clk,                    
input clr, 
input pause,                                //��ͣ 
output[3:0]an,                          //�����ʹ�� 
output[7:0]a_to_g );    

reg[20:0] clk_cnt;                          //�����Ƶʱ�� 
reg [3:0] NUM;                           //������ʾ���� 
reg [13:0] s ;                             // ����ܸ��ü���(������ʾ) 
reg p_flag ;                              //��ͣ��ʶλ 
wire  temp_a ;                          //ʮ���Ƽ���ʱ�� 
reg [3:0] temp_b ;                       //�����λ�� 
reg [3:0] temp_c ;                       //����ʮλ�� 
 
always @(posedge clk or posedge clr )      //����ʱ�ӻ������¼� 
begin  
 if(clr) 
 clk_cnt = 0;                    //�����������£���Ƶʱ�ӻ���  
 else if(!p_flag)                 //�����Ƶʱ���������ҷ���ͣ״̬����ʱ  
 begin 
    clk_cnt = clk_cnt + 1;              
 end   
end 
  
assign temp_a = clk_cnt[20] ;           //ȡ��Ƶ���ʱ����Ϊʮ���Ƽ���ʱ�� 
always @( posedge temp_a or posedge clr)     //����ʮ���Ƽ����������¼� 
begin 
if(clr)                             //�����������£���λ��ʮλ����    
   begin  	
   temp_b = 0; 
 	temp_c = 0 ; 
 	end 
else  
  begin                          //���ʮ���Ƽ�ʱʱ�����٣���λ����    
   temp_b = temp_b+1; 
  if(temp_b == 10)                //�����λ�� 9��ʮλ�� 1����λ����     
   begin       
   temp_b = 0;     
   temp_c = temp_c + 1 ; 
   if(temp_c ==10)              //���ʮλ�� 9��ʮλ����      
	 temp_c = 0 ;     
	end  
 end 
end 
 
always @( posedge clk)             //����ܸ����л�ʵ�� 
begin    
  s = s+1; 
  if(s[13])                       //������λ��Ȼ������     
   s = 0; 
end 
 
always @( posedge pause)          //��ͣ�¼�������ת��ͣ��־λ 
p_flag = ~ p_flag ; 
 
assign an[0] = s[12] ;                //��λ�����ʹ�� 
assign an[1] = ~s[12] ;              //ʮλ�����ʹ�� 
assign an[3:2] = 2'b11 ;             //��ֹ������������� 
 
 
always @(*)  
case(s[12])                     //��ϸ���ʹ�ܣ����������ʾ����  
                               
1:NUM = temp_c;               //��ʾʮλ����  
0:NUM = temp_b;               //��ʾ��λ���� 
endcase 
 
CLK_SW_7seg_sub  A1(.NUM(NUM), 
                    .a_to_g(a_to_g));  //�����������ʾ��ģ�� 
 
endmodule 
