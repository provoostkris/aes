------------------------------------------------------------------------------
--  AES transformation function : add round key
--  rev. 1.0 : 2023 provoost kris
------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_misc.all;
use     ieee.numeric_std.all;

library work;
use     work.aes_pkg.all;

entity trf_addroundkey is
  port(
    clk           : in  std_logic;                    --system clock
    reset_n       : in  std_logic;                    --active low reset

    addroundkey_s  : in  std_logic_vector(0 to c_seq-1);
    roundkey_s     : in  std_logic_vector(0 to c_seq-1);
    addroundkey_m  : out std_logic_vector(0 to c_seq-1)
  );
end trf_addroundkey;

architecture rtl of trf_addroundkey is

    --! array storage
    signal in_bytes_i           : t_raw_bytes ( 0 to c_arr-1);
    signal in_bytes_roundkey_i  : t_raw_bytes ( 0 to c_arr-1);
    signal out_bytes_i          : t_raw_bytes ( 0 to c_arr-1);

begin

--! map input slv to 'input bytes'
  process(reset_n, clk) is
  begin
      if reset_n='0' then
        in_bytes_i           <= ( others => ( others => '0'));
        in_bytes_roundkey_i  <= ( others => ( others => '0'));
      elsif rising_edge(clk) then
        in_bytes_i           <= f_slv_to_bytes(addroundkey_s);
        in_bytes_roundkey_i  <= f_slv_to_bytes(roundkey_s);
      end if;
  end process;

--! perform the add round key operation
  process(reset_n, clk) is
  begin
      if reset_n='0' then
        out_bytes_i  <= ( others => ( others => '0'));
      elsif rising_edge(clk) then
        for j in 0 to c_arr-1 loop
          out_bytes_i(j)   <= in_bytes_i(j) xor in_bytes_roundkey_i(j);
        end loop;
      end if;
  end process;

--! map 'output bytes' to slv
addroundkey_m   <= f_bytes_to_slv(out_bytes_i);

end rtl;