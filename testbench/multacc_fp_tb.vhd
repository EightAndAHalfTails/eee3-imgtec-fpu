------------------------------------------------------------------
--Testbench for floating point multiply-accumulate
--reads threeInput_datapak.txt for input data
--use IEEE floating point package to calculate reference result

--This testbench may have to be modify to improve accuracy of "correct" result

--vhdl test entity: multacc
--author: Weng Lio
--version: 05/06/2014
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.float_pkg.ALL;		--ieee floating point package
use ieee.fixed_float_types.all;
use ieee.fixed_pkg.all;
USE std.textio.ALL;

ENTITY multacc_tb IS
END multacc_tb;

ARCHITECTURE tb OF multacc_tb IS

	SIGNAL clk, reset: STD_LOGIC; 
	SIGNAL A, B, C, result: STD_LOGIC_VECTOR(31 DOWNTO 0);		--result=ab+c

	ALIAS slv IS std_logic_vector;
	
	FUNCTION v2i( x : STD_LOGIC_VECTOR) RETURN INTEGER IS
	BEGIN
		RETURN to_integer(SIGNED(x));
	END;
   
 	FUNCTION i2v( x : INTEGER) RETURN STD_LOGIC_VECTOR IS
	BEGIN
		RETURN slv(to_signed(x, 32));
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
	multacc: ENTITY work.multacc
	PORT MAP(
		multacc_in1		=>A,
		multacc_in2		=>B,
		multacc_in3 	=> C,
		multacc_out		=>result
	);

	------------------------------------------------------------
	-- main process reads lines from "threeInput_datapak.txt"
	-- each line consists of 2 fp numbers to be multiplied and a third to be added to
	------------------------------------------------------------
	main: PROCESS
		FILE f				: TEXT OPEN read_mode IS "threeInput_datapak.txt";
		VARIABLE buf		: LINE;
		VARIABLE x, y, z    : FLOAT32;
		VARIABLE tb_result	: FLOAT32;
		VARIABLE n          : INTEGER;		--line counter
		VARIABLE incorrect_result : INTEGER;
		VARIABLE nan_lines : INTEGER;
		VARIABLE inf_lines : INTEGER;
	
	BEGIN
		reset <= '1';
		WAIT UNTIL clk'EVENT and clk = '1';
		reset <= '0';
		
		n := 1;
		incorrect_result := 0;
		nan_lines := 0;
		inf_lines := 0;
		
		---------------------------------------------------------------------
		-- read data file until eof
		WHILE NOT endfile(f) LOOP
			WAIT UNTIL clk'EVENT and clk = '1';
			readline(f, buf);
			If buf'LENGTH = 0 THEN
				REPORT "skipping line: " & INTEGER'IMAGE(n) SEVERITY note;
			ELSE
				REPORT "Reading input line:" & INTEGER'IMAGE(n) SEVERITY note;
				
				read(buf, x);
				read(buf, y);
				read(buf, z);
				
				A<=to_slv(x);
				B<=to_slv(y);
				C<=to_slv(z);
				
				tb_result := (x*y)+z;
				
				WAIT UNTIL clk'EVENT AND clk = '1';
				IF result /= to_slv(tb_result) THEN
					incorrect_result := incorrect_result+1;
					REPORT to_string(x) & "*" & to_string(y) & " + " & to_string(z) & "is " & 
						to_string(to_float(result)) & ". Correct answer should be " & to_string(tb_result) SEVERITY warning;
				END IF;

				--------------------------------------------------------------
				-- if either input or output is NaN
				IF unordered(x,y) = true THEN
					nan_lines := nan_lines + 1;
					REPORT "NaN input(s): " & to_string(x) & " and " & to_string(y) & ". Result is " & 
						to_string(to_float(result)) SEVERITY note;			
				--------------------------------------------------------------
				-- there's something wrong with this ELSIF condition 
				-- but whatever I will change it later
				ELSIF isfinite(x) = false or isfinite(y)=false or isfinite(z)=false or isfinite(to_float(result))=false THEN
					inf_lines := inf_lines + 1;
					REPORT "infinite: " & to_string(x) & ", " & to_string(y) & " and " & to_string(z) & ". Result is " & 
						to_string(to_float(result)) SEVERITY note;
				END IF;
				
			END IF;	
			
			n := n+1;
		END LOOP;

	IF incorrect_result = 0 THEN
		REPORT "***************** TEST PASSED *****************";
		REPORT "Number of NaN lines: " & INTEGER'IMAGE(nan_lines) SEVERITY note;
		REPORT "Number of Inf lines: " & INTEGER'IMAGE(inf_lines) SEVERITY note;
	ELSE
		REPORT "***************** TEST FAILED, number of incorrect results = " & INTEGER'IMAGE(incorrect_result);
	END IF;
	
	REPORT "Multiply-accumulate test finished normally." SEVERITY failure;

	END PROCESS main;
	
END tb;