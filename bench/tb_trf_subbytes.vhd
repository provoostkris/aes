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
signal rst          : std_ulogic :='0';
signal rst_n        : std_ulogic ;

--! DUT ports

signal subbytes_s    : std_logic_vector(0 to c_seq-1);
signal subbytes_m    : std_logic_vector(0 to c_seq-1);

--! procedures
procedure proc_wait_clk
  (constant cycles : in natural) is
begin
   for i in 0 to cycles-1 loop
    wait until rising_edge(clk);
   end loop;
end procedure;

begin

--! standard signals
	clk            <= not clk  after c_clk_per/2;
  rst_n          <= not rst;

--! dut
dut: entity work.trf_subbytes(rtl)
  port map (
    clk               => clk,
    reset_n           => rst_n,

		subbytes_s        => subbytes_s,
    subbytes_m        => subbytes_m
  );


	--! run test bench
	p_run: process

	  procedure proc_reset
	    (constant cycles : in natural) is
	  begin
	     rst <= '1';
	     for i in 0 to cycles-1 loop
	      wait until rising_edge(clk);
	     end loop;
	     rst <= '0';
	  end procedure;

	begin

	  report " RUN TST.00 ";
	    subbytes_s     <= ( others => '0');
	    proc_reset(3);
	    proc_wait_clk(2);

	  report " RUN TST.01 ";
			for k in 0 to c_seq/8-1 loop
	    	 subbytes_s(k*8+0 to k*8+7)     <= std_logic_vector(to_unsigned(k,8)) ;
		  end loop;
	    proc_reset(3);
	    proc_wait_clk(2);


	    proc_wait_clk(10);
	  report " END of test bench" severity failure;

	end process;

end architecture rtl;
