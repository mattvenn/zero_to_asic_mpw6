// SPDX-FileCopyrightText: 2020 Efabless Corporation
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

`timescale 1 ns / 1 ps

// change module name to something that suits your project
module PrimitiveCalculator_tb;
    initial begin
        // change to suit your project
        $dumpfile ("PrimitiveCalculator.vcd");
        $dumpvars (0, PrimitiveCalculator_tb);
        #1;
    end

    reg clk;
    reg RSTB;
    reg power1, power2;
    reg power3, power4;

    wire gpio;
    wire [37:0] mprj_io;

    ///// convenience signals that match what the cocotb test modules are looking for
    // change to suit your project. Here's how we can make some nicer named signals for inputs & outputs



    wire sync = mprj_io[21];

    wire [6:0] seven_segment_out = mprj_io[18:12];
    wire seven_segment_digit = mprj_io[19];
    wire led_flag = mprj_io[20];    

    wire select, restart, rotary_a, rotary_b;

    assign mprj_io[ 8] = select;
    assign mprj_io[ 9] = restart;
    assign mprj_io[10] = rotary_a;
    assign mprj_io[11] = rotary_b;


    /////
    

    wire flash_csb;
    wire flash_clk;
    wire flash_io0;
    wire flash_io1;

    wire VDD3V3 = power1;
    wire VDD1V8 = power2;
    wire USER_VDD3V3 = power3;
    wire USER_VDD1V8 = power4;
    wire VSS = 1'b0;

    caravel uut (
        .vddio    (VDD3V3),
        .vssio    (VSS),
        .vdda     (VDD3V3),
        .vssa     (VSS),
        .vccd     (VDD1V8),
        .vssd     (VSS),
        .vdda1    (USER_VDD3V3),
        .vdda2    (USER_VDD3V3),
        .vssa1    (VSS),
        .vssa2    (VSS),
        .vccd1    (USER_VDD1V8),
        .vccd2    (USER_VDD1V8),
        .vssd1    (VSS),
        .vssd2    (VSS),
        .clock    (clk),
        .gpio     (gpio),
        .mprj_io  (mprj_io),
        .flash_csb(flash_csb),
        .flash_clk(flash_clk),
        .flash_io0(flash_io0),
        .flash_io1(flash_io1),
        .resetb   (RSTB)
    );

    spiflash #(
        // change the hex file to match your project
        .FILENAME("PrimitiveCalculator.hex")
    ) spiflash (
        .csb(flash_csb),
        .clk(flash_clk),
        .io0(flash_io0),
        .io1(flash_io1),
        .io2(),         // not used
        .io3()          // not used
    );

endmodule
`default_nettype wire
