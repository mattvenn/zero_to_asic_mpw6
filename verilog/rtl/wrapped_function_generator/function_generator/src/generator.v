`default_nettype none
`timescale 1ns/1ns

module generator #(
    parameter   [31:0]  BASE_ADDRESS    = 32'h3000_0000,        // base address
    /*

    DATA PARTITION  NAME            DESCRIPTION
    15:0            period          clock cycles between putting next data on the output
    23:16           ram_end_addr    where to start reading the data in the shared RAM
    24              run             if high, set the design running

    */
    parameter   [15:0]  PERIOD          = 16'd8,                 // default period
    parameter   [7:0]   RAM_END_ADDR  = 8'd0                  // default start address in RAM to read pattern
)(
    // CaravelBus peripheral ports
    input wire          caravel_wb_clk_i,       // clock, runs at system clock
    input wire          caravel_wb_rst_i,       // main system reset
    input wire          caravel_wb_stb_i,       // write strobe
    input wire          caravel_wb_cyc_i,       // cycle
    input wire          caravel_wb_we_i,        // write enable
    input wire  [3:0]   caravel_wb_sel_i,       // write word select
    input wire  [31:0]  caravel_wb_dat_i,       // data in
    input wire  [31:0]  caravel_wb_adr_i,       // address
    output reg          caravel_wb_ack_o,       // ack
    output reg  [31:0]  caravel_wb_dat_o,       // data out

    // RAMBus controller ports
    output wire         rambus_wb_clk_o,        // clock, must run at system clock
    output wire         rambus_wb_rst_o,        // reset
    output reg          rambus_wb_stb_o,        // write strobe
    output reg          rambus_wb_cyc_o,        // cycle
    output reg          rambus_wb_we_o,         // write enable
    output reg  [3:0]   rambus_wb_sel_o,        // write word select
    output reg  [31:0]  rambus_wb_dat_o,        // data out
    output reg  [7:0]   rambus_wb_adr_o,        // address
    input wire          rambus_wb_ack_i,        // ack
    input wire  [31:0]  rambus_wb_dat_i,        // data in

    // output for driving DAC
    output reg [7:0]    dac,

    // debug outputs
    output wire         dbg_ram_addr_zero,
    output wire         dbg_state_run,
    output wire         dbg_dac_start,
    output wire         dbg_ram_wb_stb,
    output wire         dbg_caravel_wb_stb
);

    // rename some signals
    wire clk = caravel_wb_clk_i;
    assign rambus_wb_clk_o = clk;
    wire reset = caravel_wb_rst_i;
    // assign rambus_wb_rst_o = reset;

    // debug outputs
    assign dbg_ram_addr_zero = ram_address == 0;
    assign dbg_state_run = run;
    assign dbg_dac_start = dbg_dac_start_q;
    assign dbg_ram_wb_stb = rambus_wb_stb_o;
    assign dbg_caravel_wb_stb = caravel_wb_stb_i;
    reg dbg_dac_start_q;
    always @(posedge clk)
        dbg_dac_start_q = dac_state == DAC_STATE_UPDATE;


    // CaravelBus registers
    reg [15:0] period;
    reg [7:0] ram_end_addr;
    reg run;

    // CaravelBus writes
    always @(posedge clk) begin
        if(reset) begin
            period          <= PERIOD;
            ram_end_addr    <= RAM_END_ADDR;
            run             <= 1'b0;
        end
        else if(caravel_wb_stb_i && caravel_wb_cyc_i && caravel_wb_we_i && caravel_wb_adr_i == BASE_ADDRESS) begin
            period          <= caravel_wb_dat_i[15:0];
            ram_end_addr    <= caravel_wb_dat_i[23:16];
            run             <= caravel_wb_dat_i[24];
        end
    end

    // CaravelBus reads
    always @(posedge clk) begin
        if(reset)
            caravel_wb_dat_o <= 0;
        else if(caravel_wb_stb_i && caravel_wb_cyc_i && !caravel_wb_we_i && caravel_wb_adr_i == BASE_ADDRESS) begin
            caravel_wb_dat_o <= { 7'b0, run, ram_end_addr, period };
        end
    end

    // CaravelBus acks
    always @(posedge clk) begin
        if(reset)
            caravel_wb_ack_o <= 0;
        else
            // return ack immediately
            caravel_wb_ack_o <= (caravel_wb_stb_i && caravel_wb_adr_i == BASE_ADDRESS);
    end

    // FSM states for DAC
    localparam DAC_STATE_STOP           = 0;
    localparam DAC_STATE_UPDATE         = 1;
    localparam DAC_STATE_WAIT           = 2;

    // FSM states for RAM
    localparam RAM_STATE_INIT           = 0;
    localparam RAM_STATE_WAIT           = 1;
    localparam RAM_STATE_ACK            = 2;

    // DAC state registers
    reg [2:0]   dac_state;
    reg [31:0]  dac_data;
    reg [31:0]  dac_data_buf;
    reg [15:0]  wait_period;

    reg [2:0]   ram_state;
    reg [7:0]   ram_address;

    reg         fetch_next;
    reg         fetch_first;

    reg [1:0]   byte_count;

    always @(posedge clk) begin
        if(reset) begin
            dac                 <= 0;
            dac_state           <= DAC_STATE_STOP;
            dac_data            <= 0;
            dac_data_buf        <= 0;
            wait_period         <= period;
            fetch_next          <= 0;
            fetch_first         <= 1;
            byte_count          <= 0;

            ram_address         <= 0;
            ram_state           <= RAM_STATE_INIT;
            rambus_wb_adr_o     <= 0;
            rambus_wb_stb_o     <= 0;
            rambus_wb_cyc_o     <= 0;
            rambus_wb_dat_o     <= 0;
            rambus_wb_sel_o     <= 4'b1111;
            rambus_wb_we_o      <= 0;

        end else begin

            // FSM for managing DAC output
            case(dac_state)
                DAC_STATE_STOP: begin
                    if(run)
                        dac_state       <= DAC_STATE_UPDATE;
                    end

                DAC_STATE_UPDATE: begin
                    dac             <= dac_data_buf[7:0];
                    byte_count      <= byte_count + 1;
                    dac_data_buf    <= (dac_data_buf >> 8);
                    dac_state       <= DAC_STATE_WAIT;
                    wait_period     <= period - 1;
                    if(byte_count == 1) // fetch data
                        fetch_next  <= 1;
                    end

                DAC_STATE_WAIT: begin
                    wait_period     <= wait_period - 1'b1;
                    fetch_next      <= 0;
                    if(wait_period == 1)
                        dac_state   <= DAC_STATE_UPDATE;
                    end

                default:
                    dac_state <= DAC_STATE_STOP;

            endcase

            // FSM for fetching next word over RAMBus
            case(ram_state)
		RAM_STATE_INIT: begin
		    if (ram_address & 8'h08) begin
		    	    ram_address <= 0;
		    	    ram_state <= RAM_STATE_WAIT;
		    	end else begin
		    	    ram_address <= ram_address + 1;
			end
		    end
                RAM_STATE_WAIT: begin
                    if(fetch_next || fetch_first) begin
                        ram_state           <= RAM_STATE_ACK;
                        rambus_wb_adr_o     <= ram_address;
                        ram_address         <= ram_address + 1;

                        rambus_wb_cyc_o     <= 1;
                        rambus_wb_stb_o     <= 1;

                        // wrap around at end address
                        if(ram_address == ram_end_addr - 1)
                            ram_address     <= 0;
                        end

                        fetch_first <= 0;

                    end

                RAM_STATE_ACK: begin
                    if(rambus_wb_ack_i) begin
                        rambus_wb_cyc_o     <= 0;
                        rambus_wb_stb_o     <= 0;
                        dac_data            <= rambus_wb_dat_i;
                        dac_data_buf        <= dac_data;
                        ram_state           <= RAM_STATE_WAIT;
                        end
                    end

                default:
                    ram_state <= RAM_STATE_WAIT;
            endcase
        end
    end

    assign rambus_wb_rst_o = reset || (ram_state == RAM_STATE_INIT);

    `ifdef FORMAL
    reg formal_init = 0;
    always @(posedge clk) begin
        formal_init <= 1;
        assume(reset == !formal_init);
        if(!reset && formal_init) begin
            assert(ram_state == RAM_STATE_INIT || ram_state == RAM_STATE_WAIT || ram_state == RAM_STATE_ACK);
            assert(dac_state == DAC_STATE_STOP || dac_state == DAC_STATE_UPDATE || dac_state == DAC_STATE_WAIT);

            // fix this - should probably only start reading from ram if an address is actually set via wishbone
            // assert(ram_address < ram_end_addr);
        end
    end
    `endif

endmodule
