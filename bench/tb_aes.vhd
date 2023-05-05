------------------------------------------------------------------------------
--  Test Bench for the aes
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

entity tb_aes is
	port(
		y        :  out std_logic
	);
end entity tb_aes;

architecture rtl of tb_aes is

constant c_clk_per  : time      := 20 ns ;

signal clk          : std_ulogic :='0';
signal rst          : std_ulogic :='0';

--! DUT ports
signal KEY          : std_logic_vector(1 downto 0); --! Push button - debounced
signal SW           : std_logic_vector(3 downto 0); --! Slide button
signal Led          : std_logic_vector(7 downto 0); --! indicators

--! procedures
procedure proc_wait_clk
  (constant cycles : in natural) is
begin
   for i in 0 to cycles-1 loop
    wait until rising_edge(clk);
   end loop;
end procedure;

begin

	clk            <= not clk  after c_clk_per/2;
  
	KEY(0)         <= '0', '1' after c_clk_per * 10 ;
	KEY(1)         <= '0', '1' after c_clk_per * 12 ;
	SW(0)          <= '1', '0' after c_clk_per * 14 ;
	SW(1)          <= '1', '0' after c_clk_per * 16 ;
	SW(2)          <= '1', '0' after c_clk_per * 18 ;
	SW(3)          <= '1', '0' after c_clk_per * 20 ;

dut: entity work.aes(rtl)
  port map (
    FPGA_CLK1_50      => clk,
    FPGA_CLK2_50      => clk,
    FPGA_CLK3_50      => clk,
    -- Buttons & LEDs
    KEY               => KEY,
    SW                => SW,
    Led               => Led,
    -- ADV7513
    status            => y
  );


	--! run test bench
	p_run: process

	begin

	  report " RUN TST.00 ";
	  proc_wait_clk(200);

	  report " END of test bench" severity failure;

	end process;
end architecture rtl;