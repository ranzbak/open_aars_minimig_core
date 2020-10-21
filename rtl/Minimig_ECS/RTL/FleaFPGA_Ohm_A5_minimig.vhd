library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

entity FleaFPGA_Ohm_A5 is
 
	port(
	-- System clock and reset
	sys_clock		: in		std_logic;	-- 25MHz clock input from external xtal oscillator.
	sys_reset		: in		std_logic;	-- master reset input from reset header.

	-- On-board user buttons and status LED
	n_led1			: buffer	std_logic;
 
	-- Digital video out
	LVDS_Red		: out		std_logic_vector(0 downto 0);	-- 
	LVDS_Green		: out		std_logic_vector(0 downto 0);	-- 
	LVDS_Blue		: out		std_logic_vector(0 downto 0);	-- 
	LVDS_ck			: out		std_logic_vector(0 downto 0);	-- 
	
	-- USB Slave (FT230x) debug interface 
	slave_tx_o 		: out		std_logic;
	slave_rx_i 		: in		std_logic;
	slave_cts_i 	: in		std_logic;	-- Receives signal from #RTS pin on FT230x, where applicable.

	-- SDRAM interface (For use with 16Mx16bit or 32Mx16bit SDR DRAM, depending on version)
	Dram_Clk		: out		std_logic;	-- clock to SDRAM
	Dram_CKE		: out		std_logic;	-- clock to SDRAM
	Dram_n_Ras		: out		std_logic;	-- SDRAM RAS
	Dram_n_Cas		: out		std_logic;	-- SDRAM CAS
	Dram_n_We		: out		std_logic;	-- SDRAM write-enable
	Dram_BA			: out		std_logic_vector(1 downto 0);	-- SDRAM bank-address
	Dram_Addr		: out		std_logic_vector(12 downto 0);	-- SDRAM address bus
	Dram_Data		: inout		std_logic_vector(15 downto 0);	-- data bus to/from SDRAM
	Dram_n_cs		: out		std_logic;
	--Dram_dqm		: out		std_logic_vector(1 downto 0);
	Dram_DQMH		: out		std_logic;
	Dram_DQML		: out		std_logic;

    -- GPIO Header (RasPi compatible GPIO format)
	GPIO_2			: inout		std_logic;
	GPIO_3			: inout		std_logic;
	GPIO_4			: in		std_logic;
	GPIO_5			: inout		std_logic;
	GPIO_6			: inout		std_logic;	
	GPIO_7			: in		std_logic;	
	GPIO_8			: in		std_logic;	
	GPIO_9			: in		std_logic;	
	GPIO_10			: in		std_logic;
	GPIO_11			: in		std_logic;	
	GPIO_12			: inout		std_logic;	
	GPIO_13			: out		std_logic;	
	GPIO_14			: inout		std_logic;	
	GPIO_15			: in		std_logic;	
	GPIO_16			: in		std_logic;	
	GPIO_17			: in		std_logic;
	GPIO_18			: in		std_logic;	
	GPIO_19			: out		std_logic;	
	GPIO_20			: inout		std_logic;
	GPIO_21			: in		std_logic;	
	GPIO_22			: in		std_logic;	
	GPIO_23			: in		std_logic;
	GPIO_24			: in		std_logic;
	GPIO_25			: inout		std_logic;	
	GPIO_26			: inout		std_logic;	
	GPIO_27			: inout		std_logic;
	GPIO_IDSD		: inout		std_logic;
	GPIO_IDSC		: inout		std_logic;

	-- Sigma Delta ADC ('Enhanced' Ohm-specific GPIO functionality)	
	-- NOTE: Must comment out GPIO_5, GPIO_7, GPIO_10 AND GPIO_24 as instructed in the pin constraints file (.LPF) in order to use
	--ADC0_input	: in		std_logic;
	--ADC0_error	: buffer	std_logic;
	--ADC1_input	: in		std_logic;
	--ADC1_error	: buffer	std_logic;
	--ADC2_input	: in		std_logic;
	--ADC2_error	: buffer	std_logic;
	--ADC3_input	: in		std_logic;
	--ADC3_error	: buffer	std_logic;

	-- SD/MMC Interface (Support either SPI or nibble-mode)
	mmc_dat1		: in		std_logic;
	mmc_dat2		: in		std_logic;
	mmc_n_cs		: out		std_logic;
	mmc_clk			: out		std_logic;
	mmc_mosi		: out		std_logic; 
	mmc_miso		: in		std_logic;

	-- PS/2 Mode enable, keyboard and Mouse interfaces
	PS2_enable		: out		std_logic;
	PS2_clk1		: inout		std_logic;
	PS2_data1		: inout		std_logic;
	
	PS2_clk2		: inout		std_logic;
	PS2_data2		: inout		std_logic
	);
