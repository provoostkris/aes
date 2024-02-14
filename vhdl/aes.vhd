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
signal s_keyexpand_tready    : std_logic;
signal s_keyexpand_tdata     : std_logic_vector(0 to c_key-1);
signal s_keyexpand_tlast     : std_logic;
signal s_keyexpand_tvalid    : std_logic;
signal m_keyexpand_tready    : std_logic;
signal m_keyexpand_tdata     : t_raw_words ( 0    to c_nb*(c_nr+1)-1);
signal m_keyexpand_tlast     : std_logic;
signal m_keyexpand_tvalid    : std_logic;

signal s_subbytes_tready    : std_logic_vector(0 to c_nr);
signal s_subbytes_tdata     : t_round_vec(0 to c_nr);
signal s_subbytes_tlast     : std_logic_vector(0 to c_nr);
signal s_subbytes_tvalid    : std_logic_vector(0 to c_nr);
signal m_subbytes_tready    : std_logic_vector(1 to c_nr);
signal m_subbytes_tdata     : t_round_vec(1 to c_nr);
signal m_subbytes_tlast     : std_logic_vector(1 to c_nr);
signal m_subbytes_tvalid    : std_logic_vector(1 to c_nr);

signal s_shiftrows_tready    : std_logic_vector(1 to c_nr);
signal s_shiftrows_tdata     : t_round_vec(1 to c_nr);
signal s_shiftrows_tlast     : std_logic_vector(1 to c_nr);
signal s_shiftrows_tvalid    : std_logic_vector(1 to c_nr);
signal m_shiftrows_tready    : std_logic_vector(1 to c_nr);
signal m_shiftrows_tdata     : t_round_vec(1 to c_nr);
signal m_shiftrows_tlast     : std_logic_vector(1 to c_nr);
signal m_shiftrows_tvalid    : std_logic_vector(1 to c_nr);

signal s_mixcolumns_tready    : std_logic_vector(1 to c_nr);
signal s_mixcolumns_tdata     : t_round_vec(1 to c_nr);
signal s_mixcolumns_tlast     : std_logic_vector(1 to c_nr);
signal s_mixcolumns_tvalid    : std_logic_vector(1 to c_nr);
signal m_mixcolumns_tready    : std_logic_vector(1 to c_nr);
signal m_mixcolumns_tdata     : t_round_vec(1 to c_nr);
signal m_mixcolumns_tlast     : std_logic_vector(1 to c_nr);
signal m_mixcolumns_tvalid    : std_logic_vector(1 to c_nr);

signal s_addroundkey_tready    : std_logic_vector(1 to c_nr);
signal s_addroundkey_tdata     : t_round_vec(1 to c_nr);
signal s_addroundkey_tlast     : std_logic_vector(1 to c_nr);
signal s_addroundkey_tvalid    : std_logic_vector(1 to c_nr);
signal s_roundkey_tready       : std_logic_vector(0 to c_nr);
signal s_roundkey_tdata        : t_round_vec(0 to c_nr);
signal s_roundkey_tlast        : std_logic_vector(0 to c_nr);
signal s_roundkey_tvalid       : std_logic_vector(0 to c_nr);
signal m_addroundkey_tready    : std_logic_vector(0 to c_nr);
signal m_addroundkey_tdata     : t_round_vec(0 to c_nr);
signal m_addroundkey_tlast     : std_logic_vector(0 to c_nr);
signal m_addroundkey_tvalid    : std_logic_vector(0 to c_nr);

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

      s_keyexpand_tready => s_keyexpand_tready,
      s_keyexpand_tdata  => s_keyexpand_tdata ,
      s_keyexpand_tlast  => s_keyexpand_tlast ,
      s_keyexpand_tvalid => s_keyexpand_tvalid,

      m_keyexpand_tready => m_keyexpand_tready,
      m_keyexpand_tdata  => m_keyexpand_tdata ,
      m_keyexpand_tlast  => m_keyexpand_tlast ,
      m_keyexpand_tvalid => m_keyexpand_tvalid
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

      s_addroundkey_tready => s_subbytes_tready(0),
      s_addroundkey_tdata  => s_subbytes_tdata(0),
      s_addroundkey_tlast  => s_subbytes_tlast(0),
      s_addroundkey_tvalid => s_subbytes_tvalid(0),

      s_roundkey_tready    => s_roundkey_tready(0),
      s_roundkey_tdata     => s_roundkey_tdata(0),
      s_roundkey_tlast     => s_roundkey_tlast(0),
      s_roundkey_tvalid    => s_roundkey_tvalid(0),

      m_addroundkey_tready => m_addroundkey_tready(0),
      m_addroundkey_tdata  => m_addroundkey_tdata(0),
      m_addroundkey_tlast  => m_addroundkey_tlast(0),
      m_addroundkey_tvalid => m_addroundkey_tvalid(0)
    );


