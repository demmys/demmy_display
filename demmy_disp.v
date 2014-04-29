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
    parameter TRUE = 1'b1,
    parameter FALSE = 1'b0,
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
    input CLOCK_50MHZ,
    // Button (reset button)
    input BUTTON_SOUTH,
    // LCD (character display)
    output [7:0] LCD_DATA_BIT,
    output LCD_ENABLE,
    output LCD_REGISTER_SELECT,
    output LCD_READ_WRITE,
    // LED (debug display)
    output [7:0] LED
);



// Output register
reg [7:0] lcd_db;
assign LCD_DATA_BIT = lcd_db;
reg lcd_e;
assign LCD_ENABLE = lcd_e;
reg lcd_rs;
assign LCD_REGISTER_SELECT = lcd_rs;
reg lcd_rw;
assign LCD_READ_WRITE = lcd_rw;
reg [7:0] led;
assign LED = led;

// Internal register
reg [7:0] state;
reg [1:0] process;
reg [31:0] clock_count;
reg [31:0] wait_time;



// State transition function
function [7:0] state_transition;
    input [7:0] state;
    begin
        case (state)
            // Infinity roop
            8'hfe: state_transition = state;
            // Final state
            8'h10: state_transition = 8'hfe;
            // Transition
            default: state_transition = state + 8'b1;
        endcase
    end
endfunction



// Reset, consume process or wait routine
always @(posedge CLOCK_50MHZ or posedge BUTTON_SOUTH) begin
    if (BUTTON_SOUTH == TRUE) begin

        // Reset
        state <= 8'b0;
        process <= 2'b00;
        clock_count <= 32'b0;
        lcd_e <= FALSE;
        lcd_rw <= FALSE;

    end else begin
        case (process)
            2'b01: begin
                // Enable command
                lcd_e <= TRUE;
                process <= 2'b10;
            end
            2'b10: begin
                if (clock_count == LCD_COMMAND_WAIT) begin
                    // Disenable command
                    lcd_e <= FALSE;
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
        endcase

        // Wait
        clock_count <= clock_count + 32'b1;

    end
end



// Main routine
//     - set module output signal
//     - set wait_time
always @(state) begin
    case (state)
        // LCD Initialize
        8'h00: begin
            lcd_db <= 8'b0;
            lcd_rs <= FALSE;
            wait_time <= FPGA_CONFIG_WAIT;
        end
        8'h01: begin
            lcd_db <= ENABLE_8BIT_CMD;
            wait_time <= ENABLE_8BIT_WAIT_1;
        end
        8'h02: begin
            lcd_db <= ENABLE_8BIT_CMD;
            wait_time <= ENABLE_8BIT_WAIT_2;
        end
        8'h03: begin
            lcd_db <= ENABLE_8BIT_CMD;
            wait_time <= NO_WAIT;
        end
        // LCD configuration
        8'h04: begin
            lcd_db <= FUNCTION_SET_CMD;
            wait_time <= NO_WAIT;
        end
        8'h05: begin
            lcd_db <= ENTRY_MODE_CMD;
            wait_time <= NO_WAIT;
        end
        8'h06: begin
            lcd_db <= DISPLAY_CONTROL_CMD;
            wait_time <= NO_WAIT;
        end
        8'h07: begin
            lcd_db <= DISPLAY_CLEAR_CMD;
            wait_time <= LCD_PREPARE_WAIT;
        end
        // Display characters
        8'h08: begin
            lcd_db <= SET_DD_RAM_ADDRESS | 8'h00;
            wait_time <= NO_WAIT;
        end
        8'h09: begin
            lcd_rs <= TRUE;
            // D
            lcd_db <= 8'h44; 
            wait_time <= NO_WAIT;
        end
        8'h10: begin
            lcd_rs <= FALSE;
            wait_time <= NO_WAIT;
        end
    endcase
end



// Debug routine
always @(posedge CLOCK_50MHZ or posedge BUTTON_SOUTH) begin
    if (BUTTON_SOUTH == TRUE) begin
        led <= 8'hff;
    end else begin
        led <= state;
    end
end



endmodule
