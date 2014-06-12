------------------------------------------------------------------
--Testbench for floating point square root
--reads oneInput_datapak.txt for input data (IEEE 754 format)

--THIS IS A NAIVE TEST AND WILL FAIL IN SOME SCENARIO
--Result from the test entity is squared and check against the 
--input number

--vhdl test entity: sqrt
--author: Weng Lio
--version: 02/06/2014
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.float_pkg.ALL;		--ieee floating point package
USE work.tb_lib.all;
USE std.textio.ALL;

ENTITY sqrt_tb IS
END sqrt_tb;

ARCHITECTURE tb OF sqrt_tb IS
	SIGNAL clk, reset: STD_LOGIC;
	SIGNAL A, result: STD_LOGIC_VECTOR(31 DOWNTO 0);

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
	sqrt_test: ENTITY work.sqrt
	PORT MAP(
		sqrt_in1		=>A,
		sqrt_out		=>result
	);

	------------------------------------------------------------
	-- main process reads lines from "oneInput_datapak.txt"
	-- each line consist of one fp number to be square-rooted
	------------------------------------------------------------
	main: PROCESS
		FILE f				: TEXT OPEN read_mode IS "oneInput_datapak.txt";
		VARIABLE buf		: LINE;
		VARIABLE x	 		: FLOAT32; 
		VARIABLE square_result : FLOAT32;
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
				
				read(buf, x);
				
				A<=to_slv(x);
				
				WAIT UNTIL clk'EVENT AND clk = '1';
				----------------------------------------------------------------------
				-- calculate square of result (exception with -1)
				IF x = NEG_ONE_F THEN
					square_result := NEG_ONE_F;
				ELSE
					square_result := to_float(result)* to_float(result);
				END IF;
				----------------------------------------------------------------------
				--check square of result with input x
				IF square_result /= x THEN
					incorrect_result := incorrect_result+1;
					REPORT "Sqaure root of " & to_string(x) & "gives " &to_string(to_float(result)) & 
							" which is incorrect" SEVERITY warning;
					REPORT "since square of " & to_string(to_float(result)) & " is " & to_string(square_result);
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