end FleaFPGA_Ohm_A5;

  
architecture arch of FleaFPGA_Ohm_A5 is
 
	signal clk  : std_logic := '0';	
	signal clk7m  : std_logic := '0';
	signal clk28m  : std_logic := '0';   
 
	signal aud_l  : std_logic;
	signal aud_r  : std_logic;  
	signal dma_1  : std_logic := '1'; 
 
	signal n_joy1   : std_logic_vector(5 downto 0);
	signal n_joy2   : std_logic_vector(5 downto 0);
 
	signal ps2k_clk_in : std_logic;
	signal ps2k_clk_out : std_logic;
	signal ps2k_dat_in : std_logic;
	signal ps2k_dat_out : std_logic;	
	signal ps2m_clk_in : std_logic;
	signal ps2m_clk_out : std_logic;
	signal ps2m_dat_in : std_logic;
	signal ps2m_dat_out : std_logic;	
 
   signal red_u     : std_logic_vector(3 downto 0);
   signal green_u   : std_logic_vector(3 downto 0);
   signal blue_u    : std_logic_vector(3 downto 0); 
 
   signal red     : std_logic_vector(7 downto 0) := (others => '0');
   signal green   : std_logic_vector(7 downto 0) := (others => '0');
   signal blue    : std_logic_vector(7 downto 0) := (others => '0');
   signal hsync   : std_logic := '0';
   signal vsync   : std_logic := '0';
   signal dvi_hsync   : std_logic := '0';
   signal dvi_vsync   : std_logic := '0';
   signal blank   : std_logic := '0';
	signal videoblank: std_logic;  
  
   signal clk_dvi  : std_logic := '0';
   signal clk_dvin : std_logic := '0'; 
 
	signal temp_we : std_logic := '0';
	signal diskoff : std_logic;
	
 	signal pwm_accumulator : std_logic_vector(8 downto 0);
	
    signal clk_vga   : std_logic := '0';
    signal PLL_lock  : std_logic := '0';
    signal n_15khz   : std_logic := '1';

	signal VTEMP_DAC		:std_logic_vector(4 downto 0);
	signal audio_data : std_logic_vector(17 downto 0);
	signal convert_audio_data : std_logic_vector(17 downto 0);

	signal DAC_R : std_logic;
	signal DAC_L : std_logic;

	signal amiga_rs232_rxd : std_logic;
	signal amiga_rs232_txd : std_logic;
	
	signal l_audio_ena    : boolean; 
	signal r_audio_ena    : boolean;
	
	constant cnt_div: integer:=617;                  -- Countervalue for 48khz Audio Enable,  567 for 25MHz PCLK
    signal   cnt:     integer range 0 to cnt_div-1; 
    signal   ce:      std_logic;

    signal   rightdatasum:	std_logic_vector(14 downto 0);
    signal   leftdatasum:	std_logic_vector(14 downto 0);
    signal   left_sampled:	std_logic_vector(15 downto 0);
    signal   right_sampled:	std_logic_vector(15 downto 0);
	
	 
    signal   pll_locked 	: std_logic;
    signal   reset_n 	: std_logic;
    signal   reset_combo1 	: std_logic;
	
