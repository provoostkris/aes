------------------------------------------------------------------------------
--  AES galois field multiplication
--  rev. 1.0 : 2023 provoost kris
------------------------------------------------------------------------------

--! look up table import from :
-- https://en.wikipedia.org/wiki/Rijndael_MixColumns

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_misc.all;
use     ieee.numeric_std.all;

library work;
use     work.aes_pkg.all;

entity galois_mul is
	port (
		lookup : in  std_logic_vector(7 downto 0);
		result : out std_logic_vector(7 downto 0)
	);
end galois_mul;

architecture mul_2 of galois_mul is

  signal lookup_i  : integer range 0 to 2**8;
  
  constant  c_lut_mul_2 : t_raw_bytes ( 0 to 255 ) := (
    x"00",x"02",x"04",x"06",x"08",x"0a",x"0c",x"0e",x"10",x"12",x"14",x"16",x"18",x"1a",x"1c",x"1e",
    x"20",x"22",x"24",x"26",x"28",x"2a",x"2c",x"2e",x"30",x"32",x"34",x"36",x"38",x"3a",x"3c",x"3e",
    x"40",x"42",x"44",x"46",x"48",x"4a",x"4c",x"4e",x"50",x"52",x"54",x"56",x"58",x"5a",x"5c",x"5e",
    x"60",x"62",x"64",x"66",x"68",x"6a",x"6c",x"6e",x"70",x"72",x"74",x"76",x"78",x"7a",x"7c",x"7e",
    x"80",x"82",x"84",x"86",x"88",x"8a",x"8c",x"8e",x"90",x"92",x"94",x"96",x"98",x"9a",x"9c",x"9e",
    x"a0",x"a2",x"a4",x"a6",x"a8",x"aa",x"ac",x"ae",x"b0",x"b2",x"b4",x"b6",x"b8",x"ba",x"bc",x"be",
    x"c0",x"c2",x"c4",x"c6",x"c8",x"ca",x"cc",x"ce",x"d0",x"d2",x"d4",x"d6",x"d8",x"da",x"dc",x"de",
    x"e0",x"e2",x"e4",x"e6",x"e8",x"ea",x"ec",x"ee",x"f0",x"f2",x"f4",x"f6",x"f8",x"fa",x"fc",x"fe",
    x"1b",x"19",x"1f",x"1d",x"13",x"11",x"17",x"15",x"0b",x"09",x"0f",x"0d",x"03",x"01",x"07",x"05",
    x"3b",x"39",x"3f",x"3d",x"33",x"31",x"37",x"35",x"2b",x"29",x"2f",x"2d",x"23",x"21",x"27",x"25",
    x"5b",x"59",x"5f",x"5d",x"53",x"51",x"57",x"55",x"4b",x"49",x"4f",x"4d",x"43",x"41",x"47",x"45",
    x"7b",x"79",x"7f",x"7d",x"73",x"71",x"77",x"75",x"6b",x"69",x"6f",x"6d",x"63",x"61",x"67",x"65",
    x"9b",x"99",x"9f",x"9d",x"93",x"91",x"97",x"95",x"8b",x"89",x"8f",x"8d",x"83",x"81",x"87",x"85",
    x"bb",x"b9",x"bf",x"bd",x"b3",x"b1",x"b7",x"b5",x"ab",x"a9",x"af",x"ad",x"a3",x"a1",x"a7",x"a5",
    x"db",x"d9",x"df",x"dd",x"d3",x"d1",x"d7",x"d5",x"cb",x"c9",x"cf",x"cd",x"c3",x"c1",x"c7",x"c5",
    x"fb",x"f9",x"ff",x"fd",x"f3",x"f1",x"f7",x"f5",x"eb",x"e9",x"ef",x"ed",x"e3",x"e1",x"e7",x"e5"
  );

begin

  lookup_i  <= to_integer(unsigned(lookup));
  result    <= c_lut_mul_2(lookup_i) ;

end architecture mul_2;


architecture mul_3 of galois_mul is

  signal lookup_i  : integer range 0 to 2**8;
  
  constant  c_lut_mul_3 : t_raw_bytes ( 0 to 255 ) := (
    x"00",x"03",x"06",x"05",x"0c",x"0f",x"0a",x"09",x"18",x"1b",x"1e",x"1d",x"14",x"17",x"12",x"11",
    x"30",x"33",x"36",x"35",x"3c",x"3f",x"3a",x"39",x"28",x"2b",x"2e",x"2d",x"24",x"27",x"22",x"21",
    x"60",x"63",x"66",x"65",x"6c",x"6f",x"6a",x"69",x"78",x"7b",x"7e",x"7d",x"74",x"77",x"72",x"71",
    x"50",x"53",x"56",x"55",x"5c",x"5f",x"5a",x"59",x"48",x"4b",x"4e",x"4d",x"44",x"47",x"42",x"41",
    x"c0",x"c3",x"c6",x"c5",x"cc",x"cf",x"ca",x"c9",x"d8",x"db",x"de",x"dd",x"d4",x"d7",x"d2",x"d1",
    x"f0",x"f3",x"f6",x"f5",x"fc",x"ff",x"fa",x"f9",x"e8",x"eb",x"ee",x"ed",x"e4",x"e7",x"e2",x"e1",
    x"a0",x"a3",x"a6",x"a5",x"ac",x"af",x"aa",x"a9",x"b8",x"bb",x"be",x"bd",x"b4",x"b7",x"b2",x"b1",
    x"90",x"93",x"96",x"95",x"9c",x"9f",x"9a",x"99",x"88",x"8b",x"8e",x"8d",x"84",x"87",x"82",x"81",	
    x"9b",x"98",x"9d",x"9e",x"97",x"94",x"91",x"92",x"83",x"80",x"85",x"86",x"8f",x"8c",x"89",x"8a",
    x"ab",x"a8",x"ad",x"ae",x"a7",x"a4",x"a1",x"a2",x"b3",x"b0",x"b5",x"b6",x"bf",x"bc",x"b9",x"ba",
    x"fb",x"f8",x"fd",x"fe",x"f7",x"f4",x"f1",x"f2",x"e3",x"e0",x"e5",x"e6",x"ef",x"ec",x"e9",x"ea",	
    x"cb",x"c8",x"cd",x"ce",x"c7",x"c4",x"c1",x"c2",x"d3",x"d0",x"d5",x"d6",x"df",x"dc",x"d9",x"da",	
    x"5b",x"58",x"5d",x"5e",x"57",x"54",x"51",x"52",x"43",x"40",x"45",x"46",x"4f",x"4c",x"49",x"4a",
    x"6b",x"68",x"6d",x"6e",x"67",x"64",x"61",x"62",x"73",x"70",x"75",x"76",x"7f",x"7c",x"79",x"7a",	
    x"3b",x"38",x"3d",x"3e",x"37",x"34",x"31",x"32",x"23",x"20",x"25",x"26",x"2f",x"2c",x"29",x"2a",
    x"0b",x"08",x"0d",x"0e",x"07",x"04",x"01",x"02",x"13",x"10",x"15",x"16",x"1f",x"1c",x"19",x"1a"
  );

begin

  lookup_i  <= to_integer(unsigned(lookup));
  result    <= c_lut_mul_3(lookup_i) ;

end architecture mul_3;
