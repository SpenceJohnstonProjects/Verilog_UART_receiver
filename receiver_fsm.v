/*
Author: Spence Johnston
Module: uart reciever
Purpose: Receives data from GPIO using the UART protocol.

Notes:
	receives input from TX. LEN = size of data
	even parity
	1 stop bit
	
	runs at 16x the baud rate. Because of this, samples on 8th clock pulse for data (the middle).
*/

module receiver_fsm
# (
	parameter LEN=8,
	parameter BAUD_MULT=16
) (
	input clk, reset, uart_in,
	output reg [LEN-1:0] char,
	output reg out_en
);

//states
localparam 
	IDLE = 0,
	START = 1,
	DATA = 2,
	PARITY = 3,
	END = 4,
	SEND = 5;

reg [2:0] state;

reg[3:0] data_count;
reg[5:0] cycle_count;

reg parity;

always @ ( posedge clk )
begin
	if (reset)
		state = IDLE;
	else
		case (state)
			IDLE:
			begin
				data_count = 0;
				cycle_count = 0;
				
				if(~uart_in)
					state = START;
				else
					state = state;
			end
			START://loop through start signal 
			begin
				if (cycle_count < 15) //because of 16x speed
				begin
					cycle_count = cycle_count + 1;
					state = state;
				end
				else
				begin
					cycle_count = 0;
					state = DATA;
				end
			end
			DATA://manage data. pole at 8th cycle, grab 8 bits
			begin
				if(data_count < 8)
				begin
					if( cycle_count < 15 )
					begin
						if( cycle_count == 8)
							char[data_count] = uart_in;					
						cycle_count = cycle_count + 1;
						state = state;
					end
					else
					begin
						data_count = data_count + 1;
						cycle_count = 0;
						state = state;
					end
				end
				else
				begin
					cycle_count = 0;
					state = PARITY;
				end
			end
			PARITY:
			begin
				if (cycle_count < 15) //because of 16x speed
				begin
					if (cycle_count == 8)
						parity = uart_in;
					cycle_count = cycle_count + 1;
					state = state;
				end
				else
				begin
					cycle_count = 0;
					state = END;
				end			
			end
			END:
			begin
				if (cycle_count < 14)//because of 16x speed. was 15, but took off 1 cycle for enable state.
				begin
					if (cycle_count == 8)
						if(uart_in)//& (parity == (char[0] ^ char[1] ^ ...)))
							state = SEND;
					cycle_count = cycle_count + 1;
					state = state;
				end
				else
				begin
					state = IDLE; //error if this is hit. Can add error handling later.
				end
			end
			SEND:
				state = IDLE;
		endcase
end

always @ (state)
begin
	case (state)
		IDLE,
		START,
		DATA,
		PARITY,
		END:
		begin
			out_en = 0;
		end
		SEND:
		begin
			out_en = 1;	
		end
	endcase
end
endmodule 

//TESTBENCH
module receiver_fsm_bench;

reg clk, reset, uart_in;
wire [7:0] char;
wire out_en;

receiver_fsm t0 (clk, reset, uart_in, char, out_en);

initial
begin
	clk = 1;
	reset = 1;
	uart_in = 1;
	
	#2 reset = 0;
	#2 uart_in = 0;
	#16 uart_in = 1;
	#16 uart_in = 0;
	#16 uart_in = 1;
end

always
begin
	#1 clk = ~clk;
end
endmodule 