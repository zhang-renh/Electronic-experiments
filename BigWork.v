

//以下是时钟分频器			 //
//base_fre 控制基础频率		 //
//Time2 的频率是 Time1 的两倍//
///////////////////////////////
module clock
	(input clk,
	 input clr,
	 output reg Time1,
	 output reg Time2,
	 output reg seg_fre		//数码管刷新频率
	);
	
	//parameter base_fre = 25;
	reg[32:0] clk_cnt;
	
	always @(posedge clk or posedge clr)
	begin
		if(clr)
			clk_cnt = 0;
		else
			begin
				clk_cnt = clk_cnt + 1;
				if(clk_cnt[32:29]>15)
					clk_cnt=0;
			end
	end
	
	always @(*)
	begin
		Time1 = clk_cnt[25];
		Time2 = clk_cnt[26];
		seg_fre = clk_cnt[15];
	end
	//led_control led(.clk(Time1));
	//num_to_seg n_to_s(.seg_fre(seg_fre));
endmodule

//////////////////////
//二进制向七段码转换//
//////////////////////
module num_to_seg
	(input seg_fre,//wire seg_fre,
	 input[15:0]NUMS,			//四个数码管，每个用4位二进制数表示
	 output reg[6:0] segment,
	 output reg[3:0] seg_sel
	);
	
	//seg_sel = 4'b0001;
	reg[3:0] NUM;
	
	always @(*)
	case(NUM)
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
	
	always @(posedge seg_fre)
	//begin
		//if (posedge seg_fre)
			begin
				seg_sel = seg_sel * 2;
				case(seg_sel)
					1	:NUM = NUMS[3:0];
					2	:NUM = NUMS[7:4];
					4	:NUM = NUMS[11:8];
					8	:NUM = NUMS[15:12];
				endcase
			end
	//end	
endmodule


//////////////////
//led控制		//
//每次只有一个灯亮
//////////////////
module led_control
	(//input start,
	 //input over,
	 input clk,
	 output reg[7:0] led_state
	 );
	 //reg[7:0] led0;
	 //assign led0=0;
	// always @(posedge clk)
	 //begin
		//led0=led0+1;
	 //end
	 
	 always @(*)
	 begin
		led_state=led_state+1;
	 end
	
endmodule

////////////////////
//开关检测与处理  //
////////////////////
module switch
	(input[7:0] switch,
	 input[7:0] led_state,
	 output reg success
	// output fail
	);
	
	always @(switch[0])// and led_state[0]=1)
	begin
		if(led_state[0] ==1 )
			success = 1;
	end
	
	always @(switch[1])
	begin
		if(led_state[1] == 1)
			success = 1;
	end
	//dec_counter cn1(.clk(success));
endmodule

//////////////////
//十进制加法器  //
//////////////////

module dec_counter
	(input clk,
	 output reg[3:0] NUM,
	 output reg carry
	);
	
	//NUM = 4'b0000;
	
	always @(posedge clk)
	begin
		carry = 0;
		if(NUM >= 9)
			begin
				NUM = 0;
				carry = 1;
			end
		else
			NUM = NUM + 1;
	end
endmodule

module top
	(input clk,
	 input[7:0] switch,
	 output[7:0] led,
	 output[7:0] segment,
	 output[3:0] seg_sel
	);
	
	
	wire inclk;
	wire seg_fre;
	wire[7:0] led_state;
	wire[15:0] NUMS;
	wire carry1;
	wire carry2;
	wire carry3;
	wire carry4;
	//wire[3:0] count2;
	//wire[3:0] count3;
	//wire[3:0] count4;
	
	assign led=led_state;
	clock clock0
	(
		.clk(clk),
		.Time1(inclk),
		.seg_fre(seg_fre)
	);
	
	led_control led1
	(
		.clk(inclk),
		.led_state(led_state)
	);
	
	switch sw
	(
		.led_state(led_state),
		.switch(switch),
		.success(carry1)
	);
	
	num_to_seg n_to_s
	(
		.seg_fre(seg_fre),
		.NUMS(NUMS),
		.segment(segment),
		.seg_sel(seg_sel)
	);
	
	dec_counter counter1
	(
		.clk(carry1),
		.NUM(NUMS[3:0]),
		.carry(carry2)
	);
	dec_counter counter2
	(
		.clk(carry2),
		.NUM(NUMS[7:4]),
		.carry(carry3)
	);
	dec_counter counter3
	(
		.clk(carry3),
		.NUM(NUMS[11:8]),
		.carry(carry4)
	);
	dec_counter counter4
	(
		.clk(carry4),
		.NUM(NUMS[15:12])
	);
endmodule
