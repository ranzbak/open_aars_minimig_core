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

create_pblock pblock_dv_ddr_send
resize_pblock [get_pblocks pblock_dv_ddr_send] -add {CLOCKREGION_X0Y1:CLOCKREGION_X0Y1}
add_cells_to_pblock [get_pblocks pblock_dv_ddr_send] [get_cells -quiet [list dv_ddr_send]]

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
connect_debug_port u_ila_0/probe0 [get_nets [list {my_pal_to_ddr/myupsample/r_cur_read_buf[0]} {my_pal_to_ddr/myupsample/r_cur_read_buf[1]}]]
connect_debug_port u_ila_0/probe3 [get_nets [list {my_pal_to_ddr/myupsample/r_cur_write_buf[0]} {my_pal_to_ddr/myupsample/r_cur_write_buf[1]}]]


create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 2 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk200m_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 8 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {my_pal_to_ddr/__i_pal_g[0]} {my_pal_to_ddr/__i_pal_g[1]} {my_pal_to_ddr/__i_pal_g[2]} {my_pal_to_ddr/__i_pal_g[3]} {my_pal_to_ddr/__i_pal_g[4]} {my_pal_to_ddr/__i_pal_g[5]} {my_pal_to_ddr/__i_pal_g[6]} {my_pal_to_ddr/__i_pal_g[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 8 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {my_pal_to_ddr/__i_pal_b[0]} {my_pal_to_ddr/__i_pal_b[1]} {my_pal_to_ddr/__i_pal_b[2]} {my_pal_to_ddr/__i_pal_b[3]} {my_pal_to_ddr/__i_pal_b[4]} {my_pal_to_ddr/__i_pal_b[5]} {my_pal_to_ddr/__i_pal_b[6]} {my_pal_to_ddr/__i_pal_b[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 8 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {my_pal_to_ddr/myupsample/r_hd_r[0]} {my_pal_to_ddr/myupsample/r_hd_r[1]} {my_pal_to_ddr/myupsample/r_hd_r[2]} {my_pal_to_ddr/myupsample/r_hd_r[3]} {my_pal_to_ddr/myupsample/r_hd_r[4]} {my_pal_to_ddr/myupsample/r_hd_r[5]} {my_pal_to_ddr/myupsample/r_hd_r[6]} {my_pal_to_ddr/myupsample/r_hd_r[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 14 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {my_pal_to_ddr/myupsample/v_div_var[0]} {my_pal_to_ddr/myupsample/v_div_var[1]} {my_pal_to_ddr/myupsample/v_div_var[2]} {my_pal_to_ddr/myupsample/v_div_var[3]} {my_pal_to_ddr/myupsample/v_div_var[4]} {my_pal_to_ddr/myupsample/v_div_var[5]} {my_pal_to_ddr/myupsample/v_div_var[6]} {my_pal_to_ddr/myupsample/v_div_var[7]} {my_pal_to_ddr/myupsample/v_div_var[8]} {my_pal_to_ddr/myupsample/v_div_var[9]} {my_pal_to_ddr/myupsample/v_div_var[10]} {my_pal_to_ddr/myupsample/v_div_var[11]} {my_pal_to_ddr/myupsample/v_div_var[12]} {my_pal_to_ddr/myupsample/v_div_var[13]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 13 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {my_pal_to_ddr/myupsample/r_addra[0]} {my_pal_to_ddr/myupsample/r_addra[1]} {my_pal_to_ddr/myupsample/r_addra[2]} {my_pal_to_ddr/myupsample/r_addra[3]} {my_pal_to_ddr/myupsample/r_addra[4]} {my_pal_to_ddr/myupsample/r_addra[5]} {my_pal_to_ddr/myupsample/r_addra[6]} {my_pal_to_ddr/myupsample/r_addra[7]} {my_pal_to_ddr/myupsample/r_addra[8]} {my_pal_to_ddr/myupsample/r_addra[9]} {my_pal_to_ddr/myupsample/r_addra[10]} {my_pal_to_ddr/myupsample/r_addra[11]} {my_pal_to_ddr/myupsample/r_addra[12]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 13 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {my_pal_to_ddr/myupsample/r_addrb[0]} {my_pal_to_ddr/myupsample/r_addrb[1]} {my_pal_to_ddr/myupsample/r_addrb[2]} {my_pal_to_ddr/myupsample/r_addrb[3]} {my_pal_to_ddr/myupsample/r_addrb[4]} {my_pal_to_ddr/myupsample/r_addrb[5]} {my_pal_to_ddr/myupsample/r_addrb[6]} {my_pal_to_ddr/myupsample/r_addrb[7]} {my_pal_to_ddr/myupsample/r_addrb[8]} {my_pal_to_ddr/myupsample/r_addrb[9]} {my_pal_to_ddr/myupsample/r_addrb[10]} {my_pal_to_ddr/myupsample/r_addrb[11]} {my_pal_to_ddr/myupsample/r_addrb[12]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 8 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {my_pal_to_ddr/myupsample/r_hd_b[0]} {my_pal_to_ddr/myupsample/r_hd_b[1]} {my_pal_to_ddr/myupsample/r_hd_b[2]} {my_pal_to_ddr/myupsample/r_hd_b[3]} {my_pal_to_ddr/myupsample/r_hd_b[4]} {my_pal_to_ddr/myupsample/r_hd_b[5]} {my_pal_to_ddr/myupsample/r_hd_b[6]} {my_pal_to_ddr/myupsample/r_hd_b[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 8 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {my_pal_to_ddr/myupsample/r_hd_g[0]} {my_pal_to_ddr/myupsample/r_hd_g[1]} {my_pal_to_ddr/myupsample/r_hd_g[2]} {my_pal_to_ddr/myupsample/r_hd_g[3]} {my_pal_to_ddr/myupsample/r_hd_g[4]} {my_pal_to_ddr/myupsample/r_hd_g[5]} {my_pal_to_ddr/myupsample/r_hd_g[6]} {my_pal_to_ddr/myupsample/r_hd_g[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 8 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {my_pal_to_ddr/__i_pal_r[0]} {my_pal_to_ddr/__i_pal_r[1]} {my_pal_to_ddr/__i_pal_r[2]} {my_pal_to_ddr/__i_pal_r[3]} {my_pal_to_ddr/__i_pal_r[4]} {my_pal_to_ddr/__i_pal_r[5]} {my_pal_to_ddr/__i_pal_r[6]} {my_pal_to_ddr/__i_pal_r[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list my_pal_to_ddr/__i_pal_hsync]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list my_pal_to_ddr/__i_pal_vsync]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list my_pal_to_ddr/myupsample/r_next_buf]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list my_pal_to_ddr/myupsample/r_pix_en]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk200m_BUFG]
