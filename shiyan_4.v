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
input pause,                                //暂停 
output[3:0]an,                          //数码管使能 
output[7:0]a_to_g );    

reg[20:0] clk_cnt;                          //保存分频时钟 
reg [3:0] NUM;                           //保存显示数字 
reg [13:0] s ;                             // 数码管复用计数(交替显示) 
reg p_flag ;                              //暂停标识位 
wire  temp_a ;                          //十进制计数时钟 
reg [3:0] temp_b ;                       //保存个位数 
reg [3:0] temp_c ;                       //保存十位数 
 
always @(posedge clk or posedge clr )      //处理时钟或清零事件 
begin  
 if(clr) 
 clk_cnt = 0;                    //如果清零键按下，分频时钟回零  
 else if(!p_flag)                 //如果分频时钟沿来临且非暂停状态，计时  
 begin 
    clk_cnt = clk_cnt + 1;              
 end   
end 
  
assign temp_a = clk_cnt[20] ;           //取分频后的时钟作为十进制计数时钟 
always @( posedge temp_a or posedge clr)     //处理十进制计数和清零事件 
begin 
if(clr)                             //如果清零键按下，个位和十位回零    
   begin  	
   temp_b = 0; 
 	temp_c = 0 ; 
 	end 
else  
  begin                          //如果十进制计时时钟来临，个位计数    
   temp_b = temp_b+1; 
  if(temp_b == 10)                //如果个位超 9，十位加 1，个位回零     
   begin       
   temp_b = 0;     
   temp_c = temp_c + 1 ; 
   if(temp_c ==10)              //如果十位超 9，十位回零      
	 temp_c = 0 ;     
	end  
 end 
end 
 
always @( posedge clk)             //数码管复用切换实现 
begin    
  s = s+1; 
  if(s[13])                       //检测最高位，然后清零     
   s = 0; 
end 
 
always @( posedge pause)          //暂停事件处理，翻转暂停标志位 
p_flag = ~ p_flag ; 
 
assign an[0] = s[12] ;                //个位数码管使能 
assign an[1] = ~s[12] ;              //十位数码管使能 
assign an[3:2] = 2'b11 ;             //禁止另外两个数码管 
 
 
always @(*)  
case(s[12])                     //配合复用使能，交替更换显示数字  
                               
1:NUM = temp_c;               //显示十位数字  
0:NUM = temp_b;               //显示个位数字 
endcase 
 
CLK_SW_7seg_sub  A1(.NUM(NUM), 
                    .a_to_g(a_to_g));  //调用数码管显示子模块 
 
endmodule 
