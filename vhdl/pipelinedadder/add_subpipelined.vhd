--------------------------------------------------------------------------------------
--add_sub.vhd
--------------------------------------------------------------------------------------
--pipelined
--------------------------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.all;
use work.types.all;

ENTITY addsub IS 
	PORT 
	( clk,reset: IN std_logic;
	  add_in1		: IN  std_logic_vector(31 downto 0);
	  add_in2		: IN  std_logic_vector(31 downto 0);
	  operation_i		: IN  std_logic; -- 0:add, 1:sub
	  add_out		: OUT std_logic_vector(31 downto 0);
	  done			:OUT std_logic
	);
END ENTITY addsub;

architecture rtl of addsub IS
signal A,B,result                               :float32_t;
signal addsub_A_st_B :std_logic;
signal input_NaN,input_NaN0,input_NaN1,input_NaN2  :boolean;
signal expo_diff,expo_diff0,expo_diff1		:sgn(8 downto 0);
signal result_denorm          :std_logic;
signal result_inf,result_inf3 :std_logic;
signal result_NaN,result_NaN3 :std_logic;
signal result_zero,result_zero3 :std_logic;


signal operation0,operation1        :std_logic;
signal temp_sign0,temp_sign1,temp_sign2,temp_sign3  :sign_t;


signal pre_shift_opA,pre_shift_opB              :slv(27 downto 1);

signal post_shift_opA,post_shift_opB	        :slv(27 downto 0);

signal temp_expo0,temp_expo1:exponent_t;
signal prenorm_result_e_s		:exponent_t;
signal prenorm_result_man_s		:std_logic_vector(28 downto 0);
signal leadingzeros           		:integer range 0 to 28;

signal postnorm_result_e_s		:exponent_t;
signal postnorm_result_man_s		:std_logic_vector(25 downto 0);

begin

  sign_logic:process
    variable temp_sign : sign_t;
  begin
    wait until clk'EVENT and clk='1';
      if reset='1' then 
	temp_sign0<='0';
	temp_sign1<='0';
	temp_sign2<='0';
	temp_sign3<='0';
	result.sign<='0';

	operation0<='0';
	operation1<='0';
      else
        for i in 0 to 4 loop
          case i is
            when 0 =>   if addsub_A_st_B='1' then
                          if operation_i='0' then		
                            temp_sign0<=B.sign;
                          else
                            temp_sign0<=NOT B.sign;
                          end if;		         
                        elsif 	usg(A.exponent)=usg(B.exponent) AND usg(A.significand)=usg(B.significand) THEN
                          if operation_i='0' then		
                            temp_sign0<=A.sign and B.sign;
                          else
                            temp_sign0<=A.sign and (not B.sign);
                          end if;	
                        else													                                                               
                          temp_sign0<=A.sign;					
                        end if;
                        operation0<=A.sign xor B.sign xor operation_i;
            when 1 =>operation1<=operation0;
                     temp_sign1<=temp_sign0;
            when 2 =>temp_sign2<=temp_sign1;
            when 3 =>temp_sign3<=temp_sign2;
            when 4 =>result.sign<=temp_sign3;
            when others => null;
          end case;
        end loop;
      end if;
       
    end process sign_logic;

reg:process
begin
wait until clk'EVENT and clk='1';
if reset='1' then 

	input_NaN0<=false;
	input_NaN1<=false;
	input_NaN2<=false;
	
	expo_diff0<=(others=>'0');
	expo_diff1<=(others=>'0');
	
	temp_expo1<=(others=>'0');

	result_NaN3<='0';
	result_inf3<='0';
	result_zero3<='0';
	done<='0';
else
 for i in 0 to 4 loop
  case i is
	when 0=>	--swap
		input_NaN0<=input_NaN;
		expo_diff0<=expo_diff;		
	when 1=> --align
	  input_NaN1<=input_NaN0;
		temp_expo1<=temp_expo0;
		expo_diff1<=expo_diff0;
	when 2=>	--add
		input_NaN2<=input_NaN1;
	when 3=>	--normalise
		result_NaN3<=result_NaN;
		result_inf3<=result_inf;
		result_zero3<=result_zero;
	when 4=>
		done<='1';
	when others=>null;
  end case;
 end loop;
end if;

end process reg;
-----------------------------------------------------------------pipeline stage 0----------------------------------------------------------------------------------------------------------------
  A<=slv2float(add_in1);
  B<=slv2float(add_in2);
  add_out<=float2slv(result);
  addsub_A_st_B<='1' when usg(A.exponent)<usg(B.exponent) or (usg(A.exponent)=usg(B.exponent) and usg(A.significand)<usg(B.significand)) else '0';
  input_NaN<=isNan(A) or isNan(B);
  expo_diff<=sgn(resize(usg(A.exponent),9)-resize(usg(B.exponent),9));

  swap :process
    constant zeros :exponent_t :=(others=>'0');
    variable A_man_v,B_man_v   :slv(27 downto 1);
    begin
    wait until clk'EVENT and clk='1';
