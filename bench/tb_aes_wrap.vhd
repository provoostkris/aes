------------------------------------------------------------------------------
--  Test Bench for the aes
--  rev. 1.0 : 2023 Provoost Kris
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;


library work;
use     work.aes_pkg.all;

entity tb_aes_wrap is
	port(
		y        :  out std_logic
	);
end entity tb_aes_wrap;

architecture rtl of tb_aes_wrap is

  constant c_clk_per  : time      := 20 ns ;

  signal clk            : std_ulogic :='0';
  signal rst_n          : std_ulogic :='0';

  --! DUT ports
  signal s_key_tready  : std_logic;                                --! key input
  signal s_key_tdata   : std_logic_vector(8-1 downto 0);
  signal s_key_tlast   : std_logic;
  signal s_key_tvalid  : std_logic;
  signal s_dat_tready  : std_logic;                                --! dat input
  signal s_dat_tdata   : std_logic_vector(8-1 downto 0);
  signal s_dat_tlast   : std_logic;
  signal s_dat_tvalid  : std_logic;
  signal m_dat_tvalid  : std_logic;                               --! dat output
  signal m_dat_tdata   : std_logic_vector(8-1 downto 0);
  signal m_dat_tlast   : std_logic;
  signal m_dat_tready  : std_logic;

  --! procedures
  procedure proc_wait_clk
    (constant cycles : in natural) is
  begin
     for i in 0 to cycles-1 loop
      wait until rising_edge(clk);
     end loop;
  end procedure;

begin

  dut: entity work.aes_wrap(rtl)
    port map (

      clk           => clk,
      rst_n         => rst_n,

      s_key_tready  => s_key_tready ,
      s_key_tdata   => s_key_tdata  ,
      s_key_tlast   => s_key_tlast  ,
      s_key_tvalid  => s_key_tvalid ,

      s_dat_tready  => s_dat_tready ,
      s_dat_tdata   => s_dat_tdata  ,
      s_dat_tlast   => s_dat_tlast  ,
      s_dat_tvalid  => s_dat_tvalid ,

      m_dat_tvalid  => m_dat_tvalid ,
      m_dat_tdata   => m_dat_tdata  ,
      m_dat_tlast   => m_dat_tlast  ,
      m_dat_tready  => m_dat_tready
    );

  --! clk drivers
	clk    <= not clk  after c_clk_per/2;

  --! unused for now
  y <= 'Z';

	--! run test bench
	p_run: process

	begin

	  report " RUN TST.00 ";

      s_key_tdata <= ( others => '0');
      s_dat_tdata <= ( others => '0');
      rst_n <= '0';
      proc_wait_clk(2);
      rst_n <= '1';

      proc_wait_clk(150);

	  report " END of test bench" severity failure;

	end process;
end architecture rtl;