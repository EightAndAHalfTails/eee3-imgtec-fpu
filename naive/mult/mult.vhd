library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity mult is
  port(
    mult_in1, mult_in2 : in std_logic_vector(31 downto 0);
    mult_out : out std_logic_vector(31 downto 0)
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
  
  signal a, b, product : float32_t;
  
  signal computed_exponent : signed(8 downto 0);
  signal computed_significand : unsigned(47 downto 0);
  
begin
  a.sign <= mult_in1(31);
  a.exponent <= mult_in1(30 downto 23);
  a.significand <= mult_in1(22 downto 0);
  
  b.sign <= mult_in2(31);
  b.exponent <= mult_in2(30 downto 23);
  b.significand <= mult_in2(22 downto 0);
  
  mult_out(31) <= product.sign;
  mult_out(30 downto 23) <= product.exponent;
  mult_out(22 downto 0) <= product.significand;
  
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
  compute_exponent: process(a, b)
    variable exp_a, exp_b : signed(8 downto 0) := (others => '0');
  begin
    -- exponent bits represent (exponent + 127) so must
    -- subtract 127 to obtain actual exponent.
    exp_a := signed(resize(unsigned(a.exponent), 9)) + to_signed(-127, 9);
    exp_b := signed(resize(unsigned(b.exponent), 9)) + to_signed(-127, 9);
    computed_exponent <= exp_a + exp_b;
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
  begin
    computed_significand <= unsigned('1' & a.significand) * unsigned('1' & b.significand); -- & = concat operator
    -- This integer would be 48 bits in hardware. We are
    -- interpreting the 2 msb as the integer bits, and the
    -- rest as fractional bits.
  end process compute_significand;
  -----------------------------------------------------------
  
  -----------------------------------------------------------
  -- fp_normalise
  -- We must normalise the result so that the significand is
  -- between 1 and 2 TODO: handle denormals
  -- this stage will also truncate the 
  -----------------------------------------------------------
  fp_normalise_round: process(computed_significand, computed_exponent)
    variable final_significand : unsigned(23 downto 0); -- includes implied top bit
    variable final_exponent : signed(8 downto 0);
    constant one_half : unsigned(23 downto 0) := (23 => '1', others => '0');
  begin
    ---------------------------------------------------------
    -- If the whole part is lower than 2, we can simply take
    -- the fractional part as-is, truncated to 23 bits.
    if computed_significand(47) = '0' then -- top bit 1 <--> number > 2
      final_significand := computed_significand(46 downto 23);
      final_exponent := computed_exponent;
      
      ---------------------------------------------------------
      -- We examine the truncated part to find out which way
      -- to round:
      if computed_significand(22 downto 0)&'0' > one_half --round up
      or(computed_significand(22 downto 0)&'0' = one_half and final_significand(0) = '1') -- rte, round down gives odd
      then
        -- round up = increment significand
        final_significand := final_significand + to_unsigned(1, 24);
      end if; -- round down = truncate
    else
      ---------------------------------------------------------
      -- If the whole part is greater than 2, then we need to
      -- half the result. We can achieve this by simply taking
      -- the slice one bit more significant.
      final_significand := computed_significand(47 downto 24);
      final_exponent := computed_exponent + to_signed(1, 9);
      
      ---------------------------------------------------------
      -- We examine the truncated part to find out which way
      -- to round:
      if computed_significand(23 downto 0) > one_half --round up
      or(computed_significand(23 downto 0) = one_half and final_significand(0) = '1') -- rte, round down gives odd
      then
        -- round up = increment significand
        final_significand := final_significand + to_unsigned(1, 24);
      end if; -- round down = truncate
    end if;
      
    --TODO: handle denormals
    -- check if out of bounds
    -- (final_exponent + 127) must be in range [1, 254]
    -- (0 is reserved for subnormals, and 255 is inf and nan)
    -- which makes the range of final_exponent [-126, 127]
    -- If exponent is lower than -126 or greater than 127,
    -- it must be rounded
    if final_exponent < to_signed(-126, 9) then
      --for now, round to 0
      product.exponent <= (others => '0');
      product.significand <= (others => '0');
    elsif final_exponent > to_signed(127, 9) then
      --for now, round to inf
      product.exponent <= (others => '1');
      product.significand <= (others =>'0');
    else
      --normal
      product.exponent <= std_logic_vector(resize(unsigned(final_exponent + to_signed(127, 9)), 8));
      product.significand <= std_logic_vector(final_significand(22 downto 0));
    end if;
  end process fp_normalise_round;
end architecture arch;
