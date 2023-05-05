------------------------------------------------------------------------------
--  package for the aes designs
--  rev. 1.0 : 2023 Provoost Kris
------------------------------------------------------------------------------


--! look up table import from :
-- https://github.com/torvalds/linux/blob/master/lib/crypto/aes.c

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

package aes_pkg is

  constant c_seq    : natural := 128; --! definition of the sequences size
  constant c_arr    : natural :=  16; --! definition of the matrix size
  constant c_key    : natural := 256; --! definition of the key size
  
  constant c_nk     : natural :=  8; --! key length (words)
  constant c_nb     : natural :=  4; --! block size (words)
  constant c_nr     : natural := 14; --! number of rounds
  
  
  constant c_ref_plain : std_logic_vector(0 to 127) := x"00112233445566778899aabbccddeeff" ; --! value from fips 197 document
  constant c_ref_key   : std_logic_vector(0 to 255) := x"000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"; --! value from fips 197 document

  type t_raw_bytes          is array ( integer range <> ) of std_logic_vector( 7 downto 0);
  type t_state_bytes        is array ( integer range <> ) of t_raw_bytes ( 0 to 3);
  type t_raw_words          is array ( integer range <> ) of std_logic_vector(0 to 31);
  type t_round_vec          is array ( integer range <> ) of std_logic_vector(0 to c_seq-1);

  --https://en.wikipedia.org/wiki/AES_key_schedule
  constant c_rcon   : t_raw_bytes(1 to 29) := (
    x"01", x"02", x"04", x"08", x"10", x"20", x"40", x"80", x"1B", x"36",
    x"6C", x"D8", x"AB", x"4D", x"9A", x"2F", x"5E", x"BC", x"63", x"C6", 
    x"97", x"35", x"6A", x"D4", x"B3", x"7D", x"FA", x"EF", x"C5"
  );

  constant  c_lut_nor : t_raw_bytes ( 0 to 255 ) := (
    x"63", x"7c", x"77", x"7b", x"f2", x"6b", x"6f", x"c5",
    x"30", x"01", x"67", x"2b", x"fe", x"d7", x"ab", x"76",
    x"ca", x"82", x"c9", x"7d", x"fa", x"59", x"47", x"f0",
    x"ad", x"d4", x"a2", x"af", x"9c", x"a4", x"72", x"c0",
    x"b7", x"fd", x"93", x"26", x"36", x"3f", x"f7", x"cc",
    x"34", x"a5", x"e5", x"f1", x"71", x"d8", x"31", x"15",
    x"04", x"c7", x"23", x"c3", x"18", x"96", x"05", x"9a",
    x"07", x"12", x"80", x"e2", x"eb", x"27", x"b2", x"75",
    x"09", x"83", x"2c", x"1a", x"1b", x"6e", x"5a", x"a0",
    x"52", x"3b", x"d6", x"b3", x"29", x"e3", x"2f", x"84",
    x"53", x"d1", x"00", x"ed", x"20", x"fc", x"b1", x"5b",
    x"6a", x"cb", x"be", x"39", x"4a", x"4c", x"58", x"cf",
    x"d0", x"ef", x"aa", x"fb", x"43", x"4d", x"33", x"85",
    x"45", x"f9", x"02", x"7f", x"50", x"3c", x"9f", x"a8",
    x"51", x"a3", x"40", x"8f", x"92", x"9d", x"38", x"f5",
    x"bc", x"b6", x"da", x"21", x"10", x"ff", x"f3", x"d2",
    x"cd", x"0c", x"13", x"ec", x"5f", x"97", x"44", x"17",
    x"c4", x"a7", x"7e", x"3d", x"64", x"5d", x"19", x"73",
    x"60", x"81", x"4f", x"dc", x"22", x"2a", x"90", x"88",
    x"46", x"ee", x"b8", x"14", x"de", x"5e", x"0b", x"db",
    x"e0", x"32", x"3a", x"0a", x"49", x"06", x"24", x"5c",
    x"c2", x"d3", x"ac", x"62", x"91", x"95", x"e4", x"79",
    x"e7", x"c8", x"37", x"6d", x"8d", x"d5", x"4e", x"a9",
    x"6c", x"56", x"f4", x"ea", x"65", x"7a", x"ae", x"08",
    x"ba", x"78", x"25", x"2e", x"1c", x"a6", x"b4", x"c6",
    x"e8", x"dd", x"74", x"1f", x"4b", x"bd", x"8b", x"8a",
    x"70", x"3e", x"b5", x"66", x"48", x"03", x"f6", x"0e",
    x"61", x"35", x"57", x"b9", x"86", x"c1", x"1d", x"9e",
    x"e1", x"f8", x"98", x"11", x"69", x"d9", x"8e", x"94",
    x"9b", x"1e", x"87", x"e9", x"ce", x"55", x"28", x"df",
    x"8c", x"a1", x"89", x"0d", x"bf", x"e6", x"42", x"68",
    x"41", x"99", x"2d", x"0f", x"b0", x"54", x"bb", x"16"
  );

  constant  c_lut_inv : t_raw_bytes ( 0 to 255 ) := (
    x"52", x"09", x"6a", x"d5", x"30", x"36", x"a5", x"38",
    x"bf", x"40", x"a3", x"9e", x"81", x"f3", x"d7", x"fb",
    x"7c", x"e3", x"39", x"82", x"9b", x"2f", x"ff", x"87",
    x"34", x"8e", x"43", x"44", x"c4", x"de", x"e9", x"cb",
    x"54", x"7b", x"94", x"32", x"a6", x"c2", x"23", x"3d",
    x"ee", x"4c", x"95", x"0b", x"42", x"fa", x"c3", x"4e",
    x"08", x"2e", x"a1", x"66", x"28", x"d9", x"24", x"b2",
    x"76", x"5b", x"a2", x"49", x"6d", x"8b", x"d1", x"25",
    x"72", x"f8", x"f6", x"64", x"86", x"68", x"98", x"16",
    x"d4", x"a4", x"5c", x"cc", x"5d", x"65", x"b6", x"92",
    x"6c", x"70", x"48", x"50", x"fd", x"ed", x"b9", x"da",
    x"5e", x"15", x"46", x"57", x"a7", x"8d", x"9d", x"84",
    x"90", x"d8", x"ab", x"00", x"8c", x"bc", x"d3", x"0a",
    x"f7", x"e4", x"58", x"05", x"b8", x"b3", x"45", x"06",
    x"d0", x"2c", x"1e", x"8f", x"ca", x"3f", x"0f", x"02",
    x"c1", x"af", x"bd", x"03", x"01", x"13", x"8a", x"6b",
    x"3a", x"91", x"11", x"41", x"4f", x"67", x"dc", x"ea",
    x"97", x"f2", x"cf", x"ce", x"f0", x"b4", x"e6", x"73",
    x"96", x"ac", x"74", x"22", x"e7", x"ad", x"35", x"85",
    x"e2", x"f9", x"37", x"e8", x"1c", x"75", x"df", x"6e",
    x"47", x"f1", x"1a", x"71", x"1d", x"29", x"c5", x"89",
    x"6f", x"b7", x"62", x"0e", x"aa", x"18", x"be", x"1b",
    x"fc", x"56", x"3e", x"4b", x"c6", x"d2", x"79", x"20",
    x"9a", x"db", x"c0", x"fe", x"78", x"cd", x"5a", x"f4",
    x"1f", x"dd", x"a8", x"33", x"88", x"07", x"c7", x"31",
    x"b1", x"12", x"10", x"59", x"27", x"80", x"ec", x"5f",
    x"60", x"51", x"7f", x"a9", x"19", x"b5", x"4a", x"0d",
    x"2d", x"e5", x"7a", x"9f", x"93", x"c9", x"9c", x"ef",
    x"a0", x"e0", x"3b", x"4d", x"ae", x"2a", x"f5", x"b0",
    x"c8", x"eb", x"bb", x"3c", x"83", x"53", x"99", x"61",
    x"17", x"2b", x"04", x"7e", x"ba", x"77", x"d6", x"26",
    x"e1", x"69", x"14", x"63", x"55", x"21", x"0c", x"7d"
  );

  function f_slv_to_bytes     (x: std_logic_vector)   return t_raw_bytes;
  function f_slv_to_words     (x: std_logic_vector)   return t_raw_words;
  
  function f_bytes_to_slv     (x: t_raw_bytes)        return std_logic_vector;
  function f_words_to_slv     (x: t_raw_words)        return std_logic_vector;

  function f_bytes_to_state   (x: t_raw_bytes)        return t_state_bytes;
  function f_state_to_bytes   (x: t_state_bytes)      return t_raw_bytes;

  function f_rotword          (x: std_logic_vector)   return std_logic_vector;
  function f_subword          (x: std_logic_vector)   return std_logic_vector;

