--------------------------------------------------------------------------------------
--prenorm_addsub.vhd
--------------------------------------------------------------------------------------

LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.all;
USE config_pack.all;

ENTITY prenorm_addsub IS 
	PORT 
	( 
	  A_i				: IN  std_logic_vector(31 downto 0);
	  B_i				: IN  std_logic_vector(31 downto 0);
	  operation_i			: IN  std_logic;
	  A_man_o,B_man_o		: OUT std_logic_vector(25 downto 0);	--(hidden &mantissa &guard &round &sticky)(1+23+1+1+1=27)
	  temp_exp_o			: OUT std_logic_vector(7 downto 0);
	  sign_o			: OUT std_logic;
	  eop_o				: OUT std_logic
	);
END ENTITY prenorm_addsub;


ARCHITECTURE rtl of prenorm_addsub IS

--control signals
SIGNAL addsub_opA_st_opB,addsub_expoA_st_expoB,addsub_expoA_eq_expoB						:std_logic;
SIGNAL addsub_A_denorm,addsub_B_denorm  :std_logic;
SIGNAL operation             											:std_logic;

--internal signals
SIGNAL A_si_s,B_si_s,temp_sign											:sign_t;
SIGNAL A_e_s,B_e_s,temp_expo											:exponent_t;
SIGNAL A_man_s,B_man_s   											:significand_t;
SIGNAL expo_diff												:slv(8 downto 0);
SIGNAL shift_unit												:integer range 0 to 255;

SIGNAL pre_shift_opA												:slv(25 downto 1);
SIGNAL pre_shift_opB												:slv(25 downto 1);
SIGNAL post_shift_opA												:slv(25 downto 0);
SIGNAL post_shift_opB												:slv(25 downto 0);


BEGIN

--------------------------------------------------------------------------------------------
--output signals
--------------------------------------------------------------------------------------------
	output:BLOCK
	BEGIN
		A_man_o			<=	post_shift_opA;
		B_man_o			<=	post_shift_opB;
		temp_exp_o		<=	temp_expo;
		sign_o			<=	temp_sign;
		eop_o			<=	operation;
	END BLOCK output;

--------------------------------------------------------------------------------------------
--unpacking
--This block is used to unpack the 32 numbers into corresponding 
--sections (sign&exponent&mantissa)
--------------------------------------------------------------------------------------------
  
	unpack:BLOCK
	BEGIN
		A_si_s	<=	A_i(31);
		A_e_s	<=	A_i(30 downto 23);
		A_man_s	<=	A_i(22 downto 0);

		B_si_s	<=	B_i(31);
		B_e_s	<=	B_i(30 downto 23);
		B_man_s	<=	B_i(22 downto 0);
	END BLOCK unpack;
	
--------------------------------------------------------------------------------------------
--internal signal connections
--------------------------------------------------------------------------------------------

	expo_diff<=slv(Resize(usg(A_e_s),9)-Resize(usg(B_e_s),9));				--exponent difference (with one signed bit)
	--control logic flags
	addsub_A_denorm<='1'  WHEN  usg(A_e_s)=0 ELSE '0';                --flag: A is denormal
  addsub_B_denorm<='1'  WHEN  usg(B_e_s)=0 ELSE '0';                --flag: B is denormal
  
	addsub_expoA_st_expoB<='1'	WHEN usg(A_e_s)<usg(B_e_s) ELSE '0';			--flag: exponent of A< exponent of B
	addsub_expoA_eq_expoB<='1'	WHEN usg(A_e_s)=usg(B_e_s) ELSE '0';			--flag:	exponent of A= exponent of B
	addsub_opA_st_opB<='1'		WHEN usg(A_man_s)<usg(B_man_s) ELSE '0';		--flag: mantissa of A< mantissa of B
	--compute shift unit
	shift_unit<=to_integer(abs(sgn(expo_diff(8 downto 0))));				--take exponent difference as number of shifts required
		
--------------------------------------------------------------------------------------------
--for add(0):same sign=>addition(0)	different sign=>subtraction(1)
--for subtract(1):same sign=>subtraction(1)	different sign=>addition(0)
--------------------------------------------------------------------------------------------
	operation<=A_si_s XOR B_si_s XOR operation_i;								--effective operation mode for adder stage	

