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
  clk_100mhz_p, clk_100mhz_n: in std_logic;
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
  dr_dqm: out std_logic_vector(3 downto 0);
  dr_d: inout std_logic_vector(31 downto 0);
  dr_we_n: out std_logic;
  -- FFM Module IO
  fioa: inout std_logic_vector(7 downto 0);
  fiob: inout std_logic_vector(31 downto 20);
  -- ADV7513 video chip
  dv_clk: inout std_logic;
  dv_sda: inout std_logic;
  dv_scl: inout std_logic;
  dv_int: inout std_logic;
  dv_de: inout std_logic;
  dv_hsync: inout std_logic;
  dv_vsync: inout std_logic;
  dv_spdif: inout std_logic;
  dv_mclk: inout std_logic;
  dv_i2s: inout std_logic_vector(3 downto 0);
  dv_sclk: inout std_logic;
  dv_lrclk: inout std_logic;
  dv_d: inout std_logic_vector(23 downto 0);
  -- Low-Cost HDMI video out
  vid_d_p, vid_d_n: out std_logic_vector(3 downto 0)
);
end;

architecture struct of amiga_ffm_a7100 is
  -- keyboard
  alias ps2_clk1 : std_logic is fioa(6);
  alias ps2_data1 : std_logic is fioa(4);
  signal PS_enable: std_logic;
  -- mouse
  alias ps2_clk2 : std_logic is fioa(3);
  alias ps2_data2 : std_logic is fioa(1);

  alias DAC_L: std_logic is fioa(2);
  alias DAC_R: std_logic is fioa(0);

  alias led_power: std_logic is fioa(5); -- green LED
  alias led_floppy: std_logic is fioa(7); -- red LED

  signal LVDS_Red: std_logic_vector(0 downto 0);
  signal LVDS_Green: std_logic_vector(0 downto 0);
  signal LVDS_Blue: std_logic_vector(0 downto 0);
  signal LVDS_ck: std_logic_vector(0 downto 0);
  signal tmds_out_clk: std_logic;
  signal tmds_out_rgb: std_logic_vector(2 downto 0);

  signal sys_reset: std_logic;

  alias mmc_dat1: std_logic is sd_m_d(1);
  alias mmc_dat2: std_logic is sd_m_d(2);
  alias mmc_n_cs: std_logic is sd_m_d(3);
  alias mmc_clk: std_logic is sd_m_clk;
  alias mmc_mosi: std_logic is sd_m_cmd;
  alias mmc_miso: std_logic is sd_m_d(0);
  -- END ALIASING

  signal clk_100MHz: std_logic; -- converted from differential to single ended
  signal clk_fb_main, clk_fb_sdram: std_logic; -- feedback internally used in clock generator
  signal clk: std_logic := '0';	
  signal clk7m: std_logic := '0';
  signal clk28m: std_logic := '0';   
 
  signal aud_l: std_logic;
  signal aud_r: std_logic;  
  signal dma_1: std_logic := '1'; 
 
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
 
  signal red_u, green_u, blue_u: std_logic_vector(3 downto 0);
 
  signal red, green, blue: std_logic_vector(7 downto 0) := (others => '0');
  signal hsync, vsync: std_logic := '0';
  signal blank   : std_logic := '0';
  signal videoblank: std_logic;  
  signal dvi_hsync   : std_logic := '0';
  signal dvi_vsync   : std_logic := '0';
  
  signal clk_dvi, clk140m, clk281m: std_logic := '0';
 
  signal temp_we : std_logic := '0';
  signal diskoff : std_logic;
	
  signal n_15khz   : std_logic := '1';

  signal audio_data : std_logic_vector(17 downto 0);
  signal convert_audio_data : std_logic_vector(17 downto 0);

  signal l_audio_ena    : boolean; 
  signal r_audio_ena    : boolean;
	
  constant cnt_div: integer:=617;                  -- Countervalue for 48khz Audio Enable,  567 for 25MHz PCLK
  signal   cnt:     integer range 0 to cnt_div-1; 
  signal   ce:      std_logic;

  signal   rightdatasum:	std_logic_vector(14 downto 0);
  signal   leftdatasum:	std_logic_vector(14 downto 0);
  signal   left_sampled:	std_logic_vector(15 downto 0);
  signal   right_sampled:	std_logic_vector(15 downto 0);
	 
  constant pll_reset: std_logic := '0';
  signal pll_locked_main, pll_locked_sdram: std_logic;
  signal reset: std_logic;
  signal reset_n: std_logic;
  signal reset_combo1: std_logic;

  -- emard audio-video and aliasing
  signal S_audio: std_logic_vector(23 downto 0) := (others => '0');
  signal S_spdif_out: std_logic;
  signal ddr_d: std_logic_vector(3 downto 0);
  signal dvid_crgb: std_logic_vector(7 downto 0); -- clock, red, green, blue
  alias clk_pixel: std_logic is clk28m;
  alias clk_pixel_shift: std_logic is clk_dvi;
  -- end emard AV
  signal sw: std_logic_vector(3 downto 0) := (others => '1');
