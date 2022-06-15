module dump();
    initial begin
        $dumpfile ("ClockDivider.vcd");
        $dumpvars (0, ClockDivider);
        #1;
    end
endmodule
