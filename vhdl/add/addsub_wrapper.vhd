---------------------------------------------------------------------
-- addsub wrapper for timing analysis
---------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.addsub;

ENTITY addsub_wrapper IS
	PORT 
	(
		clk			: IN std_logic;
		
		-- addsub connections
		add_in1		: IN  std_logic_vector(31 downto 0);
		add_in2		: IN  std_logic_vector(31 downto 0);
		operation_i		: IN  std_logic;
		add_out		: OUT std_logic_vector(31 downto 0)
	);

END ENTITY addsub_wrapper;

ARCHITECTURE wrap OF addsub_wrapper IS
	SIGNAL in1		:  std_logic_vector(31 downto 0);
	SIGNAL in2		:  std_logic_vector(31 downto 0);
	SIGNAL op		:  std_logic;
	SIGNAL out1		:  std_logic_vector(31 downto 0);
BEGIN

	design: ENTITY addsub
	PORT MAP(
		add_in1		=>in1,
		add_in2		=>in2,
		operation_i =>op,
		add_out		=>out1
	);

	r1: PROCESS
	BEGIN
		WAIT UNTIL clk'EVENT and clk = '1';
		in1 <= add_in1;
		in2 <= add_in2;
		op <= operation_i;
		add_out <= out1;
	END PROCESS r1;
	
END wrap;
