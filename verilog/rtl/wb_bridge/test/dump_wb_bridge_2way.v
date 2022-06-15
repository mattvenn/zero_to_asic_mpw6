module dump();
	initial begin
		$dumpfile ("wb_bridge_2way.vcd");
		$dumpvars (0, wb_bridge_2way);
		#1;
	end
endmodule
