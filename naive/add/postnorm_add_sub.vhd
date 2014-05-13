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
		r_sign_i		:	IN		std_logic;
		operation_i		:	IN		std_logic;
		r_exponent_i		:	IN		std_logic_vector(7 downto 0);
		r_man_i			:	IN		std_logic_vector(27 downto 0);
		result_o		:	OUT 		std_logic_vector(31 downto 0)
		);


END ENTITY postnorm_add_sub;

ARCHITECTURE rtl of postnorm_add_sub IS

BEGIN

ALIAS slv IS std_logic_vector;
ALIAS usg IS unsigned;
ALIAS sgn IS signed;

SIGNAL prenorm_result_e_s		:std_logic_vector(7 downto 0);
SIGNAL prenorm_result_man_s		:std_logic_vector(27 downto 0);


SIGNAL postnorm_result_e_s		:std_logic_vector(7 downto 0);
SIGNAL postnorm_result_man_s		:std_logic_vector(26 downto 0);


SIGNAL finalised_result_e_s		:std_logic_vector(7 downto 0);
SIGNAL finalised_result_man_s		:std_logic_vector(22 downto 0);


SIGNAL leadingzeros			:integer range 0 to 26;


prenorm_result_e_s	<=	r_exponent_i;
prenorm_result_man_s	<=	r_man_i;

-----------------------------------------------------------------
--packing
--This block is used to pack the separate sections up into a 32 bit 
--floating point number
-----------------------------------------------------------------

pack:BLOCK
BEGIN
	result_o(31)		<=r_sign_i;
	result_o(30 downto 23)	<=finalised_result_e_s;
	result(22 downto 0)	<=finalised_result_man_s;

END BLOCK pack;

-----------------------------------------------------------------
--leading zero detector
--The process detect the number of leading zeros in result to enable
--normalization in later stage
-----------------------------------------------------------------

leading_zero_detector:PROCESS(prenorm_result_man_s)

VARIABLE count		:integer range 0 to 27;

BEGIN

	FOR i IN prenorm_result_man_s'high TO  prenorm_result_man_s'low LOOP
		IF prenorm_result_man_s(i)='0' 	count:=count+1;
		ELSE EXIT;
	END LOOP;
	
	leadingzeros	<= count-1;
END PROCESS leading_zero_detector;


-----------------------------------------------------------------
--normaliser
--The process normalise the result to be a 27 bit output with hidden+mantissa+G+R+T
--ready for rounding
-----------------------------------------------------------------
normaliser:PROCESS(prenorm_result_man_s,prenorm_result_e_s,leadingzeros)
BEGIN	
	postnorm_result_e_s	<=	prenorm_result_e_s;
	IF prenorm_result_man_s(27)='1' THEN						--if mantissa has overflowed
	
		postnorm_result_e_s <= slv(usg(prenorm_result_e_s)+1);

		postnorm_result_man_s(26 downto 1) <= prenorm_result_man_s(27 downto 2) SRL 1;
		postnorm_result_man_s(0) <= prenorm_result_man_s(1) OR prenorm_result_man_s(0);

	ELSE										--if mantissa cancellation happens
	--ELSIF postnorm_result_man_s='0' THEN		
		postnorm_result_e_s <= slv(usg(prenorm_result_e_s)-leadingzeros);
		
		FOR i IN 0 TO 26 LOOP
			IF i>leadingzeros AND i<27 THEN 				
				postnorm_result_man_s(i)<=prenorm_result_man_s(i-leadingzeros);--right shift
			ELSE
				postnorm_result_man_s(i)<='0';					--zero padding
			END IF;
		END LOOP;
	--ELSE
	--			postnorm_result_e_s<=prenorm_result_e_s;
	--			postnorm_result_man_s<=prenorm_result_man_s(26 downto 0);
	--END IF;
		
	END IF;	 
END PROCESS normaliser;

-----------------------------------------------------------------
--rounder
--The process round the result to be to be 23 bit mantissa
-----------------------------------------------------------------
rounder:PROCESS(postnorm_result_man_s,postnorm_result_e_s)

VARIABLE rounded_result_e_s		:std_logic_vector(7 downto 0);
VARIABLE rounded_result_man_s		:std_logic_vector(23 downto 0);

BEGIN
	rounded_result_e_s	:=postnorm_result_e_s;
	CASE postnorm_result_e_s(2 downto 0) IS
	WHEN "000"|"001"|"010"|"100"|"101"	=>rounded_result_man_s := '0'&postnorm_result_man_s(25 downto 3);
	WHEN "011"|"110"|"111"			=>rounded_result_man_s := slv(RESIZE(usg(postnorm_result_man_s(25 downto 3)),24)+1);
	END CASE;
	
	IF rounded_result_man_s(23)='1' THEN
		finalised_result_man_s	<=	rounded_result_man_s(23 downto 1);	
		finalised_result_e_s	<=	slv(usg(rounded_result_e_s)+1);
	ELSE
		finalised_result_man_s	<=	rounded_result_man_s(22 downto 0);
		finalised_result_e_s	<=	rounded_result_e_s;
	END IF;

END;

END ARCHITECTURE rtl;
