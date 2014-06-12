--------------------------------------------------------------------------------------
--addsub.vhd
--------------------------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.all;
use work.types.all;

ENTITY addsub IS 
	PORT 
	( add_in1		: IN  std_logic_vector(31 downto 0);
	  add_in2		: IN  std_logic_vector(31 downto 0);
	  operation_i		: IN  std_logic; -- 0:add, 1:sub
	  add_out		: OUT std_logic_vector(31 downto 0)
	);
END ENTITY addsub;

ARCHITECTURE rtl of addsub IS 
SIGNAL s_A,s_B          : float32_t;
SIGNAL s_A_man,s_B_man		: std_logic_vector(27 downto 0);
SIGNAL s_eop			: std_logic;
SIGNAL s_prenorm_exponent	: exponent_t;
SIGNAL s_sign			: sign_t;
SIGNAL s_prenorm_man		: std_logic_vector(28 downto 0);
SIGNAL s_leadingzeros :integer;
SIGNAL s_result_o		: slv(31 downto 0);

BEGIN
--
s_A<=slv2float(add_in1);
s_B<=slv2float(add_in2);

pre_addsub:ENTITY prenorm_addsub
PORT MAP
	(
	 A	    	=>	s_A,
	 B	    	=>	s_B,
	 operation_i	=>	operation_i,
	 A_man_o	=>	s_A_man,
	 B_man_o	=>	s_B_man,
	 temp_exp_o	=>	s_prenorm_exponent,
	 sign_o		=>	s_sign,
	 eop_o		=>	s_eop
	);

add_sub: ENTITY int26adder
PORT MAP
	(
	 opA_i		=>	s_A_man,		
	 opB_i		=>	s_B_man,
	 operation_i	=>	s_eop,
	 prenormresult_o=>	s_prenorm_man,
	 leadingzeros=>s_leadingzeros
	);

post_addsub:ENTITY postnorm_add_sub
PORT MAP
	(
	 r_sign_i	=>	s_sign,
	 leadingzeros=>s_leadingzeros,
	 r_exponent_i	=>	s_prenorm_exponent,	
	 r_man_i	=>	s_prenorm_man,		
	 result_o		=>	s_result_o
	);

sel:PROCESS(s_A,s_B,s_result_o)
  BEGIN
    IF isNan(s_A) OR isNan(s_B) THEN
      add_out<=(others=>'1');
    ELSE
      add_out<=s_result_o;
    END IF;
  END PROCESS sel;
  
END ARCHITECTURE rtl;
