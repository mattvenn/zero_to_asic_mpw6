module dump();
    initial begin
        $dumpfile ("PrimitiveCalculator.vcd");
        $dumpvars (0, PrimitiveCalculator);
        #1;
    end
endmodule
