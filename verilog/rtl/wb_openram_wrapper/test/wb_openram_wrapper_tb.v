`default_nettype none
`timescale 1ps/1ps

`include "sky130_sram_1kbyte_1rw1r_32x256_8.v"
//`include "wb_openram_wrapper.v"

module wb_openram_wrapper_tb (

    // Select writable WB port
    input           		writable_port_req,

    // Wishbone port A
    input           		wb_a_clk_i,
    input           		wb_a_rst_i,
    input           		wbs_a_stb_i,
    input           		wbs_a_cyc_i,
    input           		wbs_a_we_i,
    input   [3:0]   		wbs_a_sel_i,
    input   [31:0]  		wbs_a_dat_i,
    input   [10:0]          wbs_a_adr_i,
    output          		wbs_a_ack_o,
    output  [31:0]  		wbs_a_dat_o,

    // Wishbone port B
    input           		wb_b_clk_i,
    input           		wb_b_rst_i,
    input           		wbs_b_stb_i,
    input           		wbs_b_cyc_i,
    input           		wbs_b_we_i,
    input   [3:0]   		wbs_b_sel_i,
    input   [31:0]  		wbs_b_dat_i,
    input   [9:0] 	        wbs_b_adr_i,
    output          		wbs_b_ack_o,
    output  [31:0]  		wbs_b_dat_o
);

    initial begin
        $dumpfile ("wb_openram_wrapper.vcd");
        $dumpvars (0, wb_openram_wrapper_tb);
        #1;
    end

    // Signals connecting OpenRAM with its wrapper
    wire openram_clk0;
    wire openram_csb0;
    wire openram_web0;
    wire [3:0] openram_wmask0;
    wire [7:0] openram_addr0;
    wire [31:0] openram_din0;
    wire [31:0] openram_dout0;
    wire openram_clk1;
    wire openram_csb1;
    wire [7:0] openram_addr1;
    wire [31:0] openram_dout1;

    sky130_sram_1kbyte_1rw1r_32x256_8 openram_1kB
    (
        .clk0 (openram_clk0),
        .csb0 (openram_csb0),
        .web0 (openram_web0),
        .wmask0 (openram_wmask0),
        .addr0 (openram_addr0),
        .din0 (openram_din0),
        .dout0 (openram_dout0),

        .clk1 (openram_clk1),
        .csb1 (openram_csb1),
        .addr1 (openram_addr1),
        .dout1 (openram_dout1)
    );

    wb_openram_wrapper wb_openram_wrapper
    (
        .writable_port_req  (writable_port_req),

        // Wishbone port A
        .wb_a_clk_i     (wb_a_clk_i),
        .wb_a_rst_i     (wb_a_rst_i),
        .wbs_a_stb_i    (wbs_a_stb_i),
        .wbs_a_cyc_i    (wbs_a_cyc_i),
        .wbs_a_we_i     (wbs_a_we_i),
        .wbs_a_sel_i    (wbs_a_sel_i),
        .wbs_a_dat_i    (wbs_a_dat_i),
        .wbs_a_adr_i    (wbs_a_adr_i),
        .wbs_a_ack_o    (wbs_a_ack_o),
        .wbs_a_dat_o    (wbs_a_dat_o),

        // Wishbone port B
        .wb_b_clk_i     (wb_b_clk_i),
        .wb_b_rst_i     (wb_b_rst_i),
        .wbs_b_stb_i    (wbs_b_stb_i),
        .wbs_b_cyc_i    (wbs_b_cyc_i),
        .wbs_b_we_i     (wbs_b_we_i),
        .wbs_b_sel_i    (wbs_b_sel_i),
        .wbs_b_dat_i    (wbs_b_dat_i),
        .wbs_b_adr_i    (wbs_b_adr_i),
        .wbs_b_ack_o    (wbs_b_ack_o),
        .wbs_b_dat_o    (wbs_b_dat_o),

        // OpenRAM interface
        // Port 0: RW
        .ram_clk0       (openram_clk0),         // clock
        .ram_csb0       (openram_csb0),         // active low chip select
        .ram_web0       (openram_web0),         // active low write control
        .ram_wmask0     (openram_wmask0),       // write mask
        .ram_addr0      (openram_addr0),
        .ram_din0       (openram_din0),
        .ram_dout0      (openram_dout0),

        // Port 1: R
        .ram_clk1       (openram_clk1),         // clock
        .ram_csb1       (openram_csb1),         // active low chip select
        .ram_addr1      (openram_addr1),
        .ram_dout1      (openram_dout1)   
    );

endmodule
