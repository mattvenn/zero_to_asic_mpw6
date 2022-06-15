`default_nettype none
`timescale 1ns/1ns
module cpr(
`ifdef USE_POWER_PINS
	inout vccd1,	// User area 1 1.8V power
	inout vssd1,	// User area 1 digital ground
`endif
input clk,
input rst,
input start,
output breath_out,
output compress_out,
output pulse_out,
output [3:0] io_oeb,
output sync
);

assign io_oeb =4'b0;
assign sync = rst;

// Debounce Signals
wire debounced;
reg debounced_prev = 1'b0;
reg startCompress = 1'b0;
reg delay_1; reg delay_2; reg delay_3;  // Pulse Signals
parameter [1:0]
  ZERO = 0,
  IDLE = 1,
  COMPRESS = 2,
  BREATHE = 3,
  PULSE = 4;

reg [1:0] state = ZERO;
reg [31:0] compressTime = 0;
reg [31:0] zeroTime = 0;
wire [31:0] secTimeLimit = 50_000_000;  // 50_000_000 50MHZ 2 Times for asic time limit
wire [31:0] zeroTimeLimit = 1000;  //Reset Warning
wire [31:0] compressTimeLimit = 46_000_000;  //46_000_000 | 2.17390% percent of a second
wire [31:0] compressTimeLimitHalf = 23_000_000;  //23_000_000 | 2.17390% percent of a second
wire [31:0] compressTimeLimitQuarter = 11_500_000;  //11_500_000
reg [31:0] breathTime = 0;
reg [31:0] pulseTimecounter = 0;
reg [31:0] pulseTime = 0;
reg [2:0] signal_o = 1'b0;
reg [31:0] compressCount = 0;
reg [31:0] breatheCount = 0;

    `ifdef COCOTB_SIM
        initial begin
            $dumpfile ("cpr.vcd");
            $dumpvars (0, cpr);
            #1;
        end
    `endif

  always @(posedge clk) begin
    if(rst == 1'b1) begin
      delay_1 <= 1'b0;
      delay_2 <= 1'b0;
      delay_3 <= 1'b0;
    end else begin
      delay_1 <= start;
      delay_2 <= delay_1;
      delay_3 <= delay_2;
    end
  end

  assign debounced = delay_1 & delay_2 & delay_3;
  always @(debounced) begin
    //debounced_prev <= debounced;
    if((rst == 1'b1)) begin
      startCompress <= 1'b0;
    end
    else begin
      if((debounced == 1'b1 && debounced_prev == 1'b0)) begin
        startCompress <= 1'b1;
        // Start
      end
      else begin
        startCompress <= 1'b0;
      end
    end
  end

  // Cardiopulmonary resuscitation First Aid procedure according to AHA standards
  always @(posedge clk, posedge rst) begin
    if(rst == 1'b1) begin
      breathTime <= 0;
      compressTime <= 0;
      compressCount <= 0;
      breatheCount <= 0;
      pulseTimecounter <= 0;
      signal_o[0] <= 1'b0;
      signal_o[1] <= 1'b0;
      signal_o[2] <= 1'b0;
      state <= ZERO;
    end else begin
      case(state)
      ZERO : begin
        signal_o[0] <= 1'b1;
        signal_o[1] <= 1'b1;
        signal_o[2] <= 1'b1;
        if(zeroTime == zeroTimeLimit) begin
          state <= IDLE;
        end else begin
          zeroTime <= zeroTime + 1;
        end
      end
      IDLE : begin
        state <= IDLE;
        zeroTime<=0;
        breathTime <= 0;
        compressTime <= 0;
        pulseTime <= 0;
        compressCount <= 0;
        breatheCount <= 0;
        signal_o[0] <= 1'b0;
        signal_o[1] <= 1'b0;
        signal_o[2] <= 1'b0;
        if(startCompress == 1'b1 && start==1'b1) begin
          state <= COMPRESS;
        end
        else begin
          state <= IDLE;
        end
      end
      COMPRESS : begin
      if((rst == 1'b1)) begin
      	startCompress <= 1'b0;
      	state <= IDLE;
      end
      if(startCompress == 1'b0 && start==1'b0) begin
          state <= IDLE;
        end
        if(compressTime == compressTimeLimit) begin
          signal_o[1] <= 1'b0;
          compressTime <= 0;
        end
        else begin
          if(compressTime == compressTimeLimitHalf) begin
            compressCount <= compressCount + 1;
            signal_o[1] <= 1'b1;
            signal_o[0] <= 1'b0;
          end
          else if(compressTime == compressTimeLimitQuarter) begin
            if(compressCount == 11) begin
              signal_o[1] <= 1'b0;
              breatheCount <= breatheCount + 1;
              state <= BREATHE;
            end
          end
          compressTime <= compressTime + 1;
        end
      end
      BREATHE : begin
        if(breatheCount == 20) begin
          breathTime <= 0;
          compressCount <= 0;
          signal_o[0] <= 1'b0;
          signal_o[1] <= 1'b0;
          signal_o[2] <= 1'b1;
          state <= PULSE;
        end
        else begin
          signal_o[0] <= 1'b1;
          if(breathTime == secTimeLimit) begin
            breathTime <= 0;
            signal_o[0] <= 1'b0;
            compressCount <= 0;
            state <= COMPRESS;
          end
          else begin
            signal_o[1] <= 1'b0;
            breathTime <= breathTime + 1;
          end
        end
      end
      PULSE : begin
        if(pulseTimecounter == 2) begin
          pulseTimecounter <= 0;
          signal_o[2] <= 1'b0;
          state <= COMPRESS;
        end
        else begin
          signal_o[0] <= 1'b0;
          signal_o[1] <= 1'b0;
          signal_o[2] <= 1'b1;
          if(pulseTime == secTimeLimit) begin
            pulseTimecounter <= pulseTimecounter + 1;
            breatheCount <= 0;
            pulseTime <= 0;
            signal_o[0] <= 1'b0;
            signal_o[1] <= 1'b0;
          end
          else begin
            pulseTime <= pulseTime + 1;
          end
        end
      end
      default : begin
        state <= IDLE;
      end
      endcase
    end
  end

  assign breath_out = signal_o[0];
  assign compress_out = signal_o[1];
  assign pulse_out = signal_o[2];
endmodule
