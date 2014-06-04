library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;
use work.types.all;

---------------------------------------------------
-- Multiply-Accumulate
---------------------------------------------------
-- This entity implements the multiply-accumulate
-- instruction, that is, x = ab + c
---------------------------------------------------

entity multacc is
  port(
    multacc_in1, multacc_in2, multacc_in3 : in std_logic_vector(31 downto 0);
    multacc_out : out std_logic_vector(31 downto 0)
    );
end entity multacc;

architecture naive of multacc is
  signal product : std_logic_vector(31 downto 0);  
begin
  multiplier: entity mult port map(
    mult_in1 => multacc_in1,
    mult_in2 => multacc_in2,
    mult_out => product
    );

  ------------------------------
  -- Placeholder adder.
  ------------------------------
  -- TODO: Either replace this
  -- with the actual adder, or
  -- modify adder to fit this
  -- specification
  ------------------------------
  adder: entity addsub port map(
    add_in1 => product,
    add_in2 => multacc_in3,
    add_out => multacc_out,
    operation_i => '0'
  );
  ------------------------------
end architecture naive;

architecture fused of multacc is
  signal post_mult_sign : std_logic;
  signal post_mult_exp : unsigned(8 downto 0);
  signal post_mult_significand : unsigned(47 downto 0); --with 2 integer bits
begin
  -----------------------------------------------------------------
  -- multiply
  -----------------------------------------------------------------
  -- This stage performs the multiplication. It produces the
  -- following values:
  -----------------------------------------------------------------
  -- post_mult_sign: this is a simple xor of the imcoming signs and
  -- accurately represents the sign of the result of the
  -- multiplication.
  -----------------------------------------------------------------
  -- post_mult_exp: this is a simple unsigned addition of the
  -- incoming exponents. To get the actual exponent you must
  -- subtract 254 from this number
  -----------------------------------------------------------------
  -- post_mult_significand: this is an integer multiplication of
  -- the incoming significand bits appended to a '0' ot '1' bit as
  -- appropriate. It therefore represents the mantissa of the
  -- result, with the implied integer bits. The integer part is
  -- represented by the top two bits, while the rest represents the
  -- fractional part
  -----------------------------------------------------------------
  multiply : process(multacc_in1, multacc_in2)
    variable mult1, mult2 : float32_t;
    variable sig_a, sig_b : unsigned(23 downto 0);
    constant zeros : exponent_t := (others => '0');
  begin
    mult1 := slv2float(multacc_in1);
    mult2 := slv2float(multacc_in2);
    
    post_mult_sign <= mult1.sign xor mult2.sign;
    post_mult_exp <= resize(unsigned(mult1.exponent), 9) + resize(unsigned(mult2.exponent), 9);
    if mult1.exponent = zeros then
      sig_a := unsigned(mult1.significand & '0');
    else
      sig_a := unsigned('1' & mult1.significand);
    end if;
    if mult2.exponent = zeros then
      sig_b := unsigned(mult2.significand & '0');
    else
      sig_b := unsigned('1' & mult2.significand);
    end if;
    post_mult_significand <= sig_a * sig_b;
  end process multiply;
    
  
end architecture fused;
