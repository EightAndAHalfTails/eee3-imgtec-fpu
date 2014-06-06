library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real;
use ieee.fixed_float_types.all;
use ieee.fixed_pkg.all;
use work.all;
use work.types.all;

entity isqrt is
  generic(lookup_bits : integer := 4;
          iterations : integer := 8);
  port(
    isqrt_in1 : in std_logic_vector(31 downto 0);
    isqrt_out : out std_logic_vector(31 downto 0)
    );
end entity isqrt;

architecture lut_halley of isqrt is
  signal input, output : float32_t;
  signal s_neg_half_exp : unsigned(7 downto 0);
  signal s_sig_in, s_initial_guess, s_final_approx : ufixed(0 downto -24);
  
  type intermed_t is array (1 to iterations-1) of ufixed(0 downto -24);
  signal intermediate_values : intermed_t;
  
  type lut_t is array (integer range <>) of ufixed(0 downto -23);
  function build_lut(keysize: integer) return lut_t is
    variable lut_size : integer := 2**keysize;
    variable result : lut_t(0 to lut_size-1);
    variable radicand_bits : ufixed(0 downto -23);
    variable radicand_real : real;
  begin
    for i in result'left to result'right loop
      radicand_bits := (others => '0');
      radicand_bits(radicand_bits'high downto radicand_bits'high+1-keysize) := to_ufixed(i, radicand_bits'high, radicand_bits'high+1-keysize);
      radicand_real := to_real(radicand_bits);
      result(i) := to_ufixed(1.0 / math_real.sqrt(radicand_real), 0, -23);
    end loop;
    return result;
  end function build_lut;  
  constant initial_guess_lut : lut_t := build_lut(lookup_bits);
begin
  input <= slv2float(isqrt_in1);
  isqrt_out <= float2slv(output);
  
  ------------------------------------------------
  -- get_sig_exp
  -- square rooting involves halving the exponent,
  -- but if the exponent is odd then we must make
  -- it even first by halving the significand and
  -- incrementing the exponent.
  ------------------------------------------------
  -- if the unbiased exponent is even, we simply
  -- shift it down and add 64.
  -- if the unbiased exponent is odd, we decrease
  -- the exponent by one and shift the significand
  -- down one, before shifting the exponent. (this
  -- corresponds to truncating the exponent)
  get_sig_exp: process(input)
  begin
    s_neg_half_exp <= to_unsigned(63, 8) - unsigned(input.exponent(7 downto 1));
    
    if input.exponent(0) = '0' then -- exponent even -> exponent-127 odd -> sig needs shifting
      s_sig_in <= resize(to_ufixed(0.5, 0, -1) + to_ufixed(input.significand, -2, -24), 0, -24);
    else
      s_sig_in <= resize(to_ufixed(1, 0, 0) + to_ufixed(input.significand, -1, -23), 0, -24);
    end if;
  end process get_sig_exp;
  
  s_initial_guess <= initial_guess_lut(to_integer(unsigned(to_slv(s_sig_in)))) & '0';
  
  gen_iter: for i in 0 to iterations-1 generate
    first: if i = 0 generate
      iter0: entity isqrt_iter port map(
        init => s_sig_in,
        prev => s_initial_guess,
        curr => intermediate_values(1)
      );
    end generate first;
      
    middle: if I > 0 and I < iterations-1 generate
      iterx: entity isqrt_iter port map(
        init => s_sig_in,
        prev => intermediate_values(I),
        curr => intermediate_values(I+1)
      );
    end generate middle;
    
    last: if I = iterations-1 generate
      itern: entity isqrt_iter port map(
        init => s_sig_in,
        prev => intermediate_values(iterations-1),
        curr => s_final_approx
      );
    end generate last;
  end generate gen_iter;
  
  encode_output: process(input, s_final_approx, s_neg_half_exp)
    variable shift_amount : integer;
  begin
    if input = neg_zero then
      output <= neg_inf;
    elsif input.sign = '1' or isNan(input) then
      output <= nan;
    elsif input = pos_inf then
      output <= pos_zero;
    else
      shift_amount := leading_one(to_slv(s_final_approx)) - 1;
      report "Shifting by " & integer'image(shift_amount) severity note;
      output.sign <= '0';
      output.exponent <= slv(usg(s_neg_half_exp) - to_unsigned(shift_amount, s_neg_half_exp'length));
      output.significand <= to_slv(scalb(s_final_approx, shift_amount)(0 downto -23));
    end if;
  end process encode_output;
  
end architecture lut_halley;