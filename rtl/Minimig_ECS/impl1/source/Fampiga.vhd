

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;

entity Fampiga is
port(
        clk     : in std_logic;
        clk7m : in std_logic;
        clk28m : in std_logic;
        reset_n : in std_logic;
        powerled_out : out std_logic;
        diskled_out : out std_logic;    -- Use for SD access
        oddled_out : out std_logic; -- Use for floppy access

        -- SDRAM.  A separate shifted clock is provided by the toplevel
        sdr_addr : out std_logic_vector(12 downto 0);
        sdr_data : inout std_logic_vector(15 downto 0);
        sdr_ba : out std_logic_vector(1 downto 0);
        sdr_cke : out std_logic;
        sdr_dqm : out std_logic_vector(1 downto 0);
        sdr_cs : out std_logic;
        sdr_we : out std_logic;
        sdr_cas : out std_logic; 
        sdr_ras : out std_logic; 
        
        -- Game ports
        n_joy1 : in std_logic_vector(5 downto 0);
        n_joy2 : in std_logic_vector(5 downto 0);
    
        -- VGA
        vga_r       : out std_logic_vector(7 downto 0);
        vga_g   : out std_logic_vector(7 downto 0);
        vga_b   : out std_logic_vector(7 downto 0);
        vid_blank   : out std_logic;
        vga_hsync   : out std_logic;
        vga_vsync   : out std_logic;
        n_15khz     : in std_logic;
 
        -- PS/2
        ps2k_clk_in : inout std_logic;
        ps2k_clk_out : inout std_logic;
        ps2k_dat_in : inout std_logic;
        ps2k_dat_out : inout std_logic;
        ps2m_clk_in : inout std_logic;
        ps2m_clk_out : inout std_logic;
        ps2m_dat_in : inout std_logic;
        ps2m_dat_out : inout std_logic;
        
        -- Audio
        sigmaL : out std_logic;
        sigmaR : out std_logic;
        leftdatasum : out std_logic_vector(14 downto 0);
        rightdatasum : out std_logic_vector(14 downto 0);
        
        -- RS232
        rs232_rxd : in std_logic;
        rs232_txd : out std_logic;
        
        -- ESP8266 wifi modem
        amiga_rs232_rxd : in std_logic;
        amiga_rs232_txd : out std_logic;

        -- SD card interface
        sd_cs : out std_logic; 
        sd_miso : in std_logic;
        sd_mosi : out std_logic;
        sd_clk : out std_logic

        -- FIXME - add joystick ports
    );
end entity;

architecture RTL of Fampiga is

-- CPU
signal cpu_address : std_logic_vector(31 downto 0);
signal cpu_data_in : std_logic_vector(15 downto 0);
signal cpu_data_out : std_logic_vector(15 downto 0);
signal cpu_data_from_ram : std_logic_vector(15 downto 0);
signal n_cpu_ipl : std_logic_vector(2 downto 0);
signal n_cpu_as : std_logic;
signal n_cpu_uds : std_logic;
signal n_cpu_lds : std_logic;
signal cpu_r_w : std_logic;
signal n_cpu_dtack : std_logic;
signal n_cpu_reset : std_logic;
 
-- SDRAM    
signal mm_ram_data_out : std_logic_vector(15 downto 0);
signal mm_ram_data_in : std_logic_vector(15 downto 0);
signal mm_ram_address : std_logic_vector(21 downto 1);
signal mm_ram_bhe : std_logic;
signal mm_ram_ble : std_logic;
signal mm_ram_we : std_logic;
signal mm_ram_oe : std_logic;

-- Config
signal cpu_config : std_logic_vector(1 downto 0);
signal mem_config : std_logic_vector(5 downto 0);
signal sdram_ready : std_logic;
signal cpu_ena : std_logic;

-- TG68 signals
signal wrd : std_logic;
signal ena7RDreg : std_logic;
signal ena7WRreg : std_logic;
signal enaWRreg : std_logic;
-- signal enaRDreg : std_logic;
        
signal cpu_ramaddr : std_logic_vector(31 downto 0);
signal cpustate : std_logic_vector(5 downto 0);

signal maincpuready : std_logic;
signal cpu_dma : std_logic;
signal cpu_ram_lds : std_logic;
signal cpu_ram_uds : std_logic;

