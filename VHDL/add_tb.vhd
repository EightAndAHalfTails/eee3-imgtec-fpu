------------------------------------------------------------------
--Testbench for integer adder
--to be converted to test fp adder
--reads adder_datapak.txt for input data

--vhdl test entity: add
--author: Weng Lio
--version: 09/05/2014
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;

ENTITY add_tb IS
END add_tb;

ARCHITECTURE tb OF add_tb IS

	SIGNAL clk, reset: STD_LOGIC;
	SIGNAL A, B, result: STD_LOGIC_VECTOR(31 DOWNTO 0);

	ALIAS slv IS std_logic_vector;
	
	FUNCTION v2i( x : STD_LOGIC_VECTOR) RETURN INTEGER IS
	BEGIN
		RETURN to_integer(SIGNED(x));
	END;
   
 	FUNCTION i2v( x : INTEGER) RETURN STD_LOGIC_VECTOR IS
	BEGIN
		RETURN slv(to_signed(x, 32));
	END;
BEGIN

	clkgen: PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR 50 ns;
		clk <= '1';
		WAIT FOR 50 ns;
	END PROCESS clkgen;
  
	add: ENTITY work.add
	PORT MAP(
		clk		=>clk,
		reset	=>reset,
		A_i		=>A,
		B_i		=>B,
		result_o=>result
	);

	main: PROCESS
		FILE f			: TEXT OPEN read_mode IS "adder_datapak.txt";
		VARIABLE buf	: LINE;
		VARIABLE x, y          : INTEGER;
		VARIABLE n             : INTEGER;
	
	BEGIN
		reset <= '1';
		WAIT UNTIL clk'EVENT and clk = '1';
		reset <= '0';
		
		n := 1;
		
		WHILE NOT endfile(f) LOOP
			WAIT UNTIL clk'EVENT and clk = '1';
			readline(f, buf);
			If buf'LENGTH = 0 THEN
				REPORT "skipping line: " & INTEGER'IMAGE(n) SEVERITY note;
			ELSE
				REPORT "Reading input line:" & INTEGER'IMAGE(n) SEVERITY note;
				read(buf, x);
				read(buf, y);

				A<=i2v(x);
				B<=i2v(y);
				
				WAIT UNTIL clk'EVENT AND clk = '1';
				ASSERT result = (i2v(x+y))
					REPORT INTEGER'IMAGE(x) & "+" & INTEGER'IMAGE(y) & "is " & INTEGER'IMAGE(v2i(result)) &
						". Correct answer should be " & INTEGER'IMAGE(x+y) SEVERITY warning;
			END IF;	
			
			n := n+1;
		END LOOP;
	
	REPORT "Test finished normally." SEVERITY failure;
	END PROCESS main;
	
END tb; 