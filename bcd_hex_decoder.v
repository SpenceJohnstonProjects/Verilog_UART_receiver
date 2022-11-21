/*
Author: Spence Johnston
Module: BCD to hex decoder 
Purpose: 
	takes 4 bit (single hex) value, outputs as seven segment display line.
*/
module bcd_hex_decoder (
	input [3:0] hex_in,
	output reg [6:0] seven_out
);

always @ (hex_in)
begin					//not these for dev board, active low segs
	case (hex_in)
	4'b0000:      //Hexadecimal 0
		seven_out = 7'b1000000;
	4'b0001:    	//Hexadecimal 1
		seven_out = 7'b1111001;
	4'b0010:  		// Hexadecimal 2
		seven_out = 7'b0100100; 
	4'b0011: 		// Hexadecimal 3
		seven_out = 7'b0110000;
	4'b0100:			// Hexadecimal 4
		seven_out = 7'b0011001;
	4'b0101:			// Hexadecimal 5
		seven_out = 7'b0010010;  
	4'b0110:			// Hexadecimal 6
		seven_out = 7'b0000010;
	4'b0111:			// Hexadecimal 7
		seven_out = 7'b1111000;
	4'b1000:     	//Hexadecimal 8
		seven_out = 7'b0000000;
	4'b1001:    	//Hexadecimal 9
		seven_out = 7'b0010000;
	4'b1010:  		// Hexadecimal A
		seven_out = 7'b0001000;	
	4'b1011: 		// Hexadecimal B
		seven_out = 7'b0000011;
	4'b1100:			// Hexadecimal C
		seven_out = 7'b1000110;
	4'b1101:			// Hexadecimal D
		seven_out = 7'b0100001;
	4'b1110:			// Hexadecimal E
		seven_out = 7'b0000110;
	4'b1111:			// Hexadecimal F
		seven_out = 7'b0001110;
	endcase
end

endmodule 