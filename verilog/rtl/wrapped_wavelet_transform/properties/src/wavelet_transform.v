`default_nettype none
`define ELEM_RATIO (0.577472)
`timescale 1ns/1ns

module wavelet_transform #(
    parameter BITS_PER_ELEM = 8,
    parameter TOTAL_FILTERS = 3,
    parameter SUM_TRUNCATION = 8
) (
`ifdef USE_POWER_PINS
	inout vccd1,	// User area 1 1.8V power
	inout vssd1,	// User area 1 digital ground
`endif

    // Clock
    input wire clk,

    // Reset
    input wire rst,

    // Input Wire
    input wire signed [BITS_PER_ELEM - 1:0] i_value,

    // data_input clock (rising edge)
    input wire i_data_clk,

    // multiplexing for output channels
    input wire [7:0] i_select_output_channel,

    // 8 bit output, channel selected by multiplexer
    output wire [SUM_TRUNCATION - 1:0] o_multiplexed_wavelet_out,

    // chip active gpio signal
    output wire o_active,

    // set the multiplexed wavelet out pins as outputs
    output [8:0] io_oeb

);

  // From Python Ricker-Wavelet Generator:
  // number of taps, total_bits, approx_bits_needed for largest signed sum, filter_values

  /* 3 24 16 c77fc7 */
  /* 5 40 16 e4dd7fdde4 */
  /* 9 72 17 f9dfc81f7f1fc8dff9 */
  /* 15 120 18 fef7e7cfc9f9507f50f9c9cfe7f7fe */
  /* 27 216 18 00fefbf6ede0d2c8cbe10c416d7f6d410ce1cbc8d2e0edf6fbfe00 */
  /* 47 376 19 0000fefdfcfaf6f2ebe4dcd3ccc7c8cfddf30e2e4d67787f78674d2e0ef3ddcfc8c7ccd3dce4ebf2f6fafcfdfe0000 */
  /* 81 648 20 00000000fefefdfdfcfaf9f7f4f1eeeae5e0dbd6d2cdcac7c7c8ccd2dbe7f505172a3c4e5e6c767c7f7c766c5e4e3c2a1705f5e7dbd2ccc8c7c7cacdd2d6dbe0e5eaeef1f4f7f9fafcfdfdfefe00000000 */
  /* 141 1128 21 0000000000000000fefefefefdfdfcfcfbfaf9f8f7f5f4f2f0eeeceae7e4e2dfdcd9d6d3d0cecccac8c7c7c7c8caccd0d4d9e0e7eef7000a151f2a35404a545d666d73787c7e7f7e7c78736d665d544a40352a1f150a00f7eee7e0d9d4d0cccac8c7c7c7c8caccced0d3d6d9dcdfe2e4e7eaeceef0f2f4f5f7f8f9fafbfcfcfdfdfefefefe0000000000000000 */


  // output bits
  wire [(TOTAL_FILTERS*SUM_TRUNCATION - 1):0] truncated_wavelet_out;

  // set the multiplexed wavelet out pins as outputs, as well as active signal pin
  assign io_oeb = 9'b0_0000_0000;

  wire start_calc;

  `ifdef COCOTB_SIM
    initial begin
      $dumpfile ("wavelet_transform.vcd");
      $dumpvars (0, wavelet_transform);
    end
  `endif

  // highest frequency sets the sample rate
  parameter BASE_FREQ = 1;
  parameter BASE_NUM_ELEM = 3;
  parameter NUM_FILTERS = TOTAL_FILTERS;
  // number of elements is ∝ HIGHEST_FREQ/THIS_FREQ
  // really we should calculate the ratio of the elements to produce the freq
  // NUM_ELEM * ELEM_RATIO

  /* parameter TOTAL_TAPS = (1 + $rtoi(BASE_NUM_ELEM * 1.0 / $pow(`ELEM_RATIO, NUM_FILTERS - 1))); */
  /* parameter TOTAL_TAPS = 24; // for 1 filters starting at 3 elements */
  parameter TOTAL_TAPS = 72; // for 3 filters starting at 3 elements
  /* parameter TOTAL_TAPS = 120; // for 4 filters starting at 3 elements */
  /* parameter TOTAL_TAPS = 216; // for 5 filters starting at 3 elements */
  /* parameter TOTAL_TAPS = 376; // for 6 filters starting at 3 elements */
  /* parameter TOTAL_TAPS = 658; // for 7 filters starting at 3 elements */
  parameter BITS_PER_TAP = BITS_PER_ELEM;

  parameter TOTAL_BITS = BITS_PER_TAP * TOTAL_TAPS;

  wire [TOTAL_BITS - 1:0] taps;

  reg active;
  assign o_active = active;

  // NOTE: signal that this module is active after pulling out of reset
  always @(posedge clk) begin
    if (rst) begin
      active <= 1'b0;
    end else begin
      active <= 1'b1;
    end
  end

  output_multiplexer #(
      .NUM_FILTERS(NUM_FILTERS),
      .SUM_TRUNCATION(SUM_TRUNCATION)
  ) om_1 (
      .clk(clk),
      .rst(rst),
      .i_truncated_wavelet_out(truncated_wavelet_out),
      .i_select_output_channel(i_select_output_channel),
      .o_multiplexed_wavelet_out(o_multiplexed_wavelet_out)
  );

  shift_register_line #(
      .TOTAL_TAPS(TOTAL_TAPS),
      .BITS_PER_TAP(BITS_PER_ELEM),
      .TOTAL_BITS(TOTAL_BITS)
  ) srl_1 (
      .clk  (clk),
      .rst(rst),
      .i_value(i_value),
      .i_data_clk (i_data_clk),
      .o_start_calc (start_calc),
      .o_taps (taps[TOTAL_BITS-1:0])
    );

    fir #(
      .BITS_PER_ELEM(BITS_PER_ELEM),
      .SUM_TRUNCATION(SUM_TRUNCATION),
      .NUM_ELEM(3),
      .FILTER_VAL(24'hC77FC7),
      .MAX_BITS(16)
    ) fir_0 (
      .clk(clk),
      .rst(rst),
      .taps (taps[(BITS_PER_ELEM*3) - 1:0]),
      .o_wavelet(truncated_wavelet_out[7:0]),
      .i_start_calc(start_calc)
    );

    fir #(
      .BITS_PER_ELEM(BITS_PER_ELEM),
      .SUM_TRUNCATION(SUM_TRUNCATION),
      .NUM_ELEM(5),
      .FILTER_VAL(40'hE4DD7FDDE4),
      .MAX_BITS(16)
    ) fir_1 (
      .clk(clk),
      .rst(rst),
      .taps (taps[(BITS_PER_ELEM*5) - 1:0]),
      .o_wavelet(truncated_wavelet_out[15:8]),
      .i_start_calc(start_calc)
    );

    fir #(
      .BITS_PER_ELEM(BITS_PER_ELEM),
      .SUM_TRUNCATION(SUM_TRUNCATION),
      .NUM_ELEM(9),
      .FILTER_VAL(72'hF9DFC81F7F1FC8DFF9),
      .MAX_BITS(17)
    ) fir_2 (
      .clk(clk),
      .rst(rst),
      .taps (taps[(BITS_PER_ELEM*9) - 1:0]),
      .o_wavelet(truncated_wavelet_out[23:16]),
      .i_start_calc(start_calc)
    );

