`ifndef VERILATOR
module testbench;
  reg [4095:0] vcdfile;
  reg clock;
`else
module testbench(input clock, output reg genclock);
  initial genclock = 1;
`endif
  reg genclock = 1;
  reg [31:0] cycle = 0;
  reg [37:0] PI_io_out;
  reg [31:0] PI_la1_oenb;
  reg [31:0] PI_la3_oenb;
  reg [31:0] PI_la1_data_out;
  reg [31:0] PI_la2_data_in;
  reg [0:0] PI_active;
  reg [37:0] PI_io_in;
  reg [31:0] PI_la1_data_in;
  reg [31:0] PI_la2_data_out;
  reg [37:0] PI_io_oeb;
  reg [0:0] PI_wb_clk_i;
  reg [31:0] PI_la3_data_out;
  reg [31:0] PI_la3_data_in;
  reg [31:0] PI_la2_oenb;
  wrapped_instrumented_adder_sklansky UUT (
    .io_out(PI_io_out),
    .la1_oenb(PI_la1_oenb),
    .la3_oenb(PI_la3_oenb),
    .la1_data_out(PI_la1_data_out),
    .la2_data_in(PI_la2_data_in),
    .active(PI_active),
    .io_in(PI_io_in),
    .la1_data_in(PI_la1_data_in),
    .la2_data_out(PI_la2_data_out),
    .io_oeb(PI_io_oeb),
    .wb_clk_i(PI_wb_clk_i),
    .la3_data_out(PI_la3_data_out),
    .la3_data_in(PI_la3_data_in),
    .la2_oenb(PI_la2_oenb)
  );
`ifndef VERILATOR
  initial begin
    if ($value$plusargs("vcd=%s", vcdfile)) begin
      $dumpfile(vcdfile);
      $dumpvars(0, testbench);
    end
    #5 clock = 0;
    while (genclock) begin
      #5 clock = 0;
      #5 clock = 1;
    end
  end
`endif
  initial begin
`ifndef VERILATOR
    #1;
`endif
    // UUT.$auto$async2sync.\cc:168:execute$3297  = 32'b00000000000000000000000000000000;
    // UUT.$auto$async2sync.\cc:168:execute$3299  = 1'b0;
    // UUT.$auto$async2sync.\cc:168:execute$3301  = 32'b00000000000000000000000000000000;
    UUT.a_input = 32'b00000000000000000000000000000000;
    UUT.a_input_ext_bit_b = 32'b00000000000000000000000000000000;
    UUT.a_input_ring_bit_b = 32'b00000001000000000000000000000000;
    UUT.b_input = 32'b00000000000000000000000000000000;
    UUT.instrumented_adder.chain_out = 1'b0;
    UUT.s_output_bit_b = 32'b00000000000000000000000000000000;

    // state 0
    PI_io_out = 38'b00000000000000000000000000000000000000;
    PI_la1_oenb = 32'b00000000000000000000000000000000;
    PI_la3_oenb = 32'b00000000000000000000000000000000;
    PI_la1_data_out = 32'b00000000000000000000000000000000;
    PI_la2_data_in = 32'b00000000000000000000000000000000;
    PI_active = 1'b0;
    PI_io_in = 38'b00000000000000000000000000000000000000;
    PI_la1_data_in = 32'b00000000000000000000000000000000;
    PI_la2_data_out = 32'b00000000000000000000000000000000;
    PI_io_oeb = 38'b00000000000000000000000000000000000000;
    PI_wb_clk_i = 1'b0;
    PI_la3_data_out = 32'b00000000000000000000000000000000;
    PI_la3_data_in = 32'b00000000000000000000000000000000;
    PI_la2_oenb = 32'b00000000000000000000000000000000;
  end
  always @(posedge clock) begin
    genclock <= cycle < 0;
    cycle <= cycle + 1;
  end
endmodule
