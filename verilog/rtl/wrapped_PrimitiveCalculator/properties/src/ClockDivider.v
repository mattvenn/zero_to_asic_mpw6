`default_nettype none
`timescale 1ns/1ns

module ClockDivider #(
    parameter REG_LEN = 8
)(
    input wire clk,
    input wire rst,
    output wire out
);
    reg [REG_LEN-1:0] clk_div;
    
    always @(posedge clk) begin
        if (rst)    clk_div <= 0;
        else          clk_div <= clk_div + 1'b1;
    end

    assign out = clk_div[REG_LEN-1];

endmodule