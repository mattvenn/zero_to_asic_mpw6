`default_nettype none
`timescale 1ns/1ns

module Debouncer #(
    parameter REG_LEN = 8
)(
    input wire clk,
    input wire rst,
    input wire in_a,
    output wire out
);
    
    localparam ALL_ONE = {REG_LEN{1'b1}}, ALL_ZERO = {REG_LEN{1'b0}};

    reg [(REG_LEN-1):0] shift_reg;
    reg r_out;

    always @(posedge clk) begin
        if (rst) begin
            shift_reg   <= ALL_ZERO;
            r_out       <= 1'b0;
        end else begin
            shift_reg <= {shift_reg[REG_LEN-2:0], in_a};
            
            if      (shift_reg == ALL_ONE)      r_out <= 1'b1;
            else if (shift_reg == ALL_ZERO)     r_out <= 1'b0;
            else                                r_out <= r_out;     
        end
    end

    assign out = r_out;

endmodule