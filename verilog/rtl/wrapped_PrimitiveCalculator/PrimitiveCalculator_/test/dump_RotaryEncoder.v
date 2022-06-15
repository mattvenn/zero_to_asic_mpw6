module dump();
    initial begin
        $dumpfile ("RotaryEncoder.vcd");
        $dumpvars (0, RotaryEncoder);
        #1;
    end
endmodule
