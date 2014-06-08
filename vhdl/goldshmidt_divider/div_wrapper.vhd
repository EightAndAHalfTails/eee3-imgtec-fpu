---------------------------------------------------------------------
-- div wrapper for timing analysis
---------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.div;

ENTITY div_wrapper IS
	PORT 
	(
		clk			: IN std_logic;
		
		-- div connections
		div_in1		: IN  std_logic_vector(31 downto 0);
		div_in2		: IN  std_logic_vector(31 downto 0);
		div_out		: OUT std_logic_vector(31 downto 0)
	);

END ENTITY div_wrapper;

ARCHITECTURE wrap OF div_wrapper IS
	SIGNAL in1		:  std_logic_vector(31 downto 0);
	SIGNAL in2		:  std_logic_vector(31 downto 0);
	SIGNAL out1		:  std_logic_vector(31 downto 0);
BEGIN

	design: ENTITY div
	PORT MAP(
		div_in1		=>in1,
		div_in2		=>in2,
		div_out		=>out1
	);

	r1: PROCESS
	BEGIN
		WAIT UNTIL clk'EVENT and clk = '1';
		in1 <= div_in1;
		in2 <= div_in2;
		div_out <= out1;
	END PROCESS r1;
	
END wrap;
