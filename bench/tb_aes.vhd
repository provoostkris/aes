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

use STD.textio.all;
use ieee.std_logic_textio.all;

library work;
use     work.aes_pkg.all;

entity tb_aes is
	port(
		y        :  out std_logic
	);
end entity tb_aes;

architecture rtl of tb_aes is

  file file_inputs  : text;
  file file_results : text;

  constant c_ref_plain : std_logic_vector(0 to 127) := x"00112233445566778899aabbccddeeff" ;                                  --! value from fips 197 document
  constant c_ref_key   : std_logic_vector(0 to 255) := x"000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f";   --! value from fips 197 document

  constant c_clk_per  : time      := 20 ns ;

  signal clk            : std_ulogic :='0';
  signal rst_n          : std_ulogic :='0';

  --! DUT ports
  signal key_s : std_logic_vector(0 to c_key-1); --! key input
  signal dat_s : std_logic_vector(0 to c_seq-1); --! dat input
  signal dat_m : std_logic_vector(0 to c_seq-1); --! dat output


  --! procedures
  procedure proc_wait_clk
    (constant cycles : in natural) is
  begin
     for i in 0 to cycles-1 loop
      wait until rising_edge(clk);
     end loop;
  end procedure;

begin

  dut: entity work.aes(rtl)
    port map (

    clk           => clk,
    rst_n         => rst_n,

    key_s         => key_s,
    dat_s         => dat_s,
    dat_m         => dat_m
    );

  --! clk drivers
	clk    <= not clk  after c_clk_per/2;

	--! run test bench
	p_run: process

    alias alias_start : t_round_vec(0 to c_nr) is << signal .tb_aes.dut.subbytes_s    : t_round_vec(0 to c_nr) >> ;
    alias alias_s_box : t_round_vec(1 to c_nr) is << signal .tb_aes.dut.subbytes_m    : t_round_vec(1 to c_nr) >> ;
    alias alias_s_row : t_round_vec(1 to c_nr) is << signal .tb_aes.dut.shiftrows_m   : t_round_vec(1 to c_nr) >> ;
    alias alias_m_col : t_round_vec(1 to c_nr) is << signal .tb_aes.dut.mixcolumns_m  : t_round_vec(1 to c_nr) >> ;
    alias alias_k_sch : t_round_vec(0 to c_nr) is << signal .tb_aes.dut.roundkey_s    : t_round_vec(0 to c_nr) >> ;

    variable v_rline     : line;
    variable v_wline     : line;
    variable v_space     : character;
    variable v_round     : string(1 to 15);
    variable v_check     : std_logic_vector(c_seq-1 downto 0);
    variable v_slv_seq   : std_logic_vector(0 to c_seq-1);

	begin


	  report " RUN TST.00 ";

      key_s <= ( others => '0');
      dat_s <= ( others => '0');
      rst_n <= '0';
      proc_wait_clk(2);
      rst_n <= '1';

      proc_wait_clk(150);


	  report " RUN TST.01 ";

      file_open(file_inputs, "../references/fips_197_c3.txt",  read_mode);
      file_open(file_results, "output_results.txt", write_mode);

      key_s <= c_ref_key;
      dat_s <= c_ref_plain;
      rst_n <= '0';
      proc_wait_clk(2);
      rst_n <= '1';

      proc_wait_clk(150);

      while not endfile(file_inputs) loop
        readline(file_inputs, v_rline);
        read(v_rline, v_round);
        read(v_rline, v_space);           -- read in the space character
        hread(v_rline, v_check);

        report "Verify : " & v_round & " - " & to_hstring(v_check) ;
      end loop;

      for j in 1 to c_nr loop

        v_slv_seq := alias_start(j);
        proc_wait_clk(1);
        report "Result : " & integer'image(j) & " - " & to_hstring(v_slv_seq) ;
        swrite(v_wline, "round[" & integer'image(j) &"].start ");
        hwrite(v_wline, v_slv_seq);
        writeline(file_results, v_wline);

        v_slv_seq := alias_s_box(j);
        proc_wait_clk(1);
        report "Result : " & integer'image(j) & " - " & to_hstring(v_slv_seq) ;
        swrite(v_wline, "round[" & integer'image(j) &"].s_box ");
        hwrite(v_wline, v_slv_seq);
        writeline(file_results, v_wline);

        v_slv_seq := alias_s_row(j);
        proc_wait_clk(1);
        report "Result : " & integer'image(j) & " - " & to_hstring(v_slv_seq) ;
        swrite(v_wline, "round[" & integer'image(j) &"].s_row ");
        hwrite(v_wline, v_slv_seq);
        writeline(file_results, v_wline);

        v_slv_seq := alias_m_col(j);
        proc_wait_clk(1);
        report "Result : " & integer'image(j) & " - " & to_hstring(v_slv_seq) ;
        swrite(v_wline, "round[" & integer'image(j) &"].m_col ");
        hwrite(v_wline, v_slv_seq);
        writeline(file_results, v_wline);

        v_slv_seq := alias_k_sch(j);
        proc_wait_clk(1);
        report "Result : " & integer'image(j) & " - " & to_hstring(v_slv_seq) ;
        swrite(v_wline, "round[" & integer'image(j) &"].k_sch ");
        hwrite(v_wline, v_slv_seq);
        writeline(file_results, v_wline);

      end loop;
      
      report "Output : " & " - " & to_hstring(dat_m) ;
      swrite(v_wline, "round[14].resul ");
      hwrite(v_wline, dat_m);
      writeline(file_results, v_wline);

    --! closing files before exiting test bench
    file_close(file_inputs);
    file_close(file_results);

	  report " END of test bench" severity failure;

	end process;
end architecture rtl;