end aes_pkg;

package body aes_pkg is

  --! conversion of a std_logic_vector to an array of bytes
  function f_slv_to_bytes(x: std_logic_vector) return t_raw_bytes is
    variable v_result: t_raw_bytes( 0 to c_arr-1);
  begin
    v_result := ( others => ( others => '0'));
    for j in v_result'range loop
      v_result(j) := x(j*8+0 to j*8+7);
    end loop;
    return v_result;
  end f_slv_to_bytes;
  
  --! conversion of a std_logic_vector to an array of words
  function f_slv_to_words(x: std_logic_vector) return t_raw_words is
    variable v_result: t_raw_words( 0 to (c_key/32)-1);
  begin
    v_result := ( others => ( others => '0'));
    for j in v_result'range loop
      -- mind the endianess swap according to FIPS pub 197
      v_result(j)(0*8+0 to 0*8+7) := x(j*32+0*8+0 to j*32+0*8+7);
      v_result(j)(1*8+0 to 1*8+7) := x(j*32+1*8+0 to j*32+1*8+7);
      v_result(j)(2*8+0 to 2*8+7) := x(j*32+2*8+0 to j*32+2*8+7);
      v_result(j)(3*8+0 to 3*8+7) := x(j*32+3*8+0 to j*32+3*8+7);
    end loop;
    return v_result;
  end f_slv_to_words;

  --! conversion of an array of bytes to a std_logic_vector
  function f_bytes_to_slv(x: t_raw_bytes) return std_logic_vector is
    variable v_result: std_logic_vector(0 to c_seq-1);
  begin
    v_result := ( others => '0');
    for j in 0 to c_arr-1 loop
      v_result(j*8+0 to j*8+7) := x(j);
    end loop;
    return v_result;
  end f_bytes_to_slv;
  
  --! conversion of an array of words to a std_logic_vector
  function f_words_to_slv(x: t_raw_words) return std_logic_vector is
    variable v_result: std_logic_vector(0 to c_key-1);
  begin
    v_result := ( others => '0');
    for j in 0 to (c_key/32)-1 loop
      v_result(j*32+0*8+0 to j*32+0*8+7) := x(j)(0*8+0 to 0*8+7);
      v_result(j*32+1*8+0 to j*32+1*8+7) := x(j)(1*8+0 to 1*8+7);
      v_result(j*32+2*8+0 to j*32+2*8+7) := x(j)(2*8+0 to 2*8+7);
      v_result(j*32+3*8+0 to j*32+3*8+7) := x(j)(3*8+0 to 3*8+7);
    end loop;
    return v_result;
  end f_words_to_slv;

  --! conversion of an array of bytes to a state matrix
  function f_bytes_to_state(x: t_raw_bytes) return t_state_bytes is
    variable v_result: t_state_bytes(0 to 3);
  begin
    v_result := ( others => ( others => ( others => '0' ) ) );
    for col in 0 to 3 loop
      for row in 0 to 3 loop
        v_result(col)(row) := x(col+row*4);
      end loop;
    end loop;
    return v_result;
  end f_bytes_to_state;

  --! conversion of a state matrix to an array of bytes
  function f_state_to_bytes(x: t_state_bytes) return t_raw_bytes is
    variable v_result: t_raw_bytes(0 to c_arr-1);
  begin
    v_result := ( others => ( others => '0'));
    for col in 0 to 3 loop
      for row in 0 to 3 loop
        v_result(col+row*4) := x(col)(row);
      end loop;
    end loop;
    return v_result;
  end f_state_to_bytes;

  --! rotation function as defined in the AES standard for key expansion
  function f_rotword(x: std_logic_vector) return std_logic_vector is
    variable v_result: std_logic_vector(0 to 31);
  begin
    -- note the endianess in FIPS pub 197 when rotating
    v_result(0*8+0 to 0*8+7) := x(1*8+0 to 1*8+7);
    v_result(1*8+0 to 1*8+7) := x(2*8+0 to 2*8+7);
    v_result(2*8+0 to 2*8+7) := x(3*8+0 to 3*8+7);
    v_result(3*8+0 to 3*8+7) := x(0*8+0 to 0*8+7);
    return v_result;
  end f_rotword;

  --! substitution function as defined in the AES standard for key expansion
  function f_subword(x: std_logic_vector) return std_logic_vector is
    variable v_result: std_logic_vector(0 to 31);
  begin
    v_result(0*8+0 to 0*8+7) := c_lut_nor(to_integer(unsigned(x(0*8+0 to 0*8+7))));
    v_result(1*8+0 to 1*8+7) := c_lut_nor(to_integer(unsigned(x(1*8+0 to 1*8+7))));
    v_result(2*8+0 to 2*8+7) := c_lut_nor(to_integer(unsigned(x(2*8+0 to 2*8+7))));
    v_result(3*8+0 to 3*8+7) := c_lut_nor(to_integer(unsigned(x(3*8+0 to 3*8+7))));
    return v_result;
  end f_subword;

end aes_pkg;