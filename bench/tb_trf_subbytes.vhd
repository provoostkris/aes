------------------------------------------------------------------------------
--  Test Bench for the trf_subbytes
--  rev. 1.0 : 2023 Provoost Kris
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
-- just for random functions
use ieee.math_real.all;

library work;
use     work.aes_pkg.all;

entity tb_trf_subbytes is
  port(
    y        :  out std_logic
  );
end entity tb_trf_subbytes;

architecture rtl of tb_trf_subbytes is

constant c_clk_per  : time      := 20 ns ;

signal clk          : std_ulogic :='0';
signal rst_n        : std_ulogic :='0';

--! DUT ports
signal s_subbytes_tready   : std_logic;
signal s_subbytes_tdata    : std_logic_vector(0 to c_seq-1);
signal s_subbytes_tlast    : std_logic;
signal s_subbytes_tvalid   : std_logic;
signal m_subbytes_tready   : std_logic := '1';
signal m_subbytes_tdata    : std_logic_vector(0 to c_seq-1);
signal m_subbytes_tlast    : std_logic;
signal m_subbytes_tvalid   : std_logic;

--! procedures
procedure proc_wait_clk
  (constant cycles : in natural) is
begin
   for i in 0 to cycles-1 loop
    wait until rising_edge(clk);
   end loop;
end procedure;

begin

--! unused signals
  y <= 'Z';

--! standard signals
  clk            <= not clk  after c_clk_per/2;

--! dut
dut: entity work.trf_subbytes(rtl)
  port map (
    clk               => clk,
    reset_n           => rst_n,

    s_subbytes_tready => s_subbytes_tready,
    s_subbytes_tdata  => s_subbytes_tdata,
    s_subbytes_tlast  => s_subbytes_tlast,
    s_subbytes_tvalid => s_subbytes_tvalid,

    m_subbytes_tready => m_subbytes_tready,
    m_subbytes_tdata  => m_subbytes_tdata,
    m_subbytes_tlast  => m_subbytes_tlast,
    m_subbytes_tvalid => m_subbytes_tvalid
  );


  --! run test bench
  p_run: process

    procedure proc_reset
      (constant cycles : in natural) is
    begin
       rst_n <= '0';
       for i in 0 to cycles-1 loop
        wait until rising_edge(clk);
       end loop;
       rst_n <= '1';
    end procedure;

  begin

    report " RUN TST.00 ";
      s_subbytes_tdata     <= ( others => '0');
      s_subbytes_tlast     <= '0';
      s_subbytes_tvalid    <= '0';
      proc_reset(3);
      proc_wait_clk(5);

    report " RUN TST.01 ";
      proc_reset(3);
      for k in 0 to c_seq/8-1 loop
        s_subbytes_tdata(k*8+0 to k*8+7)     <= std_logic_vector(to_unsigned(k,8)) ;
        s_subbytes_tvalid    <= '0';
      end loop;
      s_subbytes_tvalid    <= '1';
      proc_wait_clk(1);
      s_subbytes_tvalid    <= '0';
      proc_wait_clk(10);


      proc_wait_clk(10);
    report " END of test bench" severity failure;

  end process;

end architecture rtl;
