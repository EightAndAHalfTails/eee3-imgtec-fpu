LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY add IS
	PORT(
		clk, reset  : IN std_logic;
		A_i, B_i	: IN std_logic_vector(31 DOWNTO 0);
		result_o	: OUT std_logic_vector(31 DOWNTO 0)
	);
END ENTITY add;


ARCHITECTURE rtl OF add IS
  SIGNAL result: std_logic_vector(31 DOWNTO 0);
  ALIAS slv IS std_logic_vector;
BEGIN

  adder: PROCESS(A_i, B_i, reset)
  BEGIN
    IF reset = '1' THEN
      result_o <= (OTHERS=>'0');
    END IF;
    result_o <= slv(signed(A_i)+signed(B_i));
  END PROCESS adder;
  
	
END ARCHITECTURE rtl;