begin
  -- btn(0) used as reset has inverted logic
  sys_reset <= '1'; -- '1' is not reset, '0' is reset
  mmc_dat1 <= '1';
  mmc_dat2 <= '1';

  -- Housekeeping logic for unwanted peripherals on FleaFPGA Ohm board goes here..
  -- (Note: comment out any of the following code lines if peripheral is required)

  -- Joystick bits(5-0) = fire2,fire,right,left,down,up mapped to GPIO header
  n_joy1(3)<= fiob(20) ; -- up
  n_joy1(2)<= fiob(21) ; -- down
  n_joy1(1)<= fiob(22) ; -- left
  n_joy1(0)<= fiob(23) ; -- right
  n_joy1(4)<= fiob(24) ; -- fire
  n_joy1(5)<= fiob(25) ; -- fire2

  n_joy2(3)<= fiob(26) ; -- up
  n_joy2(2)<= fiob(27) ; -- down
  n_joy2(1)<= fiob(28) ; -- left 
  n_joy2(0)<= fiob(29) ; -- right  
  n_joy2(4)<= fiob(30) ; -- fire
  n_joy2(5)<= fiob(31) ; -- fire2 

  -- Video output horizontal scanrate select 15/30kHz select via GP[BIO header
  -- n_15khz <= GP(21) ; -- Default is 30kHz video out if pin left unconnected. Connect to GND for 15kHz video.
  n_15khz <= sw(1) ; -- Default is '1' for 30kHz video out. set to '0' for 15kHz video.

  -- PS/2 Keyboard and Mouse definitions
  ps2k_dat_in<=PS2_data1;
  -- PS2_data1 <= '0' when ps2k_dat_out='0' else 'Z';
  PS2_data1 <= 'Z';
  ps2k_clk_in<=PS2_clk1;
  -- PS2_clk1 <= '0' when ps2k_clk_out='0' else 'Z';
  PS2_clk1 <= 'Z';
 
  ps2m_dat_in<=PS2_data2;
  -- PS2_data2 <= '0' when ps2m_dat_out='0' else 'Z';
  PS2_data2 <= 'Z';
  ps2m_clk_in<=PS2_clk2;
  -- PS2_clk2 <= '0' when ps2m_clk_out='0' else 'Z';
  PS2_clk2 <= 'Z';
  
  clkin_ibufgds: ibufgds
  port map (I => clk_100MHz_P, IB => clk_100MHz_N, O => clk_100MHz);

  clk_main: mmcme2_base
  generic map
  (
    clkin1_period    => 10.0,       --   100      MHz (10 ns)
    clkfbout_mult_f  => 16.875,     --  1687.5    MHz *16.875 common multiply
    divclk_divide    => 2,          --   843.75   MHz /2 common divide
    clkout0_divide_f => 7.5,        --  112.5     MHz /7.5 divide
    clkout1_divide   => 120,        --    7.03125 MHz /120 divide
    clkout2_divide   => 30,         --   28.125   MHz /30 divide
    clkout3_divide   => 6,          --  140.625   MHz /6 divide
    clkout4_divide   => 3,          --  281.25    MHz /3 divide
    bandwidth        => "LOW"
  )
  port map
  (
    pwrdwn   => '0',
    rst      => '0',
    clkin1   => clk_100MHz,
    clkfbin  => clk_fb_main,
    clkfbout => clk_fb_main,
    clkout0  => clk,                --  112.5     MHz
    clkout1  => clk7m,              --    7.03125 MHz
    clkout2  => clk28m,             --   28.125   MHz
    clkout3  => clk140m,            --  140.625   MHz
    clkout4  => clk281m,            --  281.25    MHz
    locked   => pll_locked_main
  );

  G_clk_dvi_sdr: if not C_dvid_ddr generate
    clk_dvi <= clk281m;
  end generate;
  G_clk_dvi_ddr: if C_dvid_ddr generate
    clk_dvi <= clk140m;
  end generate;

  clk_sdram: mmcme2_base
  generic map
  (
    clkin1_period    => 8.88888888, --   112.5    MHz (8.88888 ns)
    clkfbout_mult_f  => 10.0,       --  1125.0    MHz *10 common multiply
    divclk_divide    => 1,          --  1125.0    MHz /1  common divide
    clkout0_divide_f => 10.0,       --  112.5     MHz /10 divide
    clkout0_phase    => 144.0,      --            deg phase shift (multiple of 45/clkout0_divide_f = 4.5)
    bandwidth        => "LOW"
  )
  port map
  (
    pwrdwn   => '0',
    rst      => '0',
    clkin1   => clk,
    clkfbin  => clk_fb_sdram,
    clkfbout => clk_fb_sdram,
    clkout0  => dr_clk,             --  112.5     MHz phase shifted
    locked   => pll_locked_sdram
  );

  reset_combo1 <= sys_reset and pll_locked_main and pll_locked_sdram;
		
  u10 : entity work.poweronreset
  port map
  ( 
    clk => clk,
    reset_button => reset_combo1,
    reset_out => reset_n
  );
  reset <= not reset_n;
		
  led_floppy <= not diskoff; -- LED at EXPMOD PS/2 adapter
  led_Power <= reset_n; -- LED at EXPMOD PS/2 adapter

  myFampiga: entity work.Fampiga
  port map
  (
    clk=> clk,
    clk7m=> clk7m,
    clk28m=> clk28m,
    reset_n=>reset_n,
    --powerled_out=>power_leds(5 downto 4),
    diskled_out=>diskoff,
    --oddled_out=>odd_leds(5), 

    -- SDRAM.  A separate shifted clock is provided by the toplevel
    sdr_addr => dr_a,
    sdr_data => dr_d(15 downto 0),
    sdr_ba => dr_ba,
    sdr_cke => dr_cke,
    sdr_dqm => dr_dqm(1 downto 0),
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
    sigmaL => DAC_L,
    sigmaR => DAC_R,
    leftdatasum => leftdatasum,
    rightdatasum => rightdatasum,

    -- Game ports
    n_joy1 => n_joy1,
    n_joy2 => n_joy2,		
		
    -- RS232
    rs232_rxd => '1',
    rs232_txd => open,
		
    -- ESP8266 wifi modem
    amiga_rs232_rxd => '1',
    amiga_rs232_txd => open,
		
    -- SD card interface
    sd_cs => mmc_n_cs,
    sd_miso => mmc_miso,
    sd_mosi => mmc_mosi,
    sd_clk => mmc_clk
  );

  dr_d(31 downto 16) <= (others => 'Z');
  dr_dqm(3 downto 2) <= (others => '1');

  no_spdif_audio: if false generate -- disable audio generation, doesn't fit on device
  S_audio(23 downto 9) <= leftdatasum(14 downto 0);
  G_spdif_out: entity work.spdif_tx
  generic map
  (
    C_clk_freq => 28000000,  -- Hz
    C_sample_freq => 48000   -- Hz
  )
  port map
  (
    clk => clk_pixel,
    data_in => S_audio,
    spdif_out => S_spdif_out
  );
  -- audio_v(1 downto 0) <= (others => S_spdif_out);
  end generate;

  vga2dvi_converter: entity work.vga2dvid
  generic map
  (
      C_ddr     => C_dvid_ddr,
      C_depth   => 4 -- 4bpp (4 bit per pixel)
  )
  port map
  (
      clk_pixel => clk_pixel, -- 28 MHz
      clk_shift => clk_pixel_shift, -- 5*28 MHz

      in_red   => red_u,
      in_green => green_u,
      in_blue  => blue_u,

      in_hsync => hsync,
      in_vsync => vsync,
      in_blank => videoblank,

      -- single-ended output ready for vedor specific output buffers
      out_clock => dvid_crgb(7 downto 6),
      out_red   => dvid_crgb(5 downto 4),
      out_green => dvid_crgb(3 downto 2),
      out_blue  => dvid_crgb(1 downto 0)
  );

  G_dvi_sdr: if not C_dvid_ddr generate
  -- no vendor specific DDR and differntial buffers
  -- clk_pixel_shift = 10x clk_pixel
  gpdi_sdr_se: for i in 0 to 3 generate
    vid_d_p(i) <= dvid_crgb(2*i);
    vid_d_n(i) <= not dvid_crgb(2*i);
  end generate;
  end generate;

  G_dvi_ddr: if C_dvid_ddr generate
  -- vendor specific DDR and differential buffers
  -- clk_pixel_shift = 5x clk_pixel
  gpdi_ddr_diff: for i in 0 to 3 generate
    gpdi_ddr:   oddr generic map (DDR_CLK_EDGE => "SAME_EDGE", INIT => '0', SRTYPE => "SYNC") port map (D1=>dvid_crgb(2*i), D2=>dvid_crgb(2*i+1), Q=>ddr_d(i), C=>clk_pixel_shift, CE=>'1', R=>'0', S=>'0');
    gpdi_diff:  obufds port map(i => ddr_d(i), o => vid_d_p(i), ob => vid_d_n(i));
  end generate;
  end generate;

    -- adv7513 routing
    dv_clk <= clk_pixel;
    dv_de <= not videoblank;
    dv_hsync <= hsync;
    dv_vsync <= vsync;
    dv_d(23 downto 20) <= red_u;
    dv_d(19 downto 16) <= (others => red_u(0));
    dv_d(15 downto 12) <= green_u;
    dv_d(11 downto 8) <= (others => green_u(0));
    dv_d(7 downto 4) <= blue_u;
    dv_d(3 downto 0) <= (others => blue_u(0));

    i2c_send: entity work.i2c_sender
      port map
      (
        clk => clk_pixel,
        resend => reset,
        sioc => dv_scl,
        siod => dv_sda
      );

end struct;
