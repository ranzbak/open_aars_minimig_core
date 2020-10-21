library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;

entity poweronreset is
	port(
		clk : in std_logic;
		reset_button : in std_logic;
		reset_out : out std_logic
	);
end entity;

architecture rtl of poweronreset is
signal counter : unsigned(16 downto 0):=(others => '0');
signal resetbutton_debounced : std_logic;
signal powerbutton_debounced : std_logic;
signal power_cut : std_logic;

begin
	mydb : entity work.debounce
		port map(
			clk=>clk,
			signal_in=>reset_button,
			signal_out=>resetbutton_debounced
		);
	reset_out <= counter(counter'high);
	process(clk)
	begin
		if(rising_edge(clk)) then
			if resetbutton_debounced='0' then
				counter<=(others => '0');
			elsif counter(counter'high)='1' then
			else
				counter <= counter+1;
			end if;
		end if;
	end process;

end architecture;
