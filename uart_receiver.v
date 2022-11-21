/*
Author: Spence Johnston
Module: UART receiver main
Purpose: Entry point for uart receiver

Notes:
	reciever should poll 16x speed of transmitter
	baud = 9600 * 16 => 153600 hz
*/

module uart_receiver 
(
	input CLOCK_50, reset,
	input uart_in,//GPIO_0[11]
	output [6:0] HEX0, HEX1,
	output uart_out
);

//clk wire
wire clk_153600hz;
wire clk_9600hz;
//receiver_fsm output wires
wire [7:0] char_outw;
wire receiver_enablew;
//hex_to_bcd output wires
wire [3:0] onesw, tensw;

//part 1 using char_out 
clk_divider #(8,163) c0 (CLOCK_50, clk_153600hz); //153600hz 
receiver_fsm r0 (clk_153600hz, reset, uart_in, char_outw, receiver_enablew);
hex_to_bcd d0 (clk_153600hz, reset, receiver_enablew, char_outw, onesw, tensw);
bcd_hex_decoder d1 (onesw, HEX0); //HEX0 = ones place
bcd_hex_decoder d2(tensw, HEX1);

//input buff output wires
wire [7:0] char_out;
wire out_en;
//tranmit_fsm output wire
wire transmit_enw;

//part 2
clk_divider c1 (CLOCK_50, clk_9600hz);
input_buffer_fsm b0 (clk_153600hz, reset, receiver_enablew, transmit_enw, char_outw, char_out, out_en);
transmit_fsm t0 (clk_9600hz, out_en, reset, 1'b1, char_out, uart_out, transmit_enw);
endmodule 

//TESTBENCH
module uart_receiver_bench;

reg clk, reset, uart_in;
wire [6:0] ones;
wire [6:0] tens;

uart_receiver t0 (clk, reset, uart_in, ones, tens);

initial
begin
	clk = 1;
	reset = 1;
	uart_in = 1;
	
	#2 reset = 0;
	#2 uart_in = 0;
	#16 uart_in = 1;
	#16 uart_in = 0;
end

always
begin
	#1 clk = ~clk;
end
endmodule 
