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
signal s_keyexpand_tdata    : std_logic_vector(0 to c_key-1);
signal m_keyexpand_tdata    : t_raw_words ( 0    to c_nb*(c_nr+1)-1);

signal s_subbytes_tdata     : t_round_vec(0 to c_nr);
signal m_subbytes_tdata     : t_round_vec(1 to c_nr);

signal s_shiftrows_tdata    : t_round_vec(1 to c_nr);
signal m_shiftrows_tdata    : t_round_vec(1 to c_nr);

signal s_mixcolumns_tdata   : t_round_vec(1 to c_nr);
signal m_mixcolumns_tdata   : t_round_vec(1 to c_nr);

signal s_addroundkey_tdata  : t_round_vec(1 to c_nr);
signal s_roundkey_tdata     : t_round_vec(0 to c_nr);
signal m_addroundkey_tdata  : t_round_vec(0 to c_nr);

begin

--!
--! implementation
--!

  --! assign the data input to the first stage of the process
  s_subbytes_tdata(0)   <=  s_dat_tdata;

  --! assign the key to the expansion component
  s_keyexpand_tdata     <=  s_key_tdata;

--! start with the key expansion
  i_key_expand: entity work.key_expand(rtl)
    port map (
      clk               => clk,
      reset_n           => rst_n,

      s_keyexpand_tdata        => s_keyexpand_tdata,
      m_keyexpand_tdata        => m_keyexpand_tdata
    );

  -- assign round keys
  gen_keys:  for j in 0 to c_nr generate
    s_roundkey_tdata(j)   <=  m_keyexpand_tdata(j*4+0) &
                        m_keyexpand_tdata(j*4+1) &
                        m_keyexpand_tdata(j*4+2) &
                        m_keyexpand_tdata(j*4+3);
  end generate;

--! Cypher step 1 add round key
  i_trf_addroundkey: entity work.trf_addroundkey(rtl)
    port map (
      clk               => clk,
      reset_n           => rst_n,

      s_addroundkey_tdata     => s_subbytes_tdata(0),
      s_roundkey_tdata        => s_roundkey_tdata(0),
      m_addroundkey_tdata     => m_addroundkey_tdata(0)
    );


--! then cascade the four transformations for a loop of 10x/12x/14x
gen_rounds:  for j in 1 to c_nr generate

  s_subbytes_tdata(j) <= m_addroundkey_tdata(j-1);

  i_trf_subbytes: entity work.trf_subbytes(rtl)
    port map (
      clk               => clk,
      reset_n           => rst_n,

      s_subbytes_tdata        => s_subbytes_tdata(j),
      m_subbytes_tdata        => m_subbytes_tdata(j)
    );

  s_shiftrows_tdata(j) <= m_subbytes_tdata(j);

  i_trf_shiftrows: entity work.trf_shiftrows(rtl)
    port map (
      clk               => clk,
      reset_n           => rst_n,

      s_shiftrows_tdata       => s_shiftrows_tdata(j),
      m_shiftrows_tdata       => m_shiftrows_tdata(j)
    );

  s_mixcolumns_tdata(j) <= m_shiftrows_tdata(j);

  i_trf_mixcolumns: entity work.trf_mixcolumns(rtl)
    port map (
      clk               => clk,
      reset_n           => rst_n,

      s_round_tdata           => j,

      s_mixcolumns_tdata      => s_mixcolumns_tdata(j),
      m_mixcolumns_tdata      => m_mixcolumns_tdata(j)
    );

  s_addroundkey_tdata(j) <= m_mixcolumns_tdata(j);

  i_trf_addroundkey: entity work.trf_addroundkey(rtl)
    port map (
      clk               => clk,
      reset_n           => rst_n,

      s_addroundkey_tdata     => s_addroundkey_tdata(j),
      s_roundkey_tdata        => s_roundkey_tdata(j),
      m_addroundkey_tdata     => m_addroundkey_tdata(j)
    );

end generate;

--! the output state is the result of the last transformation in the last round
m_dat_tdata  <= m_addroundkey_tdata(c_nr);

end architecture rtl;