-- OSD CPU signals
signal scandoubler : std_logic;
signal hostWR : std_logic_vector(15 downto 0);
signal hostNWR : std_logic;
signal hostAddr : std_logic_vector(23 downto 0);
signal hostState : std_logic_vector(2 downto 0);
signal hostL : std_logic;
signal hostU : std_logic;
signal hostRD : std_logic_vector(15 downto 0);
signal hostena  : std_logic;
signal hostena_in   : std_logic;
signal hostData : std_logic_vector(15 downto 0);

signal dummy1 : std_logic_vector(2 downto 0);
signal dummy2 : std_logic_vector(7 downto 0);




COMPONENT Minimig1
    GENERIC ( NTSC : integer := 0 );
    PORT
    (
        cpu_address     :    IN STD_LOGIC_VECTOR(23 DOWNTO 1);
        cpu_data        :    OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        cpu_wrdata      :    IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        n_cpu_ipl       :    OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        n_cpu_as        :    IN STD_LOGIC;
        n_cpu_uds       :    IN STD_LOGIC;
        n_cpu_lds       :    IN STD_LOGIC;
        cpu_r_w     :    IN STD_LOGIC;
        n_cpu_dtack     :    OUT STD_LOGIC;
        n_cpu_reset     :    OUT STD_LOGIC;
        ram_data        :    OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        ram_address     :    OUT STD_LOGIC_VECTOR(21 DOWNTO 1);
        n_ram_ce        :    OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        n_ram_bhe       :    OUT STD_LOGIC;
        n_ram_ble       :    OUT STD_LOGIC;
        n_ram_we        :    OUT STD_LOGIC;
        n_ram_oe        :    OUT STD_LOGIC;
        clk     :    IN STD_LOGIC;
        clk28m      :    IN STD_LOGIC;
        rxd     :    IN STD_LOGIC;
        txd     :    OUT STD_LOGIC;
        cts     :    IN STD_LOGIC;
        rts     :    OUT STD_LOGIC;
        n_joy1      :    IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        n_joy2      :    IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        n_15khz     :    IN STD_LOGIC;
        pwrled      :    OUT STD_LOGIC;
        kbddat      :    IN STD_LOGIC;
        kbdclk      :    IN STD_LOGIC;
        msdat       :    IN STD_LOGIC;
        msclk       :    IN STD_LOGIC;
        msdato      :    OUT STD_LOGIC;
        msclko      :    OUT STD_LOGIC;
        kbddato     :    OUT STD_LOGIC;
        kbdclko     :    OUT STD_LOGIC;
        n_scs       :    IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        direct_sdi      :    IN STD_LOGIC;
        sdi     :    IN STD_LOGIC;
        sdo     :    INOUT STD_LOGIC;
        sck     :    IN STD_LOGIC;
        n_hsync     :    OUT STD_LOGIC;
        n_vsync     :    OUT STD_LOGIC;
        video_blank     :    OUT STD_LOGIC;
        red     :    OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        green       :    OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        blue        :    OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        leftdatasum     :    OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
        rightdatasum    :    OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
        left : OUT STD_LOGIC;
        right : OUT STD_LOGIC;
        cpu_config      :    OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        memcfg      :    OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        drv_snd     :    OUT STD_LOGIC;
        floppyled       :    OUT STD_LOGIC; 
        init_b      :    OUT STD_LOGIC;
        ramdata_in      :    IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        cpurst      :    IN STD_LOGIC;
        locked      :    IN STD_LOGIC;
        sysclock        :    IN STD_LOGIC;
        ascancode       :    IN STD_LOGIC_VECTOR(8 DOWNTO 0);
        n_joy3      :    IN STD_LOGIC_VECTOR(5 DOWNTO 0);
        n_joy4      :    IN STD_LOGIC_VECTOR(5 DOWNTO 0)
    );
END COMPONENT;

-- Peripherals

signal spi_chipselect : std_logic_vector(7 downto 0);   
signal spi_sdi : std_logic;
signal spi_sdo : std_logic;
signal spi_sck : std_logic;
signal sysreset : std_logic;
signal clk_enablez : std_logic;
signal ramm_address : std_logic_vector(23 downto 1);
-- Misc

signal fastramcfg : std_logic_vector(2 downto 0);
signal turbochipram : std_logic;

signal powerled : std_logic;
-- signal sdled : std_logic;
signal floppyled : std_logic;
signal cpu_reset1 : std_logic;

