------------------------------------------------------------------
--Testbench for floating point inverse square root
--reads oneInput_datapak.txt for input data (IEEE 754 format)

--Input is converted to real with the float_pkg
--numbers are rounded to nearest by default and denormals are supported
--1/sqrt(input) is performed using the math_real library
--answer is converted back to float to compare with design result 
--to an accuracy of 4 ulps

--vhdl test entity: isqrt
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

ENTITY isqrt_tb IS
	GENERIC( ulp : INTEGER := 4);
END isqrt_tb;

ARCHITECTURE tb OF isqrt_tb IS
	SIGNAL clk, reset, start, done: STD_LOGIC;
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
	isqrt_test: ENTITY work.isqrt
	PORT MAP(
		isqrt_in1		=>input,
		isqrt_out		=>result,
		clk				=>clk,
		reset			=>reset,
		start			=>start,
		done			=>done
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
		VARIABLE isqrt_x 	: FLOAT32;
		VARIABLE isqrt_l, isqrt_r	: FLOAT32;
		VARIABLE exponent_l, exponent_r	: unsigned(8 DOWNTO 0);
		VARIABLE mantissa_l, mantissa_r	: unsigned(24 DOWNTO 0); --25 bits for overflow, left and right bound error interval
		VARIABLE temp   	:unsigned(22 DOWNTO 0); --temp mantissa of isqrt_x
		VARIABLE n          : INTEGER;		--line counter
		VARIABLE incorrect_result : INTEGER;
	
	BEGIN
		reset <= '1';
		start <= '0';
		WAIT UNTIL clk'EVENT and clk = '1';
		reset <= '0';
		
		n := 1;
		incorrect_result := 0;
		
	  WAIT UNTIL clk'EVENT and clk = '1';		
		WHILE NOT endfile(f) LOOP
			readline(f, buf);
			If buf'LENGTH = 0 THEN
				REPORT "skipping line: " & INTEGER'IMAGE(n) SEVERITY note;
			ELSE
				REPORT "Reading input line:" & INTEGER'IMAGE(n) SEVERITY note;
				
				read(buf, x);
				
				input<=to_slv(x);
				start<='1';
				----------------------------------------------------------------------
				-- calculate square root of x (exception with -0)
				IF isnan(x) or (x(8) = '1' and x /= NZERO_F) THEN
					isqrt_x := PNAN_F;
				ELSE
					CASE x IS
						WHEN NINFINITY_F => isqrt_x := PNAN_F;
						WHEN PZERO_F =>	isqrt_x := to_float(PINFINITY_slv);
						WHEN NZERO_F => isqrt_x := to_float(NINFINITY_slv);
						WHEN OTHERS =>	x_real := to_real(x);
										isqrt_x := to_float(1.0/sqrt(x_real));
					END CASE;
				END IF;
				----------------------------------------------------------------------
				-- check sqrt_x for zeros, infinities or NaNs
				-- else find left and right boundaries of sqrt_x (4 ulps)
				getRightLeftBound(isqrt_x, ulp, isqrt_r, isqrt_l);
				
				WAIT UNTIL done = '1';
				--WAIT UNTIL clk'EVENT AND clk = '1';
				----------------------------------------------------------------------
				--check result
				REPORT "Result is " & to_string(result);
				REPORT "isqrt_l = " & to_string(isqrt_l);
				REPORT "isqrt_r = " & to_string(isqrt_r);
				IF isnan(isqrt_x) THEN
					IF not(isnan(to_float(result))) THEN
						incorrect_result := incorrect_result+1;
						REPORT "Inverse square root of " & to_string(x) & "gives " &to_string(to_float(result)) & 
							" which is incorrect. Correct answer is NAN" SEVERITY warning;
					END IF;
				ELSE
					IF not ((to_float(result) <= isqrt_r) and (to_float(result) >= isqrt_l)) THEN
						incorrect_result := incorrect_result+1;
						REPORT "Inverse square root of " & to_string(x) & "gives " &to_string(to_float(result)) & 
								" which is incorrect. Correct answer is  " & to_string(isqrt_x)SEVERITY warning;
					END IF;
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