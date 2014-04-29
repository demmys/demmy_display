`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:09:59 04/29/2014
// Design Name:   demmy_disp
// Module Name:   /home/demmys/Documents/demmy_disp/demmy_disp_test.v
// Project Name:  demmy_disp
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: demmy_disp
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module demmy_disp_test;

	// Inputs
	reg CLOCK_50MHZ = 0;
	reg BUTTON_SOUTH;

	// Outputs
	wire [7:0] LCD_DATA_BIT;
	wire LCD_ENABLE;
	wire LCD_REGISTER_SELECT;
	wire LCD_READ_WRITE;
	wire [7:0] LED;
	
	// Clock
	always #20 CLOCK_50MHZ = ~CLOCK_50MHZ;

	// Instantiate the Unit Under Test (UUT)
	demmy_disp uut (
		.CLOCK_50MHZ(CLOCK_50MHZ), 
		.BUTTON_SOUTH(BUTTON_SOUTH), 
		.LCD_DATA_BIT(LCD_DATA_BIT), 
		.LCD_ENABLE(LCD_ENABLE), 
		.LCD_REGISTER_SELECT(LCD_REGISTER_SELECT), 
		.LCD_READ_WRITE(LCD_READ_WRITE), 
		.LED(LED)
	);

	initial begin
		BUTTON_SOUTH = 1;
		#100;
		
		BUTTON_SOUTH = 0;
		#20000000 $finish;

	end
      
endmodule

