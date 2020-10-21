----------------------------
-- ULX3S Top level for MINIMIG
-- http://github.com/emard
----------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.ALL;
use IEEE.numeric_std.all;

library ecp5u;
use ecp5u.components.all;

-- package for usb joystick report decoded structure
use work.report_decoded_pack.all;
use work.usbh_setup_pack.all;

entity amiga_ulx3s is
generic
(
  C_usbhid:   boolean := false;
  C_programn: boolean := false; -- hold BTN0 to pull PROGRAMN low
  C_spdif:    boolean := false  -- SPDIF audio, may cause synthesis problems if enabled on 85F
);
port
(
  clk_25MHz: in std_logic;  -- main clock input from 25MHz clock source

  -- UART0 (FTDI USB slave serial)
  ftdi_rxd: out   std_logic;
  ftdi_txd: in    std_logic;
  -- FTDI additional signaling
  ftdi_ndsr: inout  std_logic;
  ftdi_nrts: inout  std_logic;
  ftdi_txden: inout std_logic;

  -- UART1 (WiFi serial)
  wifi_rxd: out   std_logic;
  wifi_txd: in    std_logic;
  -- WiFi additional signaling
  wifi_en: inout  std_logic := 'Z'; -- '0' will disable wifi by default
  wifi_gpio0, wifi_gpio2, wifi_gpio16, wifi_gpio17: inout std_logic := 'Z';

  -- ADC MAX11123
  adc_csn, adc_sclk, adc_mosi: out std_logic;
  adc_miso: in std_logic;

  -- SDRAM
  sdram_clk: out std_logic;
  sdram_cke: out std_logic;
  sdram_csn: out std_logic;
  sdram_rasn: out std_logic;
  sdram_casn: out std_logic;
  sdram_wen: out std_logic;
  sdram_a: out std_logic_vector (12 downto 0);
  sdram_ba: out std_logic_vector(1 downto 0);
  sdram_dqm: out std_logic_vector(1 downto 0);
  sdram_d: inout std_logic_vector (15 downto 0);

  -- Onboard blinky
  led: out std_logic_vector(7 downto 0);
  btn: in std_logic_vector(6 downto 0);
  sw: in std_logic_vector(3 downto 0);
  oled_csn, oled_clk, oled_mosi, oled_dc, oled_resn: out std_logic;

  -- GPIO
  gp, gn: inout std_logic_vector(27 downto 0);

  -- SHUTDOWN: logic '1' here will shutdown power on PCB >= v1.7.5
  shutdown: out std_logic := '0';

  -- PROGRAMN if pulled down, skip to multiboot from SPI flash
  user_programn: out std_logic := '1';

  -- Audio jack 3.5mm
  audio_l, audio_r, audio_v: inout std_logic_vector(3 downto 0) := (others => 'Z');

  -- Onboard antenna 433 MHz
  ant_433mhz: out std_logic;

  -- Digital Video (differential outputs)
  gpdi_dp, gpdi_dn: out std_logic_vector(2 downto 0);
  gpdi_clkp, gpdi_clkn: out std_logic;

  -- i2c shared for digital video and RTC
  gpdi_scl, gpdi_sda: inout std_logic;

  -- US2 port
  usb_fpga_dp: in std_logic;
  usb_fpga_bd_dp, usb_fpga_bd_dn: inout std_logic;
  usb_fpga_pu_dp, usb_fpga_pu_dn: out std_logic;

  -- Flash ROM (SPI0)
  -- commented out because it can't be used as GPIO
  -- when bitstream is loaded from config flash
  --flash_miso   : in      std_logic;
  --flash_mosi   : out     std_logic;
  --flash_clk    : out     std_logic;
  --flash_csn    : out     std_logic;

  -- SD card (SPI1)
  sd_dat3_csn, sd_cmd_di, sd_dat0_do, sd_dat1_irq, sd_dat2: inout std_logic;
  sd_clk: out std_logic;
  sd_cdn, sd_wp: in std_logic
);
end;

