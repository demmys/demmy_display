`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Engineer      : demmy
// 
// Create Date   : 23:28:09 04/27/2014 
// Module Name   : demmy_disp 
// Project Name  : demmy display
// Target Devices: Spartan 3AN Starter Kit
// Tool versions : Xilinx ISE 14.7
// Description   : Demmy's LCD message
//
//////////////////////////////////////////////////////////////////////////////////
//
module demmy_disp(
    // Clock
    input CLK_50MHZ,
    // Button
    input BTN_SOUTH,
    // LCD
    output [7:0] LCD_DB,
    output LCD_E,
    output LCD_RS,
    output LCD_RW,
    // LED
    output [7:0] LED
);


endmodule
