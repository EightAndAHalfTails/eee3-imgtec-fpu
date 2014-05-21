--------------------------------------------------------------------------------------
--int28adder.vhd
--------------------------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.all;
USE config_pack.all;

ENTITY int26adder IS 
	PORT(
		operation_i		:	IN		std_logic;
		opA_i			:	IN		std_logic_vector(27 downto 0);	
		opB_i			:	IN		std_logic_vector(27 downto 0);
		prenormresult_o		:	OUT		std_logic_vector(28 downto 0)
		);

END ENTITY int26adder;

ARCHITECTURE arch OF int26adder IS


BEGIN
--------------------------------------------------------------------------------------
--adder_proc
--The process simply add/subtract two 26 bits number output with carry
--------------------------------------------------------------------------------------
adder_proc:PROCESS(opA_i,opB_i,operation_i)
BEGIN
	IF	operation_i ='0' THEN
		prenormresult_o<=slv(Resize(usg(opA_i),29)+Resize(usg(opB_i),29));
	ELSE 
		prenormresult_o<=slv(Resize(usg(opA_i),29)-Resize(usg(opB_i),29));
	END IF;

END PROCESS adder_proc;


END ARCHITECTURE arch;
