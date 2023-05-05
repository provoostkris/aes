------------------------------------------------------------------------------
--  AES key expansion function
--  rev. 1.0 : 2023 provoost kris
------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_misc.all;
use     ieee.numeric_std.all;

library work;
use     work.aes_pkg.all;

entity key_expand is
  port(
    clk           : in  std_logic;                    --system clock
    reset_n       : in  std_logic;                    --active low reset

    keyexpand_s   : in  std_logic_vector(0 to c_key-1);
    keyexpand_m   : out t_raw_words ( 0 to c_nb*(c_nr+1)-1)
  );
end key_expand;

architecture rtl of key_expand is

    --! array storage
    signal in_words_i         : t_raw_words ( 0 to c_key/32-1);

    -- the round key is a set of 15 times 32 bits
    signal round_keys_i       : t_raw_words ( 0    to c_nb*(c_nr+1)-1);
    signal last_round_i       : t_raw_words ( c_nk to c_nb*(c_nr+1)-1);
    signal temp_round_i       : t_raw_words ( c_nk to c_nb*(c_nr+1)-1);

begin

--! map input slv to 'input bytes'
  process(reset_n, clk) is
  begin
      if reset_n='0' then
        in_words_i  <= ( others => ( others => '0'));
      elsif rising_edge(clk) then
        in_words_i  <= f_slv_to_words(keyexpand_s);
      end if;
  end process;

gen_keyexpand_init:  for j in 0 to c_nk-1 generate

  round_keys_i(j) <=  in_words_i(j) ;

end generate;

gen_keyexpand_round: for j in c_nk to c_nb*(c_nr+1)-1 generate
  
  temp_round_i(j) <=  round_keys_i(j-1);
  last_round_i(j) <=  round_keys_i(j-8);
  round_keys_i(j) <=  last_round_i(j) xor f_subword(f_rotword(temp_round_i(j))) xor c_rcon(j/8) & x"000000" when (j mod 8 = 0) else
                      last_round_i(j) xor f_subword(temp_round_i(j))                                        when (j mod 8 = 4) else
                      last_round_i(j) xor temp_round_i(j);

end generate;
  
--! map the expanded keys to the output array
  -- process(reset_n, clk) is
  -- begin
      -- if reset_n='0' then
        -- keyexpand_m  <= ( others => ( others => '0'));
      -- elsif rising_edge(clk) then
        -- keyexpand_m  <= round_keys_i;
      -- end if;
  -- end process;
  
        keyexpand_m  <= round_keys_i;

end rtl;
