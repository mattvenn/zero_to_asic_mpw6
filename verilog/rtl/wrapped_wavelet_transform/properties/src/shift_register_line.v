`default_nettype none

module shift_register_line #(
    parameter TOTAL_TAPS = 9,
    parameter BITS_PER_TAP = 8,
    parameter TOTAL_BITS = 9 * 8
) (
    // Clock
    input wire clk,

    // Reset
    input wire rst,

    // Inputs Streaming
    input wire signed [BITS_PER_TAP - 1:0] i_value,

    // clock in the data
    input wire i_data_clk,

    // signal to fir's, data is ready to start calculation
    output wire o_start_calc,

    // TAPS
    output reg [TOTAL_BITS - 1:0] o_taps
);

  reg stb;
  reg start_calc;
  reg data_clk_previous; // data_clk one cycle before
  reg data_clk_two_previous; // data_clk two cycles before

  initial begin
    o_taps = 0;
    stb = 0;
    start_calc = 0;
    data_clk_previous = 0;
    data_clk_two_previous = 0;
  end

  always @(posedge clk) begin
    if (rst) begin
      o_taps <= 0;
      stb <= 0;
      start_calc <= 0;
      data_clk_previous <= 0;
      data_clk_two_previous <= 0;
    end else begin
      o_taps <= o_taps;
      start_calc <= 0;
      if (i_data_clk & ~data_clk_previous & ~data_clk_two_previous) begin //rising clk with one redundant reg to fix metastability
        o_taps <= {o_taps[((TOTAL_BITS-1)-BITS_PER_TAP):0], i_value};
        start_calc <= 1;
      end
      data_clk_previous <= i_data_clk;
      data_clk_two_previous <= data_clk_previous;

    end
  end

  assign o_start_calc = start_calc;

endmodule
