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
  signal sticky_b1,sticky_b2 : std_logic; 
  
  signal eff_sub ,ab_st_c: std_logic;
  
  signal a,b,c,result : float32_t;
  
  signal pre_norm_signifcand : usg(47 downto 0);
  signal pre_norm_exponent : sgn(9 downto 0);
  signal post_norm_significand : usg(25 downto 0);
  signal post_norm_exponent : sgn(9 downto 0);
  signal leadingzeros: integer range 0 to 48;
  signal temp_sign: std_logic;
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
  
  expo_diff<=sgn(Resize(post_mult_exp,10)-Resize(usg(c.exponent),10)-127);
  --computes the exponent difference
  eff_sub<='1' when c.sign/= post_mult_sign else '0';
  ab_st_c<='1' when expo_diff < -1 or (expo_diff = -1 and post_mult_significand(47 downto 24)<'1'&usg(c.significand)) or (expo_diff=0 and post_mult_significand(47 downto 23)<"01"&usg(c.significand)) else '0';
  
  
  adder_c_align : process(c,expo_diff,eff_sub)

    variable sig_c: unsigned(23 downto 0);
    variable shift_unit : integer range -512 to 511;
    constant zeros : exponent_t := (others => '0');
    variable s_bit: std_logic;
  begin
   shift_unit:=to_integer(expo_diff);
   s_bit:='0';
   
   if eff_sub='1' then                --invert input if effective subtraction
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
   if shift_unit<-25 then               --left align operand c if out of range
                                        --shifting
     aligned_c(71 downto 48)<=sig_c;
     aligned_c(47 downto 0)<=(others=>'0');
   else

     if shift_unit>25 then              --compute stickybit if right shift by
                                        --more than 25 units
        for i in 0 to 23 loop
          if i+25<shift_unit then
              s_bit:=s_bit or sig_c(i);
          end if;
        end loop;
     end if;   
     
     for i in 0 to 71 loop              --left or right shifting within range
       if i+shift_unit<=46 and i+shift_unit>=23 then
         aligned_c(i)<=sig_c(i-23+shift_unit);         
       elsif i+shift_unit>46 then
	       aligned_c(i)<=eff_sub; 	--pad with zeros or ones at top bits
       else
         aligned_c(i)<='0';         	--pad with zeros at other locations
       end if;
     end loop;  -- i     
   end if;
   
   sticky_b1<=s_bit;                    --output sticky bit computed from this
                                        --stage
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
  --*******need to add if post_add_lsresult overflows****************!!!!!!!!!
  -----------------------------------------------------------------------------
  adder:process(aligned_c,post_mult_significand,post_mult_exp,sticky_b1,eff_sub)
    variable result : unsigned(48 downto 0);
    variable post_add_lsresult:unsigned(23 downto 0);
    variable post_add_rsresult:unsigned(47 downto 0);
    variable s_bit:std_logic;
    constant ones  :unsigned(23 downto 0):=(others=>'1');
    constant zeros :unsigned(23 downto 0):=(others=>'0');
  begin
    s_bit:=sticky_b1;

      result:=resize(post_mult_significand,49)+resize(usg(aligned_c(47 downto 0)),49);
    
    if result(48)='1' then                                              --overflow
      post_add_lsresult:=aligned_c(71 downto 48)+1;
    else
      post_add_lsresult:=aligned_c(71 downto 48);
    end if;    
    post_add_rsresult:=result(47 downto 0);
    
  ------------------------------------------------
  --multiplexer to select actual significand bits
  ------------------------------------------------
    if post_add_lsresult=zeros or (post_add_lsresult=ones and eff_sub='1') then
      pre_norm_signifcand<=post_add_rsresult;                                              --truncated to bottom bits
      pre_norm_exponent<=sgn(resize(post_mult_exp,10)-126);
    else      
      pre_norm_signifcand<=post_add_lsresult(23 downto 0)&post_add_rsresult(47 downto 24); --truncated to top bits
      pre_norm_exponent<=sgn(resize(post_mult_exp,10)-102);  
      --**********!!!if overflows******
      
      for i in 0 to 23 loop
        s_bit:=s_bit OR post_add_rsresult(i);
      end loop;
      
    end if;    
    sticky_b2<=s_bit;
  end process adder;
  
