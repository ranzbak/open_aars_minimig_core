
create_pblock pblock_1
add_cells_to_pblock [get_pblocks pblock_1] [get_cells -quiet [list myFampiga/mysdram]]
resize_pblock [get_pblocks pblock_1] -add {CLOCKREGION_X1Y1:CLOCKREGION_X1Y1}

# Clock groups
set_clock_groups -name internat_external_clocks -asynchronous -group [get_clocks [list clk_50mhz [get_clocks -of_objects [get_pins clk_main/CLKOUT0]] [get_clocks -of_objects [get_pins clk_main/CLKOUT1]] [get_clocks -of_objects [get_pins clk_main/CLKOUT2]] [get_clocks -of_objects [get_pins clk_sdram/CLKFBOUT]] [get_clocks -of_objects [get_pins clk_main/CLKFBOUT]] [get_clocks -of_objects [get_pins clk_sdram/CLKOUT0]]]] -group [get_clocks {VIRTUAL_ADV_clk VIRTUAL_ADV_clk28m VIRTUAL_DDR_clk}]



set_multicycle_path -setup -from [get_clocks -of_objects [get_pins clk_main/CLKOUT2]] -to [get_clocks -of_objects [get_pins clk_sdram/CLKOUT0]] 2
set_multicycle_path -hold -from [get_clocks -of_objects [get_pins clk_main/CLKOUT2]] -to [get_clocks -of_objects [get_pins clk_sdram/CLKOUT0]] 1




