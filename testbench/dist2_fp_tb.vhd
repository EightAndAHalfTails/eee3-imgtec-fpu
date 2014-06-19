------------------------------------------------------------------
--Testbench for floating point 2D Euclidean Distance
--reads twoInput_datapak.txt for input data
--use ieee.math_real package to calculate reference result


--vhdl test entity: dist2
--author: Weng Lio
--version: 19/06/2014
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.float_pkg.ALL;		--ieee floating point package
use ieee.math_real.all; --real data type
USE std.textio.ALL;
USE work.tb_lib.all;
USE work.all;

ENTITY dist2_tb IS
	GENERIC(	ulp : INTEGER := 4 ;
				op	: STRING(1 TO 4) := "1010"	);
END dist2_tb;

ARCHITECTURE tb OF dist2_tb IS
	SIGNAL clk, reset: STD_LOGIC; 
	SIGNAL A, B, result: STD_LOGIC_VECTOR(31 DOWNTO 0);		--result=sqrt(a*a + b*b)
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
	dist2: ENTITY work.dist2
	PORT MAP(
		dist2_in1		=>A,
		dist2_in2		=>B,
		dist2_out		=>result
	);

	------------------------------------------------------------
	-- main process reads lines from "twoInput_datapak.txt"
	-- each line consists of 2 fp numbers to be squared and then square-rooted
	------------------------------------------------------------
	main: PROCESS
		FILE f				: TEXT OPEN read_mode IS "twoInput_datapak.txt";
		VARIABLE buf		: LINE;
		VARIABLE cmd		: STRING(1 TO 4);
		VARIABLE header		: STRING(1 TO 3);
		VARIABLE ibmvectors	: BOOLEAN;
		VARIABLE x, y	    : FLOAT32;
		VARIABLE res1, res2, res_t	: FLOAT32;
		VARIABLE err1, err2, err3, err_t	: FLOAT32;
		VARIABLE res_r, res_l	: FLOAT32;
		VARIABLE result_chained	: FLOAT32;
		VARIABLE result_tb 		: FLOAT32;
		VARIABLE result_tb_real	: REAL;
		VARIABLE n          : INTEGER;		--line counter
		VARIABLE incorrect_result : INTEGER;
		VARIABLE nan_lines : INTEGER;
		VARIABLE inf_lines : INTEGER;
		VARIABLE inaccurate_lines : INTEGER;	--where using float pkg does not match real result
		VARIABLE incorrect_lines : line_numbers;
	
	BEGIN
		reset <= '1';
		WAIT UNTIL clk'EVENT and clk = '1';
		reset <= '0';
		
		n := 1;
		incorrect_result := 0;
		nan_lines := 0;
		inf_lines := 0;
		inaccurate_lines := 0;
		incorrect_lines := (0,0,0,0,0,0,0,0,0,0);

		---------------------------------------------------------------------
		-- read data file until eof
		readline(f, buf);
		read(buf, header);
		IF header = "ibm" THEN
			ibmvectors := true;
		ELSE
			ibmvectors := false;
			file_close(f);
			file_open(f, "twoInput_datapak.txt", read_mode);
		END IF;
		
		WHILE NOT endfile(f) LOOP
			WAIT UNTIL clk'EVENT and clk = '1';
			readline(f, buf);
			If buf'LENGTH = 0 THEN
				REPORT "skipping line: " & INTEGER'IMAGE(n) SEVERITY note;
			ELSE
				REPORT "Reading input line:" & INTEGER'IMAGE(n) SEVERITY note;
				
				IF ibmvectors = true THEN
					read(buf, cmd);
				ELSE
					cmd := op;
				END IF;
				
				IF cmd = op THEN

					read(buf, x);
					read(buf, y);

					A<=to_slv(x);
					B<=to_slv(y);
					
				-----------------------------------------------------------
				--calculate chained result
				result_chained := ieee.float_pkg.sqrt(((x*x)+(y*y)));
				
				--calculate result_tb using real package if number is infinite
				IF isfinite(x) and isfinite(y) and not(isnan(x) or isnan(y))THEN
					result_tb := to_float(ieee.math_real.sqrt((to_real(x)*to_real(x))+(to_real(y)*to_real(y))));
					-- check if overflow
					IF slv(result_tb(7 DOWNTO 0)) = "11111111" THEN
						result_tb := to_float(slv(result_tb(8 DOWNTO 0)) & "00000000000000000000000");
					END IF;
				ELSE
					REPORT "Using chained result";
					result_tb := result_chained;
				END IF;
	
				-------------------------------------------------------------
				--calculate best rounded result res_t and total error
				IF isnan(x) or isnan(y) THEN
					res_t := result_tb;
				ELSE
					---------------------------------------------------------
					--calculate x^2
					IF isfinite(x*x) and not(iszero(x*x)) THEN
						--REPORT "Performing Dekker 1";
						dekkerMult(x,x,res1,err1);
					ELSE
						res1 := PNAN_F;
						err1 := PNAN_F;
					END IF;
					REPORT "res1 is " & to_string(res1);
					REPORT "err1 is " & to_string(err1);
					---------------------------------------------------------
					--calculate y^2
					IF isfinite(y*y) and not(iszero(y*y)) THEN
						--REPORT "Performing Dekker 2";
						dekkerMult(y,y,res2,err2);
					ELSE
						res2 := PNAN_F;
						err2 := PNAN_F;
					END IF;
					REPORT "res2 is " & to_string(res2);
					REPORT "err2 is " & to_string(err2);
					---------------------------------------------------------
					--adding x^2 and y^2
					IF isfinite(res1+res2) and not(iszero(res1+res2)) and not(isnan(res1)) and not(isnan(res2)) and not(isnan(err1)) and not(isnan(err2)) THEN
						--REPORT "Performing twoSum";
						twoSum(res1, res2, res_t, err3);
						err_t := (err2+ err3) + err1;
						res_t := res_t + err_t;
					ELSE
						res_t := PNAN_F;
						err_t := PNAN_F;
					END IF;
					REPORT "res_t is " & to_string(res_t);
					REPORT "err_t is " & to_string(err_t);
					---------------------------------------------------------
					--square root
					IF (to_slv(x*x)=NZERO_slv) and (to_slv(y*y) = NZERO_slv) THEN 
						res_t := NZERO_F;		--sqrt(-0) = (-0)
					ELSIF isnan(res_t) or res_t < PZERO_F THEN
						REPORT "using chained/real pkg";
						res_t := result_tb;
					ELSIF res_t = PINFINITY_F THEN
						res_t := PINFINITY_F;
					ELSE
						res_t := to_float(ieee.math_real.sqrt(to_real(res_t)));
					END IF;

				END IF;
				----------------------------------------------------------				
				getRightLeftBound(res_t, ulp, res_r, res_l);

				REPORT "result_chained = " & to_string(result_chained);
				REPORT "result real = " & to_string(result_tb);	
				--------------------------------------------------------------
				-- check result from design
				WAIT UNTIL clk'EVENT AND clk = '1';
				REPORT "Result is " & to_string(to_float(result));
				IF isnan(result_tb) THEN
					IF not(isnan(to_float(result))) THEN
						IF incorrect_result < 10 THEN
							incorrect_lines(incorrect_result) := n;
						END IF;
						incorrect_result := incorrect_result+1;
						REPORT "Euclidean dist of " & to_string(x) & " and " & to_string(y) & " is " & 
							to_string(to_float(result)) & ". Correct answer should be NaN" SEVERITY warning;
					END IF;
				---------------------------------------------------------------
				-- in case of overflow or underflow when squaring
				ELSIF result_chained = PINFINITY_F or result_chained = PZERO_F THEN
					IF not(to_float(result)<=res_r and to_float(result) >= res_l) and result /= to_slv(result_chained) THEN
						REPORT "result_right is " & to_string(res_r);
						REPORT "result left is " & to_string(res_l);
						IF incorrect_result < 10 THEN
								incorrect_lines(incorrect_result) := n;
						END IF;
						incorrect_result := incorrect_result+1;
						REPORT "Euclidean dist of " & to_string(x) & " and " & to_string(y) & " is " & 
							to_string(to_float(result)) & ". Correct answer should be " & to_string(res_t) SEVERITY warning;
					END IF;
				ELSIF not(to_float(result)<=res_r and to_float(result) >= res_l) THEN
					REPORT "result_right is " & to_string(res_r);
					REPORT "result left is " & to_string(res_l);
					IF incorrect_result < 10 THEN
							incorrect_lines(incorrect_result) := n;
					END IF;
					incorrect_result := incorrect_result+1;
					REPORT "Euclidean dist of " & to_string(x) & " and " & to_string(y) & " is " & 
							to_string(to_float(result)) & ". Correct answer should be " & to_string(res_t) SEVERITY warning;
				END IF;
		
			END IF;	
		END IF;
			
		n := n+1;
		END LOOP;

	IF incorrect_result = 0 THEN
		REPORT "***************** TEST PASSED *****************";
		REPORT "Number of NaN lines: " & INTEGER'IMAGE(nan_lines) SEVERITY note;
		REPORT "Number of Inf lines: " & INTEGER'IMAGE(inf_lines) SEVERITY note;
		REPORT "Float pkg and Real pkg mismatch (number of lines): " & INTEGER'IMAGE(inaccurate_lines) SEVERITY note;
	ELSE
		REPORT "***************** TEST FAILED, number of incorrect results = " & INTEGER'IMAGE(incorrect_result);
		REPORT "Float pkg and Real pkg mismatch (number of lines): " & INTEGER'IMAGE(inaccurate_lines) SEVERITY note;
		FOR i IN 0 TO 9 LOOP
			IF incorrect_lines(i) /= 0 THEN
				REPORT "Error in line " & INTEGER'IMAGE(incorrect_lines(i));
			END IF;
		END LOOP;
		IF incorrect_result > 10 THEN
			REPORT "etc.";
		END IF;
	END IF;
	
	REPORT "2D Euclidean distance test finished normally." SEVERITY failure;

	END PROCESS main;
	
END tb; 

