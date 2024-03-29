------------------------------------------------------------------------------
--  Test Bench for the trf_addroundkey
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

entity tb_trf_addroundkey is
	port(
		y        :  out std_logic
	);
end entity tb_trf_addroundkey;

architecture rtl of tb_trf_addroundkey is

constant c_clk_per  : time      := 20 ns ;

signal clk          : std_ulogic :='0';
signal rst_n        : std_ulogic :='0';

--! DUT ports
signal s_addroundkey_tready   : std_logic;
signal s_addroundkey_tdata    : std_logic_vector(0 to c_seq-1);
signal s_addroundkey_tlast    : std_logic;
signal s_addroundkey_tvalid   : std_logic;
signal s_roundkey_tready      : std_logic;
signal s_roundkey_tdata       : std_logic_vector(0 to c_seq-1);
signal s_roundkey_tlast       : std_logic;
signal s_roundkey_tvalid      : std_logic;
signal m_addroundkey_tready   : std_logic := '1';
signal m_addroundkey_tdata    : std_logic_vector(0 to c_seq-1);
signal m_addroundkey_tlast    : std_logic;
signal m_addroundkey_tvalid   : std_logic;

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
dut: entity work.trf_addroundkey(rtl)
  port map (
    clk               => clk,
    reset_n           => rst_n,

    s_addroundkey_tready => s_addroundkey_tready,
    s_addroundkey_tdata  => s_addroundkey_tdata,
    s_addroundkey_tlast  => s_addroundkey_tlast,
    s_addroundkey_tvalid => s_addroundkey_tvalid,

    s_roundkey_tready    => s_roundkey_tready,
    s_roundkey_tdata     => s_roundkey_tdata,
    s_roundkey_tlast     => s_roundkey_tlast,
    s_roundkey_tvalid    => s_roundkey_tvalid,

    m_addroundkey_tready => m_addroundkey_tready,
    m_addroundkey_tdata  => m_addroundkey_tdata,
    m_addroundkey_tlast  => m_addroundkey_tlast,
    m_addroundkey_tvalid => m_addroundkey_tvalid
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
	    s_addroundkey_tdata     <= ( others => '0');
	    s_addroundkey_tlast     <= '0';
	    s_addroundkey_tvalid    <= '0';
	    s_roundkey_tdata        <= ( others => '0');
	    s_roundkey_tlast        <= '0';
	    s_roundkey_tvalid       <= '0';
	    proc_reset(3);
	    proc_wait_clk(5);

	  report " RUN TST.01 ";
			for k in 0 to c_arr-1 loop
        s_addroundkey_tdata(k*8+0 to k*8+7)  <= std_logic_vector(to_unsigned(k+0,8)) ;
        s_addroundkey_tlast     <= '0';
        s_addroundkey_tvalid    <= '1';
        s_roundkey_tdata(k*8+0 to k*8+7)     <= std_logic_vector(to_unsigned(k+c_arr,8)) ;
        s_roundkey_tlast        <= '0';
        s_roundkey_tvalid       <= '1';
		  end loop;
	    proc_reset(3);
	    proc_wait_clk(1);
	    s_addroundkey_tvalid    <= '0';
	    s_roundkey_tvalid       <= '0';
	    proc_wait_clk(5);


	    proc_wait_clk(10);
	  report " END of test bench" severity failure;

	end process;

end architecture rtl;