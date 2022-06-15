`default_nettype none
`timescale 1ns/1ns

module HexSevenSegmentDecoder (
    input wire clk,
    input wire rst,
    input wire load,
    input wire [3:0] tens,
    input wire [3:0] units,
    output reg [6:0] display_out,
    output reg digit
);

    reg [3:0] tens_r;
    reg [3:0] units_r;
    wire [3:0] decode;

    always @(posedge clk) begin
        if (rst) begin 
            tens_r <= 4'b0;
            units_r <= 4'b0;
            digit <= 1'b0;
        end else begin 
            if (load) begin
                tens_r <= tens;
                units_r <= units;
            end else begin 
                tens_r <= tens_r;
                units_r <= units_r;
            end 

            digit <= ~digit;
        end
    end

    assign decode = digit ? tens_r : units_r;

    always @(*) begin
        case (decode) 
                //                 7654321
            4'h0: display_out = 7'b0111111;
            4'h1: display_out = 7'b0000110;
            4'h2: display_out = 7'b1011011;
            4'h3: display_out = 7'b1001111; 
            4'h4: display_out = 7'b1100110;
            4'h5: display_out = 7'b1101101;
            4'h6: display_out = 7'b1111101;
            4'h7: display_out = 7'b0000111;
            4'h8: display_out = 7'b1111111;
            4'h9: display_out = 7'b1101111;
            4'ha: display_out = 7'b1011111;
            4'hb: display_out = 7'b1111100;
            4'hc: display_out = 7'b1011000;
            4'hd: display_out = 7'b1011110;
            4'he: display_out = 7'b1111011;
            4'hf: display_out = 7'b1110001;
            default: 
                display_out = 7'b0000000;
        endcase
    end

endmodule


