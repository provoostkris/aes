------------------------------------------------------------------------------
--  Test Bench for the key_expand
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

entity tb_key_expand is
	port(
		y        :  out std_logic
	);
end entity tb_key_expand;

architecture rtl of tb_key_expand is

constant c_clk_per  : time      := 20 ns ;

constant c_cypher_key : t_raw_bytes ( 0 to c_key/8-1 ) := (
    x"60",x"3d",x"eb",x"10",x"15",x"ca",x"71",x"be",x"2b",x"73",x"ae",x"f0",x"85",x"7d",x"77",x"81",
    x"1f",x"35",x"2c",x"07",x"3b",x"61",x"08",x"d7",x"2d",x"98",x"10",x"a3",x"09",x"14",x"df",x"f4"
    );


signal clk          : std_ulogic :='0';
signal rst_n        : std_ulogic :='0';

--! DUT ports
signal s_keyexpand_tready    : std_logic;
signal s_keyexpand_tdata     : std_logic_vector(0 to c_key-1);
signal s_keyexpand_tlast     : std_logic;
signal s_keyexpand_tvalid    : std_logic;
signal m_keyexpand_tready    : std_logic;
signal m_keyexpand_tdata     : t_raw_words ( 0    to c_nb*(c_nr+1)-1);
signal m_keyexpand_tlast     : std_logic;
signal m_keyexpand_tvalid    : std_logic;

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
dut: entity work.key_expand(rtl)
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
	    m_keyexpand_tready    <= '1';
	    s_keyexpand_tdata     <= ( others => '0');
	    s_keyexpand_tlast     <= '0';
	    s_keyexpand_tvalid    <= '1';
	    proc_reset(3);
	    proc_wait_clk(10);

	  report " RUN TST.01 ";
			for k in 0 to c_key/8-1 loop
        m_keyexpand_tready    <= '1';
	    	s_keyexpand_tdata(k*8+0 to k*8+7)  <= c_cypher_key(k) ;
        s_keyexpand_tlast     <= '0';
        s_keyexpand_tvalid    <= '1';
		  end loop;
	    proc_reset(3);
	    proc_wait_clk(10);


	    proc_wait_clk(10);
	  report " END of test bench" severity failure;

	end process;

end architecture rtl;
