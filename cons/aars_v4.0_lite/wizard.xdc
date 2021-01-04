# Clock groups
set_clock_groups -name internat_external_clocks -asynchronous -group [get_clocks [list clk_50mhz [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] [get_clocks -of_objects [get_pins clk_main/CLKOUT1]] [get_clocks -of_objects [get_pins clk_main/CLKOUT2]] [get_clocks -of_objects [get_pins clk_sdram/CLKFBOUT]] [get_clocks -of_objects [get_pins clk_main/CLKFBOUT]] [get_clocks -of_objects [get_pins clk_sdram/CLKOUT0]]]] -group [get_clocks {VIRTUAL_ADV_clk VIRTUAL_ADV_clk28m VIRTUAL_DDR_clk}]

# Intra clock paths
set_multicycle_path -setup -from [get_clocks -of_objects [get_pins clk_main/CLKOUT1]] -to [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] 8
set_multicycle_path -hold -from [get_clocks -of_objects [get_pins clk_main/CLKOUT1]] -to [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] 7
set_multicycle_path -setup -from [get_clocks -of_objects [get_pins clk_main/CLKOUT1]] -to [get_clocks -of_objects [get_pins clk_main/CLKOUT2]] 4
set_multicycle_path -hold -from [get_clocks -of_objects [get_pins clk_main/CLKOUT1]] -to [get_clocks -of_objects [get_pins clk_main/CLKOUT2]] 3
set_multicycle_path -setup -from [get_clocks -of_objects [get_pins clk_main/CLKOUT2]] -to [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] 4
set_multicycle_path -hold -from [get_clocks -of_objects [get_pins clk_main/CLKOUT2]] -to [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] 3
set_multicycle_path -setup -start -from [get_clocks -of_objects [get_pins clk_main/CLKOUT2]] -to [get_clocks -of_objects [get_pins clk_main/CLKOUT1]] 4
set_multicycle_path -hold -start -from [get_clocks -of_objects [get_pins clk_main/CLKOUT2]] -to [get_clocks -of_objects [get_pins clk_main/CLKOUT1]] 3
set_multicycle_path -setup -start -from [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] -to [get_clocks -of_objects [get_pins clk_main/CLKOUT1]] 8
set_multicycle_path -hold -start -from [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] -to [get_clocks -of_objects [get_pins clk_main/CLKOUT1]] 7
set_multicycle_path -setup -start -from [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] -to [get_clocks -of_objects [get_pins clk_main/CLKOUT2]] 4
set_multicycle_path -hold -start -from [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] -to [get_clocks -of_objects [get_pins clk_main/CLKOUT2]] 3

# Clock paths in clk (112MHz)
set _xlnx_shared_i0 [get_nets -hierarchical -regexp .*(DPO|mulu_reg|use_base|PC|wbmemmask|regfile_reg).*]
set_multicycle_path -setup -start -from [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] -through $_xlnx_shared_i0 -to [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] 4
set_multicycle_path -hold -start -from [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] -through $_xlnx_shared_i0 -to [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] 3

set _xlnx_shared_i1 [get_nets -hierarchical -regexp .*(oddout_reg|opcode|trap|memory_config_reg|state|enable|SPO|Reset_reg|Flags|memaddr_delta).*]
set_multicycle_path -setup -start -from [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] -through $_xlnx_shared_i1 -to [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] 4
set_multicycle_path -hold -start -from [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] -through $_xlnx_shared_i1 -to [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] 3

set _xlnx_shared_i2 [get_nets -hierarchical -regexp .*(exec).*]
set_multicycle_path -setup -start -from [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] -through $_xlnx_shared_i2 -to [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] 4
set_multicycle_path -hold -start -from [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] -through $_xlnx_shared_i2 -to [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] 3

# set_false_path -from [get_pins -hierarchical -regexp {.*joy(a|b)_reg\[.*\].*}] -to [get_pins -hierarchical -regexp {.*myFampiga/MyMinimig/USERIO1/_sjoy1_reg\[.*\].*}]

create_pblock pblock_1
add_cells_to_pblock [get_pblocks pblock_1] [get_cells -quiet [list myFampiga/mysdram]]
resize_pblock [get_pblocks pblock_1] -add {CLOCKREGION_X1Y1:CLOCKREGION_X1Y1}

set_input_delay -clock [get_clocks VIRTUAL_ADV_clk] -min -add_delay -5.000 [get_ports {sd_m_d[*]}]
set_input_delay -clock [get_clocks VIRTUAL_ADV_clk] -max -add_delay 5.000 [get_ports {sd_m_d[*]}]
set_output_delay -clock [get_clocks VIRTUAL_ADV_clk] -min -add_delay -5.000 [get_ports {sd_m_d[*]}]
set_output_delay -clock [get_clocks VIRTUAL_ADV_clk] -max -add_delay 5.000 [get_ports {sd_m_d[*]}]
set_output_delay -clock [get_clocks VIRTUAL_ADV_clk] -min -add_delay -5.000 [get_ports sd_m_clk]
set_output_delay -clock [get_clocks VIRTUAL_ADV_clk] -max -add_delay 5.000 [get_ports sd_m_clk]
set_output_delay -clock [get_clocks VIRTUAL_ADV_clk] -min -add_delay -5.000 [get_ports sd_m_cmd]
set_output_delay -clock [get_clocks VIRTUAL_ADV_clk] -max -add_delay 5.000 [get_ports sd_m_cmd]


set_multicycle_path -setup -from [get_clocks -of_objects [get_pins clk_main/CLKOUT2]] -to [get_clocks -of_objects [get_pins clk_sdram/CLKOUT0]] 2
set_multicycle_path -hold -from [get_clocks -of_objects [get_pins clk_main/CLKOUT2]] -to [get_clocks -of_objects [get_pins clk_sdram/CLKOUT0]] 1


set_max_delay -from [get_pins -hierarchical -regexp {.*my_pal_to_ddr/_i_pal.*_reg.*/C$.*}] -to [get_pins -hierarchical -regexp {.*my_pal_to_ddr/__i_pal_.*_reg.*/D$.*}] 1.500