begin
	-- Housekeeping logic for unwanted peripherals on FleaFPGA Ohm board goes here..
	-- (Note: comment out any of the following code lines if peripheral is required)

 Dram_CKE <= '1'; -- DRAM Clock enable. 
 PS2_enable <= '1'; -- Configure USB host bias resistors for alternate PS/2 functionality.

-- Audio output mapped to GPIO header
GPIO_13 <= DAC_R; 
GPIO_19 <= DAC_L;

-- Joystick bits(5-0) = fire2,fire,right,left,down,up mapped to GPIO header
n_joy1(3)<= GPIO_4 ; -- up
n_joy1(2)<= GPIO_7 ; -- down
n_joy1(1)<= GPIO_8 ; -- left
n_joy1(0)<= GPIO_9 ; -- right
n_joy1(4)<= GPIO_10 ; -- fire
n_joy1(5)<= GPIO_11 ; -- fire2

n_joy2(3)<= GPIO_15 ; -- up
n_joy2(2)<= GPIO_17 ; -- down
n_joy2(1)<= GPIO_18 ; -- left 
n_joy2(0)<= GPIO_22 ; -- right  
n_joy2(4)<= GPIO_23 ; -- fire
n_joy2(5)<= GPIO_24 ; -- fire2 

-- Video output horizontal scanrate select 15/30kHz select via GPIO header
n_15khz <= GPIO_21 ; -- Default is 30kHz video out if pin left unconnected. Connect to GND for 15kHz video. 

-- Amiga UART connection to GPIO header
amiga_rs232_rxd <= GPIO_16;
GPIO_12 <= amiga_rs232_txd;

-- PS/2 Keyboard and Mouse definitions
	ps2k_dat_in<=PS2_data1;
	PS2_data1 <= '0' when ps2k_dat_out='0' else 'Z';
	ps2k_clk_in<=PS2_clk1;
	PS2_clk1 <= '0' when ps2k_clk_out='0' else 'Z';	
 
	ps2m_dat_in<=PS2_data2;
	PS2_data2 <= '0' when ps2m_dat_out='0' else 'Z';
	ps2m_clk_in<=PS2_clk2;
	PS2_clk2 <= '0' when ps2m_clk_out='0' else 'Z';	 
  
	-- User HDL project modules and port mappings go here..

	u0 : entity work.C64_clock
	port map(
		CLKI			=>	sys_clock,
		CLKOP			=>	clk,
		
		CLKOS			=>	Dram_Clk,
		CLKOS2			=>	clk28m,
		CLKOS3			=>	clk7m,
		LOCK			=>  pll_locked
		);  
		
	u01 : entity work.DVI_PLL -- 
	port map(
		CLKI			=>	sys_clock,
		CLKOP			=>	open, -- 112.5MHz
		CLKOS			=>	clk_dvi, -- 140.625 MHz
		CLKOS2			=>	clk_dvin -- 140.625 MHz
		);  		

reset_combo1 <=	sys_reset and pll_locked;
		
	u10 : entity work.poweronreset
		port map( 
			clk => clk,
			reset_button => reset_combo1,
			reset_out => reset_n
			--power_button => power_button,
			--power_hold => power_hold		
		);		
		

		
--Dram_n_cs <= '1';
--mmc_n_cs <= '1';

n_led1 <= not diskoff;

--SRAM_n_oe <= not temp_we; 
--SRAM_n_we <= temp_we;

