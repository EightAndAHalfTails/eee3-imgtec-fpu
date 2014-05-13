library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity mult is
  port(
    a_in, b_in : in std_logic_vector(31 downto 0);
    product_out : out std_logic_vector(31 downto 0)
    );
end entity mult;

architecture arch of mult is
  alias sign_t is std_logic;
  subtype exponent_t is std_logic_vector(7 downto 0);
  subtype significand_t is std_logic_vector(22 downto 0);
  type float32_t is record
    sign : sign_t;
    exponent : exponent_t;
    significand : significand_t;
  end record;
  
  signal must_normalise : std_logic;
  signal a, b, product : float32_t;
  
begin
  a.sign <= a_in(31);
  a.exponent <= a_in(30 downto 23);
  a.significand <= a_in(22 downto 0);
  
  b.sign <= b_in(31);
  b.exponent <= b_in(30 downto 23);
  b.significand <= b_in(22 downto 0);
  
  product_out(31) <= product.sign;
  product_out(30 downto 23) <= product.exponent;
  product_out(22 downto 0) <= product.significand;
  
  -----------------------------------------------------------
  -- compute sign
  -- same signs result in a positive sign (0 sign bit)
  -- different signs result in a negative sign (1 sign bit)
  -----------------------------------------------------------
  product.sign <= a.sign xor b.sign;
  -----------------------------------------------------------

  -----------------------------------------------------------
  -- compute exponent
  -- for multiplication, exponents simply add. However,
  -- multiplication of the significands may result in an
  -- extra power of 2 that needs to be brought into the
  -- exponent.
  -----------------------------------------------------------
  compute_exponent: process(a, b, must_normalise)
    variable exp_a, exp_b, exp_out: integer := 0;
  begin
    -- exponent bits represent (exponent + 127) so must
    -- subtract 127 to obtain actual exponent.
    exp_a := to_integer(unsigned(a.exponent)) - 127;
    exp_b := to_integer(unsigned(b.exponent)) - 127;
    exp_out := exp_a + exp_b;
    if must_normalise = '1' then
      exp_out := exp_out + 1;
    end if;
    
    -- TODO: check if out of bounds
    product.exponent <= std_logic_vector(to_unsigned(exp_out + 127, 8));
  end process compute_exponent;
  -----------------------------------------------------------
  
  -----------------------------------------------------------
  -- compute significand
  -- the significand of the product is simply the product of
  -- the significands of the inputs. Remember that the
  -- significand is given by 1.{significand bits}. This
  -- number can be constructed by interpreting the bits,
  -- appended to a '1', as an integer, then dividing by
  -- 2^(significand width).
  -- However, to avod using fixed-point libraries, I have
  -- adopted to do the multiplication on integers, and divide
  -- by 2^(2*significand width) to get the final result.
  -- If the product significand is greater than 2, it must
  -- be halved and the exponent incremented by 1.
  -----------------------------------------------------------
  compute_significand: process(a, b)
    variable mult_result : std_logic_vector(47 downto 0);
  begin
    mult_result := std_logic_vector(unsigned('1' & a.significand) * unsigned('1' & b.significand)); -- & = concat operator
    -- This integer would be 48 bits in hardware. We are
    -- interpreting the 2 msb as the integer bits, and the
    -- rest as fractional bits.
    ---------------------------------------------------------
    -- If the whole part is lower than 2, we can simply take
    -- the fractional part as-is, truncated to 23 bits.
    if mult_result(47) = '0' then -- top bit 1 <--> number > 2
      product.significand <= mult_result(45 downto 23);
      must_normalise <= '0';
    else
      ---------------------------------------------------------
      -- If the whole part is greater than 2, then we need to
      -- half the result. We can achieve this by simply taking
      -- the slice one bit more significant.
      product.significand <= mult_result(46 downto 24);
      must_normalise <= '1';
    end if;
  end process compute_significand;
  -----------------------------------------------------------
  
end architecture arch;
