----------------------------
-- ULX3S Top level for MINIMIG
-- http://github.com/emard
----------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;
-- use IEEE.MATH_REAL.ALL;

library unisim;
use unisim.vcomponents.all;

entity amiga_ffm_a7100 is
generic
(
  C_dvid_ddr: boolean := false -- true: use vendor-specific DDR-differential output buffeers
);
port
(
  clk_50mhz: in std_logic;
  -- RS232
  uart3_txd: out std_logic; -- rs232 txd
  uart3_rxd: in std_logic; -- rs232 rxd
  -- SD card (SPI)
  sd_m_clk, sd_m_cmd: out std_logic;
  sd_m_d: inout std_logic_vector(3 downto 0);
  sd_m_cdet: in std_logic;
  -- SDRAM
  dr_clk: out std_logic;
  dr_cke: out std_logic;
  dr_cs_n: out std_logic;
  dr_a: out std_logic_vector(12 downto 0);
  dr_ba: out std_logic_vector(1 downto 0);
  dr_ras_n, dr_cas_n: out std_logic;
  dr_dqm: out std_logic_vector(1 downto 0);
  dr_d: inout std_logic_vector(15 downto 0);
  dr_we_n: out std_logic;
  -- ADV7511 video chip
  --dv_clk: inout std_logic;
  dv_clk: out std_logic;
  dv_sda: inout std_logic;
  dv_scl: inout std_logic;
-- dv_int: inout std_logic;
  dv_de: out std_logic;
  dv_hsync: out std_logic;
  dv_vsync: out std_logic;
  dv_cecclk: out std_logic;
-- dv_spdif: inout std_logic;
-- dv_mclk: inout std_logic;
--  dv_i2s: inout std_logic_vector(3 downto 0);
--  dv_sclk: inout std_logic;
--  dv_lrclk: inout std_logic;
  dv_d: out std_logic_vector(11 downto 0);
  -- Joystick ports via MCP32S17
  js_mosi: out std_logic;
  js_miso: inout std_logic;
  js_cs: out std_logic;
  js_sck: out std_logic;
  js_inta: in std_logic;
  -- PS2 keyboard
  ps2_clk1: inout std_logic;
  ps2_data1: inout std_logic;
  -- PS2 mouse
  ps2_clk2: inout std_logic;
  ps2_data2: inout std_logic;
  -- max 9850 i2s headphone out
  max_sclk: out std_logic;
  max_lrclk: out std_logic;
  max_i2s: out std_logic;
  -- leds
  led_core: out std_logic;
  led_power: out std_logic;
  led_fdisk: out std_logic;
  led_hdisk: out std_logic;
  led_user: out std_logic;
  -- Floppy interface
  exp_sel0: in std_logic;
  exp_sel1: in std_logic;
  exp_dir: in std_logic;
  exp_step: in std_logic;
  exp_chng: in std_logic;
  exp_index: in std_logic;
  exp_rdy: in std_logic;
  exp_dkrd: in std_logic;
  exp_trk0: in std_logic;
  exp_dkwdb: in std_logic;
  exp_dkweb: in std_logic;
  exp_side: in std_logic;

  -- reset input
  sys_reset_in: in std_logic;
  button_user: in std_logic;
  button_osd: in std_logic
);
end;

architecture struct of amiga_ffm_a7100 is

  -- alias DAC_L: std_logic is fioa(2);
  -- alias DAC_R: std_logic is fioa(0);

  -- alias led_power: std_logic is fioa(5); -- green LED
  -- alias led_floppy: std_logic is fioa(7); -- red LED

  signal sys_reset_n: std_logic;

  --alias mmc_dat1: std_logic is sd_m_d(1);
  --alias mmc_dat2: std_logic is sd_m_d(2);
  --alias mmc_n_cs: std_logic is sd_m_d(3);
  alias mmc_clk: std_logic is sd_m_clk;
  alias mmc_mosi: std_logic is sd_m_cmd;
  alias mmc_miso: std_logic is sd_m_d(0);
  -- END ALIASING

  -- Internal MMC (SD-card) signals
  signal mmc_n_cs: std_logic;

  --signal clk_100MHz: std_logic; -- converted from differential to single ended
  signal clk_fb_main, clk_fb_sdram: std_logic; -- feedback internally used in clock generator
  signal clk: std_logic := '0';	
  signal clk7m: std_logic := '0';
  signal clk28m: std_logic := '0';

  signal n_joy1: std_logic_vector(5 downto 0);
  signal n_joy2: std_logic_vector(5 downto 0);

  signal ps2k_clk_in: std_logic;
  signal ps2k_clk_out: std_logic;
  signal ps2k_dat_in: std_logic;
  signal ps2k_dat_out: std_logic;	
  signal ps2m_clk_in: std_logic;
  signal ps2m_clk_out: std_logic;
  signal ps2m_dat_in: std_logic;
  signal ps2m_dat_out: std_logic;	

  signal red_u, green_u, blue_u: std_logic_vector(7 downto 0);

