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
add_cells_to_pblock [get_pblocks pblock_dv_ddr_send] [get_cells -quiet [list dv_ddr_send]]
resize_pblock [get_pblocks pblock_dv_ddr_send] -add {CLOCKREGION_X0Y1:CLOCKREGION_X0Y1}

set_input_delay -clock [get_clocks VIRTUAL_ADV_clk] -min -add_delay -5.000 [get_ports {sd_m_d[*]}]
set_input_delay -clock [get_clocks VIRTUAL_ADV_clk] -max -add_delay 5.000 [get_ports {sd_m_d[*]}]
set_output_delay -clock [get_clocks VIRTUAL_ADV_clk] -min -add_delay -5.000 [get_ports {sd_m_d[*]}]
set_output_delay -clock [get_clocks VIRTUAL_ADV_clk] -max -add_delay 5.000 [get_ports {sd_m_d[*]}]
set_output_delay -clock [get_clocks VIRTUAL_ADV_clk] -min -add_delay -5.000 [get_ports sd_m_clk]
set_output_delay -clock [get_clocks VIRTUAL_ADV_clk] -max -add_delay 5.000 [get_ports sd_m_clk]
set_output_delay -clock [get_clocks VIRTUAL_ADV_clk] -min -add_delay -5.000 [get_ports sd_m_cmd]
set_output_delay -clock [get_clocks VIRTUAL_ADV_clk] -max -add_delay 5.000 [get_ports sd_m_cmd]











create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 13 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {myFampiga/mysdram/sdaddr[0]} {myFampiga/mysdram/sdaddr[1]} {myFampiga/mysdram/sdaddr[2]} {myFampiga/mysdram/sdaddr[3]} {myFampiga/mysdram/sdaddr[4]} {myFampiga/mysdram/sdaddr[5]} {myFampiga/mysdram/sdaddr[6]} {myFampiga/mysdram/sdaddr[7]} {myFampiga/mysdram/sdaddr[8]} {myFampiga/mysdram/sdaddr[9]} {myFampiga/mysdram/sdaddr[10]} {myFampiga/mysdram/sdaddr[11]} {myFampiga/mysdram/sdaddr[12]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 3 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {myFampiga/mysdram/slot1_type[0]} {myFampiga/mysdram/slot1_type[1]} {myFampiga/mysdram/slot1_type[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 16 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {myFampiga/mysdram/sdata_reg[0]} {myFampiga/mysdram/sdata_reg[1]} {myFampiga/mysdram/sdata_reg[2]} {myFampiga/mysdram/sdata_reg[3]} {myFampiga/mysdram/sdata_reg[4]} {myFampiga/mysdram/sdata_reg[5]} {myFampiga/mysdram/sdata_reg[6]} {myFampiga/mysdram/sdata_reg[7]} {myFampiga/mysdram/sdata_reg[8]} {myFampiga/mysdram/sdata_reg[9]} {myFampiga/mysdram/sdata_reg[10]} {myFampiga/mysdram/sdata_reg[11]} {myFampiga/mysdram/sdata_reg[12]} {myFampiga/mysdram/sdata_reg[13]} {myFampiga/mysdram/sdata_reg[14]} {myFampiga/mysdram/sdata_reg[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 4 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {myFampiga/mysdram/sdram_state[0]} {myFampiga/mysdram/sdram_state[1]} {myFampiga/mysdram/sdram_state[2]} {myFampiga/mysdram/sdram_state[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 16 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {myFampiga/hostWR[0]} {myFampiga/hostWR[1]} {myFampiga/hostWR[2]} {myFampiga/hostWR[3]} {myFampiga/hostWR[4]} {myFampiga/hostWR[5]} {myFampiga/hostWR[6]} {myFampiga/hostWR[7]} {myFampiga/hostWR[8]} {myFampiga/hostWR[9]} {myFampiga/hostWR[10]} {myFampiga/hostWR[11]} {myFampiga/hostWR[12]} {myFampiga/hostWR[13]} {myFampiga/hostWR[14]} {myFampiga/hostWR[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 16 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {myFampiga/hostData[0]} {myFampiga/hostData[1]} {myFampiga/hostData[2]} {myFampiga/hostData[3]} {myFampiga/hostData[4]} {myFampiga/hostData[5]} {myFampiga/hostData[6]} {myFampiga/hostData[7]} {myFampiga/hostData[8]} {myFampiga/hostData[9]} {myFampiga/hostData[10]} {myFampiga/hostData[11]} {myFampiga/hostData[12]} {myFampiga/hostData[13]} {myFampiga/hostData[14]} {myFampiga/hostData[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 3 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {myFampiga/hostState[0]} {myFampiga/hostState[1]} {myFampiga/hostState[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 16 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {myFampiga/hostRD[0]} {myFampiga/hostRD[1]} {myFampiga/hostRD[2]} {myFampiga/hostRD[3]} {myFampiga/hostRD[4]} {myFampiga/hostRD[5]} {myFampiga/hostRD[6]} {myFampiga/hostRD[7]} {myFampiga/hostRD[8]} {myFampiga/hostRD[9]} {myFampiga/hostRD[10]} {myFampiga/hostRD[11]} {myFampiga/hostRD[12]} {myFampiga/hostRD[13]} {myFampiga/hostRD[14]} {myFampiga/hostRD[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 24 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {myFampiga/hostAddr[0]} {myFampiga/hostAddr[1]} {myFampiga/hostAddr[2]} {myFampiga/hostAddr[3]} {myFampiga/hostAddr[4]} {myFampiga/hostAddr[5]} {myFampiga/hostAddr[6]} {myFampiga/hostAddr[7]} {myFampiga/hostAddr[8]} {myFampiga/hostAddr[9]} {myFampiga/hostAddr[10]} {myFampiga/hostAddr[11]} {myFampiga/hostAddr[12]} {myFampiga/hostAddr[13]} {myFampiga/hostAddr[14]} {myFampiga/hostAddr[15]} {myFampiga/hostAddr[16]} {myFampiga/hostAddr[17]} {myFampiga/hostAddr[18]} {myFampiga/hostAddr[19]} {myFampiga/hostAddr[20]} {myFampiga/hostAddr[21]} {myFampiga/hostAddr[22]} {myFampiga/hostAddr[23]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list myFampiga/enaWRreg]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list myFampiga/hostena]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list myFampiga/hostL]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list myFampiga/mysdram/hostNWR]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list myFampiga/hostU]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list myFampiga/sdr_cs]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list myFampiga/sdr_we]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list myFampiga/mysdram/sdwrite]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_BUFG]
