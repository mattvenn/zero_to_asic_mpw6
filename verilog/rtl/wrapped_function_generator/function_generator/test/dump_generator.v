module dump();
    initial begin
        $dumpfile ("generator.vcd");
        $dumpvars (0, generator);
        #1;
    end
endmodule