if reset='1' then
      pre_shift_opA<=(others=>'0');						
      pre_shift_opB<=(others=>'0');
      temp_expo0<=(others=>'0');
else
    if A.exponent=zeros then                     	--if A is a denormal number
      A_man_v:=A.significand&"0000";             	
    else
      A_man_v:='1'& A.significand&"000";	        --restore the hidden bit & initialise guard bit
    end if;

    if B.exponent=zeros then
      B_man_v:=B.significand&"0000";
    else
      B_man_v:='1'&B.significand&"000";
    end if;

    if addsub_A_st_B='1' then		                 --if abs(A)<abs(B)
      pre_shift_opA<=B_man_v;						
      pre_shift_opB<=A_man_v;
      temp_expo0<=B.exponent;		
    else				                         --abs(A)>=abs(B)
      pre_shift_opA<=A_man_v;
      pre_shift_opB<=B_man_v;
      temp_expo0<=A.exponent;
    end if;	
end if;
  end process swap;

-----------------------------------------------------------------pipeline stage 1----------------------------------------------------------------------------------------------------------------
  align:PROCESS
    VARIABLE sticky_b              :std_logic; 
    VARIABLE shift_unit            :integer range 0 to 255;	

  BEGIN
    WAIT UNTIL clk'EVENT and clk='1';
if reset='1' then
	post_shift_opA<=(others=>'0');
	post_shift_opB<=(others=>'0');
	
else
    sticky_b := '0';
    shift_unit:=to_integer(abs(expo_diff0(8 downto 0)));--take exponent difference as number of shifts required

    FOR i IN 1 TO 27 LOOP
      ----------------------------------
      --sticky bit
      ----------------------------------
      IF i<shift_unit+1	THEN 
        sticky_b:=sticky_b OR pre_shift_opB(i);			--after shifting, sticky bit become bitwiseOR of shifted bits
      END IF;
      ---------------------------------
      --shift by shift_unit
      ----------------------------------
      IF i+shift_unit<28	THEN 				
        post_shift_opB(i)       <=      pre_shift_opB(i+shift_unit);		--right shift
      ELSE
        post_shift_opB(i)       <=      '0';					--zero padding				
      END IF;		
    END LOOP;

    post_shift_opB(0)   <=	sticky_b;					      --sticky bit of B	  
    post_shift_opA      <=	pre_shift_opA&'0';					--A+sticky bit
end if;	
  END PROCESS align;
-----------------------------------------------------------------pipeline stage 2----------------------------------------------------------------------------------------------------------------

      adder_proc:PROCESS
      BEGIN
        WAIT UNTIL clk'EVENT and clk='1';
IF reset='1' THEN
	prenorm_result_man_s<=(others=>'0');
	prenorm_result_e_s<=(OTHERS=>'0');
ELSE
	IF operation1 ='0' THEN
          prenorm_result_man_s<=slv(Resize(usg(post_shift_opA),29)+Resize(usg(post_shift_opB),29));
	ELSE 
          prenorm_result_man_s<=slv(Resize(usg(post_shift_opA),29)-Resize(usg(post_shift_opB),29));
	END IF;
        prenorm_result_e_s<=temp_expo1;
END IF;
END PROCESS adder_proc;

      LZA:process	--suzuki96 leading zero anticipator
        variable A_0:  std_logic_vector(28 downto 0);
        variable B_0:  std_logic_vector(28 downto 0);
        variable f:	 std_logic_vector(28 downto 1);
        variable count:integer range 0 to 28;
      BEGIN
	WAIT UNTIL clk'EVENT and clk='1';
IF reset='1' THEN
	leadingzeros<=0;
ELSE
        count:=0;
        A_0:='0'&post_shift_opA;
        if operation1='1' then
          B_0:=not ('0'&post_shift_opB);
	else
          B_0:='0'&post_shift_opB;
	end if;

        for i in f'HIGH downto f'LOW+1 loop
          f(i):=(NOT (A_0(i) XOR B_0(i))) AND (A_0(i-1) or B_0(i-1));
	end loop;
	
	for i in f'HIGH downto f'LOW+1 loop
          if f(i)='1' then exit;
          else count:=count+1;
          end if;
	end loop;
 	leadingzeros<=count;
END IF;
end process LZA;
-----------------------------------------------------------------pipeline stage 3----------------------------------------------------------------------------------------------------------------
result_denorm<='1'  WHEN  (usg(prenorm_result_e_s)=0 AND prenorm_result_man_s(28)='0') OR usg(prenorm_result_e_s)<=leadingzeros ELSE '0'; 
result_NaN<='1' WHEN input_NaN2 or (usg(prenorm_result_e_s)=255 AND usg(prenorm_result_man_s) =0) ELSE '0';
result_inf<='1' WHEN usg(prenorm_result_e_s)=255 AND usg(prenorm_result_man_s) /=0 ELSE '0';
result_zero<='1' WHEN usg(prenorm_result_man_s)=0 ELSE '0';

