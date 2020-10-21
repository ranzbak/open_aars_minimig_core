-- Preloaded RAM with single clock
-- converted by osdbootstrap_bin2vhdl.py

-- when pass_thru enabled on port
-- then Read-during-write on port should return newly written data

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity osd_bootstrap is
	generic 
	(
		pass_thru_a: boolean := True;
		data_width: natural := 16;
		addr_width: natural := 11
	);
	port 
	(
		clk: in std_logic;
		addr_a: in std_logic_vector((addr_width-1) downto 0);
		we_a: in std_logic_vector(1 downto 0) := "00";
		data_in_a: in std_logic_vector((data_width-1) downto 0);
		data_out_a: out std_logic_vector((data_width-1) downto 0)
	);
end osd_bootstrap;

architecture rtl of osd_bootstrap is
	-- Build a 2-D array type for the RAM
	subtype data_t is std_logic_vector((8-1) downto 0);
	type memory_t is array(0 to 2**addr_width-1) of data_t;

	-- Declare the RAM
shared variable ram0: memory_t := (
x"00",x"00",x"00",x"08",x"fc",x"55",x"00",x"0e",
x"00",x"80",x"50",x"fc",x"40",x"00",x"14",x"00",
x"1c",x"0c",x"79",x"00",x"14",x"00",x"10",x"2e",
x"00",x"56",x"fa",x"3c",x"00",x"9a",x"20",x"fa",
x"2c",x"00",x"7e",x"7c",x"00",x"00",x"18",x"04",
x"f8",x"00",x"fc",x"fe",x"00",x"f8",x"00",x"fa",
x"08",x"00",x"5e",x"fe",x"6f",x"20",x"6f",x"6e",
x"20",x"53",x"5f",x"41",x"31",x"59",x"00",x"f8",
x"00",x"79",x"aa",x"00",x"0e",x"0a",x"ba",x"82",
x"04",x"00",x"75",x"fc",x"aa",x"00",x"0e",x"c0",
x"00",x"10",x"00",x"aa",x"4e",x"3c",x"20",x"bc",
x"ff",x"41",x"2e",x"11",x"bc",x"ff",x"3c",x"fe",
x"f0",x"3c",x"ff",x"11",x"bc",x"ff",x"c0",x"c9",
x"f6",x"bc",x"ff",x"7c",x"03",x"04",x"e8",x"00",
x"00",x"75",x"fc",x"55",x"00",x"0e",x"fa",x"86",
x"00",x"d0",x"fe",x"75",x"fc",x"55",x"00",x"0e",
x"fa",x"5a",x"00",x"bc",x"ff",x"75",x"3c",x"95",
x"40",x"00",x"40",x"3c",x"ff",x"41",x"00",x"36",
x"3c",x"87",x"48",x"3c",x"00",x"aa",x"28",x"3c",
x"87",x"69",x"3c",x"00",x"00",x"1a",x"3c",x"ff",
x"77",x"00",x"10",x"3c",x"ff",x"7a",x"00",x"06",
x"3c",x"ff",x"51",x"f9",x"da",x"00",x"bc",x"ff",
x"7c",x"02",x"04",x"81",x"41",x"79",x"00",x"0c",
x"10",x"98",x"80",x"98",x"80",x"98",x"80",x"98",
x"12",x"80",x"40",x"80",x"40",x"58",x"80",x"58",
x"80",x"00",x"80",x"81",x"3c",x"00",x"40",x"81",
x"0c",x"bc",x"ff",x"11",x"3c",x"ff",x"f0",x"00",
x"75",x"01",x"01",x"04",x"01",x"09",x"01",x"00",
x"01",x"01",x"04",x"01",x"09",x"01",x"00",x"01",
x"01",x"04",x"01",x"09",x"01",x"00",x"01",x"01",
x"04",x"01",x"09",x"01",x"00",x"01",x"01",x"04",
x"01",x"09",x"01",x"00",x"01",x"01",x"04",x"01",
x"09",x"01",x"00",x"01",x"01",x"04",x"01",x"09",
x"01",x"00",x"01",x"01",x"04",x"01",x"09",x"01",
x"00",x"75",x"74",x"72",x"20",x"6e",x"74",x"0a",
x"49",x"69",x"20",x"6f",x"65",x"0a",x"49",x"69",
x"20",x"61",x"6c",x"72",x"0d",x"00",x"65",x"65",
x"20",x"61",x"6c",x"72",x"0d",x"00",x"6f",x"6d",
x"6e",x"20",x"69",x"65",x"75",x"5f",x"72",x"6f",
x"0d",x"00",x"69",x"65",x"75",x"5f",x"72",x"6f",
x"0d",x"00",x"44",x"43",x"66",x"75",x"64",x"0d",
x"00",x"fc",x"ff",x"00",x"0c",x"f9",x"da",x"00",
x"7c",x"ff",x"04",x"7c",x"20",x"08",x"3c",x"64",
x"bc",x"ff",x"c9",x"fa",x"3c",x"32",x"00",x"4e",
x"7c",x"03",x"04",x"3c",x"01",x"12",x"ca",x"ee",
x"7a",x"7a",x"00",x"fa",x"8f",x"ff",x"75",x"3c",
x"00",x"00",x"bc",x"ff",x"81",x"f8",x"00",x"32",
x"3c",x"01",x"7c",x"bc",x"ff",x"bc",x"ff",x"bc",
x"ff",x"11",x"00",x"01",x"68",x"bc",x"ff",x"11",
x"00",x"aa",x"5c",x"7c",x"03",x"04",x"7a",x"66",
x"00",x"ae",x"8f",x"3c",x"32",x"42",x"44",x"3c",
x"d0",x"bc",x"ff",x"c9",x"fa",x"00",x"00",x"3c",
x"01",x"e6",x"00",x"e8",x"e0",x"00",x"fa",x"da",
x"bc",x"ff",x"11",x"3c",x"40",x"08",x"fc",x"00",
x"00",x"0c",x"bc",x"ff",x"bc",x"ff",x"bc",x"ff",
x"34",x"fc",x"00",x"00",x"0c",x"3c",x"0a",x"3c",
x"d0",x"bc",x"ff",x"c9",x"fa",x"00",x"8a",x"16",
x"7c",x"03",x"04",x"ca",x"e6",x"7a",x"a1",x"30",
x"8f",x"ff",x"75",x"7c",x"01",x"08",x"7c",x"03",
x"04",x"bc",x"ff",x"7a",x"79",x"14",x"8f",x"00",
x"75",x"18",x"08",x"c0",x"da",x"00",x"f4",x"75",
x"08",x"6f",x"08",x"10",x"08",x"d8",x"da",x"00",
x"f4",x"5f",x"75",x"00",x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"c0",
x"00",x"2c",x"00",x"38",x"4a",x"28",x"55",x"fe",
x"42",x"28",x"aa",x"ff",x"3a",x"3a",x"b8",x"7c",
x"70",x"7c",x"40",x"30",x"e8",x"be",x"c0",x"29",
x"08",x"58",x"40",x"58",x"c0",x"00",x"2c",x"00",
x"fe",x"10",x"28",x"55",x"fe",x"08",x"28",x"aa",
x"ff",x"04",x"ff",x"75",x"a8",x"41",x"31",x"36",
x"24",x"fc",x"0c",x"00",x"16",x"a8",x"20",x"20",
x"3a",x"36",x"fc",x"10",x"00",x"16",x"a8",x"20",
x"20",x"3a",x"24",x"fc",x"00",x"00",x"16",x"a8",
x"41",x"33",x"52",x"bc",x"a8",x"20",x"20",x"56",
x"b2",x"fc",x"20",x"00",x"16",x"28",x"0a",x"bc",
x"ff",x"00",x"80",x"00",x"00",x"98",x"3a",x"2e",
x"28",x"0e",x"58",x"80",x"c1",x"00",x"30",x"39",
x"20",x"00",x"16",x"24",x"28",x"2c",x"58",x"40",
x"58",x"c0",x"00",x"18",x"28",x"24",x"58",x"40",
x"58",x"80",x"28",x"10",x"f8",x"32",x"00",x"c0",
x"00",x"18",x"28",x"16",x"58",x"80",x"28",x"10",
x"f8",x"c1",x"00",x"1c",x"01",x"28",x"12",x"48",
x"28",x"11",x"c0",x"00",x"3a",x"48",x"80",x"00",
x"28",x"0d",x"c0",x"00",x"38",x"80",x"80",x"c1",
x"00",x"34",x"00",x"75",x"3a",x"8e",x"c0",x"00",
x"20",x"22",x"b9",x"00",x"20",x"3a",x"9e",x"48",
x"c0",x"00",x"24",x"3a",x"74",x"c0",x"00",x"26",
x"75",x"3a",x"6c",x"3a",x"80",x"c1",x"00",x"24",
x"49",x"04",x"88",x"f8",x"ba",x"6a",x"c0",x"00",
x"26",x"75",x"e7",x"20",x"49",x"00",x"a2",x"78",
x"0f",x"10",x"72",x"0a",x"32",x"00",x"30",x"00",
x"0a",x"3c",x"20",x"30",x"00",x"36",x"c8",x"ea",
x"00",x"28",x"0b",x"c0",x"00",x"2a",x"39",x"20",
x"00",x"16",x"08",x"28",x"14",x"58",x"40",x"28",
x"1a",x"58",x"c0",x"00",x"20",x"df",x"04",x"ff",
x"75",x"e8",x"20",x"ca",x"aa",x"3a",x"ea",x"80",
x"c0",x"00",x"26",x"79",x"00",x"24",x"8c",x"46",
x"06",x"00",x"5e",x"82",x"df",x"04",x"00",x"75",
x"6f",x"04",x"00",x"4c",x"00",x"3a",x"24",x"e8",
x"00",x"3a",x"b2",x"80",x"c0",x"00",x"26",x"79",
x"00",x"24",x"e2",x"08",x"0c",x"5f",x"d6",x"08",
x"75",x"00",x"75",x"39",x"20",x"00",x"16",x"38",
x"39",x"0c",x"00",x"16",x"6c",x"3a",x"74",x"88",
x"ba",x"7e",x"00",x"c8",x"58",x"3a",x"67",x"40",
x"30",x"00",x"58",x"c0",x"00",x"20",x"bc",x"ff",
x"0f",x"7c",x"ff",x"75",x"3a",x"46",x"88",x"ba",
x"50",x"00",x"9a",x"2a",x"3a",x"39",x"7c",x"7f",
x"40",x"40",x"30",x"00",x"58",x"40",x"58",x"c0",
x"00",x"20",x"bc",x"00",x"07",x"bc",x"ff",x"ff",
x"75",x"00",x"75",x"02",x"3a",x"06",x"00",x"80",
x"81",x"00",x"88",x"88",x"ba",x"06",x"00",x"00",
x"4e",x"52",x"01",x"88",x"7c",x"ff",x"7c",x"ff",
x"14",x"30",x"00",x"42",x"80",x"00",x"32",x"36",
x"4a",x"10",x"0a",x"30",x"00",x"4a",x"30",x"01",
x"5a",x"7c",x"01",x"02",x"4a",x"bc",x"00",x"ff",
x"c2",x"00",x"20",x"bc",x"ff",x"0f",x"02",x"1f",
x"7c",x"ff",x"75",x"1f",x"00",x"75",
others => (others => '0'));
shared variable ram1: memory_t := (
x"00",x"10",x"00",x"00",x"33",x"55",x"00",x"04",
x"61",x"02",x"66",x"33",x"00",x"00",x"04",x"61",
x"04",x"67",x"42",x"00",x"04",x"61",x"04",x"66",
x"61",x"05",x"43",x"00",x"61",x"05",x"67",x"41",
x"00",x"61",x"03",x"30",x"20",x"61",x"06",x"67",
x"4e",x"20",x"31",x"60",x"20",x"4e",x"20",x"41",
x"00",x"61",x"03",x"60",x"6e",x"74",x"66",x"75",
x"64",x"4f",x"44",x"43",x"30",x"53",x"53",x"41",
x"10",x"0c",x"aa",x"00",x"04",x"66",x"b0",x"03",
x"66",x"70",x"4e",x"33",x"aa",x"00",x"04",x"23",
x"00",x"04",x"61",x"00",x"66",x"32",x"4e",x"12",
x"00",x"53",x"67",x"30",x"12",x"00",x"b0",x"00",
x"66",x"32",x"01",x"30",x"12",x"00",x"10",x"51",
x"ff",x"12",x"00",x"33",x"00",x"00",x"41",x"fe",
x"70",x"4e",x"33",x"55",x"00",x"04",x"41",x"01",
x"61",x"02",x"70",x"4e",x"33",x"55",x"00",x"04",
x"41",x"01",x"61",x"02",x"70",x"4e",x"22",x"00",
x"00",x"70",x"60",x"22",x"00",x"00",x"70",x"60",
x"22",x"00",x"00",x"20",x"00",x"01",x"60",x"22",
x"00",x"00",x"20",x"40",x"00",x"60",x"22",x"00",
x"00",x"70",x"60",x"22",x"00",x"00",x"70",x"60",
x"22",x"00",x"00",x"43",x"00",x"40",x"12",x"00",
x"33",x"00",x"00",x"12",x"48",x"4a",x"00",x"04",
x"67",x"e1",x"12",x"e1",x"12",x"e1",x"12",x"e1",
x"60",x"d0",x"48",x"12",x"48",x"e1",x"12",x"e1",
x"12",x"70",x"12",x"12",x"22",x"00",x"9c",x"53",
x"67",x"12",x"00",x"30",x"b0",x"00",x"67",x"80",
x"4e",x"d2",x"b1",x"6a",x"0a",x"00",x"b1",x"d0",
x"d2",x"b1",x"6a",x"0a",x"00",x"b1",x"d0",x"d2",
x"b1",x"6a",x"0a",x"00",x"b1",x"d0",x"d2",x"b1",
x"6a",x"0a",x"00",x"b1",x"d0",x"d2",x"b1",x"6a",
x"0a",x"00",x"b1",x"d0",x"d2",x"b1",x"6a",x"0a",
x"00",x"b1",x"d0",x"d2",x"b1",x"6a",x"0a",x"00",
x"b1",x"d0",x"d2",x"b1",x"6a",x"0a",x"00",x"b1",
x"d0",x"4e",x"53",x"61",x"74",x"49",x"69",x"0d",
x"00",x"6e",x"74",x"64",x"6e",x"0d",x"00",x"6e",
x"74",x"66",x"69",x"75",x"65",x"0a",x"52",x"73",
x"74",x"66",x"69",x"75",x"65",x"0a",x"43",x"6d",
x"61",x"64",x"54",x"6d",x"6f",x"74",x"45",x"72",
x"72",x"0a",x"54",x"6d",x"6f",x"74",x"45",x"72",
x"72",x"0a",x"53",x"48",x"20",x"6f",x"6e",x"20",
x"0a",x"33",x"ff",x"00",x"04",x"43",x"00",x"40",
x"33",x"00",x"00",x"33",x"00",x"00",x"32",x"00",
x"32",x"ff",x"51",x"ff",x"34",x"00",x"61",x"fe",
x"33",x"00",x"00",x"b0",x"00",x"67",x"51",x"ff",
x"48",x"ff",x"61",x"00",x"58",x"70",x"4e",x"22",
x"00",x"20",x"12",x"00",x"53",x"66",x"61",x"fe",
x"b0",x"00",x"66",x"12",x"00",x"12",x"00",x"12",
x"00",x"10",x"0c",x"00",x"66",x"12",x"00",x"10",
x"0c",x"00",x"66",x"33",x"00",x"00",x"48",x"ff",
x"61",x"00",x"58",x"34",x"00",x"53",x"67",x"32",
x"07",x"12",x"00",x"51",x"ff",x"61",x"fe",x"b0",
x"00",x"66",x"61",x"fd",x"66",x"61",x"fd",x"66",
x"12",x"00",x"10",x"c0",x"00",x"66",x"33",x"00",
x"00",x"04",x"12",x"00",x"12",x"00",x"12",x"00",
x"60",x"33",x"00",x"00",x"04",x"34",x"00",x"32",
x"07",x"12",x"00",x"51",x"ff",x"61",x"fd",x"67",
x"33",x"00",x"00",x"51",x"ff",x"48",x"fe",x"61",
x"58",x"70",x"4e",x"33",x"00",x"00",x"33",x"00",
x"00",x"12",x"00",x"48",x"fe",x"61",x"58",x"70",
x"4e",x"10",x"67",x"13",x"00",x"80",x"60",x"4e",
x"2f",x"20",x"00",x"4a",x"67",x"13",x"00",x"80",
x"60",x"20",x"4e",x"00",x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",
x"00",x"00",x"00",x"00",x"00",x"00",x"70",x"23",
x"00",x"04",x"61",x"fc",x"66",x"0c",x"00",x"01",
x"66",x"0c",x"00",x"01",x"66",x"30",x"ff",x"c0",
x"00",x"b0",x"00",x"64",x"43",x"01",x"d2",x"20",
x"00",x"e0",x"48",x"e0",x"23",x"00",x"04",x"61",
x"fb",x"66",x"0c",x"00",x"01",x"66",x"0c",x"00",
x"01",x"67",x"70",x"4e",x"0c",x"46",x"54",x"00",
x"66",x"13",x"00",x"00",x"04",x"0c",x"32",x"20",
x"00",x"67",x"13",x"00",x"00",x"04",x"0c",x"36",
x"20",x"00",x"67",x"13",x"00",x"00",x"04",x"0c",
x"46",x"54",x"00",x"66",x"0c",x"32",x"20",x"00",
x"66",x"13",x"00",x"00",x"04",x"20",x"00",x"c0",
x"00",x"ff",x"0c",x"00",x"02",x"66",x"22",x"ff",
x"30",x"00",x"e0",x"d2",x"23",x"00",x"04",x"0c",
x"00",x"00",x"04",x"66",x"20",x"00",x"e0",x"48",
x"e0",x"23",x"00",x"04",x"20",x"00",x"e0",x"48",
x"e0",x"d2",x"53",x"00",x"66",x"60",x"70",x"23",
x"00",x"04",x"30",x"00",x"e0",x"d2",x"53",x"00",
x"66",x"23",x"00",x"04",x"20",x"10",x"00",x"e1",
x"10",x"00",x"33",x"00",x"04",x"e8",x"d2",x"70",
x"10",x"00",x"33",x"00",x"04",x"92",x"92",x"23",
x"00",x"04",x"70",x"4e",x"20",x"fe",x"23",x"00",
x"04",x"66",x"42",x"00",x"04",x"30",x"fe",x"e8",
x"33",x"00",x"04",x"20",x"fe",x"23",x"00",x"04",
x"4e",x"20",x"fe",x"32",x"fe",x"33",x"00",x"04",
x"e2",x"65",x"e3",x"60",x"d0",x"fe",x"23",x"00",
x"04",x"4e",x"48",x"20",x"24",x"61",x"fa",x"66",
x"74",x"4a",x"67",x"70",x"12",x"00",x"b2",x"00",
x"67",x"d2",x"00",x"b2",x"00",x"66",x"51",x"ff",
x"70",x"10",x"00",x"33",x"00",x"04",x"0c",x"00",
x"00",x"04",x"66",x"30",x"00",x"e0",x"48",x"30",
x"00",x"e0",x"23",x"00",x"04",x"4c",x"04",x"70",
x"4e",x"41",x"00",x"51",x"ff",x"20",x"fd",x"52",
x"23",x"00",x"04",x"53",x"00",x"04",x"66",x"61",
x"67",x"61",x"ff",x"60",x"4c",x"04",x"70",x"4e",
x"20",x"00",x"61",x"ff",x"61",x"fa",x"66",x"41",
x"02",x"20",x"fd",x"52",x"23",x"00",x"04",x"53",
x"00",x"04",x"66",x"2f",x"61",x"20",x"66",x"20",
x"4e",x"70",x"4e",x"0c",x"00",x"00",x"04",x"67",
x"0c",x"00",x"00",x"04",x"67",x"20",x"fd",x"e0",
x"d0",x"fd",x"61",x"f9",x"66",x"10",x"fd",x"d0",
x"30",x"00",x"e0",x"23",x"00",x"04",x"80",x"ff",
x"00",x"b0",x"ff",x"4e",x"20",x"fd",x"ee",x"d0",
x"fd",x"61",x"f9",x"66",x"10",x"fd",x"c0",x"00",
x"d0",x"d0",x"20",x"00",x"e0",x"48",x"e0",x"23",
x"00",x"04",x"80",x"f0",x"00",x"b0",x"ff",x"ff",
x"4e",x"70",x"4e",x"2f",x"20",x"fd",x"22",x"d0",
x"d0",x"22",x"e0",x"e4",x"d0",x"fd",x"24",x"61",
x"f9",x"66",x"20",x"e2",x"c0",x"01",x"b0",x"01",
x"66",x"10",x"00",x"c1",x"52",x"61",x"f9",x"66",
x"e1",x"14",x"60",x"14",x"00",x"e1",x"14",x"00",
x"e1",x"c2",x"00",x"67",x"e8",x"c4",x"00",x"0f",
x"23",x"00",x"04",x"84",x"ff",x"f0",x"20",x"24",
x"b0",x"ff",x"4e",x"24",x"70",x"4e",
others => (others => '0'));

begin
	-- Port A
	G_port_a_passthru: if pass_thru_a generate
	process(clk)
	begin
	if(rising_edge(clk)) then
	    if(we_a(0) = '1') then
		ram0(conv_integer(addr_a)) := data_in_a(7 downto 0);
	    end if;
	    if(we_a(1) = '1') then
		ram1(conv_integer(addr_a)) := data_in_a(15 downto 8);
	    end if;
	    data_out_a <= ram1(conv_integer(addr_a)) & ram0(conv_integer(addr_a));
	end if;
	end process;
	end generate;

	G_port_a_not_passthru: if not pass_thru_a generate
	process(clk)
	begin
	if(rising_edge(clk)) then 
	    data_out_a <= ram1(conv_integer(addr_a)) & ram0(conv_integer(addr_a));
	    if(we_a(0) = '1') then
		ram0(conv_integer(addr_a)) := data_in_a(7 downto 0);
	    end if;
	    if(we_a(1) = '1') then
		ram1(conv_integer(addr_a)) := data_in_a(15 downto 8);
	    end if;
	end if;
	end process;
	end generate;
end rtl;
