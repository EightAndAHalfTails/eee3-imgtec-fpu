library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
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
    dot2_in1, dot2_in2, dot2_in3,dot2_in4 : in std_logic_vector(31 downto 0);
    dot2_out : out std_logic_vector(31 downto 0)
    );
end entity dot2;

architecture implementation of dot2 is

  signal a,b,c,d,result : float32_t;

  signal post_mult_sign1,post_mult_sign2,temp_sign    :sign_t;
  signal post_mult_exp1,post_mult_exp2      :usg(8 downto 0);
  signal post_mult_significand1,post_mult_significand2:usg(47 downto 0);
  signal exp_diff                           :sgn(9 downto 0);
  signal opA,opB                            :usg(47 downto 0);
  signal pre_norm_exponent                  :usg(8 downto 0);
  signal pre_norm_significand               :usg(48 downto 0);
  signal post_norm_significand              :usg(25 downto 0);
  signal post_norm_exponent                 :usg(8 downto 0);
  --flags
  signal ab_st_cd                           :std_logic;
  
begin  -- implementation
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

exp_diff<=sgn(resize(post_mult_exp1,10)-resize(post_mult_exp2,10));
ab_st_cd<='1' when exp_diff <0 or (exp_diff=0 and post_mult_significand1<post_mult_significand2) else '0';
-------------------------------------------------------------------------------
  --adder
  -----------------------------------------------------------------------------
  add:PROCESS(post_mult_significand1,post_mult_significand2,post_mult_exp1,post_mult_exp2,post_mult_sign1,post_mult_sign2,ab_st_cd,exp_diff)
  variable opA,opB: usg(47 downto 0);
  variable shift_unit: integer range 0 to 512; 
  variable post_shift_opB:usg(47 downto 0);
  variable eof   :std_logic; 
	BEGIN
	  shift_unit:=to_integer(abs(exp_diff));
	  post_shift_opB:=(others=>'0');
	  eof:=post_mult_sign1 xor post_mult_sign2;
	----------------------------
	--swap
	----------------------------
  if ab_st_cd = '1' then
  opA:=post_mult_significand2;
  opB:=post_mult_significand1;
  pre_norm_exponent<=post_mult_exp2;
  temp_sign<=post_mult_sign2;
  else
  opA:=post_mult_significand1;
  opB:=post_mult_significand2;
  pre_norm_exponent<=post_mult_exp1;
  temp_sign<=post_mult_sign1;
  end if;
  ----------------------------
  --shift
  ----------------------------
  for i IN 1 TO 47 LOOP
				----------------------------------
				--sticky bit
				----------------------------------
				IF i<shift_unit	THEN 
					post_shift_opB(0):=post_shift_opB(0) OR opB(i);			--after shifting, sticky bit become bitwiseOR of shifted bits
				END IF;
				----------------------------------
				--shift by shift_unit
				----------------------------------
				IF i+shift_unit<28	THEN 				
					post_shift_opB(i):=opB(i+shift_unit);		--right shift
				ELSE
					post_shift_opB(i):='0';					--zero padding				
				END IF;								
	end loop;
	----------------------------
	--add
	----------------------------
	if eof='0' then
	  pre_norm_significand <= resize(opA,49)+resize(post_shift_opB,49);
	else
	  pre_norm_significand <= resize(opA,49)-resize(post_shift_opB,49);
	end if;
	
	end process add;
--------------------------------------------------------
  --normalise
  ------------------------------------------------------
normalise:process(pre_norm_significand,pre_norm_exponent)
    variable leadingzeros : integer range 0 to 49;
    variable sft_result_significand : usg(48 downto 0);
    variable sft_result_exponent: usg(8 downto 0);
    variable s_bit:std_logic;
    variable sft_unit:integer range -512 to 511;
  begin
    leadingzeros := 0;
    
    -----------------------------------------------------------------------------
    --leading zero detector
    ---------------------------------------------------------------------------
      for i in pre_norm_significand'high downto pre_norm_significand'low loop
        if pre_norm_significand(i)='0' then
          leadingzeros:=leadingzeros+1;
          sft_result_significand:=sft_result_significand sll 1;--left shift until left aligned
        else
          exit; 
        end if;
      end loop;
      
      sft_result_exponent:=pre_norm_exponent-leadingzeros-127;
      
      post_norm_significand<=sft_result_significand(48 downto 24)&s_bit;
      post_norm_exponent<=sft_result_exponent;
      
  end process normalise;
  
  --------------------------------------------------------------------------------------
  --rounder
  --The process round the result to be to be 23 bit mantissa
  --------------------------------------------------------------------------------------
  rounder:PROCESS(post_norm_significand,post_norm_exponent,temp_sign)

    VARIABLE rounded_result_e_s		:usg(8 downto 0);
    VARIABLE rounded_result_man_s	:usg(23 downto 0);

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
    
    if rounded_result_e_s>=255 then     --overflows
      result.exponent	<=(others=>'1');
      result.significand<=(others=>'0');
    else
      result.significand	<=	slv(rounded_result_man_s(22 downto 0));
      result.exponent	   <=	slv(rounded_result_e_s(7 downto 0));
    end if;
    result.sign<=temp_sign;
  end process rounder;
  
end implementation;
