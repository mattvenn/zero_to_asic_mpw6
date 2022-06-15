// SPDX-FileCopyrightText: 2021 Embelon
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0


`default_nettype none

module wb_port_control 
#(
    parameter READ_ONLY = 1,
    parameter LATENCY_CNTR_WIDTH = 4
)
(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // configuration for clock stretching
    input [LATENCY_CNTR_WIDTH-1:0] prefetch_cycles,
    input [LATENCY_CNTR_WIDTH-1:0] read_cycles,

    // Wishbone port A
    input           		wb_clk_i,
    input           		wb_rst_i,
    input           		wbs_stb_i,
    input           		wbs_cyc_i,
    input           		wbs_we_i,
    output          		wbs_ack_o,
    output [31:0]           wbs_dat_o,

    // OpenRAM interface: RW
    output                  ram_clk,       // stretched clock
    output          		ram_csb,       // active low chip select
    output          		ram_web,       // active low write control
    input  [31:0]           ram_dout
);

// FSM
parameter S_IDLE = 0, S_ACTIVATE = 1, S_PREFETCH = 2, S_READWRITE = 3, S_ACK = 4;
reg [2:0] state_r;

reg [LATENCY_CNTR_WIDTH-1:0] cycle_r;
reg int_clk_r;
reg [31:0] dout_r;

always @(negedge wb_clk_i) begin
	if (wb_rst_i) begin
        state_r <= S_IDLE;
        cycle_r <= 0;
        int_clk_r <= 0;
        dout_r <= 0;
    end else begin
        case (state_r)
			S_IDLE: begin	
                if (wbs_stb_i && wbs_cyc_i) begin
                    if (wbs_we_i && READ_ONLY) begin
                        state_r <= S_ACK;
                    end else begin
                        state_r <= S_ACTIVATE;
                    end
                end
            end
            S_ACTIVATE: begin
                state_r <= S_PREFETCH;
                cycle_r <= prefetch_cycles;
                int_clk_r <= 1;
            end
            S_PREFETCH: begin
                if (cycle_r) begin
                    cycle_r <= cycle_r - 1;
                end else begin
                    state_r <= S_READWRITE;
                    cycle_r <= read_cycles;
                    int_clk_r <= 0;
                end
            end
            S_READWRITE: begin
                if (cycle_r) begin
                    cycle_r <= cycle_r - 1;
                end else begin
                    dout_r <= ram_dout;
                    state_r <= S_ACK;                    
                end
            end
            S_ACK: begin
                if ((wbs_stb_i && wbs_cyc_i) == 0) begin
                    state_r <= S_IDLE;
                end
            end
        endcase
    end
end

// drive CS on rising edges
reg csb_r;

always @(posedge wb_clk_i) begin
    if (wb_rst_i) begin
        csb_r <= 1;
    end else begin
        case (state_r)
            S_ACTIVATE: begin
                csb_r <= 0;
            end
            S_ACK: begin
                csb_r <= 1;
            end
        endcase
    end
end

assign wbs_dat_o = ((state_r == S_ACK) && wbs_stb_i && wbs_cyc_i) ? dout_r : 32'h0;
assign wbs_ack_o = (state_r == S_ACK) && wbs_stb_i && wbs_cyc_i;

assign ram_clk = (state_r == S_IDLE) ? wb_clk_i : int_clk_r;
assign ram_csb = csb_r;
assign ram_web = !wbs_we_i || READ_ONLY;

endmodule	// wb_port_control

`default_nettype wire
