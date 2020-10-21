-- VHDL netlist generated by SCUBA Diamond (64-bit) 3.9.1.119
-- Module  Version: 5.7
--C:\lscc\diamond\3.9_x64\ispfpga\bin\nt64\scuba.exe -w -n DVI_PLL -lang vhdl -synth synplify -bus_exp 7 -bb -arch sa5p00 -type pll -fin 25 -fclkop 112.5 -fclkop_tol 5.0 -fclkos 140.625 -fclkos_tol 2.0 -phases 0 -fclkos2 140.625 -fclkos2_tol 2.0 -phases2 90 -phase_cntl STATIC -fb_mode 1 -fdc C:/lscc/diamond/3.3_x64/examples/Flea_zero_Amiga_HDMI/RTL/DVI_PLL/DVI_PLL.fdc 

-- Mon Aug 21 18:35:42 2017

library IEEE;
use IEEE.std_logic_1164.all;
library ECP5U;
use ECP5U.components.all;

entity DVI_PLL is
    port (
        CLKI: in  std_logic; 
        CLKOP: out  std_logic; 
        CLKOS: out  std_logic; 
        CLKOS2: out  std_logic);
end DVI_PLL;

architecture Structure of DVI_PLL is

    -- internal signal declarations
    signal REFCLK: std_logic;
    signal LOCK: std_logic;
    signal CLKOS2_t: std_logic;
    signal CLKOS_t: std_logic;
    signal CLKOP_t: std_logic;
    signal scuba_vhi: std_logic;
    signal scuba_vlo: std_logic;

    attribute FREQUENCY_PIN_CLKOS2 : string; 
    attribute FREQUENCY_PIN_CLKOS : string; 
    attribute FREQUENCY_PIN_CLKOP : string; 
    attribute FREQUENCY_PIN_CLKI : string; 
    attribute ICP_CURRENT : string; 
    attribute LPF_RESISTOR : string; 
    attribute FREQUENCY_PIN_CLKOS2 of PLLInst_0 : label is "140.625000";
    attribute FREQUENCY_PIN_CLKOS of PLLInst_0 : label is "140.625000";
    attribute FREQUENCY_PIN_CLKOP of PLLInst_0 : label is "112.500000";
    attribute FREQUENCY_PIN_CLKI of PLLInst_0 : label is "25.000000";
    attribute ICP_CURRENT of PLLInst_0 : label is "5";
    attribute LPF_RESISTOR of PLLInst_0 : label is "16";
    attribute syn_keep : boolean;
    attribute NGD_DRC_MASK : integer;
    attribute NGD_DRC_MASK of Structure : architecture is 1;

begin
    -- component instantiation statements
    scuba_vhi_inst: VHI
        port map (Z=>scuba_vhi);

    scuba_vlo_inst: VLO
        port map (Z=>scuba_vlo);

    PLLInst_0: EHXPLLL
        generic map (PLLRST_ENA=> "DISABLED", INTFB_WAKE=> "DISABLED", 
        STDBY_ENABLE=> "DISABLED", DPHASE_SOURCE=> "DISABLED", 
        CLKOS3_FPHASE=>  0, CLKOS3_CPHASE=>  0, CLKOS2_FPHASE=>  0, 
        CLKOS2_CPHASE=>  4, CLKOS_FPHASE=>  0, CLKOS_CPHASE=>  3, 
        CLKOP_FPHASE=>  0, CLKOP_CPHASE=>  4, PLL_LOCK_MODE=>  0, 
        CLKOS_TRIM_DELAY=>  0, CLKOS_TRIM_POL=> "FALLING", 
        CLKOP_TRIM_DELAY=>  0, CLKOP_TRIM_POL=> "FALLING", 
        OUTDIVIDER_MUXD=> "DIVD", CLKOS3_ENABLE=> "DISABLED", 
        OUTDIVIDER_MUXC=> "DIVC", CLKOS2_ENABLE=> "ENABLED", 
        OUTDIVIDER_MUXB=> "DIVB", CLKOS_ENABLE=> "ENABLED", 
        OUTDIVIDER_MUXA=> "DIVA", CLKOP_ENABLE=> "ENABLED", CLKOS3_DIV=>  1, 
        CLKOS2_DIV=>  4, CLKOS_DIV=>  4, CLKOP_DIV=>  5, CLKFB_DIV=>  9, 
        CLKI_DIV=>  2, FEEDBK_PATH=> "CLKOP")
        port map (CLKI=>CLKI, CLKFB=>CLKOP_t, PHASESEL1=>scuba_vlo, 
            PHASESEL0=>scuba_vlo, PHASEDIR=>scuba_vlo, 
            PHASESTEP=>scuba_vlo, PHASELOADREG=>scuba_vlo, 
            STDBY=>scuba_vlo, PLLWAKESYNC=>scuba_vlo, RST=>scuba_vlo, 
            ENCLKOP=>scuba_vlo, ENCLKOS=>scuba_vlo, ENCLKOS2=>scuba_vlo, 
            ENCLKOS3=>scuba_vlo, CLKOP=>CLKOP_t, CLKOS=>CLKOS_t, 
            CLKOS2=>CLKOS2_t, CLKOS3=>open, LOCK=>LOCK, INTLOCK=>open, 
            REFCLK=>REFCLK, CLKINTFB=>open);

    CLKOS2 <= CLKOS2_t;
    CLKOS <= CLKOS_t;
    CLKOP <= CLKOP_t;
end Structure;
