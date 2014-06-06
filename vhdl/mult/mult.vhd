library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;
use work.types.all;
use ieee.fixed_float_types.all;
use ieee.fixed_pkg.all;

entity mult is
  port(
    mult_in1, mult_in2 : in std_logic_vector(31 downto 0);
    mult_out : out std_logic_vector(31 downto 0)
    );
end entity mult;

architecture naive of mult is
  signal a, b, product : float32_t;
  
  signal computed_exponent : integer range -254 to 256;
  signal computed_significand : ufixed(1 downto -46);
  
  signal norm_exp : integer range -300 to 257;
  signal norm_sig : ufixed(0 downto -23);
    
begin
  a <= slv2float(mult_in1);
  b <= slv2float(mult_in2);
  mult_out <= float2slv(product);

  -----------------------------------------------------------
  -- compute exponent
  -- for multiplication, exponents simply add. However,
  -- multiplication of the significands may result in an
  -- extra power of 2 that needs to be brought into the
  -- exponent.
  -----------------------------------------------------------
  compute_exponent: process(a, b)
  begin
    -- exponent bits represent (exponent + 127) so must
    -- subtract 127 to obtain actual exponent.
    computed_exponent <= to_integer(usg(a.exponent)) + to_integer(usg(b.exponent)) - 254;
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
    variable sig_a, sig_b : ufixed(0 downto -23);
    constant zeros : exponent_t := (others => '0');
  begin
    if a.exponent = zeros then
      sig_a := ufixed(a.significand & '0');
    else
      sig_a := ufixed('1' & a.significand);
    end if;

    if b.exponent = zeros then
      sig_b := ufixed(b.significand & '0');
    else
      sig_b := ufixed('1' & b.significand);
    end if;
    
    computed_significand <= sig_a * sig_b;
    report "Performing " & v2s(to_slv(sig_a)) & " * " & v2s(to_slv(sig_b)) severity note;
  end process compute_significand;
  -----------------------------------------------------------
  
  normalise_round: process(computed_significand, computed_exponent)
    variable shift_amount: integer range -128 to 46;
    variable shifted_sig : ufixed(1 downto -47);
    variable rounded_sig : ufixed(0 downto -23);
    variable shifted_exp : integer range -300 to 257;
    variable roundup : boolean;
    
    constant ulp : ufixed(rounded_sig'high downto rounded_sig'low) := (rounded_sig'low => '1', others => '0');
  begin
    report "computed_exponent is " & integer'image(computed_exponent);
    report "computed_significand is " & v2s(to_slv(computed_significand));
    
    shift_amount := leading_one(to_slv(computed_significand)) - 2;
    if shift_amount = -2 then
      shift_amount := 0;
    end if;
    shifted_exp := computed_exponent - shift_amount;
    
    -- assure that do not shift below 2^-126
    if computed_exponent - shift_amount < -126 then
      shift_amount := computed_exponent + 126;
      shifted_exp := -127;
    end if;
    
    report "shift_amount is " & integer'image(shift_amount);
    shifted_sig := resize(computed_significand, 1, -47) sll shift_amount;
    rounded_sig := shifted_sig(0 downto -23);
    roundup := scalb(shifted_sig(-24 downto -47), 23) > to_ufixed(0.5, 0, -1)
            or (scalb(shifted_sig(-24 downto -47), 23) = to_ufixed(0.5, 0, -1) and rounded_sig(rounded_sig'low) = '1');
    if roundup then
      rounded_sig := resize(rounded_sig + ulp, 0, -23);
    end if;
    
    norm_exp <= shifted_exp;
    norm_sig <= rounded_sig;
  end process normalise_round;
  
  encode_output: process(norm_exp, norm_sig, a, b)
  begin
    -- check if out of bounds
    -- (final_exponent + 127) must be in range [1, 254]
    -- (0 is reserved for subnormals, and 255 is inf and nan)
    -- which makes the range of final_exponent [-126, 127]
    report "norm_exp is " & integer'image(norm_exp) severity note;
    report "norm_sig is " & v2s(to_slv(norm_sig)) severity note;
    if   (isInf(a) and isZero(b))
      or (isInf(b) and isZero(a))
      or isNan(a)
      or isNan(b) then
      product <= nan;
    elsif isInf(a) or isInf(b) then
      if (a.sign xor b.sign) = '1' then
        product <= neg_inf;
      else
        product <= pos_inf;
      end if;
    elsif isZero(a) or isZero(b) then
      if (a.sign xor b.sign) = '1' then
        product <= neg_zero;
      else
        product <= pos_zero;
      end if;
    elsif norm_exp < -126 then
      -- denormal
      product.sign <= a.sign xor b.sign;
      product.exponent <= (others => '0');
      product.significand <= to_slv(norm_sig(-1 downto -23));
    elsif norm_exp > 127 then
      --round to inf
      product.sign <= a.sign xor b.sign;
      product.exponent <= (others => '1');
      product.significand <= (others =>'0');
    else
      --normal
      product.sign <= a.sign xor b.sign;
      product.exponent <= slv(to_unsigned(norm_exp + 127, 8));
      product.significand <= to_slv(norm_sig(-1 downto -23));
    end if;
  end process encode_output;
end architecture naive;
