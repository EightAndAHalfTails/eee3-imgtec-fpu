------------------------------------------------------------------
--Testbench for floating point 3D dot product
--reads sixInput_datapak.txt for input data (IEEE 754 format)

--Input is converted to real with the float_pkg
--numbers are rounded to nearest by default and denormals are supported
--ab+cd+ef is performed using the math_real library
--answer is converted back to float to compare with design result 
--accuracy no worse than chaining

--vhdl test entity: dot3
--author: Weng Lio
--version: 18/06/2014
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.float_pkg.ALL;		--ieee floating point package
use ieee.math_real.all; --real data type
USE std.textio.ALL;
USE work.tb_lib.all;

ENTITY dot3_tb IS
END dot3_tb;

ARCHITECTURE tb OF dot3_tb IS
	SIGNAL clk, reset: STD_LOGIC;
	SIGNAL a,b,c,d,e,f, result: STD_LOGIC_VECTOR(31 DOWNTO 0);	

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
	dot3_test: ENTITY work.dot3
	PORT MAP(
		dot3_in1		=>a,
		dot3_in2		=>b,
		dot3_in3		=>c,
		dot3_in4		=>d,
		dot3_in5		=>e,
		dot3_in6		=>f,
		dot3_out		=>result
	);

	------------------------------------------------------------
	-- main process reads lines from "sixInput_datapak.txt"
	-- each line consist of one fp number to be square-rooted
	------------------------------------------------------------
	main: PROCESS
		FILE fin				: TEXT OPEN read_mode IS "sixInput_datapak.txt";
		VARIABLE buf		: LINE;
		VARIABLE p,q,r,s,t,u		: FLOAT32;
		VARIABLE res1, res2, res3, res4, res_t	: FLOAT32;
		VARIABLE err1, err2, err3, err4, err5, err_t	: FLOAT32;
		VARIABLE result_tb 	: FLOAT32;
		VARIABLE result_chained	:FLOAT32;
		
		--VARIABLE dot3_l, dot3_r	: slv(31 DOWNTO 0);
		--VARIABLE exponent_l, exponent_r	: unsigned(8 DOWNTO 0);
		--VARIABLE mantissa_l, mantissa_r	: unsigned(24 DOWNTO 0); --25 bits for overflow, left and right bound error interval
		VARIABLE temp   	:unsigned(22 DOWNTO 0); --temp mantissa of dot3_x
		VARIABLE n          : INTEGER;		--line counter
		VARIABLE incorrect_result : INTEGER;
		VARIABLE incorrect_lines : line_numbers;
	
	BEGIN
		reset <= '1';
		WAIT UNTIL clk'EVENT and clk = '1';
		reset <= '0';
		
		n := 1;
		incorrect_result := 0;
		incorrect_lines := (0,0,0,0,0,0,0,0,0,0);
		
		WHILE NOT endfile(fin) LOOP
			WAIT UNTIL clk'EVENT and clk = '1';
			readline(fin, buf);
			If buf'LENGTH = 0 THEN
				REPORT "skipping line: " & INTEGER'IMAGE(n) SEVERITY note;
			ELSE
				REPORT "Reading input line:" & INTEGER'IMAGE(n) SEVERITY note;
				
				read(buf, p);
				read(buf, q);
				read(buf, r);
				read(buf, s);
				read(buf, t);
				read(buf, u);
				
				a<=to_slv(p);
				b<=to_slv(q);
				c<=to_slv(r);
				d<=to_slv(s);
				e<=to_slv(t);
				f<=to_slv(u);
				
				--calculate chained result
				result_chained := ((p*q)+(r*s))+(t*u);
				
				--calculate result_tb using real package
				result_tb := to_float(((to_real(p)*to_real(q))+(to_real(r)*to_real(s)))+(to_real(t)*to_real(u)));
				--------------------------------------------------------------
				-- check if overflow
				IF slv(result_tb(7 DOWNTO 0)) = "11111111" THEN
					result_tb := to_float(slv(result_tb(8 DOWNTO 0)) & "00000000000000000000000");
				END IF;
				
				-------------------------------------------------------------
				--calculate best rounded result res_t and total error
				IF isnan(p) or isnan(q) or isnan(r) or isnan(s) or isnan(t) or isnan(u) THEN
					res_t := result_tb;
				ELSE
					IF isfinite(p*q) and not(iszero(p*q)) THEN
						--REPORT "Performing Dekker 1";
						dekkerMult(p,q,res1,err1);
					ELSE
						res1 := PNAN_F;
						err1 := PNAN_F;
					END IF;
					REPORT "res1 is " & to_string(res1);
					REPORT "err1 is " & to_string(err1);
					IF isfinite(r*s) and not(iszero(r*s)) THEN
						--REPORT "Performing Dekker 2";
						dekkerMult(r,s,res2,err2);
					ELSE
						res2 := PNAN_F;
						err2 := PNAN_F;
					END IF;
					REPORT "res2 is " & to_string(res2);
					REPORT "err2 is " & to_string(err2);
					IF isfinite(t*u) and not(iszero(t*u)) THEN
						--REPORT "Performing Dekker 3";
						dekkerMult(t,u,res3,err3);
					ELSE
						res3 := PNAN_F;
						err3 := PNAN_F;
					END IF;
					REPORT "res3 is " & to_string(res3);
					REPORT "err3 is " & to_string(err3);
					IF isfinite(res1+res2) and not(iszero(res1+res2)) and not(isnan(res1)) and not(isnan(res2)) and not(isnan(err1)) and not(isnan(err2)) THEN
						--REPORT "Performing twoSum";
						twoSum(res1, res2, res4, err4);
					ELSE
						res4 := PNAN_F;
						err4 := PNAN_F;
					END IF;
					IF isfinite(res4+res3) and not(iszero(res4+res3)) and not(isnan(res4)) and not(isnan(res3)) and not(isnan(err1)) 
						and not(isnan(err2)) and not(isnan(err3)) and not(isnan(err4)) and not(isnan(err5)) THEN
						twoSum(res4, res3, res_t, err5);
						err_t := (err4+err2)+err1;
						err_t := (err5+err3)+err_t;						
						res_t := res_t + err_t;
					ELSE
						REPORT "Using real package";
						res_t := result_tb;
						err_t := PNAN_F;
					END IF;
					REPORT "res_t is " & to_string(res_t);
					REPORT "err_t is " & to_string(err_t);
				END IF;
				-----------------------------------
				-- TODO: check if result is within range of res_t +/- abs(err_t)
				
				
				WAIT UNTIL clk'EVENT AND clk = '1';
				----------------------------------------------------------------------
				--check result
				REPORT "result_chained = " & to_string(result_chained);
				REPORT "result real = " & to_string(result_tb);
				-- IF isnan(result_tb) THEN
					-- IF not(isnan(to_float(result))) THEN
						-- incorrect_result := incorrect_result+1;
						-- REPORT "2D dot product of " & to_string(p) & ", " & to_string(q) &", "& to_string(r) &" and "& to_string(s)
							-- & "gives " &to_string(to_float(result)) & " which is incorrect. Correct answer is NAN" SEVERITY warning;
					-- END IF;
				-- ELSIF result/=to_slv(result_tb) THEN
					-- incorrect_result := incorrect_result+1;
					-- REPORT "2D dot product of " & to_string(p) & ", " & to_string(q) &", "& to_string(r) &" and "& to_string(s)
							-- & "gives " &to_string(to_float(result)) & " which is incorrect. Correct answer is  " & to_string(result_tb)SEVERITY warning;
				-- END IF;
				
				IF not(isfinite(res_t)) THEN
					IF to_float(result) /= res_t THEN
						IF incorrect_result < 10 THEN
							incorrect_lines(incorrect_result) := n;
						END IF;
						incorrect_result := incorrect_result+1;
						REPORT "3D dot product of " & to_string(p) & ", " & to_string(q) &", "& to_string(r) &", "& to_string(s) & ", " & to_string(t) & " and " & to_string(u) 
							& " gives " &to_string(to_float(result)) & " which is incorrect. Correct answer is " & to_string(res_t) SEVERITY warning;
						END IF;
				ELSIF isnan(res_t) THEN
					IF not(isnan(to_float(result))) THEN
						IF incorrect_result < 10 THEN
							incorrect_lines(incorrect_result) := n;
						END IF;
						incorrect_result := incorrect_result+1;
						REPORT "2D dot product of " & to_string(p) & ", " & to_string(q) &", "& to_string(r) &", "& to_string(s) & ", " & to_string(t) & " and " & to_string(u) 
							& " gives " &to_string(to_float(result)) & " which is incorrect. Correct answer is NAN" SEVERITY warning;
					END IF;
				ELSIF result_chained > res_t THEN
					IF incorrect_result < 10 THEN
						incorrect_lines(incorrect_result) := n;
					END IF;
					IF not(to_float(result)>= res_t and to_float(result)<= result_chained) THEN
						incorrect_result := incorrect_result+1;
						REPORT "3D dot product of " & to_string(p) & ", " & to_string(q) &", "& to_string(r) &", "& to_string(s) & ", " & to_string(t) & " and " & to_string(u) 
							& " gives " &to_string(to_float(result)) & " which is incorrect. Correct answer is " & to_string(res_t) SEVERITY warning;
					END IF;
				ELSIF not(to_float(result)<= res_t and to_float(result)>= result_chained) THEN
					IF incorrect_result < 10 THEN
						incorrect_lines(incorrect_result) := n;
					END IF;
					incorrect_result := incorrect_result+1;
					REPORT "3D dot product of " & to_string(p) & ", " & to_string(q) &", "& to_string(r) &", "& to_string(s) & ", " & to_string(t) & " and " & to_string(u) 
							& " gives " &to_string(to_float(result)) & " which is incorrect. Correct answer is " & to_string(res_t) SEVERITY warning;
				END IF;
				
			END IF;	
			
			n := n+1;
		END LOOP;
	
	IF incorrect_result = 0 THEN
		REPORT "***************** TEST PASSED *****************";
	ELSE
		REPORT "***************** TEST FAILED, number of incorrect results = " & INTEGER'IMAGE(incorrect_result);
		FOR i IN 0 TO 9 LOOP
			IF incorrect_lines(i) /= 0 THEN
				REPORT "Error in line " & INTEGER'IMAGE(incorrect_lines(i));
			END IF;
		END LOOP;
		IF incorrect_result > 10 THEN
			REPORT "etc.";
		END IF;
	END IF;
	
	REPORT "Test finished normally." SEVERITY failure;
	END PROCESS main;
	
END tb; 