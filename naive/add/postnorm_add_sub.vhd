--------------------------------------------------------------------------------------
--postnorm_add_sub.vhd
--------------------------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.all;

ENTITY postnorm_add_sub IS 
	PORT(
		clk,reset		:	IN 		std_logic;
<<<<<<< HEAD:fpu adder/postnorm_add_sub.vhd
		r_sign_i		:	IN		std_logic;
		operation_i		:	IN		std_logic;
		r_exponent_i		:	IN		std_logic_vector(8 downto 0);
		r_man_i			:	IN		std_logic_vector(23 downto 0);
		sticky_b		:	IN		std_logic;
		result_o		:	OUT 		std_logic_vector(31 downto 0)
		);
=======
		r_exponent_i		:	IN		std_logic_vector(8 downto 0);
		r_man_i			:	IN		std_logic_vector(23 downto 0);
		sticky_b		:	IN		std_logic;
		result_o		:	OUT 		std_logic_vector(31 downto 0);		
		)
>>>>>>> 8662823138f707f7e5cb9525268b099ba3603ede:naive/add/postnorm_add_sub.vhd

END ENTITY postnorm_add_sub;

ARCHITECTURE rtl of postnorm_add_sub IS

BEGIN

<<<<<<< HEAD:fpu adder/postnorm_add_sub.vhd
ALIAS slv IS std_logic_vector;
ALIAS usg IS unsigned;
ALIAS sgn IS signed;


SIGNAL postnorm_result_e_s		:std_logic_vector(7 downto 0);
SIGNAL postnorm_result_man_s		:std_logic_vector(22 downto 0);

SIGNAL prenorm_result_e_s		:std_logic_vector(7 downto 0);
SIGNAL prenorm_result_man_s		:std_logic_vector(22 downto 0);


-----------------------------------------------------------------
--packing
--This block is used to pack the separate sections up into a 32 bit 
--floating point number
-----------------------------------------------------------------
  
unpack:BLOCK
BEGIN
	result_o(31)		<=r_sign_i;
	result_o(30 downto 23)	<=postnorm_result_e_s;
	result(22 downto 0)	<=postnorm_result_man_s;

END BLOCK unpack;

-----------------------------------------------------------------
--
--
--
-----------------------------------------------------------------


zero_counter: PROCESS
BEGIN


END;

rounder:PROCESS
BEGIN
END;

normaliser:PROCESS
BEGIN
	IF operation_i='0' THEN 	--performing add
		IF  r_man_i(23) ='1' THEN		--adder carry
			postnorm_result_e_s	<=	slv(prenorm_result_e_s+1);
			postnorm_result_man_s	<=	
		END IF;
		



END;

=======
>>>>>>> 8662823138f707f7e5cb9525268b099ba3603ede:naive/add/postnorm_add_sub.vhd
END ARCHITECTURE rtl;