normaliser:PROCESS
  VARIABLE sft_man: slv(28 downto 0);
  VARIABLE sft_exp: slv(7 downto 0);
BEGIN	
  WAIT UNTIL clk'EVENT and clk='1';
IF reset='1' THEN
	postnorm_result_e_s<=(OTHERS=>'0');
	postnorm_result_man_s<=(OTHERS=>'0');
	
ELSE
  IF prenorm_result_man_s(28)='1' THEN
    
    postnorm_result_e_s<=slv(usg(prenorm_result_e_s)+1);
    postnorm_result_man_s(25 downto 1)<=prenorm_result_man_s(28 downto 4);
    postnorm_result_man_s(0)<=prenorm_result_man_s(3) OR prenorm_result_man_s(2) OR prenorm_result_man_s(1) OR prenorm_result_man_s(0);
		
  ELSIF result_denorm='1' THEN
    sft_exp:= (OTHERS=>'0');
    FOR i IN 0 TO 28 LOOP
      IF i<usg(prenorm_result_e_s) THEN
        sft_man(i):='0';
      ELSE 
        sft_man(i):=prenorm_result_man_s(i-to_integer(usg(prenorm_result_e_s)));			
      END IF;
    END LOOP;      
    postnorm_result_e_s<=sft_exp;
    postnorm_result_man_s(25 downto 1)<=sft_man(28 downto 4);
    postnorm_result_man_s(0)<=sft_man(3) OR sft_man(2) OR sft_man(1) OR sft_man(0);
    
  ELSE                                                            
    
    sft_exp:= slv(usg(prenorm_result_e_s)-leadingzeros+1);
    FOR i IN 0 TO 28 LOOP
      IF i<leadingzeros THEN
        sft_man(i):='0';
      ELSE 
        sft_man(i):=prenorm_result_man_s(i-leadingzeros);				
      END IF;
    END LOOP;
      if (sft_man(28)='0') then
        postnorm_result_e_s<=slv(usg(sft_exp)-1);
        postnorm_result_man_s(25 downto 1)<=sft_man(27 downto 3);
        postnorm_result_man_s(0)<=sft_man(2) OR sft_man(1) OR sft_man(0);
      else
        postnorm_result_e_s<=sft_exp;
        postnorm_result_man_s(25 downto 1)<=sft_man(28 downto 4);
        postnorm_result_man_s(0)<=sft_man(3) OR sft_man(2) OR sft_man(1) OR sft_man(0);
      end if;
   
  END IF;
END IF;
END PROCESS normaliser;

-----------------------------------------------------------------pipeline stage 4----------------------------------------------------------------------------------------------------------------
rounder:PROCESS
constant ones : exponent_t := (others=>'0');
VARIABLE rounded_result_e_s		:exponent_t;
VARIABLE rounded_result_man_s		:slv(23 downto 0);


BEGIN
WAIT UNTIL clk'EVENT and clk='1';	
if reset='1' then
	result.exponent<=(others=>'0');
	result.significand<=(others=>'0');
else
	CASE postnorm_result_man_s(2 downto 0) IS						--rounding decoder(LSB+GUARD+STICKY)  RTE rounding mode
	WHEN "000"|"001"|"010"|"100"|"101"	=>rounded_result_man_s := '0'&postnorm_result_man_s(24 downto 2);			--round down
	WHEN "011"|"110"|"111"			=>rounded_result_man_s := slv(RESIZE(usg(postnorm_result_man_s(24 downto 2)),24)+1);	--round up
	WHEN OTHERS => NULL;
	END CASE;
	IF rounded_result_man_s(23)='1' OR (usg(postnorm_result_e_s)=0 AND postnorm_result_man_s(25)='1') THEN
	  rounded_result_e_s:=slv(usg(postnorm_result_e_s)+1);
	ELSE
	  rounded_result_e_s			:=postnorm_result_e_s;
	END IF;
	if result_NaN3='1'  then 
          result.exponent	 <=	(OTHERS=>'1');
	  result.significand	  <=	(OTHERS=>'1');
	elsif result_inf3='1' then
	  result.exponent	 <=	(OTHERS=>'1');
          result.significand	  <=	(OTHERS=>'0');  
        elsif result_zero3='1' then 
	  result.exponent	 <=	(OTHERS=>'0');
	  result.significand	  <=	(OTHERS=>'0');
        ELSE
          result.exponent	  <=	rounded_result_e_s;
          IF rounded_result_e_s="11111111" THEN                           --overflow 
            result.significand	<=(OTHERS=>'0');	     
          ELSE
            result.significand	<=rounded_result_man_s(22 downto 0);	--1 bit shift adjustment
	  END IF;
	END IF;
end if;
END PROCESS rounder;
END ARCHITECTURE rtl;