-- DEBUG HOSTCPU
-- attribute mark_debug : string; 
-- attribute mark_debug of sdram_ready : signal is "true";
-- attribute mark_debug of clk_enablez : signal is "true";
-- attribute mark_debug of hostData : signal is "true";
-- attribute mark_debug of hostAddr : signal is "true";
-- attribute mark_debug of hostWR : signal is "true";
-- attribute mark_debug of hostU : signal is "true";
-- attribute mark_debug of hostL : signal is "true";
-- attribute mark_debug of hostState : signal is "true";
-- DEBUG

-- DEBUG CFIDE + SDRAM
-- attribute mark_debug : string; 
-- attribute mark_debug of hostAddr : signal is "true";
-- attribute mark_debug of hostWR : signal is "true";
-- attribute mark_debug of hostRD : signal is "true";
-- attribute mark_debug of hostL : signal is "true";
-- attribute mark_debug of hostU : signal is "true";
-- attribute mark_debug of sdr_we : signal is "true";
-- attribute mark_debug of sdr_cs : signal is "true";
-- attribute mark_debug of hostena : signal is "true";
-- attribute mark_debug of enaWRreg : signal is "true";
-- attribute mark_debug of hostState : signal is "true";
-- attribute mark_debug of hostData : signal is "true";
-- DEBUG


begin
    sdr_cke<='1';
    powerled_out<=powerled;
    oddled_out<=floppyled;
    diskled_out<=spi_chipselect(1);

    sd_clk <= spi_sck;
    sd_cs <= spi_chipselect(1);
    sd_mosi <= spi_sdi;

    
MyMinimig: COMPONENT Minimig1
    generic map
    (
        NTSC => 0 
    )
    port map
    (
        -- CPU signals
        cpu_address => cpu_address(23 downto 1),
        cpu_data => cpu_data_in,
        cpu_wrdata => cpu_data_out,
        n_cpu_ipl => n_cpu_ipl,
        n_cpu_as => n_cpu_as,
        n_cpu_uds => n_cpu_uds,
        n_cpu_lds => n_cpu_lds,
        cpu_r_w => cpu_r_w,
        n_cpu_dtack => n_cpu_dtack,
        n_cpu_reset => n_cpu_reset,
        
        -- SDRAM
        
        ram_data => mm_ram_data_out,
        ram_address => mm_ram_address,
        n_ram_ce => open, -- mm_ram_ce,
        n_ram_bhe => mm_ram_bhe,
        n_ram_ble => mm_ram_ble,
        n_ram_we => mm_ram_we,
        n_ram_oe => mm_ram_oe,
        
        -- Clocks
        
        clk => clk7m, -- 113Mhz
        clk28m => clk28m, -- 28Mhz
        
        -- Peripherals
        
        rxd => amiga_rs232_rxd,
        txd => amiga_rs232_txd,
        --rxd => '1',
        --txd => open,
        cts => '0',
        rts => open,
        n_joy1 => n_joy1,
        n_joy2 => n_joy2,
        n_15khz => n_15khz,
        pwrled => powerled,
        kbddat => ps2k_dat_in,
        kbdclk => ps2k_clk_in,
        msdat => ps2m_dat_in,
        msclk => ps2m_clk_in,
        msdato => ps2m_dat_out,
        msclko => ps2m_clk_out,
        kbddato => ps2k_dat_out,
        kbdclko => ps2k_clk_out,
        n_scs => spi_chipselect(6 downto 4),
        direct_sdi => sd_miso,
        sdi => spi_sdi,
        sdo => spi_sdo,
        sck => spi_sck,
        
        -- Video
        
        n_hsync => vga_hsync,
        n_vsync => vga_vsync,
        video_blank => vid_blank,
        red => vga_r,
        green => vga_g,
        blue => vga_b, 
        
        -- Audio
         left => sigmaL,
         right => sigmaR,       
        leftdatasum => leftdatasum,
        rightdatasum => rightdatasum,
        
        cpu_config => cpu_config,
        memcfg => mem_config, 
        drv_snd => open,
        floppyled => oddled_out,
        init_b => open,
        ramdata_in => mm_ram_data_in,
        cpurst => cpu_reset1,
        locked => sdram_ready,
        sysclock => clk,
        ascancode => "100000000",
        n_joy3 => "111111",
        n_joy4 => "111111"
    );
    
    cpu_reset1 <= not (maincpuready and n_cpu_reset and sdram_ready);
    sysreset <= n_cpu_reset and sdram_ready;
     
