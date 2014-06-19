------------------------------------------------------------------
--Testbench for floating point adder/subtracter
--reads twoInput_datapak.txt for input data
--perform test with addition and then subtraction
--use IEEE floating point package to calculate reference result

--vhdl test entity: addsub
--author: Weng Lio
--version: 13/06/2014
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.float_pkg.ALL;		--ieee floating point package
USE std.textio.ALL;
USE work.tb_lib.all;

ENTITY add_tb IS
	GENERIC( pipelineSize : INTEGER := 4 );
END add_tb;

ARCHITECTURE tb OF add_tb IS
	SIGNAL clk, reset, operation: STD_LOGIC;   --operation 0 for add, 1 for sub
	SIGNAL A, B, result: STD_LOGIC_VECTOR(31 DOWNTO 0);

	TYPE INT_ARRAY IS ARRAY(INTEGER RANGE <>) OF INTEGER;
	TYPE FLOAT32_ARRAY IS ARRAY(INTEGER RANGE <> ) OF FLOAT32;
	
	
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
		clk 		=> clk,
		reset		=> reset,
		add_in1		=> A,
		add_in2		=> B,
		operation_i => operation,
		add_out		=> result
	);

	------------------------------------------------------------
	-- main process reads lines from "twoInput_datapak.txt"
	-- each line consists of 2 fp numbers to be added
	-- check sum of these numbers with output of test entity
	------------------------------------------------------------
	main: PROCESS
		FILE f				: TEXT OPEN read_mode IS "twoInput_datapak.txt";
		VARIABLE buf		: LINE;
		VARIABLE x, y       : FLOAT32_ARRAY(0 TO (pipelineSize-1));
		VARIABLE result_tb	: FLOAT32_ARRAY(0 TO (pipelineSize-1));
		VARIABLE arrCounter	: INTEGER;
		VARIABLE op			: BIT;
		VARIABLE op_symbol	: STRING(1 TO 1);
		VARIABLE n          : INTEGER;		--line counter
		VARIABLE incorrect_result : INT_ARRAY(0 TO 1);
		VARIABLE nan_lines	: INTEGER;
		VARIABLE inf_lines	: INTEGER;
		VARIABLE i			: INTEGER;
	
	BEGIN
		reset <= '1';
		WAIT UNTIL clk'EVENT and clk = '1';
		reset <= '0';
		
		n := 1;
		incorrect_result(0) := 0;
		incorrect_result(1) := 0;
		nan_lines := 0;
		inf_lines := 0;
		i := 0;
		arrCounter := 0;
		
		operation <= '0';

		WHILE i < 2 LOOP
				
			REPORT "************** PERFORMING TEST "& INTEGER'IMAGE(i+1) & " ********************";
			---------------------------------------------------------------------
			-- read data file until eof
			WHILE NOT endfile(f) LOOP
				WAIT UNTIL clk'EVENT and clk = '1';
				readline(f, buf);
				If buf'LENGTH = 0 THEN
					REPORT "skipping line: " & INTEGER'IMAGE(n) SEVERITY note;
				ELSE
					REPORT "Reading input line:" & INTEGER'IMAGE(n) SEVERITY note;

					read(buf, x(arrCounter));
					read(buf, y(arrCounter));
					
					A<=to_slv(x(arrCounter));
					B<=to_slv(y(arrCounter));
					
					IF i = 0 THEN
						result_tb(arrCounter) := x(arrCounter)+y(arrCounter);
						op_symbol := "+";
					ELSE
						result_tb(arrCounter) := x(arrCounter)-y(arrCounter);
						op_symbol := "-";
					END IF;

					arrCounter := arrCounter + 1;
					arrCounter := arrCounter mod pipelineSize;
					
					
					WAIT UNTIL clk'EVENT AND clk = '1';
					
					IF n > (pipelineSize-1) THEN
					--REPORT "checking line " & INTEGER'IMAGE(n-pipelineSize+1);
						IF isnan(result_tb(arrCounter)) THEN
							IF not(isnan(to_float(result))) THEN
								incorrect_result(i) := incorrect_result(i)+1;
								REPORT to_string(x(arrCounter)) & op_symbol & to_string(y(arrCounter)) & " is " & to_string(to_float(result)) &
									". Correct answer should be NaN" SEVERITY warning;
							END IF;
						ELSE
							IF result /= to_slv(result_tb(arrCounter)) THEN
								incorrect_result(i) := incorrect_result(i)+1;
								REPORT to_string(x(arrCounter)) & op_symbol & to_string(y(arrCounter)) & " is " & to_string(to_float(result)) &
									". Correct answer should be " & to_string(result_tb(arrCounter)) SEVERITY warning;
							END IF;
						END IF;
					END IF;
					-- --------------------------------------------------------------
					-- -- if either input or output is NaN
					-- IF unordered(x,y) = true THEN
						-- nan_lines := nan_lines + 1;
						-- REPORT "NaN input(s): " & to_string(x) & " and " & to_string(y) & ". Result is " & 
							-- to_string(to_float(result)) SEVERITY note;			
					-- --------------------------------------------------------------
					-- -- if either input or output is infinity
					-- ELSIF isfinite(x) = false or isfinite(y)=false or isfinite(to_float(result))=false THEN
						-- inf_lines := inf_lines + 1;
						-- REPORT "infinite: " & to_string(x) & " and " & to_string(y) & ". Result is " & 
							-- to_string(to_float(result)) SEVERITY note;
					-- END IF;
					
				END IF;	
				
				n := n+1;
			END LOOP;
			----------------------------------------------------------------------------
			--check remaining array
			FOR j in 0 TO pipelineSize-2 LOOP
				WAIT UNTIL clk'EVENT AND clk = '1';
				--REPORT "checking line " & INTEGER'IMAGE(n-pipelineSize+1);
				IF i = 0 THEN
					result_tb(arrCounter) := x(arrCounter)+y(arrCounter);
					op_symbol := "+";
				ELSE
					result_tb(arrCounter) := x(arrCounter)-y(arrCounter);
					op_symbol := "-";
				END IF;
				arrCounter := arrCounter + 1;
				arrCounter := arrCounter mod pipelineSize;
				
				WAIT UNTIL clk'EVENT AND clk = '1';
				IF isnan(result_tb(arrCounter)) THEN
					IF not(isnan(to_float(result))) THEN
						incorrect_result(i) := incorrect_result(i)+1;
						REPORT to_string(x(arrCounter)) & op_symbol & to_string(y(arrCounter)) & " is " & to_string(to_float(result)) &
							". Correct answer should be NaN" SEVERITY warning;
					END IF;
				ELSIF result /= to_slv(result_tb(arrCounter)) THEN
						incorrect_result(i) := incorrect_result(i)+1;
						REPORT to_string(x(arrCounter)) & op_symbol & to_string(y(arrCounter)) & " is " & to_string(to_float(result)) &
							". Correct answer should be " & to_string(result_tb(arrCounter)) SEVERITY warning;
				END IF;
				n := n+1;
			END LOOP;
			
			file_close(f);
			file_open(f, "twoInput_datapak.txt", read_mode);
			operation <= '1';
			n := 1;
			i := i+1;
			arrCounter := 0;
		
		END LOOP;
	
		IF incorrect_result(0) = 0 THEN
			REPORT "***************** ADDITION TEST PASSED *****************";
		ELSE
			REPORT "***************** ADDITION TEST FAILED, number of incorrect results = " & INTEGER'IMAGE(incorrect_result(0));
		END IF;
		
		IF incorrect_result(1) = 0 THEN
			REPORT "***************** SUBTRACTION TEST PASSED *****************";
		ELSE
			REPORT "***************** SUBTRACTION TEST FAILED, number of incorrect results = " & INTEGER'IMAGE(incorrect_result(1));
		END IF;
		
		REPORT "AddSub pipeline test finished normally." SEVERITY failure;

		END PROCESS main;
	
END tb; 