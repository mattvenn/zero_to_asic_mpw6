module dump();
    initial begin
        $dumpfile ("Debouncer.vcd");
        $dumpvars (0, Debouncer);
        #1;
    end
endmodule
