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
USE std.textio.ALL;
USE work.txt_util.ALL;
USE work.tb_lib.all;
USE work.ALL;

ENTITY div_tb IS
	GENERIC( ulp : INTEGER := 1);
END div_tb;

ARCHITECTURE tb OF div_tb IS
	SIGNAL clk, reset: STD_LOGIC;
	SIGNAL A, B, result: STD_LOGIC_VECTOR(31 DOWNTO 0);
	
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
		FILE fout			: TEXT OPEN write_mode IS "div_output.txt";
		VARIABLE buf		: LINE;
		VARIABLE x, y, z    : FLOAT32;	-- z = x/y
		VARIABLE z_l, z_r	: slv(31 DOWNTO 0);	--left and right bound of z
		VARIABLE exponent_l, exponent_r	: unsigned(8 DOWNTO 0);
		VARIABLE mantissa_l, mantissa_r	: unsigned(24 DOWNTO 0); --25 bits for overflow, left and right bound for z error interval
		VARIABLE n          : INTEGER;		--line counter
		VARIABLE incorrect_result : INTEGER;
		VARIABLE temp   :unsigned(22 DOWNTO 0); --temp mantissa of z

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
				
				----------------------------------------------------------------------
				-- check if divide by zero and numerator is not NaN
				IF iszero(y) and (not(isnan(x))) and (not(iszero(x))) THEN
					IF (x(8) xor y(8)) = '0' THEN
						z := pos_inffp;
					ELSE
						z := neg_inffp;
					END IF;
				ELSE
					z := x/y;
				END IF;

				----------------------------------------------------------------------
				-- check z for zeros, infinities or NaNs
				-- else find left and right boundaries of z (4 ulps)
				IF (not(isfinite(z))) or iszero(z) or isnan(z) THEN
					--REPORT "z is not normal";
					z_l := to_slv(z);
					z_r := to_slv(z);
				ELSE
					exponent_r := '0'& unsigned(z(7 DOWNTO 0));
					exponent_l := '0'& unsigned(z(7 DOWNTO 0));				
					temp:=unsigned(to_slv(z(-1 DOWNTO -23)));
					
					-- if z is positive, then z_r is greater than z and z_l is smaller than z
					IF z(8) = '0' THEN  
						mantissa_r := unsigned("01" & temp) + to_unsigned(ulp, 25);
						mantissa_l := unsigned("01" & temp) - to_unsigned(ulp, 25);
						
						-- find z_r
						-- if mantissa overflow, increment exp
						-- check if exponent overflow
						IF mantissa_r(24) = '1' THEN
							exponent_r := exponent_r + to_unsigned(1, 9);
							
							IF exponent_r(8) = '1' THEN
								z_r := PINFINITY_slv;
							ELSE
								z_r := slv('0'&exponent_r(7 DOWNTO 0) & mantissa_r(23 DOWNTO 1));
							END IF;
						ELSE
							z_r := slv('0'&exponent_r(7 DOWNTO 0) &  mantissa_r(22 DOWNTO 0));
						END IF;
						
						-- find z_l
						-- if mantissa underflow, decrement exponent
						-- if z is denormal and mantissa underflow, z_l will be set to positive zero
						IF mantissa_l(23) = '0' THEN
							IF exponent_l = "00000000" THEN
								z_l := PZERO_slv;
							ELSE
								exponent_l := exponent_l - to_unsigned(1,9);
								z_l := slv('0' & exponent_l(7 DOWNTO 0) & mantissa_l(21 DOWNTO 0) & '0');
							END IF;
						ELSE
							z_l := slv('0' & exponent_l(7 DOWNTO 0) & mantissa_l(22 DOWNTO 0));
						END IF;	
						
					ELSE 
					-- if z is negative, then z_r is less negative than z and z_l is more negative than z
						mantissa_r := unsigned("01" & temp) - to_unsigned(ulp, 25);
						mantissa_l := unsigned("01" & temp) + to_unsigned(ulp, 25);
						
						-- find z_r
						IF mantissa_r(23) = '0' THEN
							IF exponent_r = "00000000" THEN
								z_r := NZERO_slv;
							ELSE
								exponent_r := exponent_r - to_unsigned(1,9);
								z_r := slv('1' & exponent_r(7 DOWNTO 0) & mantissa_r(21 DOWNTO 0) & '0');
							END IF;
						ELSE 
							z_r := slv('1' & exponent_r(7 DOWNTO 0) & mantissa_r(22 DOWNTO 0));
						END IF;
						
						-- find z_l
						IF mantissa_l(24) = '1' THEN
							exponent_l := exponent_l + to_unsigned(1, 9);
							
							IF exponent_l(8) = '1' THEN
								z_l := NINFINITY_slv;
							ELSE
								z_l := slv('1'&exponent_l(7 DOWNTO 0) & mantissa_l(23 DOWNTO 1));
							END IF;
						ELSE
							z_l := slv('1'&exponent_l(7 DOWNTO 0) &  mantissa_l(22 DOWNTO 0));
						END IF;
						
					END IF;
				END IF;
				
				--REPORT "z_l = " & to_string(z_l);
				--REPORT "z_r = " & to_string(z_r);
				
				WAIT UNTIL clk'EVENT AND clk = '1';
				--REPORT "z = " & to_string(z) & " and result = " & to_string(to_float(result));
				PRINT(fout, str(result));
				IF (to_float(result) > to_float(z_r)) OR (to_float(result) < to_float(z_l)) THEN
					incorrect_result := incorrect_result+1;
					REPORT to_string(x) & "/" & to_string(y) & "is " & to_string(to_float(result)) &
						". Correct answer should be " & to_string(z) SEVERITY warning;
				ELSIF result /= to_slv(z) THEN
					REPORT to_string(x) & "/" & to_string(y) & "is " & to_string(to_float(result)) &
						". Correct answer should be " & to_string(z) & "...Result ok(?)" SEVERITY note;
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