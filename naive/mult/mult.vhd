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
  
  function leading_one(inp: std_logic_vector) return integer is
    variable result, count: integer; 
  begin
    count := 0;
    result := 0;
    for i in inp'left downto inp'right loop
      count := count + 1;
      if inp(i) = '1' then 
        result := count;
        exit;
      end if;
    end loop;
    return result;
  end function leading_one;
    
  function v2s(inp: std_logic_vector) return string is
    variable result: string(1 to inp'length);
  begin
    for i in inp'left downto inp'right loop
      result(1+inp'left-i) := std_logic'image(inp(i))(2);
    end loop;
    return result;
  end function v2s;

  
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
  -- significand is given by 1.{significand bits}, except for
  -- denormals, for which it is 0.{significand bits}
  -- Here we encode the number as an integer, but remember
  -- that the top bit represents the integer part, and the
  -- lower bits represent the fractional part.
  -- If the product significand is greater than 2, it must
  -- be halved and the exponent incremented by 1.
  -----------------------------------------------------------
  compute_significand: process(a, b)
    variable sig_a, sig_b : unsigned(23 downto 0) := (others => '0');
    constant zeros : exponent_t := (others => '0');
  begin
    if a.exponent = zeros then
      sig_a := unsigned(a.significand & '0');
    else
      sig_a := unsigned('1' & a.significand);
    end if;

    if b.exponent = zeros then
      sig_b := unsigned(b.significand & '0');
    else
      sig_b := unsigned('1' & b.significand);
    end if;
    
    computed_significand <= sig_a * sig_b;
    report "Performing " & v2s(std_logic_vector(sig_a)) & " * " & v2s(std_logic_vector(sig_b)) severity note;
  end process compute_significand;
  -----------------------------------------------------------
  
  -----------------------------------------------------------
  -- fp_normalise_round
  -- The final number must be normalised if possible. At
  -- this point there are three cases: if the integer part of
  -- the significand is 2 or 3, we will refer to these
  -- numbers as "supernormal", and it must be shifted down to
  -- between 1 and 2. if the number is already in this range,
  -- the number is "normal", and no shifting is necessary. If
  -- the significand is lower than 1, then the number is
  -- "subnormal". If possible, we should decrement the
  -- exponent to shift the significand up. If this can not be
  -- done, we can encode it as a denormal number.
  -----------------------------------------------------------
  fp_normalise_round: process(computed_significand, computed_exponent)
    variable final_significand : unsigned(23 downto 0); -- includes implied top bit
    variable final_exponent : signed(8 downto 0);
    constant one_half : unsigned(23 downto 0) := (23 => '1', others => '0');
    variable shift_amount : integer := 0;
    variable exponent_leeway : integer := 0;
  begin
    report "computed_exponent is " & integer'image(to_integer(computed_exponent)) severity note;
    report "computed_significand is " & v2s(std_logic_vector(computed_significand)) severity note;
    if computed_exponent < to_signed(-127, 9) then
      -- try to bring into denormal range
      shift_amount := to_integer(to_signed(-127, 9) - computed_exponent);
      final_exponent := to_signed(-127, 9);
      final_significand := SHIFT_RIGHT(computed_significand, shift_amount)(47 downto 24);
      
      ---------------------------------------------------------
      -- We examine the truncated part to find out if we should
      -- have rounded up:
      if SHIFT_RIGHT(computed_significand, shift_amount)(23 downto 0) > one_half --round up
      or(SHIFT_RIGHT(computed_significand, shift_amount)(23 downto 0) = one_half and final_significand(0) = '1') -- rte, round down gives odd
      then
        -- round up = increment significand
        final_significand := final_significand + to_unsigned(1, 24);
      end if; -- round down = truncate (which we already did)
      ---------------------------------------------------------
    else
      case computed_significand(47 downto 46) is
      when "00" => null; -- subnormal
        ---------------------------------------------------------
        -- This function to detect the leading one may synthesise
        -- to pretty large hardware. I saw another method which
        -- involves reversing the vector, inverting it, adding 1,
        -- and then ANDing it with the original reversed vector,
        -- which may be smaller. However, this gives the result
        -- one-hot encoded.
        shift_amount := leading_one(std_logic_vector(computed_significand(45 downto 0)));
        exponent_leeway := to_integer(computed_exponent - to_signed(-127, 9));
        report "shift_amount = " & integer'image(shift_amount) severity note;
        report "exponent_leeway = " & integer'image(exponent_leeway) severity note;
        if shift_amount = 0 then -- no ones in significand --> number is 0
          final_significand := (others => '0');
          final_exponent := to_signed(-127, 9);
        else
          if exponent_leeway < shift_amount then -- cannot be normalised
            report "cannot be normalised" severity note;
            shift_amount := exponent_leeway;
          end if;
          final_significand := SHIFT_LEFT(computed_significand(47 downto 0), shift_amount)(46 downto 23);
          final_exponent := computed_exponent - to_signed(shift_amount, 9);
        end if;
        
        ---------------------------------------------------------
        -- We examine the truncated part to find out if we should
        -- have rounded up:
        if SHIFT_LEFT(computed_significand(47 downto 0), shift_amount)(22 downto 0)&'0' > one_half --round up
        or(SHIFT_LEFT(computed_significand(47 downto 0), shift_amount)(22 downto 0)&'0' = one_half and final_significand(0) = '1') -- rte, round down gives odd
        then
          -- round up = increment significand
          final_significand := final_significand + to_unsigned(1, 24);
        end if; -- round down = truncate (which we already did)
        ---------------------------------------------------------
      when "01" => -- normal
        ---------------------------------------------------------
        -- Truncate the significand to 23 bits, taking only the
        -- fractional part. This is equivalent to rounding down
        final_significand := computed_significand(46 downto 23);
        final_exponent := computed_exponent;
        
        ---------------------------------------------------------
        -- We examine the truncated part to find out if we should
        -- have rounded up:
        if computed_significand(22 downto 0)&'0' > one_half --round up
        or(computed_significand(22 downto 0)&'0' = one_half and final_significand(0) = '1') -- rte, round down gives odd
        then
          -- round up = increment significand
          final_significand := final_significand + to_unsigned(1, 24);
        end if; -- round down = truncate (which we already did)
        ---------------------------------------------------------
      when "10" | "11" => null; -- supernormal
        ---------------------------------------------------------
        -- If the whole part is greater than 2, then we need to
        -- half the result. We can achieve this by simply taking
        -- the slice one bit more significant.
        final_significand := computed_significand(47 downto 24);
        final_exponent := computed_exponent + to_signed(1, 9);
      
        ---------------------------------------------------------
        -- We examine the truncated part to find out if we should
        -- have rounded up:
        if computed_significand(23 downto 0) > one_half --round up
        or(computed_significand(23 downto 0) = one_half and final_significand(0) = '1') -- rte, round down gives odd
        then
          -- round up = increment significand
          final_significand := final_significand + to_unsigned(1, 24);
        end if; -- round down = truncate (which we already did)
        ---------------------------------------------------------
      when others => null;
      end case;
    end if;
      
    -- check if out of bounds
    -- (final_exponent + 127) must be in range [1, 254]
    -- (0 is reserved for subnormals, and 255 is inf and nan)
    -- which makes the range of final_exponent [-126, 127]
    report "final_exponent is " & integer'image(to_integer(final_exponent));
    report "final_significand is " & v2s(std_logic_vector(final_significand)) severity note;
    if final_exponent = to_signed(-127, 9) then
      -- denormal
      product.exponent <= (others => '0');
      product.significand <= std_logic_vector(final_significand(23 downto 1));
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
