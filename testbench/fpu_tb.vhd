------------------------------------------------------------------
--Testbench for floating point unit
--reads twoInput_datapak.txt for input data
--use IEEE floating point package to calculate reference result

--vhdl test ENTITY: fpu
--author: Weng Lio
--version: 15/06/2014
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.float_pkg.ALL;		--ieee floating point package
USE std.textio.ALL;
USE ieee.std_logic_textio.all;	--read slv from file
USE work.txt_util.ALL;
USE work.tb_lib.all;
USE work.ALL;

ENTITY fpu_tb IS
	GENERIC(	input_file: string := "fpu_input.txt";
				log_file: 	string := "fpu_output.txt"
			);
END fpu_tb;


--TYPE opcode_t IS ARRAY (3 DOWNTO 0) OF std_logic;
--CONSTANT add	: opcode_t := "0000"

ARCHITECTURE tb OF fpu_tb IS
	SIGNAL clk, reset, start: std_logic;
	SIGNAL busy, done		: std_logic;
	SIGNAL opcode			: slv(3 DOWNTO 0);
	SIGNAL in1, in2, in3, in4, in5, in6			: slv(31 DOWNTO 0);
	SIGNAL result			: slv(31 DOWNTO 0);
	
BEGIN
 
	-- clock generation process
	clkgen: PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR 50 ns;
		clk <= '1';
		WAIT FOR 50 ns;
	END PROCESS clkgen;

	-- test ENTITY
	fpu: ENTITY work.fpu
	PORT MAP(
		clk		=> clk,
		reset 	=> reset,
		start	=> start,
		busy	=> busy,
		done	=> done,
		fpu_in1		=> in1,
		fpu_in2		=> in2,
		fpu_in3		=> in3,
		opcode		=> opcode,
		fpu_out		=> result
	);

	------------------------------------------------------------
	-- main process reads lines from "fpu_input.txt"
	-- each line consists of an opcode and the corresponding
	-- input(s) for the operation
	-- check result of these numbers with output of test ENTITY
	------------------------------------------------------------
	main: PROCESS
		FILE fin				: TEXT OPEN read_mode IS input_file;
		FILE fout			: TEXT OPEN write_mode IS log_file;
		VARIABLE buf		: LINE;
		VARIABLE cmd		: string(1 TO 4);
		VARIABLE a,b,c,d,e,f 	: FLOAT32;
		VARIABLE result_tb	: FLOAT32;
		VARIABLE n          : INTEGER;		--line counter
		VARIABLE incorrect_result : INTEGER;
		VARIABLE nan_lines : INTEGER;
		VARIABLE inf_lines : INTEGER;
	
	BEGIN
		reset <= '1';
		start <= '0';
		WAIT UNTIL clk'EVENT and clk = '1';
		reset <= '0';
		
		n := 1;
		incorrect_result := 0;
		nan_lines := 0;
		inf_lines := 0;
		
		---------------------------------------------------------------------
		-- 
		WHILE NOT endfile(fin) LOOP
			WAIT UNTIL clk'EVENT and clk = '1';
			readline(fin, buf);
			If buf'LENGTH = 0 THEN
				REPORT "skipping line: " & INTEGER'IMAGE(n) SEVERITY note;
			ELSE
				REPORT "Reading input line:" & INTEGER'IMAGE(n) SEVERITY note;
				
				read(buf, cmd);
				opcode <= to_opcode(cmd); --TODO write this function
				CASE cmd IS
					WHEN "nop_" => -- NOP
					WHEN "mul_" => -- MUL
						read(buf, a);
						read(buf, b);
						in1 <= to_slv(a);
						in2 <= to_slv(b);
						result_tb := a*b;
					WHEN "add_" => -- ADD
						read(buf, a);
						read(buf, b);
						in1 <= to_slv(a);
						in2 <= to_slv(b);
						result_tb := a+b;
					WHEN "sub_" => -- SUB
						read(buf, a);
						read(buf, b);
						in1 <= to_slv(a);
						in2 <= to_slv(b);
						result_tb := a-b;
					WHEN "fma_" => -- FMA
						read(buf, a);
						read(buf, b);
						read(buf, c);
						in1 <= to_slv(a);
						in2 <= to_slv(b);
						in3 <= to_slv(c);
						result_tb := a*b+c;
					WHEN "div_" => -- DIV
						read(buf, a);
						read(buf, b);
						in1 <= to_slv(a);
						in2 <= to_slv(b);
						result_tb := a/b;
					WHEN "dot2" => -- DOT2
						read(buf, a);
						read(buf, b);
						read(buf, c);
						read(buf, d);
						in1 <= to_slv(a);
						in2 <= to_slv(b);
						in3 <= to_slv(c);
						in4 <= to_slv(d);
						result_tb := a*b+c*d;				
					WHEN "dot3" => -- DOT3
						read(buf, a);
						read(buf, b);
						read(buf, c);
						read(buf, d);
						read(buf, e);
						read(buf, f);
						in1 <= to_slv(a);
						in2 <= to_slv(b);
						in3 <= to_slv(c);
						in4 <= to_slv(d);
						in5 <= to_slv(e);
						in6 <= to_slv(f);
						result_tb := a*b+c*d+e*f;
					WHEN "sqrt" => -- SQRT
						read(buf, a);
						in1 <= to_slv(a);
						result_tb := sqrt(a);
					WHEN "isqr" => -- ISQRT
						read(buf, a);
						in1 <= to_slv(a);
						result_tb := 1/sqrt(a);
					WHEN "mag2" => -- MAG2
						read(buf, a);
						read(buf, b);
						in1 <= to_slv(a);
						in2 <= to_slv(b);
						result_tb := a*b;
					WHEN "mag3" => -- MAG3
						read(buf, a);
						read(buf, b);
						in1 <= to_slv(a);
						in2 <= to_slv(b);
						result_tb := sqrt(a*a+b*b);
					WHEN "norm" => -- NORM3
						read(buf, a);
						read(buf, b);
						read(buf, c);
						in1 <= to_slv(a);
						in2 <= to_slv(b);
						in3 <= to_slv(c);
						result_tb := sqrt(a*a+b*b+c*c);
					WHEN OTHERS => -- unused
						result_tb := PNAN_F;
				END CASE;
				
				start <= '1';

				IF cmd /= "nop_" THEN
					WAIT UNTIL clk'EVENT AND clk = '1' AND done = '1';
					PRINT(fout, str(result));
					IF isnan(result_tb) THEN
						IF not(isnan(to_float(result))) THEN
							incorrect_result := incorrect_result+1;
							REPORT cmd & "(" & to_string(a) & ", " & to_string(b) & ") is " & to_string(to_float(result)) &
								". Correct answer should be NaN" SEVERITY warning;
						END IF;
					ELSIF result /= to_slv(result_tb) THEN
							incorrect_result := incorrect_result+1;
							REPORT cmd & "(" & to_string(a) & ", " & to_string(b) & ")is " & to_string(to_float(result)) &
								". Correct answer should be " & to_string(result_tb) SEVERITY warning;
					END IF;
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
	
	REPORT "FPU Test finished normally." SEVERITY failure;
	END PROCESS main;

END tb;