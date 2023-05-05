------------------------------------------------------------------------------
--  TOP level design file for HDMI controller <> Terrasic DE10 nano Cyclone 5 design
--  rev. 1.0 : 2021 Provoost Kris
------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.std_logic_misc.all;

library work;
use     work.aes_pkg.all;

entity aes is
  generic (
    g_imp             : in    natural range 0 to 2 := 2
  );
  port (
    FPGA_CLK1_50      : in    std_ulogic; --! FPGA clock 1 input 50 MHz
    FPGA_CLK2_50      : in    std_ulogic; --! FPGA clock 2 input 50 MHz
    FPGA_CLK3_50      : in    std_ulogic; --! FPGA clock 3 input 50 MHz
    -- Buttons & LEDs
    KEY               : in    std_logic_vector(1 downto 0); --! Push button - debounced
    SW                : in    std_logic_vector(3 downto 0); --! Slide button
    Led               : out   std_logic_vector(7 downto 0); --! indicators
    -- status signal
    status            : out   std_logic
  );
end;

architecture rtl of aes is

signal rst_50    : std_logic;
signal rst_50_n  : std_logic;
signal clk_50    : std_logic;

-- local signals

signal led_cnt        : unsigned(24 downto 0);
signal lfsr_reg       : std_logic_vector(c_seq-1 downto 0);

signal keyexpand_s    : std_logic_vector(0 to c_key-1);
signal keyexpand_m    : t_raw_words ( 0    to c_nb*(c_nr+1)-1);

signal subbytes_s     : t_round_vec(0 to c_nr);
signal subbytes_m     : t_round_vec(1 to c_nr);

signal shiftrows_s    : t_round_vec(1 to c_nr);
signal shiftrows_m    : t_round_vec(1 to c_nr);

signal mixcolumns_s   : t_round_vec(1 to c_nr);
signal mixcolumns_m   : t_round_vec(1 to c_nr);

signal addroundkey_s  : t_round_vec(1 to c_nr);
signal roundkey_s     : t_round_vec(0 to c_nr);
signal addroundkey_m  : t_round_vec(0 to c_nr);

signal output_state   : std_logic_vector(0 to c_seq-1);

begin


--! top level assigments

clk_50                  <= FPGA_CLK1_50 ;

led(1)                  <= '0';
led(2)                  <= '0';
led(3)                  <= '0';
led(4)                  <= '0';
led(5)                  <= '0';
led(6)                  <= '0';
led(7)                  <= '0';

--! syncronous resets
p_rst_50: process (clk_50, KEY(0) )
begin
  if KEY(0) = '0' then
    rst_50   <= '1';
    rst_50_n <= '0';
  elsif rising_edge(clk_50) then
    rst_50   <= '0';
    rst_50_n <= '1';
  end if;
end process p_rst_50;

--!
--! implementation
--!

-- dummy input assignment
  process (clk_50)
    variable lfsr_tap : std_logic;
  begin
    if rising_edge(clk_50) then
      if rst_50_n = '0' then
        lfsr_reg <= (others => '1');
      else
        lfsr_tap := lfsr_reg(25) xor lfsr_reg(15) xor lfsr_reg(5) xor lfsr_reg(lfsr_reg'high);
        lfsr_reg <= lfsr_reg(lfsr_reg'high-1 downto 0) & lfsr_tap;
      end if;
    end if;
  end process;

  -- dummy assign to a pin to preserve the logic
  status <= or_reduce(output_state);

  -- put some value in the plain text
  -- subbytes_s  <= lfsr_reg ;
  subbytes_s(0)  <=  c_ref_plain;

  -- put some value in the key
  -- keyexpand_s(k)    <= (others => SW(1) );
  keyexpand_s <=  c_ref_key;

-- start with the key expansion
  i_key_expand: entity work.key_expand(rtl)
    port map (
      clk               => clk_50,
      reset_n           => rst_50_n,

      keyexpand_s        => keyexpand_s,
      keyexpand_m        => keyexpand_m
    );

  -- assign round keys
  gen_keys:  for j in 0 to c_nr generate
    roundkey_s(j)   <=  keyexpand_m(j*4+0) &
                        keyexpand_m(j*4+1) &
                        keyexpand_m(j*4+2) &
                        keyexpand_m(j*4+3);
  end generate;

-- Cipher step 1 add round key
  i_trf_addroundkey: entity work.trf_addroundkey(rtl)
    port map (
      clk               => clk_50,
      reset_n           => rst_50_n,

      addroundkey_s     => subbytes_s(0),
      roundkey_s        => roundkey_s(0),
      addroundkey_m     => addroundkey_m(0)
    );


-- then cascade the four transformations for a loop of 10x/12x/14x
gen_rounds:  for j in 1 to c_nr generate

  subbytes_s(j) <= addroundkey_m(j-1);

  i_trf_subbytes: entity work.trf_subbytes(rtl)
    port map (
      clk               => clk_50,
      reset_n           => rst_50_n,

      subbytes_s        => subbytes_s(j),
      subbytes_m        => subbytes_m(j)
    );

  shiftrows_s(j) <= subbytes_m(j);

  i_trf_shiftrows: entity work.trf_shiftrows(rtl)
    port map (
      clk               => clk_50,
      reset_n           => rst_50_n,

      shiftrows_s       => shiftrows_s(j),
      shiftrows_m       => shiftrows_m(j)
    );

  mixcolumns_s(j) <= shiftrows_m(j);

  i_trf_mixcolumns: entity work.trf_mixcolumns(rtl)
    port map (
      clk               => clk_50,
      reset_n           => rst_50_n,

      round_s           => j,

      mixcolumns_s      => mixcolumns_s(j),
      mixcolumns_m      => mixcolumns_m(j)
    );

  addroundkey_s(j) <= mixcolumns_m(j);

  i_trf_addroundkey: entity work.trf_addroundkey(rtl)
    port map (
      clk               => clk_50,
      reset_n           => rst_50_n,

      addroundkey_s     => addroundkey_s(j),
      roundkey_s        => roundkey_s(j),
      addroundkey_m     => addroundkey_m(j)
    );

end generate;

--! the output state is the result of the last transformation in the last round
output_state  <= addroundkey_m(c_nr);

--! just blink LED to see activity
p_led: process (clk_50, rst_50)
begin
  if rst_50 = '1' then
    led(0)    <= '0';
    led_cnt   <= ( others => '0');
  elsif rising_edge(clk_50) then
    led(0)    <= led_cnt(led_cnt'high);
    led_cnt   <= led_cnt + 1;
  end if;
end process p_led;

end architecture rtl;
