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
		r_exponent_i		:	IN		std_logic_vector(8 downto 0);
		r_man_i			:	IN		std_logic_vector(23 downto 0);
		sticky_b		:	IN		std_logic;
		result_o		:	OUT 		std_logic_vector(31 downto 0);		
		)

END ENTITY postnorm_add_sub;

ARCHITECTURE rtl of postnorm_add_sub IS

BEGIN

END ARCHITECTURE rtl;
