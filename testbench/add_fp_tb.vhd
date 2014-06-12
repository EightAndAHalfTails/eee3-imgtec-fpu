------------------------------------------------------------------
--Testbench for floating point adder
--reads twoInput_datapak.txt for input data
--use IEEE floating point package to calculate reference result

--vhdl test entity: addsub
--author: Weng Lio
--version: 05/06/2014
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.float_pkg.ALL;		--ieee floating point package
USE std.textio.ALL;
USE work.tb_lib;

ENTITY add_tb IS
END add_tb;

ARCHITECTURE tb OF add_tb IS
	SIGNAL clk, reset, operation: STD_LOGIC;   --operation 0 for add, 1 for sub
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
	add: ENTITY work.addsub
	PORT MAP(
		add_in1		=>A,
		add_in2		=>B,
		operation_i => operation,
		add_out		=>result
	);

	------------------------------------------------------------
	-- main process reads lines from "twoInput_datapak.txt"
	-- each line consists of 2 fp numbers to be added
	-- check sum of these numbers with output of test entity
	------------------------------------------------------------
	main: PROCESS
		FILE f				: TEXT OPEN read_mode IS "twoInput_datapak.txt";
		VARIABLE buf		: LINE;
		VARIABLE x, y       : FLOAT32;
		VARIABLE op			: BIT;
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
		-- read first line of file
		-- the first line should contain the operation code
		-- 0 for addition and 1 for subtraction
		-- testbench default to addition if none is supplied 
		-- and first line of data file will be ignored
		readline(f,buf);
		If buf'LENGTH = 0 THEN
			REPORT "skipping line: " & INTEGER'IMAGE(n) SEVERITY note;
		ELSE
			REPORT "Reading input line:" & INTEGER'IMAGE(n) SEVERITY note;
				
			IF buf'LENGTH > 1 THEN
				REPORT "Undefined operation option, default to 0. Skipping line 1" SEVERITY warning;
				operation <= '0';
			ELSE
				read(buf, op);			
				operation <= b2l(op);
				REPORT " ***************** Operation = " & BIT'IMAGE(op) & " ***************** " SEVERITY note;
			END IF;
		END IF;
		
		---------------------------------------------------------------------
		-- read data file until eof
		WHILE NOT endfile(f) LOOP
			WAIT UNTIL clk'EVENT and clk = '1';
			readline(f, buf);
			If buf'LENGTH = 0 THEN
				REPORT "skipping line: " & INTEGER'IMAGE(n) SEVERITY note;
			ELSE
				REPORT "Reading input line:" & INTEGER'IMAGE(n) SEVERITY note;
				
				-------------------------------------------------------------
				-- note: x and y from file must be in binary
				-------------------------------------------------------------
				read(buf, x);
				read(buf, y);
				
				A<=to_slv(x);
				B<=to_slv(y);
				
				WAIT UNTIL clk'EVENT AND clk = '1';
				IF op = '0' THEN
					IF result /= (to_slv(x+y)) THEN
						incorrect_result := incorrect_result+1;
						REPORT to_string(x) & "+" & to_string(y) & "is " & to_string(to_float(result)) &
							". Correct answer should be " & to_string(x+y) SEVERITY warning;
					END IF;
				ELSE
					IF result /= (to_slv(x-y)) THEN
						incorrect_result := incorrect_result+1;
						REPORT to_string(x) & "-" & to_string(y) & "is " & to_string(to_float(result)) &
							". Correct answer should be " & to_string(x-y) SEVERITY warning;
					END IF;
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
				ELSIF finite(x) = false or finite(y)=false or finite(to_float(result))=false THEN
					inf_lines := inf_lines + 1;
					REPORT "infinite: " & to_string(x) & " and " & to_string(y) & ". Result is " & 
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
	
	IF op = '0' THEN
		REPORT "Addition test finished normally." SEVERITY failure;
	ELSE
		REPORT "Subtraction test finished normally." SEVERITY failure;
	END IF;
	END PROCESS main;
	
END tb; 