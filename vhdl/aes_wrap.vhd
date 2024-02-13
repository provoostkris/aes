------------------------------------------------------------------------------
--  wrapper file for byte wise data ports with AES encryption
--  rev. 1.0 : 2024 Provoost Kris
------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.std_logic_misc.all;

library work;
use     work.aes_pkg.all;

entity aes_wrap is
  port(
    clk           : in  std_logic;                    --! system clock
    rst_n         : in  std_logic;                    --! active low reset

    s_key_tready  : out std_logic;                                --! key input
    s_key_tdata   : in  std_logic_vector(8-1 downto 0);
    s_key_tlast   : in  std_logic;
    s_key_tvalid  : in  std_logic;

    s_dat_tready  : out std_logic;                                --! dat input
    s_dat_tdata   : in  std_logic_vector(8-1 downto 0);
    s_dat_tlast   : in  std_logic;
    s_dat_tvalid  : in  std_logic;

    m_dat_tvalid  : out std_logic;                               --! dat output
    m_dat_tdata   : out std_logic_vector(8-1 downto 0);
    m_dat_tlast   : out std_logic;
    m_dat_tready  : in  std_logic
  );
end;

architecture rtl of aes_wrap is

-- local signals
signal s_aes_key_tready  :  std_logic;                                --! key input
signal s_aes_key_tdata   :  std_logic_vector(c_key-1 downto 0);
signal s_aes_key_tlast   :  std_logic;
signal s_aes_key_tvalid  :  std_logic;
signal s_aes_dat_tready  :  std_logic;                                --! dat input
signal s_aes_dat_tdata   :  std_logic_vector(c_seq-1 downto 0);
signal s_aes_dat_tlast   :  std_logic;
signal s_aes_dat_tvalid  :  std_logic;
signal m_aes_dat_tvalid  :  std_logic;                               --! dat output
signal m_aes_dat_tdata   :  std_logic_vector(c_seq-1 downto 0);
signal m_aes_dat_tlast   :  std_logic;
signal m_aes_dat_tready  :  std_logic;

begin

--!
--! implementation
--!

  --! shift in the key and the data
  process(rst_n, clk) is
  begin
      if rst_n='0' then
        s_aes_key_tdata <= ( others => '0');
        s_aes_dat_tdata <= ( others => '0');
      elsif rising_edge(clk) then
        s_aes_key_tdata <= s_aes_key_tdata(s_aes_key_tdata'high-8 downto 0) & s_key_tdata;
        s_aes_dat_tdata <= s_aes_dat_tdata(s_aes_dat_tdata'high-8 downto 0) & s_dat_tdata;
      end if;
  end process;

  --! assign to the core
  i_aes: entity work.aes(rtl)
    port map (
      clk           => clk,
      rst_n         => rst_n,

      s_key_tready  => s_aes_key_tready ,
      s_key_tdata   => s_aes_key_tdata  ,
      s_key_tlast   => s_aes_key_tlast  ,
      s_key_tvalid  => s_aes_key_tvalid ,

      s_dat_tready  => s_aes_dat_tready ,
      s_dat_tdata   => s_aes_dat_tdata  ,
      s_dat_tlast   => s_aes_dat_tlast  ,
      s_dat_tvalid  => s_aes_dat_tvalid ,

      m_dat_tvalid  => m_aes_dat_tvalid ,
      m_dat_tdata   => m_aes_dat_tdata  ,
      m_dat_tlast   => m_aes_dat_tlast  ,
      m_dat_tready  => m_aes_dat_tready
    );

  --! shift out the data
  process(rst_n, clk) is
  begin
      if rst_n='0' then
        m_dat_tdata           <= ( others => '0');
      elsif rising_edge(clk) then
        m_dat_tdata           <= m_aes_dat_tdata(m_dat_tdata'range) ;
      end if;
  end process;

end architecture rtl;