`default_nettype none
`timescale 1ns/1ns

module PrimitiveCalculator (
`ifdef USE_POWER_PINS
    inout vccd1,
    inout vssd1,
`endif
    input wire clk,
    input wire rst,
    input wire select,
    input wire restart,
    input wire rotary_a,
    input wire rotary_b,
    output wire [6:0] seven_segment_out,
    output wire seven_segment_digit,
    output reg led_flag,
    output wire [9:0] io_oeb,
    output wire sync
);
	
    assign io_oeb = 10'b0;
    assign sync = rst;

    localparam START = 3'b000, FIRST_INPUT = 3'b001, SECOND_INPUT = 3'b010, SELECTION = 3'b011, FINAL = 3'b100;

    //clock divider if needed
    wire clk_div;
    assign clk_div = clk;
//    ClockDivider #(.REG_LEN(1)) clok_divider(.clk(clk), .rst(rst), .out(clk_div)); // divides half

    // debouncing for rotary inputs and buttons
    wire rotary_a_debounce, rotary_b_debounce, restart_debounce, select_debounce;
    Debouncer #(.REG_LEN(8)) debouncer_rotary_a(.clk(clk_div), .rst(rst), .in_a(rotary_a), .out(rotary_a_debounce));
    Debouncer #(.REG_LEN(8)) debouncer_rotary_b(.clk(clk_div), .rst(rst), .in_a(rotary_b), .out(rotary_b_debounce));
    Debouncer #(.REG_LEN(8)) debouncer_rotary_select(.clk(clk_div), .rst(rst), .in_a(select), .out(select_debounce));
    Debouncer #(.REG_LEN(8)) debouncer_rotary_restart(.clk(clk_div), .rst(rst), .in_a(restart), .out(restart_debounce));

    // sense when pressing the select button
    reg select_d1;
    wire select_pressed;

    always @(posedge clk_div) begin
        select_d1 <= select_debounce;
    end 

    assign select_pressed = ~select_d1 & select_debounce;

    // getting input from rotary encoder
    wire [7:0] rotary_out;
    RotaryEncoder #(.REG_LEN(8), .ADD_SUB(1'b1)) rotary_encoder(.clk(clk_div), .rst(rst), .a(rotary_a_debounce), .b(rotary_b_debounce), .out(rotary_out));     

    // seven segment output
    reg seven_segment_load;
    reg [3:0] seven_segment_tens;
    reg [3:0] seven_segment_units;

    HexSevenSegmentDecoder seven_segment(.clk(clk_div), .rst(rst), .load(seven_segment_load), .tens(seven_segment_tens), .units(seven_segment_units), .display_out(seven_segment_out), .digit(seven_segment_digit));

    // Arithmetic logic unit
    reg alu_load;
    reg [7:0] alu_in_a_r;
    reg [7:0] alu_in_b_r;
    reg [2:0] alu_select;
    wire [7:0] alu_out;
    wire alu_flag;
    PrimitiveALU alu(.clk(clk_div) ,.rst(rst), .load(alu_load), .in_a(alu_in_a_r), .in_b(alu_in_b_r), .select(alu_select), .out(alu_out), .flag(alu_flag));

    // calculator itself
    reg [2:0] current_state; 
    reg [2:0] next_state;

    always @(posedge clk_div) begin
        if (rst) begin
            current_state <= START;            
        end else begin 
            current_state <= next_state;
        end
    end	

    always @(*) begin
        case (current_state)
            START: begin 
                if (restart_debounce) begin
                    next_state = START;
                end else if (select_pressed) begin 
                    next_state = FIRST_INPUT;
                end else begin
                    next_state = current_state;
                end 
            end 
            FIRST_INPUT: begin                
                if (restart_debounce) begin
                    next_state = START;
                end else if (select_pressed) begin 
                    next_state = SECOND_INPUT;
                end else begin
                    next_state = current_state;
                end
            end 
            SECOND_INPUT:begin
                if (restart_debounce) begin
                    next_state = START;
                end else if (select_pressed) begin 
                    next_state = SELECTION;
                end else begin
                    next_state = current_state;
                end 
            end
            SELECTION: begin
                if (restart_debounce) begin
                    next_state = START;
                end else if (select_pressed) begin 
                    next_state = FINAL;
                end else begin
                    next_state = current_state;
                end 
            end
            FINAL: begin
                if (restart_debounce) begin
                    next_state = START;
                end else if (select_pressed) begin 
                    next_state = START;
                end else begin
                    next_state = current_state;
                end 
            end
        endcase
    end

    always @(posedge clk) begin
        case (current_state)
            START: begin 
                seven_segment_load <= 1'b0;
                seven_segment_tens <= 4'b0;
                seven_segment_units <= 4'b0;
                alu_load <= 1'b0;
                alu_in_a_r <= 8'b0; 
                alu_in_b_r <= 8'b0;
                led_flag <= 1'b0;
                alu_select <= 3'b0;
            end
            FIRST_INPUT: begin
                seven_segment_load <= 1'b1;
                {seven_segment_tens, seven_segment_units} <= rotary_out;
                alu_load <= alu_load;
                alu_in_a_r <= rotary_out;
                alu_in_b_r <= alu_in_b_r;
                led_flag <= led_flag;
                alu_select <= alu_select;
            end
            SECOND_INPUT: begin
                seven_segment_load <= 1'b1;
                {seven_segment_tens, seven_segment_units} <= rotary_out;
                alu_load <= alu_load;
                alu_in_b_r <= rotary_out;
                alu_in_a_r <= alu_in_a_r;
                led_flag <= led_flag;
                alu_select <= alu_select;
            end
            SELECTION: begin
                seven_segment_load <= 1'b1;
                seven_segment_tens <= 4'b0;
                seven_segment_units <= {1'b0, rotary_out[2:0]};
                alu_select <= rotary_out[2:0];
                alu_load <= alu_load;
                alu_in_a_r <= alu_in_a_r;
                alu_in_b_r <= alu_in_b_r;
                led_flag <= led_flag;
            end
            FINAL: begin
                alu_load = 1'b1;
                {seven_segment_tens, seven_segment_units} <= alu_out;
                led_flag <= alu_flag;
                alu_select <= rotary_out[2:0];
                alu_load <= alu_load;
                alu_in_a_r <= alu_in_a_r;
                alu_in_b_r <= alu_in_b_r;
            end
        endcase
    end

endmodule
