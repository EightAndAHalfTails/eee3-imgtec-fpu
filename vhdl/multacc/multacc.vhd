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

--architecture naive of multacc is
 -- signal product : std_logic_vector(31 downto 0);  
--begin
 -- multiplier: entity mult port map(
   -- mult_in1 => multacc_in1,
  --  mult_in2 => multacc_in2,
 --   mult_out => product
--    );

  ------------------------------
  -- Placeholder adder.
  ------------------------------
  -- TODO: Either replace this
  -- with the actual adder, or
  -- modify adder to fit this
  -- specification
  ------------------------------
  --adder: entity addsub port map(
  --  add_in1 => product,
 --   add_in2 => multacc_in3,
--    add_out => multacc_out,
--    operation_i => '0'
--  );
  ------------------------------
--end architecture naive;

architecture fused of multacc is
  signal post_mult_sign : std_logic;
  signal post_mult_exp : unsigned(8 downto 0);
  signal post_mult_significand : unsigned(47 downto 0); --with 2 integer bits

  signal expo_diff : sgn(9 downto 0);
  signal aligned_c : usg(71 downto 0);
  
  signal a,b,c,result : float32_t;
  
  signal pre_norm_signifcand : usg(47 downto 0);
  signal pre_norm_exponent : usg(8 downto 0);
  signal post_norm_significand : usg(25 downto 0);
  signal post_norm_exponent : usg(7 downto 0);
  signal rightshift : std_logic;
  signal leadingzeros: integer range 0 to 48;
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


-------------------------------------------------------------------------------
  --pre-align stage
  -----------------------------------------------------------------------------
  --This stage performs the pre-alignment of the adder input with the
  --multiplication result
  -----------------------------------------------------------------------------
  --Since the significand bits of c can be either shifted left or right based
  --on the relative values of exponents. c is therefore extended to 72 bits  
  -----------------------------------------------------------------------------
  --unpack
  a<=slv2float(multacc_in1);
  b<=slv2float(multacc_in2);
  c<=slv2float(multacc_in3);
  multacc_out<=float2slv(result);
  expo_diff<=sgn(Resize(post_mult_exp,10)-Resize(usg(c.exponent),10));
  --computes the exponent difference
  
  adder_c_align : process(c,expo_diff)

    variable sig_c: unsigned(23 downto 0);
    variable shift_unit : integer range -256 to 255;
    constant zeros : exponent_t := (others => '0');
  begin
   shift_unit:=to_integer(expo_diff);
   
   if c.sign='1' then                --invert input if the sign is negative
     if c.exponent = zeros then
      sig_c := not unsigned(c.significand & '0')+1;  --normalise for
                                                        --denormal and invert
     else
      sig_c := not unsigned('1' & c.significand)+1;  --restore hidden bit
                                                        --and invert
     end if;
   else
     if c.exponent = zeros then
      sig_c := unsigned(c.significand & '0');  --normalise for denormal
     else
      sig_c := unsigned('1' & c.significand);  --restore hidden bit
     end if;
   end if;
   --------------------------------------------------------------------------
   --alignment shifting
   --shift operand c to align with the multiplication result.
   --shift_unit is a signed number which will shift the operand to the left or
   --right:neg->shift left, pos->shift right
   --                          xx.xxxxxxxxxxxxxxxxxxxxxxxx......
   -- (neg shit by shift_unit<-)x.xxxxxxxxxxx....(->pos shift by shift_unit)
   --------------------------------------------------------------------------
   if shift_unit<-25 then
     aligned_c(71 downto 48)<=sig_c;
     aligned_c(47 downto 0)<=(others=>'0');
   else
     for i in 0 to 71 loop
       if i+shift_unit<46 and i+shift_unit>21 then
         aligned_c(i)<=sig_c(i-22+shift_unit);         
       else
         aligned_c(i)<='0';
       end if;
     end loop;  -- i     
   end if;
   
  end process adder_c_align;

  
