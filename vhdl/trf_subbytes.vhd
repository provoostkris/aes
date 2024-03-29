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

    s_subbytes_tready     : out std_logic;
    s_subbytes_tdata      : in  std_logic_vector(0 to c_seq-1);
    s_subbytes_tlast      : in  std_logic;
    s_subbytes_tvalid     : in  std_logic;

    m_subbytes_tready     : in  std_logic;
    m_subbytes_tdata      : out std_logic_vector(0 to c_seq-1);
    m_subbytes_tlast      : out std_logic;
    m_subbytes_tvalid     : out std_logic
  );
end trf_subbytes;

architecture rtl of trf_subbytes is

    --! array storage
    signal in_bytes_i         : t_raw_bytes ( 0 to c_arr-1);
    signal out_bytes_i        : t_raw_bytes ( 0 to c_arr-1);

begin

--! map flow control signals
  s_subbytes_tready <= '1';
  
--! map input slv to 'input bytes'
  process(reset_n, clk) is
  begin
      if reset_n='0' then
        in_bytes_i  <= ( others => ( others => '0'));
      elsif rising_edge(clk) then
        in_bytes_i  <= f_slv_to_bytes(s_subbytes_tdata);
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

  i_shift_reg_tvalid : entity work.shift_reg(rtl) generic map (g_del => 2) port map (clk , reset_n, s_subbytes_tvalid, m_subbytes_tvalid);
  i_shift_reg_tlast  : entity work.shift_reg(rtl) generic map (g_del => 2) port map (clk , reset_n, s_subbytes_tlast , m_subbytes_tlast);
  
  process(reset_n, clk) is
  begin
      if reset_n='0' then
        m_subbytes_tdata  <= ( others => '0');
      elsif rising_edge(clk) then
        m_subbytes_tdata  <= f_bytes_to_slv(out_bytes_i);
      end if;
  end process;

end rtl;
