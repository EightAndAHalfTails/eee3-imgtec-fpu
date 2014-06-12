---------------------------------------------------------------------
-- mult wrapper for timing analysis
---------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.mult;

ENTITY mult_wrapper IS
	PORT 
	(
		clk			: IN std_logic;
		
		-- mult connections
		mult_in1		: IN  std_logic_vector(31 downto 0);
		mult_in2		: IN  std_logic_vector(31 downto 0);
		mult_out		: OUT std_logic_vector(31 downto 0)
	);

END ENTITY mult_wrapper;

ARCHITECTURE wrap OF mult_wrapper IS
	SIGNAL in1		:  std_logic_vector(31 downto 0);
	SIGNAL in2		:  std_logic_vector(31 downto 0);
	SIGNAL out1		:  std_logic_vector(31 downto 0);
BEGIN

	design: ENTITY mult
	PORT MAP(
		mult_in1		=>in1,
		mult_in2		=>in2,
		mult_out		=>out1
	);

	r1: PROCESS
	BEGIN
		WAIT UNTIL clk'EVENT and clk = '1';
		in1 <= mult_in1;
		in2 <= mult_in2;
		mult_out <= out1;
	END PROCESS r1;
	
END wrap;