--------------------------------------------------------------------------------------------
--sign_logic
--computes logic of sign bit output
--abs(A)<abs(B)=>sign to be sign of B
--abs(A)>=abs(B)=>sign to be sign of A	
--------------------------------------------------------------------------------------------	
	sign_logic:PROCESS(addsub_expoA_st_expoB,addsub_expoA_eq_expoB,addsub_opA_st_opB,operation_i,B_si_s,A_si_s)
	BEGIN
		IF addsub_expoA_st_expoB='1' OR (addsub_expoA_eq_expoB AND addsub_opA_st_opB)='1' THEN			--if abs(A) is smaller than abs(B)
			IF operation_i='0' THEN		
				temp_sign<=B_si_s;
			ELSE
				temp_sign<=NOT B_si_s;
			END IF;						
		ELSE													--abs(A)>=abs(B)
			temp_sign<=A_si_s;					
		END IF;

	END PROCESS;

--------------------------------------------------------------------------------------------
--exponent logic : select the larger exponent
--output exponent = MAX(exponent of A, exponent of B)
--------------------------------------------------------------------------------------------	
	expo_logic:PROCESS(addsub_expoA_st_expoB,B_e_s,A_e_s)
	BEGIN

		IF addsub_expoA_st_expoB='1' THEN						--if exponent of A is smaller than B
			temp_expo	<=	B_e_s;
		ELSE		  
			temp_expo	<=	A_e_s;
		END IF;

	END PROCESS;
	

--------------------------------------------------------------------------------------------
--swap process
--swap the inputs when abs(A)<abs(B)
--------------------------------------------------------------------------------------------	
	swap:PROCESS(addsub_expoA_st_expoB,addsub_opA_st_opB,addsub_expoA_eq_expoB,A_man_s,B_man_s,addsub_A_denorm,addsub_B_denorm)
	VARIABLE A_man_v,B_man_v       :slv(25 downto 1);
	
	BEGIN
	  --------------------------------------------------------------------------
	  --normalise A if denormal,restore the hidden bit & initialise guard bit  
	  --------------------------------------------------------------------------
	  IF addsub_A_denorm='1' THEN          --if A is a denormal number
	    A_man_v:=A_man_s&"00";             --normalise to 2^127*0.man*2
	  ELSE
	    A_man_v:='1'& A_man_s&'0';	        --restore the hidden bit & initialise guard bit
	  END IF;
	  --------------------------------------------------------------------------
	  --normalise B if denormal,restore the hidden bit & initialise guard bit  
	  --------------------------------------------------------------------------
	  IF addsub_B_denorm='1' THEN
	    B_man_v:=B_man_s&"00";
	  ELSE
	    B_man_v:='1'& B_man_s&'0';
	  END IF;
	  
	  --------------------------
	  --swap if abs(A)<abs(B)
	  --------------------------
		IF addsub_expoA_st_expoB='1' OR (addsub_expoA_eq_expoB AND addsub_opA_st_opB)='1' THEN		--if abs(A)<abs(B)
			pre_shift_opA<=B_man_v;						
		  pre_shift_opB<=A_man_v;		
		ELSE												                    --abs(A)>=abs(B)
			pre_shift_opA<=A_man_v;
			pre_shift_opB<=B_man_v;
		END IF;
	END PROCESS swap;
	
-------------------------------------------------------------------------------------------
--shift process : shift operand B
-------------------------------------------------------------------------------------------
	shift:PROCESS(pre_shift_opA,pre_shift_opB,shift_unit)
	VARIABLE sticky_b			:std_logic;
	BEGIN

		sticky_b := '0';
		post_shift_opA	<=	pre_shift_opA&'0';					--A+sticky bit
		
			FOR i IN 1 TO 25 LOOP
						
				----------------------------------
				--sticky bit
				----------------------------------
				IF i<shift_unit+1	THEN 
					sticky_b:=sticky_b OR pre_shift_opB(i);			--after shifting, sticky bit become bitwiseOR of shifted bits
				END IF;
				----------------------------------
				--shift by shift_unit
				----------------------------------
				IF i+shift_unit<26	THEN 				
					post_shift_opB(i)<=pre_shift_opB(i+shift_unit);		--right shift
				ELSE
					post_shift_opB(i)<='0';					--zero padding				
				END IF;		
						
			END LOOP;
				
		post_shift_opB(0)	<=	sticky_b;					--sticky bit of B


	END PROCESS shift;


END ARCHITECTURE rtl;