architecture struct of amiga_ulx3s is
  -- FLEA OHM aliasing
  -- keyboard
  alias ps2_clk1 : std_logic is usb_fpga_bd_dp;
  alias ps2_data1 : std_logic is usb_fpga_bd_dn;
  --alias ps2_clk1 : std_logic is gp(0);
  --alias ps2_data1 : std_logic is gn(0);
  --signal ps2_clk1 : std_logic := '1';
  --signal ps2_data1 : std_logic := '1';
  signal PS_enable: std_logic; -- dummy on ulx3s v1.7.x
  -- mouse
  alias ps2_clk2 : std_logic is gp(1);
  alias ps2_data2 : std_logic is gn(1);
  --signal ps2_clk2 : std_logic := '1';
  --signal ps2_data2 : std_logic := '1';

  alias sys_clock: std_logic is clk_25MHz;
  alias slave_rx_i: std_logic is ftdi_txd;
  alias slave_tx_o: std_logic is ftdi_rxd;
	
  signal LVDS_Red: std_logic_vector(0 downto 0);
  signal LVDS_Green: std_logic_vector(0 downto 0);
  signal LVDS_Blue: std_logic_vector(0 downto 0);
  signal LVDS_ck: std_logic_vector(0 downto 0);
  signal sys_reset: std_logic;

  alias mmc_dat1: std_logic is sd_dat1_irq;
  alias mmc_dat2: std_logic is sd_dat2;
  alias mmc_n_cs: std_logic is sd_dat3_csn;
  alias mmc_clk: std_logic is sd_clk;
  alias mmc_mosi: std_logic is sd_cmd_di;
  alias mmc_miso: std_logic is sd_dat0_do;
  -- END FLEA OHM ALIASING

  signal clk  : std_logic := '0';	
  signal clk7m  : std_logic := '0';
  signal clk28m  : std_logic := '0';   

  signal clk_usb : std_logic; -- 6MHz or 48MHz
 
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
	
  -- signal clk_vga   : std_logic := '0';
  signal PLL_lock  : std_logic := '0';
  signal n_15khz   : std_logic := '1';

  signal audio_data : std_logic_vector(17 downto 0);
  signal convert_audio_data : std_logic_vector(17 downto 0);

  signal DAC_R : std_logic;
  signal DAC_L : std_logic;

  signal l_audio_ena    : boolean; 
  signal r_audio_ena    : boolean;
	
  constant cnt_div: integer:=617;                  -- Countervalue for 48khz Audio Enable,  567 for 25MHz PCLK
  signal   cnt:     integer range 0 to cnt_div-1; 
  signal   ce:      std_logic;

  signal   rightdatasum  : std_logic_vector(14 downto 0);
  signal   leftdatasum   : std_logic_vector(14 downto 0);
  signal   left_sampled  : std_logic_vector(15 downto 0);
  signal   right_sampled : std_logic_vector(15 downto 0);

  signal   pll_locked 	: std_logic;
  signal   reset_n 	: std_logic;
  signal   reset_combo1 	: std_logic;

  -- emard audio-video and aliasing
  signal S_audio: std_logic_vector(23 downto 0) := (others => '0');
  signal S_spdif_out: std_logic;
  signal ddr_d: std_logic_vector(2 downto 0);
  signal ddr_clk: std_logic;
  signal dvid_red, dvid_green, dvid_blue, dvid_clock: std_logic_vector(1 downto 0);
  alias clk_pixel: std_logic is clk28m;
  alias clk_pixel_shift: std_logic is clk_dvi;
  alias clkn_pixel_shift: std_logic is clk_dvin;
  -- end emard AV
	
  -- emard usb hid joystick
  constant C_usb_speed: std_logic := '0'; -- 0:low 1:full
  signal S_hid_reset: std_logic;
  signal S_hid_report: std_logic_vector(C_report_length*8-1 downto 0);
  signal S_hid_valid: std_logic;
  signal S_report_decoded: T_report_decoded;
  -- end emard usb hid joystick
  signal R_program: std_logic_vector(26 downto 0);
