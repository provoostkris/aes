------------------------------------------------------------------------------
--  AES transformation function : sub bytes
--  rev. 1.0 : 2023 provoost kris
------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_misc.all;
use     ieee.numeric_std.all;

library work;
use     work.aes_pkg.all;

entity trf_subbytes is
  port(
    clk           : in  std_logic;                    --system clock
    reset_n       : in  std_logic;                    --active low reset

    subbytes_s    : in  std_logic_vector(0 to c_seq-1);
    subbytes_m    : out std_logic_vector(0 to c_seq-1)
  );
end trf_subbytes;

architecture rtl of trf_subbytes is

    --! array storage
    signal in_bytes_i         : t_raw_bytes ( 0 to c_arr-1);
    signal out_bytes_i        : t_raw_bytes ( 0 to c_arr-1);

begin

--! map input slv to 'input bytes'
  process(reset_n, clk) is
  begin
      if reset_n='0' then
        in_bytes_i  <= ( others => ( others => '0'));
      elsif rising_edge(clk) then
        in_bytes_i  <= f_slv_to_bytes(subbytes_s);
      end if;
  end process;

gen_subbytes: for j in 0 to c_arr-1 generate
  --! use Sbox
  i_sbox : entity work.sbox(aes_nor)
    port map(
      lookup  => in_bytes_i(j),
      result  => out_bytes_i(j)
    );
end generate;

--! map 'output bytes' to slv
  process(reset_n, clk) is
  begin
      if reset_n='0' then
        subbytes_m  <= ( others => '0');
      elsif rising_edge(clk) then
        subbytes_m  <= f_bytes_to_slv(out_bytes_i);
      end if;
  end process;

end rtl;
