/*
Author: Spence Johnston
Module: transmit finite state machine
Purpose: 
	transmits data serially via the uart protocol.
	takes one bytes as data input. On an enable signal, 
	data is wrapped and sent serially via out. done
	signifies when this module is ready for next data byte.
	done used for feedback for data in.
*/
module transmit_fsm
# (
	parameter DATA_LEN = 8
) (
	input clk, en, reset, receiver_done,
	input [DATA_LEN-1:0] data,
	output reg out,
	output reg done //ready for next signal
);

//states
localparam IDLE = 0;
localparam LOADED = 5;
localparam START = 1;
localparam TRANSMIT = 2;
localparam PARITY = 3;
localparam END = 4;

reg [2:0] state;
reg [2:0] count;
reg [DATA_LEN-1:0] data_var;
reg parity_var;

always @ ( posedge clk or posedge reset )
begin
	if (reset)
		state = IDLE;
	else 
		case ( state)
			IDLE:
			begin
				if (en)
				begin
					if(receiver_done)
						state = START;
					else
						state = LOADED;
				end
				else
					state = state;
			end
			LOADED:
			begin
				if (receiver_done)
					state = START;
				else
					state = state;
			end
			START:
			begin
				count = 0; // init for transmit loop
				state = TRANSMIT;
			end
			TRANSMIT:
			begin
				if (count < (DATA_LEN-1))
				begin
					count = count + 1;
					state = state;
				end
				else
					state = PARITY;
			end
			PARITY: 
				state = END;
			END:
			begin
				state = IDLE;
			end
		endcase 
end

always @ ( posedge clk )
begin
	case (state)
		IDLE:
		begin
			out = 1;
			done = 1;
			data_var = data;
		end
		LOADED:
		begin
			out = 1;
			done = 0;
		end
		START:
		begin
			out = 0;
			done = 0;
			parity_var = (data_var[0] ^ data_var[1]) ^ 
					(data_var[2] ^ data_var[3]) ^
					(data_var[4] ^ data_var[5]) ^
					(data_var[6] ^ data_var[7]);
		end
		TRANSMIT:
		begin
			out = data_var[0];
			data_var = data_var >> 1; //grab MSB and shift
		end
		PARITY:
		begin //even parity xor... if wanted odd xnor
			out = parity_var;
		end
		END:
		begin
			out = 1;
			done = 0;
		end
	endcase
end
endmodule 

//TESTBENCH
module transmit_fsm_bench;

reg clk, en, reset, receiver_done;
reg [7:0] data;
wire out, done;
	
transmit_fsm t0 (clk, en, reset, receiver_done, data, out, done);
	
initial
begin
	clk = 1;
	reset = 1;
	en = 0;
	data = 8'hab;
	receiver_done = 1;
	
	#2 reset = 0;
	#4 en= 1;
	#1 en = 0;
	
	#23 en = 1;
	#1 en = 0;
	
	#23 en = 1;
	#1 en = 0;
end

always
begin
	#1 clk = ~clk;
end
endmodule 