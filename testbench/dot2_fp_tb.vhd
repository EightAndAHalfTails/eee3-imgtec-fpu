------------------------------------------------------------------
--Testbench for floating point 2D dot product
--reads fourInput_datapak.txt for input data (IEEE 754 format)

--Input is converted to real with the float_pkg
--numbers are rounded to nearest by default and denormals are supported
--ab+cd is performed using the math_real library
--answer is converted back to float to compare with design result 
--accuracy no worse than chaining

--vhdl test entity: dot2
--author: Weng Lio
--version: 11/06/2014
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.float_pkg.ALL;		--ieee floating point package
use ieee.math_real.all; --real data type
USE std.textio.ALL;
USE work.tb_lib;

ENTITY dot2_tb IS
END dot2_tb;

ARCHITECTURE tb OF dot2_tb IS
	SIGNAL clk, reset: STD_LOGIC;
	SIGNAL a,b,c,d, result: STD_LOGIC_VECTOR(31 DOWNTO 0);	

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
	dot2_test: ENTITY work.dot2
	PORT MAP(
		dot2_in1		=>a,
		dot2_in2		=>b,
		dot2_in3		=>c,
		dot2_in4		=>d,
		dot2_out		=>result
	);

	------------------------------------------------------------
	-- main process reads lines from "fourInput_datapak.txt"
	-- each line consist of one fp number to be square-rooted
	------------------------------------------------------------
	main: PROCESS
		FILE f				: TEXT OPEN read_mode IS "fourInput_datapak.txt";
		VARIABLE buf		: LINE;
		VARIABLE p,q,r,s	: FLOAT32; 
		VARIABLE result_tb 	: FLOAT32;
		VARIABLE result_chained	:FLOAT32;
		
		VARIABLE nan1, nan2	: REAL;
		VARIABLE nan_result : FLOAT32;
		
		--VARIABLE dot2_l, dot2_r	: slv(31 DOWNTO 0);
		--VARIABLE exponent_l, exponent_r	: unsigned(8 DOWNTO 0);
		--VARIABLE mantissa_l, mantissa_r	: unsigned(24 DOWNTO 0); --25 bits for overflow, left and right bound error interval
		VARIABLE temp   	:unsigned(22 DOWNTO 0); --temp mantissa of dot2_x
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
				
				read(buf, p);
				read(buf, q);
				read(buf, r);
				read(buf, s);
				
				a<=to_slv(p);
				b<=to_slv(q);
				c<=to_slv(r);
				d<=to_slv(s);
				
				--calculate chained result
				result_chained := (p*q)+(r*s);
				
				--calculate result_tb using real package
				result_tb := to_float((to_real(p)*to_real(q))+(to_real(r)*to_real(s)));

				--------------------------------------------------------------
				-- check if overflow
				IF slv(result_tb(7 DOWNTO 0)) = "11111111" THEN
					result_tb := to_float(slv(result_tb(8 DOWNTO 0)) & "00000000000000000000000");
				END IF;
				
				WAIT UNTIL clk'EVENT AND clk = '1';
				----------------------------------------------------------------------
				--check result
				REPORT "result_chained = " & to_string(result_chained);
				REPORT "result real = " & to_string(result_tb);
				IF result/=to_slv(result_tb) THEN
					incorrect_result := incorrect_result+1;
					REPORT "2D dot product of " & to_string(p) & ", " & to_string(q) &", "& to_string(r) &" and "& to_string(s)
							& "gives " &to_string(to_float(result)) & " which is incorrect. Correct answer is  " & to_string(result_tb)SEVERITY warning;
				END IF;
				
			END IF;	
			
			n := n+1;
		END LOOP;
	nan_result := NNAN_F+PNAN_F;
	--------****************TEST*****************
	REPORT "ignore this: testing NaN as real numbers" & to_string(nan_result) SEVERITY warning;
	IF incorrect_result = 0 THEN
		REPORT "***************** TEST PASSED *****************";
	ELSE
		REPORT "***************** TEST FAILED, number of incorrect results = " & INTEGER'IMAGE(incorrect_result);
	END IF;
	
	REPORT "Test finished normally." SEVERITY failure;
	END PROCESS main;
	
END tb; 