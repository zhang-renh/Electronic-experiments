//Author = Zhang Renhui

//生成系统所用时钟
module clock
(
	input clk,
	input clr,
	output key_scan,			//大约20ms
	output Time_1s,				//大约1s
	output segment_refresh		//数码管刷新频率
);
reg[28:0] clk_cnt;

always @(posedge clk or posedge clr)
begin
	if(clr)// or clk_cnt[32] == 1)
		clk_cnt = 0;
	else
		clk_cnt = clk_cnt+1;
end

segment_refresh = clk_cnt[15];
Time_1s = clk_cnt[25];
key_scan = clk_cnt[20];

endmodule;

//生成8位随机数，控制led灯
module random
(
	input Time_1s,
	output[7:0] led_control
);

led_control = 8'b00000111;
always @(posedge Time_1s)
begin
	led_control[0] <= led_control[7];
    led_control[1] <= led_control[0];
    led_control[2] <= led_control[1];
    led_control[3] <= led_control[2];
    led_control[4] <= led_control[3]^led_control[7];
    led_control[5] <= led_control[4]^led_control[7];
    led_control[6] <= led_control[5]^led_control[7];
    led_control[7] <= led_control[6];
end

endmodule;

//检测开关输入，并按照当前led状态进行处理
module switch_solve
(
	input key_scan,
	input Time_1s,
	input[7:0] switch,
	input[7:0] led_control,
	output success
);
success = 1;
always @(Time_1s)
begin
	success = not success;
end
endmodule;

//10进制计数器
module dec_counter
(
	input clk,
	input clr,
	output carry,
	output[3:0] num
);

	always @(posedge clr)
	begin
		num = 0;
		carry = 0;
	end

	always @(posedge clk)
	begin
		if(num >= 9)
		begin
			num = 0;
			carry = 1;
		end
		else if
		begin
			carry = 0;
			num = num + 1;
		end
	end
endmodule;

//////////////////////
//二进制向七段码转换//
//////////////////////
module segment_control
	(input segment_refresh,
	 input[15:0] nums,			//四个数码管，每个用4位二进制数表示
	 output[6:0] segment,
	 output[3:0] segment_select
	);
	
	reg[3:0] num;
	segment_select = 4'b1110;
	
	always @(posedge segment_refresh)
	begin
		case(segment_select)
			7	:	segment_select = 4'b1110;
					num = nums[3:0];
			14	:	segment_select = 4'b1101;
					num = nums[7:4];
			13	:	segment_select = 4'b1011;
					num = nums[11:8];
			11	:   segment_select = 4'b0111;
					num = nums[15:12];
		endcase
	end
	
	always @(*)
	case(num)
		0  		:segment = 7'b0000001;
		1  		:segment = 7'b1001111;
		2  		:segment = 7'b0010010;
		3  		:segment = 7'b0000110;
		4  		:segment = 7'b1001100;
		5  		:segment = 7'b0100100;
		6  		:segment = 7'b0100000;
		7  		:segment = 7'b0001111;
		8  		:segment = 7'b0000000;
		9  		:segment = 7'b0000100;
		'hA		:segment = 7'b0001000;
		'hB		:segment = 7'b1100000;
		'hC		:segment = 7'b0110001;
		'hD		:segment = 7'b1000010;
		'hE		:segment = 7'b0110000;
		'hF		:segment = 7'b0111000;
		default	:segment = 7'b0000001;
	endcase
	
endmodule

module top
(
	input clk,
	input clr,
	input switch,
	output led_out,
	output segment_select,
	output segment
);

wire Time_1s;
wire segment_refresh;
wire key_scan;
wire[7:0] led_control;
wire carry1;
wire carry2;
wire carry3;
wire carry4;
wire[15:0] nums;


assign led_out = led_control;
clock myclock
(
	.clk(clk),
	.clr(clr),
	.Time_1s(Time_1s),
	.segment_refresh(segment_refresh)
);

random myrandom
(
	.Time_1s(Time_1s),
	.led_control(led_control)
);

switch_solve myswitch_solve
(
	.key_scan(key_scan),
	.Time_1s(Time_1s),
	.switch(switch),
	.led_control(led_control),
	.success(carry1)
);

dec_counter counter1
(
	.clk(carry1),
	.clr(clr),
	.carry(carry2),
	.num(nums[3:0])
);

dec_counter counter2
(
	.clk(carry2),
	.clr(clr),
	.carry(carry3),
	.num(nums[7:4])
);

dec_counter counter3
(
	.clk(carry3),
	.clr(clr),
	.carry(carry4),
	.num(nums[11:8])
);

dec_counter counter4
(
	.clk(carry4),
	.clr(clr),
	.num(nums[15:12])
);

segment_control mysegment_control
(
	.segment_refresh(segment_refresh),
	.nums(nums),
	.segment_select(segment_select),
	.segment(segment)
);
end module