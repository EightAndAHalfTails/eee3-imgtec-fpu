--------------------------------------------------------------------------------------
--prenorm_addsub.vhd
--------------------------------------------------------------------------------------

LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.all;

ENTITY prenorm_addsub IS 
	PORT 
	( clk,reset,mode	: IN  std_logic;
	  A_i			: IN  std_logic_vector(31 downto 0);
	  B_i			: IN  std_logic_vector(31 downto 0);
	  A_man_o,B_man_o	: OUT std_logic_vector(22 downto 0);
	  temp_exp_o		: OUT std_logic_vector(7 downto 0);
	  sign_o		: OUT std_logic;
	  eop_o			: OUT std_logic;
	  sticky_b_o		: OUT std_logic
	);
END ENTITY prenorm_addsub;

ARCHITECTURE rtl of prenorm_addsub IS

ALIAS slv IS std_logic_vector;
ALIAS usg IS unsigned;
ALIAS sgn IS signed;

SIGNAL A_si_s,B_si_s,temp_sign					:std_logic;
SIGNAL A_e_s,B_e_s,temp_expo					:slv(7 downto 0);
SIGNAL A_man_s,B_man_s,opA,opB					:slv(22 downto 0);
SIGNAL expo_diff						:slv(8 downto 0);
SIGNAL shift_unit						:usg(7 downto 0);
SIGNAL addsub_opA_st_opB,addsub_expoA_st_expoB,addsub_expoA_eq_expoB			:std_logic;
SIGNAL operation             					:std_logic;
--SIGNAL sticky_b							:std_logic;
SIGNAL pre_shift_opA,pre_shift_opB				:slv(22 downto 0);

BEGIN
A_man_o			<=	opA;
B_man_o			<=	opB;
temp_exp_o		<=	temp_expo;
sign_o			<=	temp_sign;
eop_o			<=	operation;
--sticky_b_o		<=	sticky_b;



-----------------------------------------------------------------
--unpacking
--This block is used to unpack the 32 numbers into corresponding 
--sections (sign&exponent&mantissa)
-----------------------------------------------------------------
  
	unpack:BLOCK
	BEGIN
		A_si_s	<=	A_i(31);
		A_e_s	<=	A_i(30 downto 23);
		A_man_s	<=	A_i(22 downto 0);

		B_si_s	<=	B_i(31);
		B_e_s	<=	B_i(30 downto 23);
		B_man_s	<=	B_i(22 downto 0);
	END BLOCK unpack;
------------------------------------------------------------------
--effective_op_proc

--The process computes the effective operation from the initial operator
--and sign of inputs
--{mode(add=0,sub=1)| sign of A | sign of B	=> operation(add=0,sub=1)}
--000|011|101|110=>addtion
--001|010|100|111=>subtraction
------------------------------------------------------------------
	effective_op_proc:PROCESS
	BEGIN
	WAIT UNTIL clk'EVENT AND clk='1';
		operation<=mode XOR A_si_s XOR B_si_s;				--effective operation mode
	END PROCESS effective_op_proc;
------------------------------------------------------------------
--sign_logic

--computes logic of sign bit output
--abs(A)<abs(B)=>sign to be sign of B
--abs(A)>abs(B)=>sign to be sign of A	(*************have not considered sign when abs(A)>abs(B))
------------------------------------------------------------------	
	sign_logic:PROCESS
	BEGIN
	WAIT UNTIL clk'EVENT AND clk='1';
		IF addsub_expoA_st_expoB='1'  THEN					--if exponent of A is smaller than B
			temp_sign<=B_si_s;
		ELSIF	(addsub_expoA_eq_expoB AND addsub_opA_st_opB)='1'		THEN--if exponent of A is equal to B AND mantissa of A is smaller than B
			temp_sign<=B_si_s;
		ELSE								--others
			temp_sign<=A_si_s;					
		END IF;
	END PROCESS;--NOT COMPLETED
-----------------------------------------------------------------
--exponent logic

--output exponent = MAX(exponent of A, exponent of B)
-----------------------------------------------------------------	
	expo_logic:PROCESS
	BEGIN
	WAIT UNTIL clk'EVENT AND clk='1';
		IF addsub_expoA_st_expoB='1' THEN					--if exponent of A is smaller than B
			temp_expo	<=	B_e_s;
		ELSE
			temp_expo	<=	A_e_s;
		END IF;
	END PROCESS;
	
	
--internal signal connections
	expo_diff<=slv(Resize(usg(A_e_s),9)-Resize(usg(B_e_s),9));		--exponent difference (plus one signed bit)
	--control logic block
	addsub_expoA_st_expoB<='1' WHEN usg(A_e_s)<usg(B_e_s) ELSE '0';		--flag: exponent of A< exponent of B
	addsub_expoA_eq_expoB<='1' WHEN usg(A_e_s)=usg(B_e_s) ELSE '0';		--flag:	exponent of A= exponent of B
	addsub_opA_st_opB<='1' WHEN usg(A_man_s)<usg(B_man_s) ELSE '0';		--flag: mantissa of A< mantissa of B
	--compute shift unit
	shift_unit<=usg(expo_diff(7 downto 0));					--take exponent difference as number of shifts required
-----------------------------------------------------------------
--swap process

--swap the inputs when abs(A)<abs(B)
-----------------------------------------------------------------	
	swap:PROCESS(addsub_expoA_st_expoB,addsub_opA_st_opB,addsub_expoA_eq_expoB,A_man_s,B_man_s)
	BEGIN
		IF addsub_expoA_st_expoB='1' THEN					--if exponent of A is smaller than B
			pre_shift_opA<=B_man_s;
			pre_shift_opB<=A_man_s;
				
		ELSIF (addsub_expoA_eq_expoB AND addsub_opA_st_opB)='1'	THEN--if exponent of A is equal to B AND mantissa of A is smaller than B
			pre_shift_opA<=B_man_s;
			pre_shift_opB<=A_man_s;
				
		ELSE
			pre_shift_opA<=A_man_s;
			pre_shift_opB<=B_man_s;
		END IF;
	END PROCESS swap;
-----------------------------------------------------------------
--shift process

--shift operand B by shift_unit to the right
--parallel logic for each bit
-----------------------------------------------------------------
	shift:PROCESS
	BEGIN
	WAIT UNTIL clk'EVENT AND clk='1';
		opA	<=	pre_shift_opA;					--directly connect A
		FOR i IN 0 TO 22 LOOP
			IF i+shift_unit<23	THEN 				
				opB(i)<=pre_shift_opB(i+to_integer(shift_unit));		--right shift
			ELSIF i+shift_unit=23 THEN
				opB(i)<='1';					--shift the hidden bit
			ELSE
				opB(i)<='0';					--zero padding
			END IF;
		END LOOP;
	END PROCESS shift;

--**********************************sticky bit to be considered **********
--		FOR i IN 0 TO 22 LOOP
--		IF i<shift_unit	THEN 
--		sticky_b	<=	pre_shift_opB(i) or sticky_b;
--		END IF;--NOT COMPLETED
--		END LOOP;
	

END ARCHITECTURE rtl;