sign_logic:PROCESS(post_mult_sign,c,eff_sub,ab_st_c)
	BEGIN
		IF eff_sub='1' and ab_st_c='1' THEN			
			temp_sign<=c.sign;	
		ELSE	
			temp_sign<=post_mult_sign;	
		END IF;			
	END PROCESS;
-------------------------------------------------------------------------------  
  --normalization and rounding
  -----------------------------------------------------------------------------
  normalise:process(expo_diff,pre_norm_signifcand,aligned_c,c,pre_norm_exponent,sticky_b2,eff_sub,ab_st_c)--,
    variable leadingzeros,leadingones: integer range 0 to 48;
    variable sft_result_significand : usg(47 downto 0);
    variable s_bit:std_logic;
  begin
    s_bit:=sticky_b2;
    leadingzeros := 0;
    leadingones  := 0;
  if expo_diff<-25 then
    sft_result_significand:=aligned_c(71 downto 24);
  else
    sft_result_significand:=pre_norm_signifcand;
  end if;

if eff_sub='1' and ab_st_c='1' then
    for i in pre_norm_signifcand'high downto pre_norm_signifcand'low loop
      if pre_norm_signifcand(i)='1' then
        leadingones:=leadingones+1;
        sft_result_significand:=sft_result_significand sll 1;--left shift until left aligned
      else
        exit; 
      end if;
    end loop;  -- i

else

    for i in pre_norm_signifcand'high downto pre_norm_signifcand'low loop
      if pre_norm_signifcand(i)='0' then
        leadingzeros:=leadingzeros+1;
        sft_result_significand:=sft_result_significand sll 1;--left shift until left aligned
      else
        exit; 
      end if;
    end loop;  -- i
end if;
    
    for i in 0 to 22 loop
      s_bit:=s_bit OR sft_result_significand(i);
    end loop; 
    
  --  if eff_sub='1' and ab_st_c='1' then
	--post_norm_significand<=sft_result_significand(47 downto 23)&s_bit;
  --  else
	post_norm_significand<=sft_result_significand(47 downto 23)&s_bit;
  --  end if;
    
      if expo_diff<-25 then
      post_norm_exponent<="00"&sgn(c.exponent);
      else
      post_norm_exponent<=pre_norm_exponent-leadingzeros-leadingones;
      --************!!!consider result is denormal*********
      end if;
 	
  end process normalise;

  --------------------------------------------------------------------------------------
  --rounder
  --The process round the result to be to be 23 bit mantissa
  --------------------------------------------------------------------------------------
  rounder:PROCESS(post_mult_significand,post_norm_significand,post_norm_exponent,temp_sign,eff_sub,ab_st_c,c)--,

    VARIABLE rounded_result_e_s		:sgn(9 downto 0);
    VARIABLE rounded_result_man_s	:usg(23 downto 0);

  BEGIN
	
    CASE post_norm_significand(2 downto 0) IS						--rounding decoder(LSB+GUARD+STICKY)  RTE rounding mode
      WHEN "000"|"001"|"010"|"100"|"101"=>rounded_result_man_s := '0'&post_norm_significand(24 downto 2);			--round down
      WHEN "011"|"110"|"111"		=>rounded_result_man_s := resize(usg(post_norm_significand(24 downto 2)),24)+1;	--round up
      WHEN OTHERS => NULL;
    END CASE;
  
    IF rounded_result_man_s(23)='1' THEN
      rounded_result_e_s:=post_norm_exponent(9 downto 0)+1;
    ELSE
      rounded_result_e_s:=post_norm_exponent(9 downto 0);
    END IF;
    
  if post_mult_significand =0 then
      result<=c;
  else  
    if	rounded_result_e_s(9)='1' then
      result.exponent	<=(others=>'0');
      result.significand<=(others=>'0');
    elsif rounded_result_e_s>=255 then
      result.exponent	<=(others=>'1');
      result.significand<=(others=>'0');
    else
      if eff_sub='1' and ab_st_c='1' then
      result.significand	<=	slv(not rounded_result_man_s(22 downto 0)+1);
      else
      result.significand	<=	slv(rounded_result_man_s(22 downto 0));
      end if;      
      result.exponent	<=	slv(rounded_result_e_s(7 downto 0));
    end if;
  end if;
    result.sign	<=	temp_sign;
  END PROCESS rounder;

end architecture fused;