MainCPU: entity work.TG68K
   port map
    (        
      clk => clk,
      reset => sysreset,
      clkena_in => '1',
        
      -- Standard MC68000 signals...
        
      IPL => n_cpu_ipl,
      dtack => n_cpu_dtack,

      vpa => '1',
      ein => '1',
       
      addr => cpu_address,
      data_read => cpu_data_in,
      data_write => cpu_data_out,
      as => n_cpu_as,
      uds => n_cpu_uds,
      lds => n_cpu_lds,
      rw => cpu_r_w,
      --e => open,
      --vma => open,

      -- TG68 specific signals...
          
      wrd => wrd,
      ena7RDreg => ena7RDreg,
      ena7WRreg => ena7WRreg,
      enaWRreg => enaWRreg,
       
      fromram => cpu_data_from_ram,
      ramready => cpu_ena,  -- dtack equivalent for fastram access 
      cpu => cpu_config,
      fastramcfg => fastramcfg,
      turbochipram => turbochipram,
      ramaddr => cpu_ramaddr,
      cpustate => cpustate,

      nResetOut => maincpuready,
      --skipFetch => open,
      cpuDMA => cpu_dma,
      ramlds => cpu_ram_lds,
      ramuds => cpu_ram_uds
    );

 ramm_address <= "00"&mm_ram_address;
 

mysdram : entity work.sdram
    port map
    ( 
        sdata => sdr_data,
        sdaddr => sdr_addr,
        dqm => sdr_dqm,
        sd_cs(0) => sdr_cs,
        sd_cs(3 downto 1) => dummy1,    
        ba => sdr_ba, 
        sd_we => sdr_we,
        sd_ras => sdr_ras, 
        sd_cas => sdr_cas,

        sysclk => clk,
        reset_in => reset_n,
    
        hostWR => hostWR,
--        hostNWR => hostNWR,
        hostAddr => hostAddr,
        hostState => hostState,
        hostL => hostL,
        hostU => hostU,
        hostRD => hostRD,
        hostena => hostena_in,

        cpuWR => cpu_data_out,
        cpuAddr => cpu_ramaddr(24 downto 1),
        cpuU => cpu_ram_uds,
        cpuL => cpu_ram_lds,
        cpustate => cpustate,
        cpu_dma => cpu_dma,
        cpuRD => cpu_data_from_ram,
        cpuena => cpu_ena,
        
        chipWR => mm_ram_data_out,
        chipAddr => ramm_address,
        chipU => mm_ram_bhe,
        chipL => mm_ram_ble,
        chipRW => mm_ram_we,
        chip_dma => mm_ram_oe,
        chipRD => mm_ram_data_in,

        c_7m => clk7m,

        reset_out => sdram_ready,
        --enaRDreg => open,
        enaWRreg => enaWRreg,
        ena7RDreg => ena7RDreg,
        ena7WRreg => ena7WRreg
    );

    
mycfide : entity work.cfide 
   port map ( 
        sysclk => clk,
        n_reset => sdram_ready,
        cpuena_in => hostena_in,
        memdata_in => hostRD,
        addr => hostAddr,
        cpudata_in => hostWR,
        state => hostState(1 downto 0),
        lds => hostL,
        uds => hostU,
        sd_di => spi_sdo,
         
        fastramsize => fastramcfg,
        turbochipram => turbochipram,
        scandoubler => scandoubler, 
        memce => hostState(2),
        cpudata => hostData,
        cpuena => hostena,  -- And with enaWRreg as host clkena_in
        sd_cs => spi_chipselect,
        sd_clk => spi_sck,
        sd_do => spi_sdi,
        sd_dimm => sd_miso,
        enaWRreg => enaWRreg,
        debugTxD => rs232_txd,
        debugRxD => rs232_rxd
   );


clk_enablez <= hostena and enaWRreg;
myhostcpu : entity work.TG68KdotC_Kernel
   port map(clk => clk,
        nReset => sdram_ready,
        clkena_in => clk_enablez,
        data_in => hostData,
        addr(23 downto 0) => hostAddr, 
        addr(31 downto 24) => dummy2,
        data_write => hostWR,
        nWr => hostNWR, -- uses busstate instead?
        nUDS => hostU,
        nLDS => hostL,
        busstate => hostState(1 downto 0)
        --nResetOut => open,
        --FC => open,
-- for debug        
        --skipFetct => open,
        --regin => open
    );


   
    
end rtl;


