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

entity trf_shiftrows is
  port(
    clk           : in  std_logic;                --system clock
    reset_n       : in  std_logic;                --active low reset

    s_shiftrows_tready     : out std_logic;
    s_shiftrows_tdata      : in  std_logic_vector(0 to c_seq-1);
    s_shiftrows_tlast      : in  std_logic;
    s_shiftrows_tvalid     : in  std_logic;

    m_shiftrows_tready     : in  std_logic;
    m_shiftrows_tdata      : out std_logic_vector(0 to c_seq-1);
    m_shiftrows_tlast      : out std_logic;
    m_shiftrows_tvalid     : out std_logic
  );
end trf_shiftrows;

architecture rtl of trf_shiftrows is

    --! local signals
    signal in_bytes_i         : t_raw_bytes ( 0 to c_arr-1);
    signal out_bytes_i        : t_raw_bytes ( 0 to c_arr-1);
    signal state_s_i          : t_state_bytes ( 0 to 3);
    signal state_m_i          : t_state_bytes ( 0 to 3);

begin

--! map flow control signals
  s_shiftrows_tready <= '1';

--! map input slv to 'input bytes'
  in_bytes_i  <= f_slv_to_bytes(s_shiftrows_tdata);

--! map input to state matrix
  state_s_i <= f_bytes_to_state(in_bytes_i);

--! perform the shift row operation
  process(reset_n, clk) is
  begin
      if reset_n='0' then
        state_m_i <= ( others => ( others => ( others => '0')));
      elsif rising_edge(clk) then
        -- shift is zero elements in first row
        state_m_i(0)(0)   <= state_s_i(0)(0);
        state_m_i(0)(1)   <= state_s_i(0)(1);
        state_m_i(0)(2)   <= state_s_i(0)(2);
        state_m_i(0)(3)   <= state_s_i(0)(3);
        -- shift is one element in second row
        state_m_i(1)(3)   <= state_s_i(1)(0);
        state_m_i(1)(0)   <= state_s_i(1)(1);
        state_m_i(1)(1)   <= state_s_i(1)(2);
        state_m_i(1)(2)   <= state_s_i(1)(3);
        -- shift is two elements in third row
        state_m_i(2)(2)   <= state_s_i(2)(0);
        state_m_i(2)(3)   <= state_s_i(2)(1);
        state_m_i(2)(0)   <= state_s_i(2)(2);
        state_m_i(2)(1)   <= state_s_i(2)(3);
        -- shift is three elements in forth row
        state_m_i(3)(1)   <= state_s_i(3)(0);
        state_m_i(3)(2)   <= state_s_i(3)(1);
        state_m_i(3)(3)   <= state_s_i(3)(2);
        state_m_i(3)(0)   <= state_s_i(3)(3);
      end if;
  end process;

--! map state matrix to output bytes
  out_bytes_i <= f_state_to_bytes(state_m_i);

--! map 'output bytes' to slv
  i_shift_reg_tvalid : entity work.shift_reg(rtl) generic map (g_del => 1) port map (clk , reset_n, s_shiftrows_tvalid, m_shiftrows_tvalid);
  i_shift_reg_tlast  : entity work.shift_reg(rtl) generic map (g_del => 1) port map (clk , reset_n, s_shiftrows_tlast , m_shiftrows_tlast);
  
  m_shiftrows_tdata  <= f_bytes_to_slv(out_bytes_i);

end rtl;