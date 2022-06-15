module dump();
    initial begin
        $dumpfile ("cpr.vcd");
        $dumpvars (0, cpr);
        #1;
    end
endmodule
