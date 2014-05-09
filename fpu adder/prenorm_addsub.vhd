--------------------------------------------------------------------------------------
--prenorm_addsub.vhd
--Author: ZIFAN GUO
--------------------------------------------------------------------------------------

LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.all;

ENTITY prenorm_addsub IS 
	PORT 
	( clk,reset,mode	: IN  std_logic;
	  A_i				: IN  std_logic_vector(31 downto 0);
	  B_i				: IN  std_logic_vector(31 downto 0);
	  A_man_o,B_man_o	: OUT std_logic_vector(22 downto 0);
	  temp_exp_o		: OUT std_logic_vector(7 downto 0);
	  sign_o			: OUT std_logic;
	  eop_o				: OUT std_logic;
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
SIGNAL expo_diff						        :slv(8 downto 0);
SIGNAL shift_unit						        :usg(7 downto 0);
SIGNAL addsub_opA_st_opB,addsub_expoA_st_expoB	:std_logic;
SIGNAL operation             					:std_logic;
SIGNAL sticky_b									:std_logic;

BEGIN

A_man_o			<=	opA;
B_man_o			<=	opB;
temp_exp_o		<=	temp_expo;
sign_o			<=	temp_sign;
eop_o			<=	operation;
sticky_b_o		<=	sticky_b;
-----------------------------------------------------------------
--unpacking
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
--determines effective operation(+/-)
------------------------------------------------------------------
	effective_op_proc:PROCESS
	BEGIN
	WAIT UNTIL clk'EVENT AND clk='1';
		operation<=mode XOR A_si_s XOR B_si_s;				--effective operation mode
	END PROCESS effective_op_proc;
------------------------------------------------------------------
--determines sign of result
------------------------------------------------------------------	
	sign_logic:PROCESS
	BEGIN
	WAIT UNTIL clk'EVENT AND clk='1';
		IF addsub_expoA_st_expoB OR addsub_opA_st_opB THEN
			temp_sign<=A_si_s;
		ELSE
			temp_sign<=B_si_s;
		END IF;
	END PROCESS;
-----------------------------------------------------------------
--exponent logic
-----------------------------------------------------------------	
	expo_logic:PROCESS
	BEGIN
	WAIT UNTIL clk'EVENT AND clk='1';
		IF addsub_expoA_st_expoB='0' THEN
			temp_expo	<=	A_e_s;
		ELSE	
			temp_expo	<=	B_e_s;
		END IF;
	END PROCESS;
	
	
	--internal signal connections
	expo_diff<=slv(Resize(usg(A_e_s),9)-Resize(usg(B_e_s),9));
	addsub_expoA_st_expoB<=expo_diff(8);
	shift_unit<=usg(expo_diff(7 downto 0));
	
	compare_operand:PROCESS(A_man_s,B_man_s)
	 BEGIN
		addsub_opA_eq_opB<='0';
			IF usg(A_man_s)<usg(B_man_s) THEN
				addsub_opA_st_opB<='1';
			ELSE	
				IF usg(A_man_s)=usg(B_man_s) THEN
					addsub_opA_eq_opB<='1';
				END IF;
				addsub_opA_st_opB<='0';
			END IF;
	 END PROCESS;
	 

	
	swap:PROCESS
	VARIABLE pre_shift_opA,pre_shift_opB	:	slv(22 downto 0):=(others=>'0');
	BEGIN
	WAIT UNTIL clk'EVENT AND clk='1';
		
			IF addsub_expoA_st_expoB='1' THEN
				pre_shift_opA:=B_man_s;
				pre_shift_opB:=A_man_s;
				
			ELSIF addsub_opA_st_opB='1'
				pre_shift_opA:=B_man_s;
				pre_shift_opB:=A_man_s;
				
			ELSE
				pre_shift_opA:=A_man_s;
				pre_shift_opB:=B_man_s;
				
			ELSE
			END IF;
			
		opA	<=	pre_shift_opA;
		
		FOR i IN 0 TO 22 LOOP
			IF i+shift_unit<23	THEN 
				opB(i)<=pre_shift_opB(i+shift_unit);
			ELSIF i+shift_unit=23 THEN
				opB(i)<='1';
			ELSE
				opB(i)<='0';
			END IF;
		END LOOP;
		
		FOR i IN 0 TO 22 LOOP
		IF i<shift_unit	THEN 
		sticky_b	:=	pre_shift_opB(i) or sticky_b;
		END IF;
	END LOOP;
	END PROCESS	swap;

END ARCHITECTURE rtl;