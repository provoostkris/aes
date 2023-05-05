------------------------------------------------------------------------------
--  AES transformation function : mix columns
--  rev. 1.0 : 2023 provoost kris
------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_misc.all;
use     ieee.numeric_std.all;

library work;
use     work.aes_pkg.all;

entity trf_mixcolumns is
  port(
    clk           : in  std_logic;                    --system clock
    reset_n       : in  std_logic;                    --active low reset

    round_s       : in  integer range 1 to c_nr;

    mixcolumns_s  : in  std_logic_vector(0 to c_seq-1);
    mixcolumns_m  : out std_logic_vector(0 to c_seq-1)
  );
end trf_mixcolumns;

architecture rtl of trf_mixcolumns is

    --! array storage
    signal in_bytes_i         : t_raw_bytes ( 0 to c_arr-1);
    signal out_bytes_i        : t_raw_bytes ( 0 to c_arr-1);
    signal state_s_i          : t_state_bytes ( 0 to 3);
    signal state_m_i          : t_state_bytes ( 0 to 3);

    signal in_bytes_mul_2_i   : t_raw_bytes ( 0 to c_arr-1);
    signal in_bytes_mul_3_i   : t_raw_bytes ( 0 to c_arr-1);
    signal state_s_mul_2_i    : t_state_bytes ( 0 to 3);
    signal state_s_mul_3_i    : t_state_bytes ( 0 to 3);
begin

--! map input slv to 'input bytes'
in_bytes_i  <= f_slv_to_bytes(mixcolumns_s);

--! create array which is the input bytes multiplied in galois by 2 or 3
gen_mul_states: for j in 0 to c_arr-1 generate
  --! use lookup
  i_mul_2 : entity work.galois_mul(mul_2)
    port map(
      lookup  => in_bytes_i(j),
      result  => in_bytes_mul_2_i(j)
    );
  i_mul_3 : entity work.galois_mul(mul_3)
    port map(
      lookup  => in_bytes_i(j),
      result  => in_bytes_mul_3_i(j)
    );
end generate;

--! map input to state matrix
  -- process(reset_n, clk) is
  -- begin
      -- if reset_n='0' then
        -- state_s_i         <= ( others => ( others => ( others => '0')));
        -- state_s_mul_2_i   <= ( others => ( others => ( others => '0')));
        -- state_s_mul_3_i   <= ( others => ( others => ( others => '0')));
      -- elsif rising_edge(clk) then
        -- state_s_i         <= f_bytes_to_state(in_bytes_i);
        -- state_s_mul_2_i   <= f_bytes_to_state(in_bytes_mul_2_i);
        -- state_s_mul_3_i   <= f_bytes_to_state(in_bytes_mul_3_i);
      -- end if;
  -- end process;

        state_s_i         <= f_bytes_to_state(in_bytes_i);
        state_s_mul_2_i   <= f_bytes_to_state(in_bytes_mul_2_i);
        state_s_mul_3_i   <= f_bytes_to_state(in_bytes_mul_3_i);


--! perform the shift row operation
  process(reset_n, clk) is
  begin
      if reset_n='0' then
        state_m_i <= ( others => ( others => ( others => '0')));
      elsif rising_edge(clk) then
        --! pseudo code for each element in the array to be calculated
        -- r[0] = b[0] ^ a[3] ^ a[2] ^ b[1] ^ a[1]; /* 2 * a0 + a3 + a2 + 3 * a1 */
        -- r[1] = b[1] ^ a[0] ^ a[3] ^ b[2] ^ a[2]; /* 2 * a1 + a0 + a3 + 3 * a2 */
        -- r[2] = b[2] ^ a[1] ^ a[0] ^ b[3] ^ a[3]; /* 2 * a2 + a1 + a0 + 3 * a3 */
        -- r[3] = b[3] ^ a[2] ^ a[1] ^ b[0] ^ a[0]; /* 2 * a3 + a2 + a1 + 3 * a0 */
        for j in 0 to 3 loop
          state_m_i(0)(j)   <= state_s_mul_2_i(0)(j) xor state_s_i(3)(j) xor state_s_i(2)(j) xor state_s_mul_3_i(1)(j);
          state_m_i(1)(j)   <= state_s_mul_2_i(1)(j) xor state_s_i(0)(j) xor state_s_i(3)(j) xor state_s_mul_3_i(2)(j);
          state_m_i(2)(j)   <= state_s_mul_2_i(2)(j) xor state_s_i(1)(j) xor state_s_i(0)(j) xor state_s_mul_3_i(3)(j);
          state_m_i(3)(j)   <= state_s_mul_2_i(3)(j) xor state_s_i(2)(j) xor state_s_i(1)(j) xor state_s_mul_3_i(0)(j);
        end loop;
      end if;
  end process;

--! map state matrix to output bytes
  process(reset_n, clk) is
  begin
      if reset_n='0' then
        out_bytes_i <= ( others => ( others => '0'));
      elsif rising_edge(clk) then
        out_bytes_i <= f_state_to_bytes(state_m_i);
      end if;
  end process;

--! map 'output bytes' to slv
--! note that in the last round the mixcolumns function is disabled as per FIPS standard
mixcolumns_m  <= f_bytes_to_slv(out_bytes_i) when round_s < c_nr else mixcolumns_s;

end rtl;