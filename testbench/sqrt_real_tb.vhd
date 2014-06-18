------------------------------------------------------------------
--Testbench for floating point square root
--reads oneInput_datapak.txt for input data (IEEE 754 format)

--Input is converted to real with the float_pkg
--numbers are rounded to nearest by default and denormals are supported
--sqrt(input) is performed using the math_real library
--answer is converted back to float to compare with design result 
--to an accuracy of 4 ulps

--vhdl test entity: sqrt_real
--author: Weng Lio
--version: 04/06/2014
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.float_pkg.ALL;		--ieee floating point package
use ieee.math_real.all; --real data type
USE std.textio.ALL;
USE work.tb_lib.all;

ENTITY sqrt_tb IS
	GENERIC ( ulp : INTEGER := 4 );
END sqrt_tb;

ARCHITECTURE tb OF sqrt_tb IS
	SIGNAL clk, reset: STD_LOGIC;
	SIGNAL input, result: STD_LOGIC_VECTOR(31 DOWNTO 0);

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
		sqrt_in1		=>input,
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
		VARIABLE x_real		: REAL;
		VARIABLE sqrt_x 	: FLOAT32;
		VARIABLE sqrt_l, sqrt_r	: FLOAT32;
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
				
				input<=to_slv(x);
				
				----------------------------------------------------------------------
				-- calculate square root of x (exception with -0)
				IF to_slv(x) = NZERO_slv THEN
					sqrt_x := NZERO_F;
				ELSIF isnan(x) or x < PZERO_F THEN
				  sqrt_x := PNAN_F;
				ELSIF x = PINFINITY_F THEN
				  sqrt_x := PINFINITY_F;
				ELSE
					x_real := to_real(x);
					sqrt_x := to_float(sqrt(x_real));
				END IF;
				
				----------------------------------------------------------------------
				-- check sqrt_x for zeros, infinities or NaNs
				-- else find left and right boundaries of sqrt_x (4 ulps)
				getRightLeftBound(sqrt_x, ulp, sqrt_r, sqrt_l);
				
				WAIT UNTIL clk'EVENT AND clk = '1';
				--REPORT "result from test entity is " & to_string(to_float(result));
				----------------------------------------------------------------------
				--check result
				IF isnan(sqrt_x) THEN
				  IF not(isnan(to_float(result))) THEN
				    incorrect_result := incorrect_result+1;
					   REPORT "Square root of " & to_string(x) & " gives " &to_string(to_float(result)) & 
							" which is incorrect. Correct answer is NaN" SEVERITY warning;
					END IF;
				ELSIF not((to_float(result) <= sqrt_r) AND (to_float(result) >= sqrt_l)) THEN
					incorrect_result := incorrect_result+1;
					REPORT "Square root of " & to_string(x) & " gives " &to_string(to_float(result)) & 
							" which is incorrect. Correct answer is  " & to_string(sqrt_x)SEVERITY warning;
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