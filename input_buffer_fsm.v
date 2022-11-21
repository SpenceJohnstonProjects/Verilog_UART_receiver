/*
Author: Spence Johnston
Module:  input buffer finite state machine
Purpose: handles the input buffer

Notes:
	when switch pressed, lockout signal until unpressed.
	used to send a single pulse when a button is held 
	down for longer than a clock cycle. Locks out more 
	than one pulse being sent. Outputs 'p' ascii value for part 1 of lab.
	change to switch input signal for later use
*/

module input_buffer_fsm (
	input clk, reset, en, transmitter_rdy,
	input [7:0] char,
	output reg [7:0] out,
	output reg out_en //enable the recieving fsm
);

//states
parameter WAIT = 0;
parameter PRESSED = 1;
parameter IDLE = 2;
parameter SEND = 3;

reg [1:0] state;
reg [4:0] cycle_count;

always @ ( posedge clk )
begin                        
	if ( reset )
		state = IDLE;
	else 
		case ( state )
			IDLE:
			begin
				cycle_count = 0;
				//to upper
				if( char > 8'h60 && char < 8'h7b )
					out = char - 8'h20;
				else
					out = char;
					
				if ( en == 1 )
					if (transmitter_rdy)
						state = PRESSED;
					else
						state = WAIT;
				else
					state = state;
			end
			PRESSED:
			begin
				if (cycle_count < 15) //because 16x baud rate.
				begin
					cycle_count = cycle_count + 1;
					state = state;
				end
				else
					state = SEND;
			end
			SEND:
			begin
				state = IDLE;
			end
			WAIT:
			begin
				if (transmitter_rdy)
					state = PRESSED;
				else
					state = state;
			end
		endcase
end

always @ ( state )
begin
	case (state)
		WAIT, 
		IDLE,
		SEND:
		begin
			out_en = 0;
		end
		PRESSED:
		begin
			out_en = 1;
		end	
	endcase
end
endmodule