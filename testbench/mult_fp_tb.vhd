------------------------------------------------------------------
--Testbench for floating point multiplier
--reads datapak.txt for input data
--use IEEE floating point package to calculate reference result

--vhdl test entity: mult
--author: Weng Lio
--version: 13/05/2014
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.float_pkg.ALL;		--ieee floating point package
use ieee.fixed_float_types.all;
use ieee.fixed_pkg.all;
USE std.textio.ALL;

ENTITY mult_tb IS
END mult_tb;

ARCHITECTURE tb OF mult_tb IS

	SIGNAL clk, reset: STD_LOGIC;
	SIGNAL A, B, result: STD_LOGIC_VECTOR(31 DOWNTO 0);

	ALIAS slv IS std_logic_vector;
	
	FUNCTION v2i( x : STD_LOGIC_VECTOR) RETURN INTEGER IS
	BEGIN
		RETURN to_integer(SIGNED(x));
	END;
   
 	FUNCTION i2v( x : INTEGER) RETURN STD_LOGIC_VECTOR IS
	BEGIN
		RETURN slv(to_signed(x, 32));
	END;
	
BEGIN

	-- clock generation process
	clkgen: PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR 50 ns;
		clk <= '1';
		WAIT FOR 50 ns;
	END PROCESS clkgen;

	-- test entity
	mult: ENTITY work.mult
	PORT MAP(
		mult_in1		=>A,
		mult_in2		=>B,
		mult_out=>result
	);

	------------------------------------------------------------
	-- main process reads lines from "twoInput_datapak.txt"
	-- each line consists of 2 fp numbers to be added
	-- check sum of these numbers with output of test entity
	------------------------------------------------------------
	main: PROCESS
		FILE f				: TEXT OPEN read_mode IS "twoInput_datapak.txt";
		VARIABLE buf		: LINE;
		VARIABLE x, y       : FLOAT32;
		VARIABLE i1, i2     : INTEGER;
		VARIABLE n          : INTEGER;		--line counter
		VARIABLE incorrect_result : INTEGER;
	
	BEGIN
		reset <= '1';
		WAIT UNTIL clk'EVENT and clk = '1';
		reset <= '0';
		
		n := 1;
		incorrect_result := 0;
		
		WHILE NOT endfile(f) LOOP
			WAIT UNTIL clk'EVENT and clk = '1';
			readline(f, buf);
			If buf'LENGTH = 0 THEN
				REPORT "skipping line: " & INTEGER'IMAGE(n) SEVERITY note;
			ELSE
				REPORT "Reading input line:" & INTEGER'IMAGE(n) SEVERITY note;
				
				-------------------------------------------------------------
				-- note: x and y from file must be in binary
				-------------------------------------------------------------
				read(buf, x);
				read(buf, y);
				
				A<=to_slv(x);
				B<=to_slv(y);
				
				WAIT UNTIL clk'EVENT AND clk = '1';
				IF result /= (to_slv(x*y)) THEN
					incorrect_result := incorrect_result+1;
					REPORT to_string(x) & "*" & to_string(y) & "is " & to_string(to_float(result)) &
						". Correct answer should be " & to_string(x*y) SEVERITY warning;
				END IF;
				
			END IF;	
			
			n := n+1;
		END LOOP;
	
	IF incorrect_result = 0 THEN
		REPORT "***************** TEST PASSED *****************";
	ELSE
		REPORT "***************** TEST FAILED, number of incorrect results = " & INTEGER'IMAGE(incorrect_result);
	END IF;
	
	REPORT "Test finished normally." SEVERITY failure;
	END PROCESS main;
	
END tb; 