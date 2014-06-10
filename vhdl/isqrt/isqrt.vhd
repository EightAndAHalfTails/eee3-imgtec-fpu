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

architecture fast_newton of isqrt is
  signal input, half_input, initial_guess, improved, improveder, improvedest, output : float32_t;
begin
  input <= slv2float(isqrt_in1);
  isqrt_out <= float2slv(output);
  
  guess: process(input)
    --constant magic: slv(31 downto 0) := x"5f3759df";
    constant magic: slv(31 downto 0) := x"5f375a86";
  begin
    initial_guess <= slv2float(slv(signed(magic) - signed(shift_right(unsigned(float2slv(input)), 1))));
  end process guess;
  
  half: process(input)
  begin
    half_input.sign <= input.sign;
    half_input.exponent <= slv(unsigned(input.exponent) - to_unsigned(1, input.exponent'length));
    half_input.significand <= input.significand;
  end process half;
  
  improve: entity isqrt_iter(newton) port map(
    init => half_input,
    prev => initial_guess,
    curr => improved
  );
  
  improve2: entity isqrt_iter(newton) port map(
    init => half_input,
    prev => improved,
    curr => improveder
  );
  
  improve3: entity isqrt_iter(newton) port map(
    init => half_input,
    prev => improveder,
    curr => improvedest
  );
  
  encode_output: process(improvedest, input)
    variable shift_amount : integer;
  begin
    if input = neg_zero then
      output <= neg_inf;
    elsif input.sign = '1' or isNan(input) then
      output <= nan;
    elsif input = pos_inf then
      output <= pos_zero;
    else
      output <= improvedest;
    end if;
  end process encode_output;
  
end architecture fast_newton;