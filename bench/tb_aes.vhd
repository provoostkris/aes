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
  signal s_key_tready  :  std_logic;                                --! key input
  signal s_key_tdata   :  std_logic_vector(c_key-1 downto 0);
  signal s_key_tlast   :  std_logic;
  signal s_key_tvalid  :  std_logic;
  signal s_dat_tready  :  std_logic;                                --! dat input
  signal s_dat_tdata   :  std_logic_vector(c_seq-1 downto 0);
  signal s_dat_tlast   :  std_logic;
  signal s_dat_tvalid  :  std_logic;
  signal m_dat_tvalid  :  std_logic;                               --! dat output
  signal m_dat_tdata   :  std_logic_vector(c_seq-1 downto 0);
  signal m_dat_tlast   :  std_logic;
  signal m_dat_tready  :  std_logic;

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

    procedure proc_reset
      (constant cycles : in natural) is
    begin
       rst_n <= '0';
       for i in 0 to cycles-1 loop
        wait until rising_edge(clk);
       end loop;
       rst_n <= '1';
    end procedure;

    alias alias_start : t_round_vec(0 to c_nr) is << signal .tb_aes.dut.s_subbytes_tdata    : t_round_vec(0 to c_nr) >> ;
    alias alias_s_box : t_round_vec(1 to c_nr) is << signal .tb_aes.dut.m_subbytes_tdata    : t_round_vec(1 to c_nr) >> ;
    alias alias_s_row : t_round_vec(1 to c_nr) is << signal .tb_aes.dut.m_shiftrows_tdata   : t_round_vec(1 to c_nr) >> ;
    alias alias_m_col : t_round_vec(1 to c_nr) is << signal .tb_aes.dut.m_mixcolumns_tdata  : t_round_vec(1 to c_nr) >> ;
    alias alias_k_sch : t_round_vec(0 to c_nr) is << signal .tb_aes.dut.s_roundkey_tdata    : t_round_vec(0 to c_nr) >> ;

    variable v_rline     : line;
    variable v_wline     : line;
    variable v_space     : character;
    variable v_round     : string(1 to 15);
    variable v_check     : std_logic_vector(c_seq-1 downto 0);
    variable v_slv_seq   : std_logic_vector(0 to c_seq-1);

  begin


    report " RUN TST.00 ";

      s_key_tdata  <= ( others => '0');
      s_key_tlast  <= '0';
      s_key_tvalid <= '0';
      s_dat_tdata  <= ( others => '0');
      s_dat_tlast  <= '0';
      s_dat_tvalid <= '0';
      proc_reset(3);
      proc_wait_clk(133);


    report " RUN TST.01 ";

      file_open(file_inputs, "../references/fips_197_c3.txt",  read_mode);
      file_open(file_results, "output_results.txt", write_mode);

      proc_reset(3);
      s_key_tdata  <= c_ref_key;
      s_key_tlast  <= '0';
      s_key_tvalid <= '0';
      s_dat_tdata  <= c_ref_plain;
      s_dat_tlast  <= '0';
      s_dat_tvalid <= '0';

      proc_wait_clk(2);
      s_key_tvalid <= '1';
      s_dat_tvalid <= '1';
      proc_wait_clk(1);
      s_key_tvalid <= '0';
      s_dat_tvalid <= '0';

      proc_wait_clk(133);

      while not endfile(file_inputs) loop
        readline(file_inputs, v_rline);
        read(v_rline, v_round);
        read(v_rline, v_space);           -- read in the space character
        hread(v_rline, v_check);

        report "Reference : " & v_round & " - " & to_hstring(v_check) ;
      end loop;

      for j in 1 to c_nr loop

        v_slv_seq := alias_start(j);
        report "Result : " & integer'image(j) & " - " & to_hstring(v_slv_seq) ;
        swrite(v_wline, "round[" & integer'image(j) &"].start ");
        hwrite(v_wline, v_slv_seq);
        writeline(file_results, v_wline);

        v_slv_seq := alias_s_box(j);
        report "Result : " & integer'image(j) & " - " & to_hstring(v_slv_seq) ;
        swrite(v_wline, "round[" & integer'image(j) &"].s_box ");
        hwrite(v_wline, v_slv_seq);
        writeline(file_results, v_wline);

        v_slv_seq := alias_s_row(j);
        report "Result : " & integer'image(j) & " - " & to_hstring(v_slv_seq) ;
        swrite(v_wline, "round[" & integer'image(j) &"].s_row ");
        hwrite(v_wline, v_slv_seq);
        writeline(file_results, v_wline);

        v_slv_seq := alias_m_col(j);
        report "Result : " & integer'image(j) & " - " & to_hstring(v_slv_seq) ;
        swrite(v_wline, "round[" & integer'image(j) &"].m_col ");
        hwrite(v_wline, v_slv_seq);
        writeline(file_results, v_wline);

        v_slv_seq := alias_k_sch(j);
        report "Result : " & integer'image(j) & " - " & to_hstring(v_slv_seq) ;
        swrite(v_wline, "round[" & integer'image(j) &"].k_sch ");
        hwrite(v_wline, v_slv_seq);
        writeline(file_results, v_wline);

      end loop;

      report "Cypher out :" & " - " & to_hstring(m_dat_tdata) ;
      swrite(v_wline, "round[14].resul ");
      hwrite(v_wline, m_dat_tdata);
      writeline(file_results, v_wline);

    --! closing files before exiting test bench
    file_close(file_inputs);
    file_close(file_results);

    report " END of test bench" severity failure;

  end process;
end architecture rtl;