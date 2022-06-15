// SPDX-FileCopyrightText: 2021 embelon
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
`timescale 1ns/1ns

module wb_bridge_2way
#(
    parameter UFP_BASE_ADDR = 32'h3000_0000,
    parameter UFP_BASE_MASK = 32'hfff0_0000,

    parameter UFP_BUSA_OFFSET = 32'h0000_0000,
    parameter UFP_BUSB_OFFSET = 32'h000f_f800,

    parameter BUSA_ADDR_WIDTH = 32,
    parameter BUSA_BASE_ADDR = 32'h3000_0000,
        
    parameter BUSB_ADDR_WIDTH = 11,
    parameter BUSB_BASE_ADDR = 32'h0000_0000
)
(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone UFP (Upward Facing Port)
    input           wb_clk_i,
    input           wb_rst_i,
    input           wbs_stb_i,
    input           wbs_cyc_i,
    input           wbs_we_i,
    input   [3:0]   wbs_sel_i,
    input   [31:0]  wbs_dat_i,
    input   [31:0]  wbs_adr_i,
    output          wbs_ack_o,
    output  [31:0]  wbs_dat_o,

    // Wishbone A (Downward Facing Port)
    output                          wbm_a_stb_o,
    output                          wbm_a_cyc_o,
    output                          wbm_a_we_o,
    output  [3:0]                   wbm_a_sel_o,
    input   [31:0]                  wbm_a_dat_i,
    output  [BUSA_ADDR_WIDTH-1:0]   wbm_a_adr_o,	
    input                           wbm_a_ack_i,
    output  [31:0]                  wbm_a_dat_o,


    // Wishbone B (Downward Facing Port)
    output                          wbm_b_stb_o,
    output                          wbm_b_cyc_o,
    output                          wbm_b_we_o,
    output  [3:0]                   wbm_b_sel_o,
    input   [31:0]                  wbm_b_dat_i,
    output  [BUSB_ADDR_WIDTH-1:0]   wbm_b_adr_o,	
    input                           wbm_b_ack_i,
    output  [31:0]                  wbm_b_dat_o

);

wire bridge_select;
assign bridge_select = (wbs_adr_i & UFP_BASE_MASK) == UFP_BASE_ADDR;

wire bus_a_or_b; // low means bus a, high is bus b
assign bus_a_or_b = (wbs_adr_i & ~UFP_BASE_MASK) >= UFP_BUSB_OFFSET;

wire bus_a_select, bus_b_select;
assign bus_a_select = bridge_select & !bus_a_or_b;
assign bus_b_select = bridge_select & bus_a_or_b;

wire [31:0] bus_a_address;
assign bus_a_address = (wbs_adr_i & ~UFP_BASE_MASK) - UFP_BUSA_OFFSET + BUSA_BASE_ADDR;
wire [31:0] bus_b_address;
assign bus_b_address = (wbs_adr_i & ~UFP_BASE_MASK) - UFP_BUSB_OFFSET + BUSB_BASE_ADDR;

// BUS A
assign wbm_a_stb_o = wbs_stb_i & bus_a_select;
assign wbm_a_cyc_o = wbs_cyc_i;
assign wbm_a_we_o = wbs_we_i & bus_a_select;
assign wbm_a_sel_o = wbs_sel_i & {4{bus_a_select}};
assign wbm_a_dat_o = wbs_dat_i & {32{bus_a_select}};

assign wbm_a_adr_o = bus_a_address[BUSA_ADDR_WIDTH-1:0];

// BUS B
assign wbm_b_stb_o = wbs_stb_i & bus_b_select;
assign wbm_b_cyc_o = wbs_cyc_i;
assign wbm_b_we_o = wbs_we_i & bus_b_select;
assign wbm_b_sel_o = wbs_sel_i & {4{bus_b_select}};
assign wbm_b_dat_o = wbs_dat_i & {32{bus_b_select}};

assign wbm_b_adr_o = bus_b_address[BUSB_ADDR_WIDTH-1:0];

// A or B -> UFP
assign wbs_ack_o = (wbm_a_ack_i & bus_a_select) | (wbm_b_ack_i & bus_b_select);
assign wbs_dat_o = (wbm_a_dat_i & {32{bus_a_select}}) | (wbm_b_dat_i & {32{bus_b_select}});

`ifdef FORMAL

    always @(*) begin
        // only one bus is active
        exclusive_bus:   assert(bus_a_select + bus_b_select <= 1);

        // bus A
        if(bus_a_select) begin
            a_dat_o:    assert(wbm_a_dat_o    == wbs_dat_i      );
            a_stb_o:    assert(wbm_a_stb_o    == wbs_stb_i      );

            a_dat_i:    assert(wbs_dat_o      == wbm_a_dat_i    );
            a_ack_i:    assert(wbm_a_ack_i    == wbs_ack_o      );
        // bus B
        end else if(bus_b_select) begin
            b_dat_o:    assert(wbm_b_dat_o    == wbs_dat_i      );
            b_stb_o:    assert(wbm_b_stb_o    == wbs_stb_i      );

            b_dat_i:    assert(wbs_dat_o      == wbm_b_dat_i    );
            b_ack_i:    assert(wbm_b_ack_i    == wbs_ack_o      );
        end
        
    end

`endif
endmodule	// wb_bridge_2way

`default_nettype wire
