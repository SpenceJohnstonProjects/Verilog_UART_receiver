/*
Author: Spence Johnston
Module: hex to bcd converter
Purpose: converts character from uart input into hex equivalent.
		 Seperates digit by ones and tens place.
*/
module hex_to_bcd(
	input clk, reset, en,
	input [7:0] hex_in,
	output reg [3:0] ones,
	output reg [3:0] tens
);

//states
localparam IDLE = 0;
localparam CHANGE = 1;
localparam RESET = 2;

reg[7:0] data;
reg [1:0] state;

always @ ( posedge clk)
begin
	if(reset)
		state = RESET;
	else
		case ( state )
			RESET:
			begin
				state = IDLE;
			end
			IDLE:
			begin
				if(en)
					state = CHANGE;
				else
					state = state;
			end
			CHANGE:
			begin
				state = IDLE;
			end		
		endcase	
end

always @ (state)
begin
	case (state)
	RESET:
	begin
		ones = 0;
		tens = 0;
	end
	IDLE:
	begin
		data = hex_in;
	end
	CHANGE:
	begin
		ones = data[3:0];
		tens = data[7:4];
	end
	endcase
end
endmodule 

//TESTBENCH
module hex_to_bcd_bench;

reg clk, reset, en;
reg [7:0] hex_in;
wire [3:0] ones;
wire [3:0] tens;

hex_to_bcd t0 (clk, reset, en, hex_in, ones, tens);

initial
begin
	clk = 1;
	reset = 1;
	en = 0;
	hex_in = 8'hab;
	
	#2 reset = 0;
	#2 en = 1;
	#2 en = 0;
	
end

always
begin
	#1 clk = ~clk;
end
endmodule 