myFampiga: entity work.Fampiga
	port map(
		clk=> 	clk,
		clk7m=> clk7m,
		clk28m=> clk28m,
		reset_n=>reset_n,--GPIO_wordin(0),--reset_n,
		--powerled_out=>power_led(5 downto 4),
		diskled_out=>diskoff,
		--oddled_out=>odd_led(5), 

		-- SDRAM.  A separate shifted clock is provided by the toplevel
		sdr_addr => Dram_Addr,
		sdr_data => Dram_Data,
		sdr_ba => Dram_BA,
		--sdr_cke => Dram_CKE,
		sdr_dqm(1) => Dram_DQMH,
		sdr_dqm(0) => Dram_DQML,	 	
		sdr_cs => Dram_n_cs,
		sdr_we => Dram_n_we,
		sdr_cas => Dram_n_Cas, 
		sdr_ras => Dram_n_Ras,
	 
		-- VGA 
		vga_r => red_u,
		vga_g => green_u,
		vga_b => blue_u,
		vid_blank => videoblank,
		vga_hsync => hsync,
		vga_vsync => vsync,
		n_15khz => n_15khz,
		-- PS/2
		ps2k_clk_in => ps2k_clk_in,
		ps2k_clk_out => ps2k_clk_out,
		ps2k_dat_in => ps2k_dat_in,
		ps2k_dat_out => ps2k_dat_out,
		ps2m_clk_in => ps2m_clk_in,
		ps2m_clk_out => ps2m_clk_out,
		ps2m_dat_in => ps2m_dat_in,
		ps2m_dat_out => ps2m_dat_out,
		
		-- Audio
		sigmaL => DAC_L,
		sigmaR => DAC_R,
		leftdatasum => leftdatasum,
		rightdatasum => rightdatasum,
		
		-- Game ports
		n_joy1 => n_joy1,
		n_joy2 => n_joy2,		
		
		-- RS232
		rs232_rxd => slave_rx_i,
		rs232_txd => slave_tx_o,
		
		-- ESP8266 wifi modem
		amiga_rs232_rxd => amiga_rs232_rxd,
		amiga_rs232_txd => amiga_rs232_txd,
		
		-- SD card interface
		sd_cs => mmc_n_cs,
		sd_miso => mmc_miso,
		sd_mosi => mmc_mosi,
		sd_clk => mmc_clk

		-- FIXME - add joystick ports
	);
process(clk28m)
begin
  if rising_edge(clk28m) then
	red <= std_logic_vector(red_u) & "0000";
	green <= std_logic_vector(green_u) & "0000";
	blue <= std_logic_vector(blue_u) & "0000";  
	--blank <= hsync AND vsync;
	blank <= videoblank;	
	dvi_hsync <= hsync;
	dvi_vsync <= vsync;
  end if;
end process;    

    left_sampled <= leftdatasum(14 downto 0) & '0';
	right_sampled <= rightdatasum(14 downto 0) & '0';
	
  Inst_DVI: entity work.dvid 
  PORT MAP (
    clk		      => clk_dvi,
    clk_n         => clk_dvin,	 
    clk_pixel     => clk28m,
    clk_pixel_en  => true, 
	
    red_p         => red,
    green_p       => green,
    blue_p        => blue,
    blank         => blank,
    hsync         => dvi_hsync, 
    vsync         => dvi_vsync,
	EnhancedMode  => true,
	IsProgressive  => true, 
	IsPAL  		  => true, 
	Is30kHz  	  => true,
	Limited_Range  => false,
	Widescreen    => true,
	HDMI_audio_L  => left_sampled,
	HDMI_audio_R  => right_sampled,
	HDMI_LeftEnable  => l_audio_ena,
	HDMI_RightEnable => l_audio_ena,
	red_s         => LVDS_Red,
    green_s       => LVDS_Green, 
    blue_s        => LVDS_Blue,
    clock_s       => LVDS_ck 

  ); 
  
process(clk28m)
begin
  if rising_edge(clk28m) then
    if cnt=cnt_div-1 then
      ce  <= '1';
      cnt <= 0; 
    else
      ce  <= '0';
      cnt <= cnt +1 ;
    end if;
  end if;
end process;
process(clk28m)
begin
  if rising_edge(clk28m) then
	if ce='1' then
	   l_audio_ena <= true;
	else
	   l_audio_ena <= false;
    end if;
  end if;
end process;  
  
  
end arch;
