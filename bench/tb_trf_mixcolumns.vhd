------------------------------------------------------------------------------
--  Test Bench for the trf_mixcolumns
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

entity tb_trf_mixcolumns is
	port(
		y        :  out std_logic
	);
end entity tb_trf_mixcolumns;

architecture rtl of tb_trf_mixcolumns is

constant c_clk_per  : time      := 20 ns ;

signal clk          : std_ulogic :='0';
signal rst          : std_ulogic :='0';
signal rst_n        : std_ulogic ;

--! DUT ports

signal mixcolumns_s    : std_logic_vector(0 to c_seq-1);
signal mixcolumns_m    : std_logic_vector(0 to c_seq-1);

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
dut: entity work.trf_mixcolumns(rtl)
  port map (
    clk               => clk,
    reset_n           => rst_n,

		round_s           => 1,

		mixcolumns_s      => mixcolumns_s,
    mixcolumns_m      => mixcolumns_m
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
	    mixcolumns_s     <= ( others => '0');
	    proc_reset(3);
	    proc_wait_clk(10);

	  report " RUN TST.01 ";
			for k in 0 to c_arr-1 loop
	    	 mixcolumns_s(k*8+0 to k*8+7)     <= std_logic_vector(to_unsigned(1,8)) ;
		  end loop;
	    proc_reset(3);
	    proc_wait_clk(10);

	  report " RUN TST.02 ";
			for k in 0 to c_arr-1 loop
	    	 mixcolumns_s(k*8+0 to k*8+7)     <= std_logic_vector(to_unsigned(198,8)) ;
		  end loop;
	    proc_reset(3);
	    proc_wait_clk(10);

	  report " RUN TST.03 ";
      -- Test vectors for MixColumn()
      -- Hexadecimal	Decimal
      -- Before	      After	        Before	      After
      -- db 13 53 45	8e 4d a1 bc	  219 19 83 69	  142 77 161 188
      -- f2 0a 22 5c	9f dc 58 9d	  242 10 34 92	  159 220 88 157
      -- 01 01 01 01	01 01 01 01	  1 1 1 1	        1 1 1 1
      -- c6 c6 c6 c6	c6 c6 c6 c6	  198 198 198 198	198 198 198 198
      -- d4 d4 d4 d5	d5 d5 d7 d6	  212 212 212 213	213 213 215 214
      -- 2d 26 31 4c	4d 7e bd f8	  45 38 49 76	    77 126 189 248

			for k in 0 to c_arr-1 loop
        if k = 0  then mixcolumns_s(k*8+0 to k*8+7)  <= x"db" ; end if;
        if k = 1  then mixcolumns_s(k*8+0 to k*8+7)  <= x"13" ; end if;
        if k = 2  then mixcolumns_s(k*8+0 to k*8+7)  <= x"53" ; end if;
        if k = 3  then mixcolumns_s(k*8+0 to k*8+7)  <= x"45" ; end if;

        if k = 4  then mixcolumns_s(k*8+0 to k*8+7)  <= x"f2" ; end if;
        if k = 5  then mixcolumns_s(k*8+0 to k*8+7)  <= x"0a" ; end if;
        if k = 6  then mixcolumns_s(k*8+0 to k*8+7)  <= x"22" ; end if;
        if k = 7  then mixcolumns_s(k*8+0 to k*8+7)  <= x"5c" ; end if;

        if k = 8  then mixcolumns_s(k*8+0 to k*8+7)  <= x"d4" ; end if;
        if k = 9  then mixcolumns_s(k*8+0 to k*8+7)  <= x"d4" ; end if;
        if k = 10 then mixcolumns_s(k*8+0 to k*8+7)  <= x"d4" ; end if;
        if k = 11 then mixcolumns_s(k*8+0 to k*8+7)  <= x"d5" ; end if;

        if k = 12 then mixcolumns_s(k*8+0 to k*8+7)  <= x"2d" ; end if;
        if k = 13 then mixcolumns_s(k*8+0 to k*8+7)  <= x"26" ; end if;
        if k = 14 then mixcolumns_s(k*8+0 to k*8+7)  <= x"31" ; end if;
        if k = 15 then mixcolumns_s(k*8+0 to k*8+7)  <= x"4c" ; end if;
		  end loop;

	    proc_reset(3);
	    proc_wait_clk(10);


	    proc_wait_clk(10);
	  report " END of test bench" severity failure;

	end process;

end architecture rtl;