begin
  wifi_gpio0 <= btn(0); -- holding reset for 2 sec will activate ESP32 loader
  --led(0) <= btn(0); -- visual indication of btn press
  -- btn(0) has inverted logic
  sys_reset <= btn(0);
  s_hid_reset <= not btn(0);
  sd_dat1_irq <= '1';
  sd_dat2 <= '1';

  G_yes_programn: if C_programn generate
  -- exit this FPGA core by pulling programn
  process(clk)
  begin
    if rising_edge(clk) then
      if btn(0) = '0' then
        R_program <= R_program + 1; -- BTN0 pressed
      else
        R_program <= (others => '0'); -- BTN0 released
      end if;
    end if;
  end process;
  user_programn <= not R_program(R_program'high); -- high bit is delayed after keyperss
  end generate;

  G_not_programn: if not C_programn generate
  user_programn <= '1';
  end generate;

  G_yes_usb_hid: if C_usbhid generate
  usbhid_host_inst: entity usbh_host_hid
  generic map
  (
    C_usb_speed => C_usb_speed -- '0':Low-speed '1':Full-speed
  )
  port map
  (
    clk => clk_usb, -- 6 MHz for low-speed USB1.0 device or 48 MHz for full-speed USB1.1 device
    bus_reset => S_hid_reset,
    usb_dif => usb_fpga_dp,
    usb_dp => usb_fpga_bd_dp,
    usb_dn => usb_fpga_bd_dn,
    hid_report => S_hid_report,
    hid_valid => S_hid_valid
  );
  usb_fpga_pu_dp <= '0';
  usb_fpga_pu_dn <= '0';

  usbhid_report_decoder_inst: entity usbhid_report_decoder
  generic map
  (
    C_rmouse => true, -- right stick to mouse quadrature encoder
    C_rmousex_scaler => 23, -- less -> faster mouse
    C_rmousey_scaler => 23  -- less -> faster mouse
  )
  port map
  (
    clk => clk_usb,
    hid_report => S_hid_report,
    hid_valid => S_hid_valid,
    decoded => S_report_decoded
  );

  process(clk_usb)
  begin
    if rising_edge(clk_usb) then
      -- Joystick1 port used as mouse (right stick)
      n_joy1(5) <= not (          S_report_decoded.btn_rmouse_right);  -- fire2
      n_joy1(4) <= not (btn(1) or S_report_decoded.btn_rmouse_left); -- fire
      n_joy1(3) <= not (S_report_decoded.rmouseq_y(0));       -- LSB quadrature y
      n_joy1(2) <= not (S_report_decoded.rmouseq_x(0));       -- LSB quadrature x
      n_joy1(1) <= not (S_report_decoded.rmouseq_y(1));       -- MSB quadrature y
      n_joy1(0) <= not (S_report_decoded.rmouseq_x(1));       -- MSB quadrature x

      -- Joystick2 port used as joystick (left stick, keys abxy, right trigger/bumper)
      -- Joystick2 bits(5-0) = fire2,fire,right,left,down,up mapped to GPIO header
      -- inverted logic: joystick switches pull down when pressed
      n_joy2(5) <= not (          S_report_decoded.btn_rbumper);  -- fire2
      n_joy2(4) <= not (btn(2) or S_report_decoded.btn_rtrigger or S_report_decoded.btn_back); -- fire
      n_joy2(3) <= not (btn(3) or S_report_decoded.btn_y or S_report_decoded.lstick_up   );     -- up
      n_joy2(2) <= not (btn(4) or S_report_decoded.btn_a or S_report_decoded.lstick_down );   -- down
      n_joy2(1) <= not (btn(5) or S_report_decoded.btn_x or S_report_decoded.lstick_left );   -- left
      n_joy2(0) <= not (btn(6) or S_report_decoded.btn_b or S_report_decoded.lstick_right);  -- right
    end if;
  end process;
  end generate; -- G_yes_usb_hid

  G_not_usb_hid: if not C_usbhid generate
  usb_fpga_pu_dp <= '1';
  usb_fpga_pu_dn <= '1';
  process(clk_usb)
  begin
    if rising_edge(clk_usb) then
      -- Joystick1 port used as mouse (right stick)
      n_joy1(5) <= not ('0');    -- fire2
      n_joy1(4) <= not (btn(1)); -- fire
      n_joy1(3) <= not ('0');    -- LSB quadrature y
      n_joy1(2) <= not ('0');    -- LSB quadrature x
      n_joy1(1) <= not ('0');    -- MSB quadrature y
      n_joy1(0) <= not ('0');    -- MSB quadrature x

      -- Joystick2 port used as joystick
      -- Joystick2 bits(5-0) = fire2,fire,right,left,down,up mapped to GPIO header
      -- inverted logic: joystick switches pull down when pressed
      n_joy2(5) <= not ('0');    -- fire2
      n_joy2(4) <= not (btn(2)); -- fire
      n_joy2(3) <= not (btn(3)); -- up
      n_joy2(2) <= not (btn(4)); -- down
      n_joy2(1) <= not (btn(5)); -- left
      n_joy2(0) <= not (btn(6)); -- right
    end if;
  end process;
  end generate; -- G_not_usb_hid

  led(0) <= not n_joy2(0); -- red
  led(3) <= not n_joy2(1); -- blue
  led(2) <= not n_joy2(2); -- green
  led(1) <= not n_joy2(3); -- orange
  led(4) <= not n_joy2(4); -- red
  led(5) <= not n_joy2(5); -- orange

  -- Video output horizontal scanrate select 15/30kHz select
  n_15khz <= '1'; -- sw(0) ; -- Default is '1' for 30kHz video out. set to '0' for 15kHz video.

  -- PS/2 Keyboard and Mouse definitions
  ps2k_dat_in<=PS2_data1;
  PS2_data1 <= '0' when ps2k_dat_out='0' else 'Z';
  ps2k_clk_in<=PS2_clk1;
  PS2_clk1 <= '0' when ps2k_clk_out='0' else 'Z';	
--  usb_fpga_pu_dp <= '1';
--  usb_fpga_pu_dn <= '1';

  ps2m_dat_in<=PS2_data2;
  PS2_data2 <= '0' when ps2m_dat_out='0' else 'Z';
  ps2m_clk_in<=PS2_clk2;
  PS2_clk2 <= '0' when ps2m_clk_out='0' else 'Z';	 

  clk0 : entity work.clk_minimig_vhdl
  port map
  (
    clkin   => sys_clock,
    clk_140 => clk_dvi,
    clk_112 => clk,
    clk_28  => clk28m,
    clk_7   => clk7m,
    locked  => pll_locked
  );

  G_clk_usb_low: if C_usb_speed = '0' generate
  clk1 : entity work.clk_ramusb_vhdl
  port map
  (
    clkin          => sys_clock,
    clk_112        => open,
    clk_112_120deg => sdram_clk,
    clk_6          => clk_usb    -- 6.05 MHz (ideal would be 6 MHz)
  );
  end generate;

  G_clk_usb_high: if C_usb_speed = '1' generate
    clk1 : entity work.clk_ramusb_vhdl
    port map
    (
      clkin          => sys_clock,
      clk_112        => open,
      clk_112_120deg =>	sdram_clk,
      clk_6	     => open       -- 6.05 MHz
    );
    clk2 : entity work.clk_usb_vhdl
    port map
    (
      clkin  => sys_clock,
      clk_48 => clk_usb,
      clk_6  => open
    );
  end generate;

  reset_combo1 <= sys_reset and pll_locked;

  E_power_on_reset : entity work.poweronreset
  port map( 
    clk => clk,
    reset_button => reset_combo1,
    reset_out => reset_n
  );

  led(7) <= not diskoff;

  myFampiga: entity work.Fampiga
  port map
  (
    clk     => clk,
    clk7m   => clk7m,
    clk28m  => clk28m,
    reset_n => reset_n,--GPIO_wordin(0),--reset_n,
    --powerled_out=>power_led(5 downto 4),
    diskled_out=>diskoff,
    --oddled_out=>odd_led(5), 

    -- SDRAM.  A separate shifted clock is provided by the toplevel
    sdr_addr => sdram_a,
    sdr_data => sdram_d,
    sdr_ba => sdram_ba,
    sdr_cke => sdram_cke,
    sdr_dqm => sdram_dqm,
    sdr_cs => sdram_csn,
    sdr_we => sdram_wen,
    sdr_cas => sdram_casn,
    sdr_ras => sdram_rasn,
	 
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
		
    -- ESP32 wifi modem
    amiga_rs232_rxd => wifi_txd,
    amiga_rs232_txd => wifi_rxd,
		
    -- SD card interface
    sd_cs => mmc_n_cs,
    sd_miso => mmc_miso,
    sd_mosi => mmc_mosi,
    sd_clk => mmc_clk
  );

  G_spdif_out: if C_spdif generate
  S_audio(23 downto 9) <= leftdatasum(14 downto 0);
  E_spdif_out: entity work.spdif_tx
  generic map
  (
    C_clk_freq => 28125000,  -- Hz
    C_sample_freq => 48000   -- Hz
  )
  port map
  (
    clk => clk_pixel,
    data_in => S_audio,
    spdif_out => S_spdif_out
  );
  audio_v(1 downto 0) <= (others => S_spdif_out);
  end generate;
  audio_l(3 downto 0) <= leftdatasum(14 downto 11);
  audio_r(3 downto 0) <= rightdatasum(14 downto 11);

  vga2dvi_converter: entity work.vga2dvid
  generic map
  (
      C_ddr     => true,
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

      -- single-ended output ready for differential buffers
      out_red   => dvid_red,
      out_green => dvid_green,
      out_blue  => dvid_blue,
      out_clock => dvid_clock
  );

  -- vendor specific DDR modules
  -- convert SDR 2-bit input to DDR clocked 1-bit output (single-ended)
  ddr_red:   ODDRX1F port map (D0=>dvid_red(0),   D1=>dvid_red(1),   Q=>ddr_d(2), SCLK=>clk_pixel_shift, RST=>'0');
  ddr_green: ODDRX1F port map (D0=>dvid_green(0), D1=>dvid_green(1), Q=>ddr_d(1), SCLK=>clk_pixel_shift, RST=>'0');
  ddr_blue:  ODDRX1F port map (D0=>dvid_blue(0),  D1=>dvid_blue(1),  Q=>ddr_d(0), SCLK=>clk_pixel_shift, RST=>'0');
  ddr_clock: ODDRX1F port map (D0=>dvid_clock(0), D1=>dvid_clock(1), Q=>ddr_clk,  SCLK=>clk_pixel_shift, RST=>'0');
  -- vendor specific modules for differential output
  gpdi_data_channels: for i in 0 to 2 generate
    gpdi_diff_data: OLVDS port map (A => ddr_d(i), Z => gpdi_dp(i), ZN => gpdi_dn(i));
  end generate;
  gpdi_diff_clock: OLVDS port map (A => ddr_clk, Z => gpdi_clkp, ZN => gpdi_clkn);

end struct;
