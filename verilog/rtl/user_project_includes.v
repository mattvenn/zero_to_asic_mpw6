// +------------+-----------------------------------+---------------------+------------------------------------------------------------+------------------------------------------+
// | project id | title                             | author              | repo                                                       | commit                                   |
// +------------+-----------------------------------+---------------------+------------------------------------------------------------+------------------------------------------+
// | 0          | Function generator                | Matt Venn           | https://github.com/mattvenn/wrapped_function_generator     | 701095fd880ad3bb80d6cec1d214a04e5676a65d |
// | 12         | CPR                               | Zorkan ERKAN        | https://github.com/zorkan/cpr                              | d0108b8b896cb1a952a98252f8ad5a516eb7cfcc |
// | 2          | instrumented adder - behavioural  | Matt Venn & Teo     | https://github.com/mattvenn/wrapped_instrumented_adder     | 3f4ecc54789723634520b3f780c8d0e9cc7ca25f |
// | 3          | instrumented adder - sklansky     | Matt Venn & Teo     | https://github.com/mattvenn/wrapped_instrumented_adder     | e03234240886bf383a795639fa367449af0d8159 |
// | 4          | instrumented adder - Brent Kung   | Matt Venn & Teo     | https://github.com/mattvenn/wrapped_instrumented_adder     | 0874228702abd86963615161a63b1eafce4bd95b |
// | 5          | instrumented adder - Ripple carry | Matt Venn & Teo     | https://github.com/mattvenn/wrapped_instrumented_adder     | 5c1bd6838e21b7be080d99ec564f89196b5177fb |
// | 6          | instrumented adder - Kogge Stone  | Matt Venn & Teo     | https://github.com/mattvenn/wrapped_instrumented_adder     | ab5f6a2cc1da5fbdb6d4a22bdfcb502147cbe2a8 |
// | 8          | Wavelet Transform                 | Gregory Kielian     | https://github.com/opensource-fr/wrapped_wavelet_transform | 28d8e5434ac8d74fbeb144382ba30574eb9f3f20 |
// | 7          | PrimitiveCalculator               | Emre Hepsag         | https://github.com/eemreeh/wrapped_PrimitiveCalculator     | cb64da0d1b9f5a622a02ee1793c288a04bf580ce |
// | 9          | snn-accelerator                   | Jason K. Eshraghian | https://github.com/jeshraghian/snn-accelerator             | aea4db644906e85577d58432e385d885566be87e |
// +------------+-----------------------------------+---------------------+------------------------------------------------------------+------------------------------------------+
`include "wrapped_function_generator/wrapper.v" // 0
`include "cpr/wrapper.v" // 12
`include "wrapped_instrumented_adder/wrapper.v" // 2
`include "wrapped_instrumented_adder_sklansky/wrapper.v" // 3
`include "wrapped_instrumented_adder_brent/wrapper.v" // 4
`include "wrapped_instrumented_adder_ripple/wrapper.v" // 5
`include "wrapped_instrumented_adder_kogge/wrapper.v" // 6
`include "wrapped_wavelet_transform/wrapper.v" // 8
`include "wrapped_PrimitiveCalculator/wrapper.v" // 7
`include "snn-accelerator/wrapper.v" // 9
// shared projects
`include "wb_bridge/src/wb_bridge_2way.v"
`include "wb_openram_wrapper/src/register_rw.v"
`include "wb_openram_wrapper/src/wb_port_control.v"
`include "wb_openram_wrapper/src/wb_openram_wrapper.v"
`include "openram_z2a/src/sky130_sram_1kbyte_1rw1r_32x256_8.v"