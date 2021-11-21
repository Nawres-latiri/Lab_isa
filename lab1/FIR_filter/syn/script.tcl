gui_start
analyze -f vhdl -lib WORK ../src/clk_gen.vhd
analyze -f vhdl -lib WORK ../src/data_maker.vhd
analyze -f vhdl -lib WORK ../src/data_sink.vhd
analyze -f vhdl -lib WORK ../src/ADDER.vhd
analyze -f vhdl -lib WORK ../src/MULT.vhd
analyze -f vhdl -lib WORK ../src/REG.vhd
analyze -f vhdl -lib WORK ../src/MUX_4to1.vhd
analyze -f vhdl -lib WORK ../src/MUX_4to1.vhd
analyze -f vhdl -lib WORK ../src/FIR_filter.vhd

set power_preserve_rtl_hier_names true
elaborate FIR_filter -arch behavior -lib WORK > ./elaborate_max_frequency.txt
uniquify
link


create_clock -name MY_CLK -period  0 clk

set_dont_touch_network MY_CLK
set_clock_uncertainty 0.07 [get_clocks MY_CLK]

set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] CLK]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]

set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]

compile

report_timing > ./report_timing_max_frequency.txt

report_area > ./report_area_max_frequency.txt

ungroup -all -flatten

change_names -hierarchy -output ../netlist/FIR_filter.v

write_sdc ../netlist/FIR_filter.sdc
