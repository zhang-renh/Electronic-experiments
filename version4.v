module clock
(
	input clk_in,
	//input clr,
	output seg_refresh,
	output Time_1s,
	output key_scan
);

reg[28:0] clk_cnt;

assign seg_refresh = clk_cnt[15];
assign Time_1s = clk_cnt[25];
assign key_scan = clk_cnt[20];

always @(posedge clk_in)
begin
	clk_cnt = clk_cnt + 1;
end
endmodule

module led_key
(
	input Time_1s,
	input key_scan,
	input[3:0] key_in,
	output[3:0] led_out,
	output reg success
);

reg[3:0] led_state = 4'b0001;
assign led_out = led_state;
always @(posedge Time_1s)
begin
	led_state = led_state + 1;
end

//always @(posedge key_in[0])
//begin
//	if(led_state[0] == 1)
//		begin
//		led_state[0] =0;
//		end
//end

always @(posedge key_scan)
begin
	success = 0;
	case(key_in)
		4'b0001 :
			begin
			if(led_state[0] == 1)
				begin
					assign success = 1;
					//led_state[0] = 0;
				end
			end
		4'b0010 :
			begin
			if(led_state[1] == 1)
				begin
					assign success = 1;
					//led_state[1] = 0;
				end
			end
		4'b0100 :
			begin
			if(led_state[2] == 1)
				begin
					assign success = 1;
					//led_state[2] = 0;
				end
			end
		4'b1000 :
			begin
			if(led_state[3] == 1)
				begin
					success = 1;
					//led_state[3] = 0;
				end
			end
	endcase
end

endmodule

module seg_control
(
	input seg_refresh,
	input success,
	output[3:0] select_out,
	output[6:0] segment_out
);

reg[3:0] num1 = 4'b0000;
reg[3:0] num2 = 4'b0000;
reg[3:0] select = 4'b1110;
reg[3:0] num = 4'b0000;
reg[6:0] segment = 7'b0000000;

assign select_out = select;
assign segment_out = segment;

always @(posedge success)
begin
	num1 = num1 + 1;
	if(num1 == 10)
		begin
			num1 = 0;
			num2 = num2 +1;
		end
	if(num2 == 10)
		num2 = 0;
end

always @(posedge seg_refresh)
begin
	case(select)
		4'b1110	:
			begin
				select = 4'b1101;
				num = num2;
			end
		4'b1101 :
			begin
				select = 4'b1110;
				num = num1;
			end
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

module TOP
(
	input clk_in,
	input[3:0] key_in,
	output[3:0] led_out,
	output[3:0] select_out,
	output[6:0] segment_out
);

wire Time_1s;
wire key_scan;
wire seg_refresh;
wire success;

clock inerclock
(
	.clk_in(clk_in),
	.seg_refresh(seg_refresh),
	.Time_1s(Time_1s),
	.key_scan(key_scan)
);

led_key inerled_key
(
	.Time_1s(Time_1s),
	.key_scan(key_scan),
	.key_in(key_in),
	.led_out(led_out),
	.success(success)
);

seg_control inerseg_control
(
	.seg_refresh(seg_refresh),
	.success(success),
	.select_out(select_out),
	.segment_out(segment_out)
);
endmodule 