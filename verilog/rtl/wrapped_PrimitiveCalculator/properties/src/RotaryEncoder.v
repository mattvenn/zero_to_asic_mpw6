`default_nettype none
`timescale 1ns/1ns

module RotaryEncoder #(
    parameter REG_LEN = 8,
    parameter ADD_SUB = 1'b1
) (
    input wire clk,
    input wire rst,
    input wire a,
    input wire b,
    output reg [REG_LEN-1:0] out
);

    reg a_d1, b_d1;

    always @(posedge clk) begin
        if (rst) begin 
            out <= 0;
            a_d1 <= 1'b0;
            b_d1 <= 1'b0;
        end else begin 
            a_d1 <= a;
            b_d1 <= b;

            case ({a, a_d1, b, b_d1})
                4'b1000, 
                4'b0111 : out <= out + ADD_SUB;
                
                4'b0010,
                4'b1101 : out <= out - ADD_SUB;

                default : out <= out; 
            endcase
        end
    end

endmodule