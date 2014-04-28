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
    parameter DISPLAY_CLEAR_CMD = 8'h01
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



// State register
reg [7:0] state;
// Command state register
reg [1:0] command;
// Character register
reg [7:0] char;
// Clock counter
reg [31:0] clock_count;
// Wait dist time
reg [31:0] dist_time;



// State transition function
function [7:0] state_transition;
    input [7:0] state;
    begin
        case (state) begin
            // Infinity roop
            8'hfe: state_transition = state;
            // Final state
            8'h07: state_transition = 8'h07;
            // Transition
            default: state_transition = state + 8'b1;
        end
    end
endfunction



// Reset, wait or command routine
always @(posedge CLK_50MHZ or posedge BTN_SOUTH) begin
    if (BTN_SOUTH == TRUE) begin

        // Reset
        state <= 8'b0;
        command <= 3'b0;
        char <= 8'b0;
        clock_count <= 32'b0;

    end else begin
        case (command) begin

            // Command routine
            3'd1: begin
                LCD_E <= TRUE;
                command <= 3'd2;
            end
            3'd2: begin
                if (clock_count == LCD_COMMAND_WAIT) begin
                    LCD_E <= FALSE;
                    command <= 3'd3;
                    clock_count <= 32'b0;
                end
            end
            3'd3: begin
                if (clock_count == LCD_CONFIG_WAIT) begin
                    command <= 3'd0;
                    clock_count <= 32'b0;
                end
            end

            // Wait routine
            default: begin
                if (dist_time > 0 && clock_count == dist_time) begin
                    // Wait finished
                    clock_count <= 32'b0;
                    state <= state_transition(state);
                end
            end

        end

        clock_count <= clock_count + 32'b1;

    end
end



// Main routine
//     - set module output signal
//     - set char
//     - set command state
//     - set dist_time
always @(state) begin
    case (state) begin
        // LCD Initialize
        8'h00: begin
            LCD_DB <= 8'b0;
            LCD_E <= FALSE;
            LCD_RS <= FALSE;
            LCD_RW <= FALSE;
            command <= 3'd0;
            dist_time <= FPGA_CONFIG_WAIT;
        end
        8'h01: begin
            LCD_DB <= ENABLE_8BIT_CMD;
            command <= 3'd1;
            dist_time <= ENABLE_8BIT_WAIT_1;
        end
        8'h02: begin
            LCD_DB <= ENABLE_8BIT_CMD;
            command <= 3'd1;
            dist_time <= ENABLE_8BIT_WAIT_2;
        end
        8'h03: begin
            LCD_DB <= ENABLE_8BIT_CMD;
            command <= 3'd1;
            dist_time <= NO_WAIT;
        end
        // LCD configuration
        8'h04: begin
            LCD_DB <= FUNCTION_SET_CMD;
            command <= 3'd1;
            dist_time <= NO_WAIT;
        end
        8'h05: begin
            LCD_DB <= ENTRY_MODE_CMD;
            command <= 3'd1;
            dist_time <= NO_WAIT;
        end
        8'h06: begin
            LCD_DB <= DISPLAY_CONTROL_CMD;
            command <= 3'd1;
            dist_time <= NO_WAIT;
        end
        8'h07: begin
            LCD_DB <= DISPLAY_CLEAR_CMD;
            command <= 3'd1;
            dist_time <= LCD_PREPARE_WAIT;
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
