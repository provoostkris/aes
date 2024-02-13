------------------------------------------------------------------------------
--  AES encryption algorithm
--  rev. 1.0 : 2021 Provoost Kris
------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.std_logic_misc.all;

library work;
use     work.aes_pkg.all;

entity aes is
  port(
    clk           : in  std_logic;                      --! system clock
    rst_n         : in  std_logic;                      --! active low reset

    s_key_tready  : out std_logic;                                --! key input
    s_key_tdata   : in  std_logic_vector(c_key-1 downto 0);
    s_key_tlast   : in  std_logic;
    s_key_tvalid  : in  std_logic;

    s_dat_tready  : out std_logic;                                --! dat input
    s_dat_tdata   : in  std_logic_vector(c_seq-1 downto 0);
    s_dat_tlast   : in  std_logic;
    s_dat_tvalid  : in  std_logic;

    m_dat_tvalid  : out std_logic;                               --! dat output
    m_dat_tdata   : out std_logic_vector(c_seq-1 downto 0);
    m_dat_tlast   : out std_logic;
    m_dat_tready  : in  std_logic

  );
end;

architecture rtl of aes is

-- local signals
signal keyexpand_s    : std_logic_vector(0 to c_key-1);
signal keyexpand_m    : t_raw_words ( 0    to c_nb*(c_nr+1)-1);

signal subbytes_s     : t_round_vec(0 to c_nr);
signal subbytes_m     : t_round_vec(1 to c_nr);

signal shiftrows_s    : t_round_vec(1 to c_nr);
signal shiftrows_m    : t_round_vec(1 to c_nr);

signal mixcolumns_s   : t_round_vec(1 to c_nr);
signal mixcolumns_m   : t_round_vec(1 to c_nr);

signal addroundkey_s  : t_round_vec(1 to c_nr);
signal roundkey_s     : t_round_vec(0 to c_nr);
signal addroundkey_m  : t_round_vec(0 to c_nr);

begin

--!
--! implementation
--!

  --! assign the data input to the first stage of the process
  subbytes_s(0)   <=  s_dat_tdata;

  --! assign the key to the expansion component
  keyexpand_s     <=  s_key_tdata;

--! start with the key expansion
  i_key_expand: entity work.key_expand(rtl)
    port map (
      clk               => clk,
      reset_n           => rst_n,

      keyexpand_s        => keyexpand_s,
      keyexpand_m        => keyexpand_m
    );

  -- assign round keys
  gen_keys:  for j in 0 to c_nr generate
    roundkey_s(j)   <=  keyexpand_m(j*4+0) &
                        keyexpand_m(j*4+1) &
                        keyexpand_m(j*4+2) &
                        keyexpand_m(j*4+3);
  end generate;

--! Cypher step 1 add round key
  i_trf_addroundkey: entity work.trf_addroundkey(rtl)
    port map (
      clk               => clk,
      reset_n           => rst_n,

      addroundkey_s     => subbytes_s(0),
      roundkey_s        => roundkey_s(0),
      addroundkey_m     => addroundkey_m(0)
    );


--! then cascade the four transformations for a loop of 10x/12x/14x
gen_rounds:  for j in 1 to c_nr generate

  subbytes_s(j) <= addroundkey_m(j-1);

  i_trf_subbytes: entity work.trf_subbytes(rtl)
    port map (
      clk               => clk,
      reset_n           => rst_n,

      subbytes_s        => subbytes_s(j),
      subbytes_m        => subbytes_m(j)
    );

  shiftrows_s(j) <= subbytes_m(j);

  i_trf_shiftrows: entity work.trf_shiftrows(rtl)
    port map (
      clk               => clk,
      reset_n           => rst_n,

      shiftrows_s       => shiftrows_s(j),
      shiftrows_m       => shiftrows_m(j)
    );

  mixcolumns_s(j) <= shiftrows_m(j);

  i_trf_mixcolumns: entity work.trf_mixcolumns(rtl)
    port map (
      clk               => clk,
      reset_n           => rst_n,

      round_s           => j,

      mixcolumns_s      => mixcolumns_s(j),
      mixcolumns_m      => mixcolumns_m(j)
    );

  addroundkey_s(j) <= mixcolumns_m(j);

  i_trf_addroundkey: entity work.trf_addroundkey(rtl)
    port map (
      clk               => clk,
      reset_n           => rst_n,

      addroundkey_s     => addroundkey_s(j),
      roundkey_s        => roundkey_s(j),
      addroundkey_m     => addroundkey_m(j)
    );

end generate;

--! the output state is the result of the last transformation in the last round
m_dat_tdata  <= addroundkey_m(c_nr);

end architecture rtl;