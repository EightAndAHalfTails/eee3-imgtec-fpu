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

  signal expo_diff : sgn(9 downto 0);
  signal aligned_c : usg(71 downto 0);
  signal post_add_lsresult : usg(24 downto 0);  --left shift result
  signal post_add_rsresult : usg(47 downto 0);  --right shift result
  signal a,b,c : float32_t;
  signal pre_norm_signifcand : usg(47 downto 0);
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
  -----------------------------------------------------------------------------
  --This stage performs the pre-alignment of the adder input
  -----------------------------------------------------------------------------
  --unpack
  a<=slv2float(multacc_in1);
  b<=slv2float(multacc_in2);
  c<=slv2float(multacc_in3);
  
  exp_diff<=sgn(Resize(a.exp,9)+Resize(b.exp,9)-Resize(c.exp,9));
  --computes the exponent difference
  
  adder_c_align : process(multacc_in3,exp_diff)
    variable add3 : float32_t;
    variable sig_c: unsigned(23 downto 0);
    variable shift_unit : integer range -256 to 255;
  begin
   add3:=slv2float(multacc_in3);
   shift_unit:=to_integer(exp_diff);
   
   if add3.sign='1' then                --invert input if the sign is negative
     if add3.exponent = zeros then
      sig_c := not unsigned(add3.significand & '0')+1;  --normalise for
                                                        --denormal and invert
     else
      sig_c := not unsigned('1' & add3.significand)+1;  --restore hidden bit
                                                        --and invert
     end if;
   else
     if add3.exponent = zeros then
      sig_c := unsigned(add3.significand & '0');  --normalise for denormal
     else
      sig_c := unsigned('1' & add3.significand);  --restore hidden bit
     end if;
   end if;
-------------------------------------------------------------------------------
   --alignment shifting
   --shift operand c to align with the multiplication result.
   --shift_unit is a signed number which will shift the operand to the left or
   --right:neg->shift left, pos->shift right
   --                          xx.xxxxxxxxxxxxxxxxxxxxxxxx......
   -- (neg shit by shift_unit<-)x.xxxxxxxxxxx....(->pos shift by shift_unit)
-------------------------------------------------------------------------------
     for i in 0 to 71 loop
       if i+shift_unit<46 and i+shift_unit>21 then
         aligned_c(i)<=sig_c(i-22+shift_unit);         
       else
         aligned_c(i)<='0';
       end if;
     end loop;  -- i				
  end process adder_c_align;

  -----------------------------------------------------------------------------
  --48 bit adder and a multiplexer to compute the 72 bit result
  -----------------------------------------------------------------------------
  --The process calculates the sum of the aligned operands.
  -----------------------------------------------------------------------------
  adder:process(aligned_c,post_mult_significand)
    variable result : unsigned(48 downto 0);
  begin
    result:=resize(post_mult_significand,49)+resize(unsigned(aligned_c(47 downto 0),49);

    if result(48)='1' then
      post_add_lsresult<=resize(aligned_c(71 downto 48),25)+1;
    else
      post_add_lsresult<=resize(aligned_c(71 downto 48),25);
    end if;
    
    post_add_rsresult<=result(47 downto 0);
    
  end process adder;
  -----------------------------------------------------------------------------
  --multiplexer to select actual significand bits
  -----------------------------------------------------------------------------
  mux:process(post_add_rsresult,post_add_lsresult)
  begin
    
    if expo_diff>=0 then
      
    elsif expo_diff>-26 then
            
    else
  
    end if;



    
  end process mux;
  
end architecture fused;
