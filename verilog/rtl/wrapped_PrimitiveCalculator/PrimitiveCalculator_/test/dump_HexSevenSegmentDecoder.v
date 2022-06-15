module dump();
    initial begin
        $dumpfile ("HexSevenSegmentDecoder.vcd");
        $dumpvars (0, HexSevenSegmentDecoder);
        #1;
    end
endmodule
