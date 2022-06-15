`default_nettype none

module output_multiplexer #(
    parameter NUM_FILTERS = 8,
    parameter SUM_TRUNCATION = 8
) (
    // Clock
    input wire clk,

    // Reset
    input wire rst,

    // truncated outputs from wavelets
    input wire [(NUM_FILTERS*SUM_TRUNCATION - 1):0] i_truncated_wavelet_out,

    // selection of output channels, hardcoded to 8 for now
    input wire [7:0] i_select_output_channel,

    // multiplexed output
    output wire [SUM_TRUNCATION - 1:0] o_multiplexed_wavelet_out

);

  reg [7:0] multiplexer_out;

  assign o_multiplexed_wavelet_out = multiplexer_out;

  initial begin
    multiplexer_out = 8'b0;
  end

  always @(posedge clk) begin
    if (rst) begin
      multiplexer_out <= 8'b0;
    end else begin
        case (i_select_output_channel)
          0: multiplexer_out <= i_truncated_wavelet_out[0*(SUM_TRUNCATION) +:SUM_TRUNCATION];
          1: multiplexer_out <= i_truncated_wavelet_out[1*(SUM_TRUNCATION) +:SUM_TRUNCATION];
          2: multiplexer_out <= i_truncated_wavelet_out[2*(SUM_TRUNCATION) +:SUM_TRUNCATION];
          /* 3: multiplexer_out <= i_truncated_wavelet_out[3*(SUM_TRUNCATION) +:SUM_TRUNCATION]; */
          /* 4: multiplexer_out <= i_truncated_wavelet_out[4*(SUM_TRUNCATION) +:SUM_TRUNCATION]; */
          /* 5: multiplexer_out <= i_truncated_wavelet_out[5*(SUM_TRUNCATION) +:SUM_TRUNCATION]; */
          /* 6: multiplexer_out <= i_truncated_wavelet_out[6*(SUM_TRUNCATION) +:SUM_TRUNCATION]; */
          default: multiplexer_out <= i_truncated_wavelet_out[0+:SUM_TRUNCATION];
        endcase
    end
  end


endmodule