--! then cascade the four transformations for a loop of 10x/12x/14x
gen_rounds:  for j in 1 to c_nr generate

  s_subbytes_tdata(j) <= m_addroundkey_tdata(j-1);

  i_trf_subbytes: entity work.trf_subbytes(rtl)
    port map (
      clk               => clk,
      reset_n           => rst_n,

      s_subbytes_tready => s_subbytes_tready(j),
      s_subbytes_tdata  => s_subbytes_tdata(j),
      s_subbytes_tlast  => s_subbytes_tlast(j),
      s_subbytes_tvalid => s_subbytes_tvalid(j),

      m_subbytes_tready => m_subbytes_tready(j),
      m_subbytes_tdata  => m_subbytes_tdata(j),
      m_subbytes_tlast  => m_subbytes_tlast(j),
      m_subbytes_tvalid => m_subbytes_tvalid(j)
    );

  s_shiftrows_tdata(j) <= m_subbytes_tdata(j);

  i_trf_shiftrows: entity work.trf_shiftrows(rtl)
    port map (
      clk               => clk,
      reset_n           => rst_n,

      s_shiftrows_tready => s_shiftrows_tready(j),
      s_shiftrows_tdata  => s_shiftrows_tdata(j),
      s_shiftrows_tlast  => s_shiftrows_tlast(j),
      s_shiftrows_tvalid => s_shiftrows_tvalid(j),

      m_shiftrows_tready => m_shiftrows_tready(j),
      m_shiftrows_tdata  => m_shiftrows_tdata(j),
      m_shiftrows_tlast  => m_shiftrows_tlast(j),
      m_shiftrows_tvalid => m_shiftrows_tvalid(j)
    );

  s_mixcolumns_tdata(j) <= m_shiftrows_tdata(j);

  i_trf_mixcolumns: entity work.trf_mixcolumns(rtl)
    port map (
      clk               => clk,
      reset_n           => rst_n,

      round               => j,

      s_mixcolumns_tready => s_mixcolumns_tready(j),
      s_mixcolumns_tdata  => s_mixcolumns_tdata(j),
      s_mixcolumns_tlast  => s_mixcolumns_tlast(j),
      s_mixcolumns_tvalid => s_mixcolumns_tvalid(j),

      m_mixcolumns_tready => m_mixcolumns_tready(j),
      m_mixcolumns_tdata  => m_mixcolumns_tdata(j),
      m_mixcolumns_tlast  => m_mixcolumns_tlast(j),
      m_mixcolumns_tvalid => m_mixcolumns_tvalid(j)
    );

  s_addroundkey_tdata(j) <= m_mixcolumns_tdata(j);

  i_trf_addroundkey: entity work.trf_addroundkey(rtl)
    port map (
      clk               => clk,
      reset_n           => rst_n,

      s_addroundkey_tready => s_addroundkey_tready(j),
      s_addroundkey_tdata  => s_addroundkey_tdata(j),
      s_addroundkey_tlast  => s_addroundkey_tlast(j),
      s_addroundkey_tvalid => s_addroundkey_tvalid(j),

      s_roundkey_tready    => s_roundkey_tready(j),
      s_roundkey_tdata     => s_roundkey_tdata(j),
      s_roundkey_tlast     => s_roundkey_tlast(j),
      s_roundkey_tvalid    => s_roundkey_tvalid(j),

      m_addroundkey_tready => m_addroundkey_tready(j),
      m_addroundkey_tdata  => m_addroundkey_tdata(j),
      m_addroundkey_tlast  => m_addroundkey_tlast(j),
      m_addroundkey_tvalid => m_addroundkey_tvalid(j)
    );

end generate;

--! the output state is the result of the last transformation in the last round
m_dat_tdata  <= m_addroundkey_tdata(c_nr);

end architecture rtl;