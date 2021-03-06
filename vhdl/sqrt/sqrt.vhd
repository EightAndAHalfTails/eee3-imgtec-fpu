library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real;
use work.all;
use work.types.all;

entity sqrt is
  generic(lookup_bits : integer := 7;
          iterations : integer := 4);
  port(
    sqrt_in1 : in std_logic_vector(31 downto 0);
    sqrt_out : out std_logic_vector(31 downto 0)
    );
end entity sqrt;

architecture babylon of sqrt is
  type lut_t is array (integer range <>) of significand_t;
  
  function build_lut(keysize: integer) return lut_t is
    variable lut_size : integer := 2**keysize;
    variable result : lut_t(0 to lut_size-1);
    variable radicand_bits : significand_t;
    variable radicand_real : real;
  begin
    for i in result'left to result'right loop
      radicand_bits := (others => '0');
      radicand_bits(22 downto 23-keysize) := std_logic_vector(to_unsigned(i, keysize));
      radicand_real := real(to_integer(unsigned(radicand_bits))) / (2.0**21);
      result(i) := significand_t(to_unsigned(integer(math_real.floor(math_real.sqrt(radicand_real) * (2.0**21))), 23));
    end loop;
    return result;
  end function build_lut;  
  constant initial_guess_lut : lut_t := build_lut(lookup_bits);
  
  signal input, output : float32_t;
  signal s_sig_in : unsigned(24 downto 0);
  signal s_half_exp : integer range -63 to 64;
  signal s_final_approx : slv(24 downto 0);
  signal s_initial_guess : slv(24 downto 0);
  
  type intermed_t is array (1 to iterations-1) of slv(24 downto 0);
  signal intermediate_values : intermed_t;
begin
  input <= slv2float(sqrt_in1);
  sqrt_out <= float2slv(output);
  
  s_initial_guess(24 downto 2) <= initial_guess_lut(to_integer(s_sig_in(24 downto 25-lookup_bits)));
  s_initial_guess(1 downto 0) <= "00";
  
  ------------------------------------------------
  -- get_sig_exp
  -- square rooting involves halving the exponent,
  -- but if the exponent is odd then we must make
  -- it even first by halving the significand and
  -- incrementing the exponent.
  ------------------------------------------------
  -- if the exponent is odd, we increase
  -- the exponent by one and shift the significand
  -- down one, before halving the exponent.
  get_sig_exp: process(input)
    variable exp : integer range -127 to 128;
    variable halfexp : integer range -63 to 64;
  begin
    exp := to_integer(unsigned(input.exponent)) - 127;
    if exp = -127 then
      -- denormal --> 0.{bits}0 x 2^-126
      s_sig_in <= unsigned('0' & input.significand & '0');
    elsif exp mod 2 = 0 then
      -- 1.{bits}0
      s_sig_in <= unsigned('1' & input.significand & '0');
    else
      -- 0.1{bits}
      exp := exp + 1;
      s_sig_in(24 downto 23) <= "01";
      s_sig_in(22 downto 0) <= unsigned(input.significand);
    end if;
    
    s_half_exp <= exp/2;
  end process get_sig_exp;
  
  gen_iter: for i in 0 to iterations-1 generate
    first: if i = 0 generate
      iter0: entity iter port map(
        init => slv(s_sig_in),
        prev => s_initial_guess,
        curr => intermediate_values(1)
      );
    end generate first;
      
    middle: if I > 0 and I < iterations-1 generate
      iterx: entity iter port map(
        init => slv(s_sig_in),
        prev => intermediate_values(I),
        curr => intermediate_values(I+1)
      );
    end generate middle;
    
    last: if I = iterations-1 generate
      itern: entity iter port map(
        init => slv(s_sig_in),
        prev => intermediate_values(iterations-1),
        curr => s_final_approx
      );
    end generate last;
  end generate gen_iter;
  
  encode_output: process(input, s_final_approx, s_half_exp)
    variable shift_amount : integer range -1 to 24;
  begin
    if input = neg_zero then
      output <= neg_zero;
    elsif input = pos_zero then
      output <= pos_zero;
    elsif input.sign = '1' or isNan(input) then
      output <= nan;
    elsif input = pos_inf then
      output <= pos_inf;
    else
      shift_amount := leading_one(s_final_approx) - 1;
      report "Shifting by " & integer'image(shift_amount) severity note;
      output.sign <= '0';
      output.exponent <= slv(to_unsigned(s_half_exp - shift_amount + 127, output.exponent'length));
      output.significand <= slv(shift_left(usg(s_final_approx), shift_amount)(23 downto 1));
    end if;
  end process encode_output;
  
end architecture babylon;