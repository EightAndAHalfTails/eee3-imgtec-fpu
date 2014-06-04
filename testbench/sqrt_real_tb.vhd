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
use ieee.fixed_float_types.all;
use ieee.fixed_pkg.all;
use ieee.math_real.all; --real data type
USE std.textio.ALL;

ENTITY sqrt_tb IS
END sqrt_tb;

ARCHITECTURE tb OF sqrt_tb IS

	SIGNAL clk, reset: STD_LOGIC;
	SIGNAL input, result: STD_LOGIC_VECTOR(31 DOWNTO 0);

	ALIAS slv IS std_logic_vector;
	--------------------------------------------------------------
	--TODO: switch to package constants
	CONSTANT NEG_ONE: FLOAT32 := "10111111100000000000000000000000";
	CONSTANT PINFINITY	: slv := "01111111100000000000000000000000";
	CONSTANT NINFINITY	: slv := "11111111100000000000000000000000";
	CONSTANT PZERO		: slv := "00000000000000000000000000000000";
	CONSTANT NZERO		: slv := "10000000000000000000000000000000";
	
	FUNCTION v2i( x : STD_LOGIC_VECTOR) RETURN INTEGER IS
	BEGIN
		RETURN to_integer(SIGNED(x));
	END;
   
 	FUNCTION i2v( x : INTEGER) RETURN STD_LOGIC_VECTOR IS
	BEGIN
		RETURN slv(to_signed(x, 32));
	END;
	
	FUNCTION iszero(x:FLOAT32) RETURN BOOLEAN IS
	BEGIN
		RETURN (x=zerofp or x = neg_zerofp);
	END;
	
	FUNCTION isfinite(x:FLOAT32) RETURN BOOLEAN IS
	BEGIN
		RETURN (x/=pos_inffp or x/=neg_inffp);
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
		VARIABLE sqrt_l, sqrt_r	: slv(31 DOWNTO 0);
		VARIABLE exponent_l, exponent_r	: unsigned(8 DOWNTO 0);
		VARIABLE mantissa_l, mantissa_r	: unsigned(24 DOWNTO 0); --25 bits for overflow, left and right bound error interval
		VARIABLE temp   	:unsigned(22 DOWNTO 0); --temp mantissa of sqrt_x
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
				-- calculate square root of x (exception with -1)
				IF x = NEG_ONE THEN
					sqrt_x := NEG_ONE;
				ELSE
					x_real := to_real(x);
					sqrt_x := to_float(sqrt(x_real));
				END IF;
				
				----------------------------------------------------------------------
				-- check sqrt_x for zeros, infinities or NaNs
				-- else find left and right boundaries of sqrt_x (4 ulps)
				IF (not(isfinite(sqrt_x))) or iszero(sqrt_x) or isnan(sqrt_x) THEN
					REPORT "sqrt_x is not normal number";
					sqrt_l := to_slv(sqrt_x);
					sqrt_r := to_slv(sqrt_x);
				ELSE
					exponent_r := '0'& unsigned(sqrt_x(7 DOWNTO 0));
					exponent_l := '0'& unsigned(sqrt_x(7 DOWNTO 0));				
					temp:=unsigned(sqrt_x(-1 DOWNTO -23));
					
					-- if sqrt_x is positive, then sqrt_r is greater than sqrt_x and sqrt_l is smaller than sqrt_x
					IF sqrt_x(8) = '0' THEN  
						mantissa_r := unsigned("01" & temp) + to_unsigned(4, 25);
						mantissa_l := unsigned("01" & temp) - to_unsigned(4, 25);
						
						-- find sqrt_r
						-- if mantissa overflow, increment exp
						-- check if exponent overflow
						IF mantissa_r(24) = '1' THEN
							exponent_r := exponent_r + to_unsigned(1, 9);
							
							IF exponent_r(8) = '1' THEN
								sqrt_r := PINFINITY;
							ELSE
								sqrt_r := slv('0'&exponent_r(7 DOWNTO 0) & mantissa_r(23 DOWNTO 1));
							END IF;
						ELSE
							sqrt_r := slv('0'&exponent_r(7 DOWNTO 0) &  mantissa_r(22 DOWNTO 0));
						END IF;
						
						-- find sqrt_l
						-- if mantissa underflow, decrement exponent
						-- if sqrt_x is denormal and mantissa underflow, sqrt_l will be set to positive zero
						IF mantissa_l(23) = '0' THEN
							IF exponent_l = "00000000" THEN
								sqrt_l := PZERO;
							ELSE
								exponent_l := exponent_l - to_unsigned(1,9);
								sqrt_l := slv('0' & exponent_l(7 DOWNTO 0) & mantissa_l(21 DOWNTO 0) & '0');
							END IF;
						ELSE
							sqrt_l := slv('0' & exponent_l(7 DOWNTO 0) & mantissa_l(22 DOWNTO 0));
						END IF;	
						
					ELSE 
					-- if sqrt_x is negative, then sqrt_r is less negative than sqrt_x and sqrt_l is more negative than sqrt_x
						mantissa_r := unsigned("01" & temp) - to_unsigned(4, 25);
						mantissa_l := unsigned("01" & temp) + to_unsigned(4, 25);
						
						-- find sqrt_r
						IF mantissa_r(23) = '0' THEN
							IF exponent_r = "00000000" THEN
								sqrt_r := NZERO;
							ELSE
								exponent_r := exponent_r - to_unsigned(1,9);
								sqrt_r := slv('1' & exponent_r(7 DOWNTO 0) & mantissa_r(21 DOWNTO 0) & '0');
							END IF;
						ELSE 
							sqrt_r := slv('1' & exponent_r(7 DOWNTO 0) & mantissa_r(22 DOWNTO 0));
						END IF;
						
						-- find sqrt_l
						IF mantissa_l(24) = '1' THEN
							exponent_l := exponent_l + to_unsigned(1, 9);
							
							IF exponent_l(8) = '1' THEN
								sqrt_l := NINFINITY;
							ELSE
								sqrt_l := slv('1'&exponent_l(7 DOWNTO 0) & mantissa_l(23 DOWNTO 1));
							END IF;
						ELSE
							sqrt_l := slv('1'&exponent_l(7 DOWNTO 0) &  mantissa_l(22 DOWNTO 0));
						END IF;
						
					END IF;
				END IF;
				
				WAIT UNTIL clk'EVENT AND clk = '1';
				----------------------------------------------------------------------
				--check result
				IF (to_float(result) > to_float(sqrt_r)) OR (to_float(result) < to_float(sqrt_l)) THEN
					incorrect_result := incorrect_result+1;
					REPORT "Square root of " & to_string(x) & "gives " &to_string(to_float(result)) & 
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