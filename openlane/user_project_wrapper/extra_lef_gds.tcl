set ::env(EXTRA_LEFS) "\
	$script_dir/../../lef/wrapped_function_generator.lef \
	$script_dir/../../lef/wrapped_cpr.lef \
	$script_dir/../../lef/wrapped_instrumented_adder_behav.lef \
	$script_dir/../../lef/wrapped_instrumented_adder_sklansky.lef \
	$script_dir/../../lef/wrapped_instrumented_adder_brent.lef \
	$script_dir/../../lef/wrapped_instrumented_adder_ripple.lef \
	$script_dir/../../lef/wrapped_instrumented_adder_kogge.lef \
	$script_dir/../../lef/wrapped_wavelet_transform.lef \
	$script_dir/../../lef/wrapped_PrimitiveCalculator.lef \
	$script_dir/../../lef/wrapped_snn.lef \
	$script_dir/../../lef/wb_bridge_2way.lef \
	$script_dir/../../lef/wb_openram_wrapper.lef \
	$script_dir/../../lef/sky130_sram_1kbyte_1rw1r_32x256_8.lef "
set ::env(EXTRA_GDS_FILES) "\
	$script_dir/../../gds/wrapped_function_generator.gds \
	$script_dir/../../gds/wrapped_cpr.gds \
	$script_dir/../../gds/wrapped_instrumented_adder_behav.gds \
	$script_dir/../../gds/wrapped_instrumented_adder_sklansky.gds \
	$script_dir/../../gds/wrapped_instrumented_adder_brent.gds \
	$script_dir/../../gds/wrapped_instrumented_adder_ripple.gds \
	$script_dir/../../gds/wrapped_instrumented_adder_kogge.gds \
	$script_dir/../../gds/wrapped_wavelet_transform.gds \
	$script_dir/../../gds/wrapped_PrimitiveCalculator.gds \
	$script_dir/../../gds/wrapped_snn.gds \
	$script_dir/../../gds/wb_bridge_2way.gds \
	$script_dir/../../gds/wb_openram_wrapper.gds \
	$script_dir/../../gds/sky130_sram_1kbyte_1rw1r_32x256_8.gds "
