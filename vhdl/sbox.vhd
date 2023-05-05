------------------------------------------------------------------------------
--  AES Substitution boxes
--  rev. 1.0 : 2023 provoost kris
------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_misc.all;
use     ieee.numeric_std.all;

library work;
use     work.aes_pkg.all;

entity sbox is
	port (
		lookup : in  std_logic_vector(7 downto 0);
		result : out std_logic_vector(7 downto 0)
	);
end sbox;

architecture aes_nor of sbox is

  signal lookup_i  : integer range 0 to 2**8-1;

begin

  lookup_i  <= to_integer(unsigned(lookup));
  result    <= c_lut_nor(lookup_i) ;

end architecture aes_nor;


architecture aes_inv of sbox is

  signal lookup_i  : integer range 0 to 2**8-1;

begin

  lookup_i  <= to_integer(unsigned(lookup));
  result    <= c_lut_inv(lookup_i) ;

end architecture aes_inv;

