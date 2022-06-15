`default_nettype none
`timescale 1ns/1ns

module PrimitiveALU(
    input wire clk,
    input wire rst,
    input wire load,
    input wire [7:0] in_a,
    input wire [7:0] in_b,
    input wire [2:0] select,
    output reg [7:0] out,
    output reg flag
);

    localparam ADD = 3'b000, SUB = 3'b001, MUL = 3'b010, DIV = 3'b011, AND = 3'b100, OR = 3'b101, XOR = 3'b110, NOT = 3'b111;

    always @(posedge clk) begin
        if (rst) begin 
            out[7:0] <= 8'b0;
            flag <= 1'b0;
        end
        else if (load) begin
            case (select)
                ADD: {flag, out} <= in_a + in_b;
                SUB: begin 
                    out <= in_a - in_b;
                    if (in_b > in_a) flag <= 1'b1; //negative 
                    else flag <= 1'b0;
                end
                MUL: {flag, out} <= in_a * in_b;
                DIV: begin 
                    out <= in_a/in_b;
                    flag <= 1'b0;
                end
                AND: begin 
                    out <= in_a & in_b;
                    flag <= 1'b0;
                end
                OR: begin
                    out <= in_a | in_b;
                    flag <= 1'b0;
                end
                XOR: begin 
                    out <= in_a ^ in_b;
                    flag <= 1'b0;
                end 
                NOT: begin 
                    out <= ~in_a;
                    flag <= 1'b0;
                end
            endcase
        end
    end

endmodule
