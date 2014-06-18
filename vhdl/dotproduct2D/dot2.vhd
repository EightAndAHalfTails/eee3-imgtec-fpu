library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.types.all;

---------------------------------------------------
-- 2D dot product
---------------------------------------------------
-- This entity implements the 2D dot product
-- instruction, that is, x = ab + cd
---------------------------------------------------
entity dot2 is
  port(
    dot2_in1, dot2_in2, dot2_in3, dot2_in4 : in std_logic_vector(31 downto 0);
    dot2_out : out std_logic_vector(31 downto 0)
    );
end entity dot2;

architecture chained of dot2 is

  signal a,b,c,d,result : float32_t;

  signal post_mult_sign1,post_mult_sign2,temp_sign    :sign_t;
  signal post_mult_exp1,post_mult_exp2      :usg(8 downto 0);
  signal post_mult_significand1,post_mult_significand2:usg(47 downto 0);
  signal exp_diff                           :sgn(9 downto 0);
  signal pre_norm_exponent                  :sgn(9 downto 0);
  signal pre_norm_significand               :usg(48 downto 0);
  signal post_norm_significand              :usg(25 downto 0);
  signal post_norm_exponent                 :usg(8 downto 0);
  --flags
  signal ab_st_cd                           :std_logic;
  signal eop                                :std_logic;  
  signal neg_sig                            :std_logic;
  
begin  -- chained
  -----------------------------------------------------------------------------
  --unpack and pack
  -----------------------------------------------------------------------------
  a<=slv2float(dot2_in1);
  b<=slv2float(dot2_in2);
  c<=slv2float(dot2_in3);
  d<=slv2float(dot2_in4);
  dot2_out<=float2slv(result);
  
-------------------------------------------------------------------------------
  --multply
  -----------------------------------------------------------------------------
  --This part compute the two products separately and result is returned with 1
  --bit sign+9 bit exponent(with carry)+48 bit significand(two integer bits)
  -----------------------------------------------------------------------------
  mult1: entity multiply 
    port map (
      a=>a,
      b=>b,
      post_mult_sign=>post_mult_sign1,
      post_mult_exp=>post_mult_exp1,
      post_mult_significand=> post_mult_significand1
      );
  mult2: entity multiply
    port map (
      a=>c,
      b=>d,
      post_mult_sign=>post_mult_sign2,
      post_mult_exp=>post_mult_exp2,
      post_mult_significand=> post_mult_significand2
      );
  -----------------------------------------------------------------------------
  --take difference of two exponents+ab smaller than c flag
  -----------------------------------------------------------------------------
  exp_diff<=sgn(resize(post_mult_exp1,10)-resize(post_mult_exp2,10));
  ab_st_cd<='1' when exp_diff <0 or (exp_diff=0 and post_mult_significand1<post_mult_significand2) or isInf(c) or isInf(d) else '0';
  eop<=post_mult_sign1 xor post_mult_sign2; --effective operation:0=>add,1=>sub
-------------------------------------------------------------------------------
  --adder
  -----------------------------------------------------------------------------
  --This process swap and align the products from the multiply stage and
  --calculate the sum of products. 
  -----------------------------------------------------------------------------
  add:process(post_mult_significand1,post_mult_significand2,post_mult_exp1,post_mult_exp2,post_mult_sign1,post_mult_sign2,ab_st_cd,exp_diff,eop)
  variable opA,opB              : usg(47 downto 0);
  variable shift_unit           : integer range 0 to 512; 
  variable post_shift_opB       : usg(47 downto 0);
  variable added_result         : usg(48 downto 0);
  BEGIN
    shift_unit:=to_integer(abs(exp_diff));
    post_shift_opB:=(others=>'0');
    neg_sig<='0';
    ----------------------------
    --swap
    ----------------------------
    if ab_st_cd = '1' or post_mult_significand1=0 then              -- swap order if a*b<c*d
      opA:=post_mult_significand2;
      opB:=post_mult_significand1;
      pre_norm_exponent<=sgn(resize(post_mult_exp2,10)-125); 
      temp_sign<=post_mult_sign2;       -- sign agree with the larger number
    else
      opA:=post_mult_significand1;
      opB:=post_mult_significand2;
      pre_norm_exponent<=sgn(resize(post_mult_exp1,10)-125);
      temp_sign<=post_mult_sign1;
    end if;
    ----------------------------
    --shift
    ----------------------------
    for i in 1 to 47 loop
      ----------------------------------
      --sticky bit
      ----------------------------------
      if i<shift_unit	then 
        post_shift_opB(0):=post_shift_opB(0) OR opB(i);         --after shifting, sticky bit become bitwiseOR of shifted bits
      end if;
      ----------------------------------
      --shift by shift_unit
      ----------------------------------
      if i+shift_unit<48 then 				
        post_shift_opB(i):=opB(i+shift_unit);		        --right shift
      else
        post_shift_opB(i):='0';					--zero padding				
      end if;								
    end loop;

    ----------------------------
    --adder
    ----------------------------
    if eop='0' then
      added_result := resize(opA,49)+resize(post_shift_opB,49);
      pre_norm_significand<=added_result;
    else
      added_result := resize(opA,49)-resize(post_shift_opB,49);
      neg_sig<=added_result(48);
      pre_norm_significand<=usg(abs(sgn(added_result)));
    end if;	
	
  end process add;
  
  sign_logic:process(temp_sign,neg_sig,post_mult_sign1,post_mult_sign2,a,b,c,d)
  begin
    if (isZero(a) or isZero(b)) and (isZero(c) or isZero(d)) then
      result.sign<=post_mult_sign1 and post_mult_sign2;
    elsif neg_sig ='1' then
      result.sign<= not temp_sign;
    else
      result.sign<= temp_sign;
    end if;
  end process;
