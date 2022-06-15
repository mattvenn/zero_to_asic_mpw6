module dump();
    initial begin
        $dumpfile ("PrimitiveALU.vcd");
        $dumpvars (0, PrimitiveALU);
        #1;
    end
endmodule