--  signal red, green, blue: std_logic_vector(7 downto 0) := (others => '0');
  signal hsync, vsync: std_logic := '0';
--  signal blank   : std_logic := '0';
  signal videoblank: std_logic;
--  signal dvi_hsync   : std_logic := '0';
--  signal dvi_vsync   : std_logic := '0';

--  signal clk_dvi, clk200m, clk281m: std_logic := '0';
  signal clk200m: std_logic := '0';

--  signal temp_we : std_logic := '0';
  signal diskoff : std_logic;
	
  signal n_15khz   : std_logic := '1';

  signal   rightdatasum:	std_logic_vector(14 downto 0);
  signal   leftdatasum:	std_logic_vector(14 downto 0);
	
--  constant pll_reset: std_logic := '0';
  signal pll_locked_main, pll_locked_sdram: std_logic;
  signal reset: std_logic;
  signal reset_n: std_logic;
  signal reset_combo1: std_logic;

  -- emard audio-video and aliasing
--  signal S_audio: std_logic_vector(23 downto 0) := (others => '0');
--  signal S_spdif_out: std_logic;
--  signal ddr_d: std_logic_vector(3 downto 0);
  signal dvid_crgb: std_logic_vector(7 downto 0); -- clock, red, green, blue
  --alias clk_pixel: std_logic is clk28m;
  --alias clk_pixel_shift: std_logic is clk_dvi;
  -- end emard AV
  signal sw: std_logic_vector(3 downto 0) := (others => '1');
  -- LED assignments
  signal odd_leds: std_logic;
  signal power_leds: std_logic;
