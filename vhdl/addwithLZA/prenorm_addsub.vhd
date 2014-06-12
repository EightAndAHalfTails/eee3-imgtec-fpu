--------------------------------------------------------------------------------------
--prenorm_addsub.vhd
--------------------------------------------------------------------------------------

LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.all;
use work.types.all;

ENTITY prenorm_addsub IS 
	PORT 
	( 
	  A				: IN  float32_t;
	  B				: IN  float32_t;
	  operation_i			: IN  std_logic;
	  A_man_o,B_man_o		: OUT std_logic_vector(27 downto 0);	--(hidden &mantissa &3 guard bits &sticky)(1+23+3+1=28)
	  temp_exp_o			: OUT std_logic_vector(7 downto 0);
	  sign_o			: OUT std_logic;
	  eop_o				: OUT std_logic
	);
END ENTITY prenorm_addsub;


ARCHITECTURE rtl of prenorm_addsub IS

--control signals
SIGNAL addsub_A_st_B						 :std_logic;
SIGNAL operation           :std_logic;

--internal signals
SIGNAL temp_sign											:sign_t;
SIGNAL temp_expo											:exponent_t;
SIGNAL expo_diff											:slv(8 downto 0);

SIGNAL post_shift_opA						:slv(27 downto 0);
SIGNAL post_shift_opB						:slv(27 downto 0);


BEGIN

--------------------------------------------------------------------------------------------
--output signals
--------------------------------------------------------------------------------------------
	output:BLOCK
	BEGIN
		A_man_o			 <=	post_shift_opA;
		B_man_o			 <=	post_shift_opB;
		temp_exp_o	<=	temp_expo;
		sign_o			  <=	temp_sign;
		eop_o			   <=	operation;
	END BLOCK output;
	
  --exponent difference (with one signed bit)
	expo_diff<=slv(Resize(usg(A.exponent),9)-Resize(usg(B.exponent),9));				
	
	--control logic flags
	addsub_A_st_B<='1' WHEN usg(A.exponent)<usg(B.exponent) OR (usg(A.exponent)=usg(B.exponent) AND usg(A.significand)<usg(B.significand)) ELSE '0';
		
--------------------------------------------------------------------------------------------
--for add(0):same sign=>addition(0)	different sign=>subtraction(1)
--for subtract(1):same sign=>subtraction(1)	different sign=>addition(0)
--------------------------------------------------------------------------------------------
	operation<=A.sign XOR B.sign XOR operation_i;								--effective operation mode for adder stage	

--------------------------------------------------------------------------------------------
--sign_logic
--computes logic of sign bit output
--abs(A)<abs(B)=>sign to be sign of B
--abs(A)>=abs(B)=>sign to be sign of A	
--------------------------------------------------------------------------------------------	
	sign_logic:PROCESS(operation_i,A,B,addsub_A_st_B)
	BEGIN
		IF addsub_A_st_B='1' THEN			--if abs(A) is smaller than abs(B)
			IF operation_i='0' THEN		
				temp_sign<=B.sign;
			ELSE
				temp_sign<=NOT B.sign;
			END IF;		
		ELSIF 	usg(A.exponent)=usg(B.exponent) AND usg(A.significand)=usg(B.significand) THEN     --abs(A)=abs(B)
		   IF operation_i='0' THEN		
				temp_sign<=A.sign AND B.sign;
			 ELSE
				temp_sign<=A.sign AND (NOT B.sign);
			 END IF;	
		ELSE													                                                                --abs(A)>abs(B)
			  temp_sign<=A.sign;					
		END IF;

	END PROCESS;

--------------------------------------------------------------------------------------------
--swap and shift
--swap the inputs when abs(A)<abs(B),shift the smaller number to align with the bigger.
--------------------------------------------------------------------------------------------	
	swap_align:PROCESS(addsub_A_st_B,A,B)
	VARIABLE A_man_v,B_man_v       :slv(27 downto 1);
	VARIABLE pre_shift_opA,pre_shift_opB :slv(27 downto 1);
	VARIABLE sticky_b              :std_logic; 
	VARIABLE shift_unit            :integer range 0 to 255;
	CONSTANT zeros :exponent_t :=(others=>'0');
	
	BEGIN
	  sticky_b := '0';
	  shift_unit:=to_integer(abs(sgn(expo_diff(8 downto 0))));				--take exponent difference as number of shifts required
	  --------------------------------------------------------------------------
	  --normalise A and B if denormal,restore the hidden bit & initialise guard bit  
	  --------------------------------------------------------------------------
	  IF A.exponent=zeros THEN                     --if A is a denormal number
	    A_man_v:=A.significand&"0000";             --normalise to 2^127*0.man*2
	  ELSE
	    A_man_v:='1'& A.significand&"000";	        --restore the hidden bit & initialise guard bit
	  END IF;
	  
	  IF B.exponent=zeros THEN
	    B_man_v:=B.significand&"0000";
	  ELSE
	    B_man_v:='1'&B.significand&"000";
	  END IF;
	  
	  --------------------------
	  --swap if abs(A)<abs(B)
	  --------------------------
		IF addsub_A_st_B='1' THEN		                 --if abs(A)<abs(B)
			pre_shift_opA:=B_man_v;						
		  pre_shift_opB:=A_man_v;
		  temp_expo	<=	B.exponent;		
		ELSE												                    --abs(A)>=abs(B)
			pre_shift_opA:=A_man_v;
			pre_shift_opB:=B_man_v;
			temp_expo	<=	A.exponent;
		END IF;		
	-------------------------------------------------
	--shift
	-------------------------------------------------	
			FOR i IN 1 TO 27 LOOP
				----------------------------------
				--sticky bit
				----------------------------------
				IF i<shift_unit+1	THEN 
					sticky_b:=sticky_b OR pre_shift_opB(i);			--after shifting, sticky bit become bitwiseOR of shifted bits
				END IF;
				----------------------------------
				--shift by shift_unit
				----------------------------------
				IF i+shift_unit<28	THEN 				
					post_shift_opB(i)<=pre_shift_opB(i+shift_unit);		--right shift
				ELSE
					post_shift_opB(i)<='0';					--zero padding				
				END IF;		
			END LOOP;
				
		post_shift_opB(0)	<=	sticky_b;					      --sticky bit of B
	  post_shift_opA	<=	pre_shift_opA&'0';					--A+sticky bit
	
	END PROCESS swap_align;


END ARCHITECTURE rtl;