-------------------------------------------------------------------------------
  --normalise
  -----------------------------------------------------------------------------
  --result from addition stage is normalised with 9 bit exponent and 26 bit
  --significand (24+1+1) 
  -----------------------------------------------------------------------------
  normalise:process(pre_norm_significand,pre_norm_exponent)
    variable leadingzeros : integer range 0 to 49;
    variable sft_result_significand : usg(48 downto 0);
    variable sft_result_exponent: usg(8 downto 0);
    variable s_bit:std_logic;
    variable sft_unit:integer range -512 to 511;
  begin
    leadingzeros := 0;
    s_bit:='0';
    
      sft_result_significand:=pre_norm_significand;
      
  if pre_norm_exponent<=0 then
      sft_unit:=to_integer(not pre_norm_exponent + 1);
      
      sft_result_exponent:=(others=>'0');
      for i in 0 to 48 loop
        -----------------------------------------------------------------------
        --sticky_bit
        -----------------------------------------------------------------------
        if i <sft_unit then
          s_bit:=s_bit or pre_norm_significand(i);
        end if;
        -----------------------------------------------------------------------
        --right shift to get denormal result
        -----------------------------------------------------------------------
        if i+sft_unit<=47 then
          sft_result_significand(i):=pre_norm_significand(i+sft_unit+1);
        --shift by sft_unit+1 
        else
          sft_result_significand(i):='0';
        end if;
      end loop;
      
      sft_result_exponent:=(others=>'0');
  else
    -----------------------------------------------------------------------------
    --leading zero detector
    ---------------------------------------------------------------------------
    for i in pre_norm_significand'high downto pre_norm_significand'low loop
      if pre_norm_significand(i)='0' then
        leadingzeros:=leadingzeros+1;
      else
        exit; 
      end if;
    end loop;
    
    if  pre_norm_exponent>0 and pre_norm_exponent<=leadingzeros then
      sft_unit:=to_integer(pre_norm_exponent-1);
       sft_result_exponent:=(others=>'0');
    else
      sft_unit:=leadingzeros;
       sft_result_exponent:=usg(pre_norm_exponent(8 downto 0))-leadingzeros;
    end if;
    
    for i in 0 to 48 loop
      if i-sft_unit>=0 then
      sft_result_significand(i):=pre_norm_significand(i-sft_unit);
      else
      sft_result_significand(i):='0';
      end if;
    end loop;      
  end if;  
  
   for i in 0 to 23 loop
      s_bit:=s_bit or sft_result_significand(i);
    end loop;
    
    post_norm_significand<=sft_result_significand(48 downto 24)&s_bit;
    post_norm_exponent<=sft_result_exponent;
   
  end process normalise;
  
----------------------------------------------------------------------------------------
  --rounder
  --The process round the result to be 23 bit mantissa
  --------------------------------------------------------------------------------------
  rounder:process(post_norm_significand,post_norm_exponent,a,b,c,d,eop)

    variable rounded_result_e_s		:usg(8 downto 0);
    variable rounded_result_man_s	:usg(23 downto 0);

  begin
    case post_norm_significand(2 downto 0) IS						--rounding decoder(LSB+GUARD+STICKY)  RTE rounding mode
      when "000"|"001"|"010"|"100"|"101"=>rounded_result_man_s := '0'&post_norm_significand(24 downto 2);	        --round down
      when "011"|"110"|"111"		=>rounded_result_man_s := resize(usg(post_norm_significand(24 downto 2)),24)+1;	--round up
      when others => null;
    end case;
  
    if rounded_result_man_s(23)='1' then
      rounded_result_e_s:=post_norm_exponent+1;
    else
      rounded_result_e_s:=post_norm_exponent;
    end if;
    if isNan(a) or isNan(b) or isNan(c) or isNan(d) or (isZero(a) and isInf(b)) or (isZero(b) and isInf(a)) or (isZero(c) and isInf(d)) or (isZero(d) and isInf(c)) or ((isInf(a) or isInf(b))and(isInf(c) or isInf(d)) and eop='1') then
      result.exponent	 <=      (others=>'1');
      result.significand <=      (others=>'1');
    elsif (isZero(a) or isZero(b))and(isZero(c)or isZero(d)) then
      result.exponent	 <=      (others=>'0');
      result.significand <=      (others=>'0');

    elsif rounded_result_e_s>=255 or isInf(a) or isInf(b) or isInf(c) or isInf(d) then     --overflows
      result.exponent	 <=      (others=>'1');
      result.significand <=      (others=>'0');
	
    else
      result.significand <=	slv(rounded_result_man_s(22 downto 0));
      result.exponent	 <=	slv(rounded_result_e_s(7 downto 0));
    end if;
   
  end process rounder;
  
end chained;