begin
  -- btn(0) used as reset has inverted logic
  sys_reset_n <= sys_reset_in; -- '1' is not reset, '0' is reset

  -- LEDS off for now
  --led_core <= '1';
  --led_user <= '1';

  -- Video output horizontal scanrate select 15/30kHz select via GP[BIO header
  -- n_15khz <= GP(21) ; -- Default is 30kHz video out if pin left unconnected. Connect to GND for 15kHz video.
  -- n_15khz <= sw(1) ; -- Default is '1' for 30kHz video out. set to '0' for 15kHz video.
  n_15khz <= '1'; -- Default is '1' for 30kHz video out. set to '0' for 15kHz video
  
-- SD card tristate
  sd_m_d(0) <= 'Z'; -- Using SPI mode, So we listen
  sd_m_d(1) <= '1';
  sd_m_d(2) <= '1';
  sd_m_d(3) <= '0' when mmc_n_cs='0' else 'Z';
  
  -- PS/2 Keyboard and Mouse definitions
  ps2k_dat_in<=ps2_data1;
  ps2_data1 <= '0' when (ps2k_dat_out='0') else 'Z';
  ps2k_clk_in<=ps2_clk1;
  ps2_clk1 <= '0' when (ps2k_clk_out='0') else 'Z';

  ps2m_dat_in<=ps2_data2;
  -- ps2_data2 <= '0' when (ps2m_dat_out='0') else 'Z';
  PS2_data2 <= 'Z';
  ps2m_clk_in<=ps2_clk2;
  -- ps2_clk2 <= '0' when (ps2m_clk_out='0') else 'Z';
  ps2_clk2 <= 'Z';

  --clkin_ibufgds: ibufgds
  --port map (I => clk_100MHz_P, IB => clk_100MHz_N, O => clk_100MHz);

  -- Clock generator
  clk_main: mmcme2_base
  generic map
  (
    clkin1_period    => 20.0,       --  100      MHz (10 ns)
    clkfbout_mult_f  => 33.75,      --  1687.5    MHz *16.875 common multiply
    divclk_divide    => 2,          --  843.75   MHz /2 common divide
    clkout0_divide_f => 7.5,        --  112.5     MHz /7.5 divide
    clkout1_divide   => 120,        --  7.03125   MHz /120 divide
    clkout2_divide   => 30,         --  28.125    MHz /30 divide
    -- clkout3_divide   => 4,          --  210,94    MHz /4.25 divide
    -- clkout4_divide   => 3,          --  281.25    MHz /3 divide
    bandwidth        => "LOW"
  )
  port map
  (
    pwrdwn   => '0',
    rst      => '0',
    clkin1   => clk_50mhz,
    clkfbin  => clk_fb_main,
    clkfbout => clk_fb_main,
    clkout0  => clk,                --  112.5     MHz
    clkout1  => clk7m,              --  7.03125   MHz
    clkout2  => clk28m,             --  28.125    MHz
    -- clkout3  => clk200m,            --  210,94    MHz
    -- clkout4  => clk281m,            --  281.25    MHz
    locked   => pll_locked_main
  );

  -- G_clk_dvi_sdr: if not C_dvid_ddr generate
  --   clk_dvi <= clk281m;
  -- end generate;
  -- G_clk_dvi_ddr: if C_dvid_ddr generate
  --   clk_dvi <= clk140m;
  -- end generate;

  clk_sdram: mmcme2_base
  generic map
  (
    clkin1_period    => 8.88888888, --   112.5    MHz (8.88888 ns)
    clkfbout_mult_f  => 10.0,       --  1125.0    MHz *10 common multiply
    divclk_divide    => 1,          --  1125.0    MHz /1  common divide
    clkout0_divide_f => 5.625,      --   200.0    MHz /10 divide
    clkout0_phase    => 0.0,        --            deg phase shift (multiple of 45/clkout0_divide_f = 4.5)
    clkout1_divide   => 10,         --   112.5    MHz /10 divide
    clkout1_phase    => 144.0,      --            deg phase shift (multiple of 45/clkout0_divide_f = 4.5)
    bandwidth        => "LOW"
  )
  port map
  (
    pwrdwn   => '0',
    rst      => '0',
    clkin1   => clk,
    clkfbin  => clk_fb_sdram,
    clkfbout => clk_fb_sdram,
    clkout0  => clk200m,             --  112.5     MHz phase shifted
    clkout1  => dr_clk,             --  112.5     MHz phase shifted
    locked   => pll_locked_sdram
  );

  reset_combo1 <= sys_reset_n and pll_locked_main and pll_locked_sdram;

  dv_cecclk <= clk28m;
		
  u10 : entity work.poweronreset
  port map
  (
    clk => clk,
    reset_button => reset_combo1,
    reset_out => reset_n
  );
  reset <= not reset_n;

  -- Assign LEDS
  led_power <= not power_leds; -- LED Amiga power
  led_fdisk <= not odd_leds;   -- LED at Floppy disk led 
  led_hdisk <= not diskoff;    -- LED Harddisk wired to SD card access
  led_user  <= reset_n;        -- LED at SD card access
  led_core  <= mmc_n_cs;       -- Chip select SD card

  -- Minimig wrapper
  myFampiga: entity work.Fampiga
  port map
  (
    clk=> clk,
    clk7m=> clk7m,
    clk28m=> clk28m,
    reset_n=>reset_n,
    powerled_out=>power_leds,
    diskled_out=>diskoff,
    oddled_out=>odd_leds,

    -- SDRAM.  A separate shifted clock is provided by the toplevel
    sdr_addr => dr_a,
    sdr_data => dr_d,
    sdr_ba => dr_ba,
    sdr_cke => dr_cke,
    sdr_dqm => dr_dqm,
    sdr_cs => dr_cs_n,
    sdr_we => dr_we_n,
    sdr_cas => dr_cas_n,
    sdr_ras => dr_ras_n,

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
    -- sigmaL => DAC_L,
    -- sigmaR => DAC_R,
    leftdatasum => leftdatasum,
    rightdatasum => rightdatasum,

    -- Game ports
    n_joy1 => n_joy1,
    n_joy2 => n_joy2,		
		
    -- RS232 cross connect
    rs232_rxd => uart3_rxd,
    rs232_txd => uart3_txd,
		
    -- ESP8266 wifi modem
    amiga_rs232_rxd => '1',
    amiga_rs232_txd => open,
		
    -- SD card interface
    sd_cs => mmc_n_cs,
    sd_miso => mmc_miso,
    sd_mosi => mmc_mosi,
    sd_clk => mmc_clk
  );

  -- SPI to joystick input
  -- Joystick bits(5-0) = fire2,fire,up,down,left,right mapped to GPIO header
  -- Joystick bits(5-0) = fire2,fire,up,down,left,right mapped to GPIO header
  joystick_ports: entity work.mcp23s17_input
  port map
  (
    clk => clk28m,
    rst => reset,

    inta => js_inta,

    mosi => js_mosi,
    miso => js_miso,
    cs   => js_cs,
    sck  => js_sck,

    ready => open,

    joya => n_joy1,
    joyb => n_joy2
  );

  -- i2s transmittor
  i2s_transmitter: entity work.i2s_tx
  port map (
    clk => clk,
    rst => reset,

    prescaler => to_unsigned(16, 16),
    sclk => max_sclk,
    lrclk => max_lrclk,
    sdata => max_i2s,

    left_chan => leftdatasum & '1',
    right_chan => rightdatasum & '1'
  );

  -- Video signal to dual data rate
  -- To save pins on the FPGA
  my_pal_to_ddr: entity work.pal_to_ddr
  port map
  (
    clk => clk200m,
    i_pal_vsync => not vsync,
    i_pal_hsync => not hsync,
    i_pal_r => red_u,
    i_pal_g => green_u,
    i_pal_b => blue_u,

    o_clk_pixel => dv_clk,
    o_de => dv_de,
    o_vsync => dv_vsync,
    o_hsync => dv_hsync,
    o_data => dv_d
  );

  -- Module to configure the ADV7511
  i2c_send: entity work.i2c_sender
  port map
  (
    clk => clk28m,
    rst => reset,
    resend => '0',
    read_regs => '0',
    sioc => dv_scl,
    siod => dv_sda
  );

end struct;