/*     fir #( */
/*       .BITS_PER_ELEM(BITS_PER_ELEM), */
/*       .SUM_TRUNCATION(SUM_TRUNCATION), */
/*       .NUM_ELEM(15), */
/*       .FILTER_VAL(120'hFEF7E7CFC9F9507F50F9C9CFE7F7FE), */
/*       .MAX_BITS(18) */
/*     ) fir_3 ( */
/*       .clk(clk), */
/*       .rst(rst), */
/*       .taps (taps[(BITS_PER_ELEM*15) - 1:0]), */
/*       .o_wavelet(truncated_wavelet_out[31:24]), */
/*       .i_start_calc(start_calc) */
/*     ); */

/*     fir #( */
/*       .BITS_PER_ELEM(BITS_PER_ELEM), */
/*       .SUM_TRUNCATION(SUM_TRUNCATION), */
/*       .NUM_ELEM(27), */
/*       .FILTER_VAL(216'h00FEFBF6EDE0D2C8CBE10C416D7F6D410CE1CBC8D2E0EDF6FBFE00), */
/*       .MAX_BITS(18) */
/*     ) fir_4 ( */
/*       .clk(clk), */
/*       .rst(rst), */
/*       .taps (taps[(BITS_PER_ELEM*27) - 1:0]), */
/*       .o_wavelet(truncated_wavelet_out[39:32]), */
/*       .i_start_calc(start_calc) */
/*     ); */


    /* fir #( */
    /*   .BITS_PER_ELEM(BITS_PER_ELEM), */
    /*   .SUM_TRUNCATION(SUM_TRUNCATION), */
    /*   .NUM_ELEM(47), */
    /*   .FILTER_VAL(376'h0000fefdfcfaf6f2ebe4dcd3ccc7c8cfddf30e2e4d67787f78674d2e0ef3ddcfc8c7ccd3dce4ebf2f6fafcfdfe0000), */
    /*   .MAX_BITS(19) */
    /* ) fir_5 ( */
    /*   .clk(clk), */
    /*   .rst(rst), */
    /*   .taps (taps[(BITS_PER_ELEM*47) - 1:0]), */
    /*   .o_wavelet(truncated_wavelet_out[47:40]), */
    /*   .i_start_calc(start_calc) */
    /* ); */

    /* fir #( */
    /*   .BITS_PER_ELEM(BITS_PER_ELEM), */
    /*   .SUM_TRUNCATION(SUM_TRUNCATION), */
    /*   .NUM_ELEM(81), */
    /*   .FILTER_VAL(648'h00000000fefefdfdfcfaf9f7f4f1eeeae5e0dbd6d2cdcac7c7c8ccd2dbe7f505172a3c4e5e6c767c7f7c766c5e4e3c2a1705f5e7dbd2ccc8c7c7cacdd2d6dbe0e5eaeef1f4f7f9fafcfdfdfefe00000000), */
    /*   .MAX_BITS(20) */
    /* ) fir_6 ( */
    /*   .clk(clk), */
    /*   .rst(rst), */
    /*   .taps (taps[(BITS_PER_ELEM*81) - 1:0]), */
    /*   .o_wavelet(truncated_wavelet_out[55:48]), */
    /*   .i_start_calc(start_calc) */
    /* ); */

endmodule
