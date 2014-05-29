------------------------------------------------------------------
--Testbench for floating point divider
--reads twoInput_datapak.txt for input data (IEEE 754 format)
--use IEEE floating point package to calculate reference result

--vhdl test entity: div
--author: Weng Lio
--version: 27/05/2014
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.float_pkg.ALL;		--ieee floating point package
use ieee.fixed_float_types.all;
use ieee.fixed_pkg.all;
USE std.textio.ALL;

ENTITY div_tb IS
END div_tb;

ARCHITECTURE tb OF div_tb IS

	SIGNAL clk, reset: STD_LOGIC;
	SIGNAL A, B, result: STD_LOGIC_VECTOR(31 DOWNTO 0);

	ALIAS slv IS std_logic_vector;
	
	CONSTANT INFINITY: slv := "01111111100000000000000000000000";
	
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
	div: ENTITY work.div
	PORT MAP(
		div_in1		=>A,
		div_in2		=>B,
		div_out		=>result
	);

	------------------------------------------------------------
	-- main process reads lines from "twoInput_datapak.txt"
	-- each line consists of 2 fp numbers to be added
	-- check sum of these numbers with output of test entity
	------------------------------------------------------------
	main: PROCESS
		FILE f				: TEXT OPEN read_mode IS "twoInput_datapak.txt";
		VARIABLE buf		: LINE;
		VARIABLE x, y, z    : FLOAT32;
		VARIABLE four_ulps	: FLOAT32;
		VARIABLE max_z		: slv(31 DOWNTO 0);
		VARIABLE exponent	: unsigned(8 DOWNTO 0);
		VARIABLE mantissa	: unsigned(24 DOWNTO 0); --25 bits for overflow
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
				read(buf, y);
				
				A<=to_slv(x);
				B<=to_slv(y);
				
				z := x/y;
				
				----------------------------------------------------------------------
				-- TODO: check z for infinity, NaNs
				----------------------------------------------------------------------
				exponent := '0'& unsigned(z(7 DOWNTO 0));
				mantissa := unsigned("01" & z(-1 DOWNTO -23)) + to_unsigned(4, 25);
				
				--if mantissa overflow, increment exponent
				IF mantissa(24) = '1' THEN
					exponent := exponent + to_unsigned(1, 9);
					max_z := slv(z(8)&exponent(7 DOWNTO 0)&mantissa(22 DOWNTO 0));
					
					--if exp overflow then max is infinity
					IF exponent(8) = '1' THEN
						max_z := INFINITY;
					END IF;
				ELSE
					max_z := slv(z(8)&exponent(7 DOWNTO 0)&mantissa(22 DOWNTO 0));
				END IF;
				
				--magnitude of 4 ulps
				four_ulps := to_float(max_z) - z;
				
				WAIT UNTIL clk'EVENT AND clk = '1';

				IF (z-to_float(result)) > four_ulps OR (to_float(result)-z) > four_ulps THEN
					incorrect_result := incorrect_result+1;
					REPORT to_string(x) & "/" & to_string(y) & "is " & to_string(to_float(result)) &
						". Correct answer should be " & to_string(z) SEVERITY warning;
				ELSIF result /= to_slv(z) THEN
					REPORT "Result ok(?)" & to_string(x) & "/" & to_string(y) & "is " & to_string(to_float(result)) &
						". Correct answer should be " & to_string(z) SEVERITY note;
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