-------------------------------------------------------------------------------
  --adder
  -----------------------------------------------------------------------------
  --The process calculates the sum of the aligned operands.
  -----------------------------------------------------------------------------
  --A 48 bit adder and a multiplexer are used to compute the sum of c and
  --result of multiplication. Then the result is truncated to 48 bits based on
  --where the valid bits are. 
  -----------------------------------------------------------------------------

  adder:process(aligned_c,post_mult_significand,post_mult_exp)
    variable result : unsigned(48 downto 0);
    variable post_add_lsresult:unsigned(24 downto 0);
    variable post_add_rsresult:unsigned(47 downto 0);
  begin
    
    result:=resize(post_mult_significand,49)+resize(usg(aligned_c(47 downto 0)),49);

    if result(48)='1' then                                              --overflow
      post_add_lsresult:=resize(aligned_c(71 downto 48),25)+1;
    else
      post_add_lsresult:=resize(aligned_c(71 downto 48),25);
    end if;    
    post_add_rsresult:=result(47 downto 0);
    
  ------------------------------------------------
  --multiplexer to select actual significand bits
  ------------------------------------------------
    if post_add_lsresult=0 then
      pre_norm_signifcand<=post_add_rsresult;
      pre_norm_exponent<=post_mult_exp;
      rightshift<='1';
    else
      pre_norm_signifcand<=post_add_lsresult(23 downto 0)&post_add_rsresult(47 downto 24);
      pre_norm_exponent<=post_mult_exp+25;
      rightshift<='0';
    end if;
    
  end process adder;
  
-------------------------------------------------------------------------------  
  --normalization and rounding
  -----------------------------------------------------------------------------
  normalise:process(expo_diff,pre_norm_signifcand,aligned_c,c,pre_norm_exponent)
    variable leadingzeros : integer range 0 to 48;
    variable sft_result_significand : usg(47 downto 0);
  begin
    leadingzeros := 0;
    sft_result_significand:=pre_norm_signifcand;
    for i in pre_norm_signifcand'high downto pre_norm_signifcand'low loop
      if pre_norm_signifcand(i)='0' then
        leadingzeros:=leadingzeros+1;
        sft_result_significand:=sft_result_significand sll 1;
      else
        exit; 
      end if;
    end loop;  -- i

    if expo_diff<-25 then
      post_norm_significand<=aligned_c(71 downto 48)&"00";
      post_norm_exponent<=usg(c.exponent);
    else
      post_norm_significand<=sft_result_significand(47 downto 22);
      post_norm_exponent<=usg(pre_norm_exponent(7 downto 0))-leadingzeros;
    end if;

  end process normalise;

  --------------------------------------------------------------------------------------
  --rounder
  --The process round the result to be to be 23 bit mantissa
  --------------------------------------------------------------------------------------
  rounder:PROCESS(post_norm_significand,post_norm_exponent)

    VARIABLE rounded_result_e_s		:usg(7 downto 0);
    VARIABLE rounded_result_man_s	:usg(23 downto 0);

  BEGIN
	
    CASE post_norm_significand(2 downto 0) IS						--rounding decoder(LSB+GUARD+STICKY)  RTE rounding mode
      WHEN "000"|"001"|"010"|"100"|"101"=>rounded_result_man_s := '0'&post_norm_significand(24 downto 2);			--round down
      WHEN "011"|"110"|"111"		=>rounded_result_man_s := resize(usg(post_norm_significand(24 downto 2)),24)+1;	--round up
      WHEN OTHERS => NULL;
    END CASE;
  
    IF rounded_result_man_s(23)='1' THEN
      rounded_result_e_s:=usg(post_norm_exponent)+1;
    ELSE
      rounded_result_e_s		:=post_norm_exponent;
    END IF;
	
    result.exponent	<=	slv(rounded_result_e_s);
    result.significand	<=	slv(rounded_result_man_s(22 downto 0));	--1 bit shift adjustment
    result.sign<='1';
  END PROCESS rounder;

end architecture fused;
