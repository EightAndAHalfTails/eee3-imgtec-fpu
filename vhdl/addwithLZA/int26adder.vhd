--------------------------------------------------------------------------------------
--int28adder.vhd
--------------------------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.all;
use work.types.all;

ENTITY int26adder IS 
	PORT(
		operation_i		:	IN		std_logic;
		opA_i			:	IN		std_logic_vector(27 downto 0);	
		opB_i			:	IN		std_logic_vector(27 downto 0);
		prenormresult_o		:	OUT		std_logic_vector(28 downto 0);
		leadingzeros		:	OUT		integer range 0 to 28
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

LZA:process(opA_i,opB_i,operation_i)	--suzuki96 leading zero anticipator
  variable A_0:  std_logic_vector(28 downto 0);
  variable B_0:  std_logic_vector(28 downto 0);
  variable f:	 std_logic_vector(28 downto 1);
  variable count:integer range 0 to 28;
BEGIN
    count:=0;
  	 A_0:='0'&opA_i;
	if operation_i='1' then
  	 B_0:=not ('0'&opB_i);
	else
  	 B_0:='0'&opB_i;
	end if;

	for i in f'HIGH downto f'LOW+1 loop
	 f(i):=(NOT (A_0(i) XOR B_0(i))) AND (A_0(i-1) or B_0(i-1));
 	 if f(i)='1' then exit;
	 else count:=count+1;
	 end if;
	end loop;
 	leadingzeros<=count;
end process LZA;
END ARCHITECTURE arch;
