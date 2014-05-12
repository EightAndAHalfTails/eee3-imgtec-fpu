--------------------------------------------------------------------------------------
--addsub.vhd
--------------------------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.all;

ENTITY addsub IS 
	PORT(
		clk,reset		:	IN 		std_logic;
		opA_i			:	IN		std_logic_vector(26 downto 0);	
		opB_i			:	IN		std_logic_vector(26 downto 0);
		operation_i		:	IN		std_logic;
		prenormresult_o		:	OUT		std_logic_vector(27 downto 0)
		);

END ENTITY addsub;

ARCHITECTURE rtl OF addsub IS

ALIAS slv IS std_logic_vector;
ALIAS usg IS unsigned;
ALIAS sgn IS signed;


BEGIN
------------------------------------------------------------------
--adder_proc

--The process simply add/subtract two 27 bits number(hidden+23 mantissa+2 guard bits+1 sticky) and output 
--as a 28 bit output(with overflow)
------------------------------------------------------------------
adder_proc:PROCESS
BEGIN
	WAIT UNTIL clk'EVENT and clk='1';
		IF reset='1' THEN
				prenormresult_o<=(others=>'0');
		ELSE 
				IF	operation_i ='0' THEN
					prenormresult_o<=slv(Resize(usg(opA_i),28)+Resize(usg(opB_i),28));
				ELSE 
					prenormresult_o<=slv(Resize(usg(opA_i),28)-Resize(usg(opB_i),28));
				END IF;
		END IF;
END PROCESS adder_proc;

--to add more process (Leading Zero Anticipator)

END ARCHITECTURE rtl;
