--------------------------------------------------------------------------------------
--floating32adder.vhd
--------------------------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.all;

ENTITY add IS 
	PORT 
	( clk,reset  :IN std_logic;
	  A_i			: IN  std_logic_vector(31 downto 0);
	  B_i			: IN  std_logic_vector(31 downto 0);
	  result_o		: OUT std_logic_vector(31 downto 0)
	);
END ENTITY add;

ARCHITECTURE rtl of add IS 

SIGNAL s_A_man,s_B_man		: std_logic_vector(25 downto 0);
SIGNAL s_eop			: std_logic;
SIGNAL s_prenorm_exponent	: std_logic_vector(7 downto 0);
SIGNAL s_sign			: std_logic;
SIGNAL s_prenorm_man		: std_logic_vector(26 downto 0);

SIGNAL s_result_o		: std_logic_vector(31 downto 0);
BEGIN


pre_addsub:ENTITY prenorm_addsub
PORT MAP
	(--clk		=>	clk_i,
	 --reset	=>	reset_i,
	 A_i		=>	A_i,
	 B_i		=>	B_i,
	 A_man_o	=>	s_A_man,
	 B_man_o	=>	s_B_man,
	 temp_exp_o	=>	s_prenorm_exponent,
	 sign_o		=>	s_sign,
	 eop_o		=>	s_eop
	);

add_sub: ENTITY addsub
PORT MAP
	(--clk		=>	clk_i,
	 --reset	=>	reset_i,
	 opA_i		=>	s_A_man,		
	 opB_i		=>	s_B_man,
	 operation_i	=>	s_eop,
	 prenormresult_o=>	s_prenorm_man
	);

post_addsub:ENTITY postnorm_add_sub
PORT MAP
	(--clk		=>	clk_i,
	 --reset	=>	reset_i,
	 r_sign_i	=>	s_sign,
	 r_exponent_i	=>	s_prenorm_exponent,	
	 r_man_i	=>	s_prenorm_man,		
	 result_o	=>	s_result_o
	);

--output:PROCESS
--BEGIN
--  WAIT UNTIL clk'EVENT AND clk='1';
    result_o	<=	s_result_o;
--END PROCESS output;
END ARCHITECTURE rtl;