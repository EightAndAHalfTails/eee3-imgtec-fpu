--------------------------------------------------------------------------------------
--addsub.vhd
--------------------------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.all;
USE config_pack.all;

ENTITY addsub IS 
	PORT 
	( add_in1		: IN  std_logic_vector(31 downto 0);
	  add_in2		: IN  std_logic_vector(31 downto 0);
	  operation_i		: IN  std_logic; -- 0:add, 1:sub
	  add_out		: OUT std_logic_vector(31 downto 0)
	);
END ENTITY addsub;

ARCHITECTURE rtl of addsub IS 

SIGNAL s_A_man,s_B_man		: std_logic_vector(27 downto 0);
SIGNAL s_eop			: std_logic;
SIGNAL s_prenorm_exponent	: exponent_t;
SIGNAL s_sign			: sign_t;
SIGNAL s_prenorm_man		: std_logic_vector(28 downto 0);

SIGNAL add_in1_denorm,add_in2_denorm  :std_logic;
SIGNAL s_result_o		: float32_t;
BEGIN

add_in1_denorm<='1' WHEN usg(add_in1(30 downto 23))=255 AND usg(add_in1(22 downto 0))/=0 ELSE '0';
add_in2_denorm<='1' WHEN usg(add_in2(30 downto 23))=255 AND usg(add_in2(22 downto 0))/=0 ELSE '0';
pre_addsub:ENTITY prenorm_addsub
PORT MAP
	(
	 A_i	    	=>	add_in1,
	 B_i	    	=>	add_in2,
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
	 prenormresult_o=>	s_prenorm_man
	);

post_addsub:ENTITY postnorm_add_sub
PORT MAP
	(
	 r_sign_i	=>	s_sign,
	 r_exponent_i	=>	s_prenorm_exponent,	
	 r_man_i	=>	s_prenorm_man,		
	 result_o		=>	s_result_o
	);

sel:PROCESS(add_in1_denorm,add_in2_denorm,s_result_o)
  BEGIN
    IF (add_in1_denorm OR add_in2_denorm)='1' THEN
      add_out(31)	<=	'0';
      add_out(30 downto 23)	<=(OTHERS=>'1');
      add_out(22 downto 0)	<=	(0=>'1',OTHERS=>'0');
    ELSE
      add_out(31)	<=	s_result_o.sign;
      add_out(30 downto 23)	<=	s_result_o.exponent;
      add_out(22 downto 0)	<=	s_result_o.significand;
    END IF;
  END PROCESS sel;
END ARCHITECTURE rtl;
