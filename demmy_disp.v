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



module demmy_disp # (
    parameter TRUE = 1'b1;
    parameter FALSE = 1'b0;
    // Wait time
    parameter NO_WAIT = 32'd1,
    parameter FPGA_CONFIG_WAIT = 32'd750000,
    parameter LCD_COMMAND_WAIT = 32'd12,
    parameter LCD_CONFIG_WAIT = 32'd2000,
    parameter ENABLE_8BIT_WAIT_1 = 32'd205000 - LCD_CONFIG_WAIT,
    parameter ENABLE_8BIT_WAIT_2 = 32'd5000 - LCD_CONFIG_WAIT,
    parameter LCD_PREPARE_WAIT = 32'd82000,
    // LCD command
    parameter ENABLE_8BIT_CMD = 8'h38,
    parameter FUNCTION_SET_CMD = 8'h38,
    parameter ENTRY_MODE_CMD = 8'h06,
    parameter DISPLAY_CONTROL_CMD = 8'h0c,
    parameter DISPLAY_CLEAR_CMD = 8'h01,
    parameter SET_DD_RAM_ADDRESS = 8'h80
) (
    // Clock
    input CLK_50MHZ,
    // Button (reset button)
    input BTN_SOUTH,
    // LCD (character display)
    output [7:0] LCD_DB,
    output LCD_E,
    output LCD_RS,
    output LCD_RW,
    // LED (debug display)
    output [7:0] LED
);



// Register
reg [7:0] state;
reg [1:0] process;
reg [31:0] clock_count;
reg [31:0] wait_time;



// State transition function
function [7:0] state_transition;
    input [7:0] state;
    begin
        case (state) begin
            // Infinity roop
            8'hfe: state_transition = state;
            // Final state
            8'h10: state_transition = 8'hfe;
            // Transition
            default: state_transition = state + 8'b1;
        end
    end
endfunction



// Reset, consume process or wait routine
always @(posedge CLK_50MHZ or posedge BTN_SOUTH) begin
    if (BTN_SOUTH == TRUE) begin

        // Reset
        state <= 8'b0;
        process <= 2'b00;
        clock_count <= 32'b0;

    end else begin
        case (process) begin
            2'b01: begin
                // Enable command
                LCD_E <= TRUE;
                process <= 2'b10;
            end
            2'b10: begin
                if (clock_count == LCD_COMMAND_WAIT) begin
                    // Disenable command
                    LCD_E <= FALSE;
                    process <= 2'b11;
                    clock_count <= 32'b0;
                end
            end
            2'b11: begin
                if (clock_count == LCD_CONFIG_WAIT) begin
                    // Go to next command or wait
                    process <= 2'b00;
                    clock_count <= 32'b0;
                end
            end
            default: begin
                if (wait_time > 0 && clock_count == wait_time) begin
                    // Wait finished
                    clock_count <= 32'b0;
                    state <= state_transition(state);
                    process <= 2'b01;
                end
            end
        end

        // Wait
        clock_count <= clock_count + 32'b1;

    end
end



// Main routine
//     - set module output signal
//     - set wait_time
always @(state) begin
    case (state) begin
        // LCD Initialize
        8'h00: begin
            LCD_DB <= 8'b0;
            LCD_E <= FALSE;
            LCD_RS <= FALSE;
            LCD_RW <= FALSE;
            wait_time <= FPGA_CONFIG_WAIT;
        end
        8'h01: begin
            LCD_DB <= ENABLE_8BIT_CMD;
            wait_time <= ENABLE_8BIT_WAIT_1;
        end
        8'h02: begin
            LCD_DB <= ENABLE_8BIT_CMD;
            wait_time <= ENABLE_8BIT_WAIT_2;
        end
        8'h03: begin
            LCD_DB <= ENABLE_8BIT_CMD;
            wait_time <= NO_WAIT;
        end
        // LCD configuration
        8'h04: begin
            LCD_DB <= FUNCTION_SET_CMD;
            wait_time <= NO_WAIT;
        end
        8'h05: begin
            LCD_DB <= ENTRY_MODE_CMD;
            wait_time <= NO_WAIT;
        end
        8'h06: begin
            LCD_DB <= DISPLAY_CONTROL_CMD;
            wait_time <= NO_WAIT;
        end
        8'h07: begin
            LCD_DB <= DISPLAY_CLEAR_CMD;
            wait_time <= LCD_PREPARE_WAIT;
        end
        // Display characters
        8'h08: begin
            LCD_DB <= SET_DD_RAM_ADDRESS | 8'h00;
            wait_time <= NO_WAIT;
        end
        8'h09: begin
            LCD_RS <= TRUE;
            // D
            LCD_DB <= 8'h44; 
            wait_time <= NO_WAIT;
        end
        8'h10: begin
            LCD_RS <= FALSE;
            wait_time <= NO_WAIT;
        end
    end
end



// Debug routine
always @(posedge CLK_50MHZ or posedge BTN_SOUTH) begin
    if (BTN_SOUTH == TRUE) begin
        LED <= 8'hff;
    end else
        LED <= state;
    end
end



endmodule
