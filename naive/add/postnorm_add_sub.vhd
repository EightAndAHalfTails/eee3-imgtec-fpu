--------------------------------------------------------------------------------------
--postnorm_add_sub.vhd
--------------------------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.all;
USE config_pack.all;

ENTITY postnorm_add_sub IS 
	PORT(
		r_sign_i		:	IN		sign_t;
		r_exponent_i		:	IN		std_logic_vector(7 downto 0);
		r_man_i			:	IN		std_logic_vector(26 downto 0);
		result_o			:	OUT 		float32_t
		);


END ENTITY postnorm_add_sub;

ARCHITECTURE rtl of postnorm_add_sub IS

SIGNAL prenorm_result_e_s		:exponent_t;
SIGNAL prenorm_result_man_s		:std_logic_vector(26 downto 0);

SIGNAL postnorm_result_e_s		:exponent_t;
SIGNAL postnorm_result_man_s		:std_logic_vector(25 downto 0);

SIGNAL finalised_result_e_s		:exponent_t;
SIGNAL finalised_result_man_s		:significand_t;

SIGNAL leadingzeros			:integer range 0 to 27;

SIGNAL result_denorm  :std_logic;
BEGIN

--signals connecting to port
prenorm_result_e_s		<=	r_exponent_i;
prenorm_result_man_s		<=	r_man_i;

--------------------------------------------------------------------------------------
--packing
--This block is used to pack the separate sections up into a 32 bit 
--record
--------------------------------------------------------------------------------------
pack:BLOCK
BEGIN
	result_o.sign		<=r_sign_i;
	result_o.exponent	<=finalised_result_e_s;
	result_o.significand	<=finalised_result_man_s;
END BLOCK pack;

--denormal flag
result_denorm<='1'  WHEN  usg(r_exponent_i)=0 ELSE '0';                --flag: result is denormal
--------------------------------------------------------------------------------------
--leading zero detector
--The process detect the number of leading zeros in result to enable
--normalization in later stage
--------------------------------------------------------------------------------------

leading_zero_detector:PROCESS(prenorm_result_man_s)

VARIABLE count		:integer range 0 to 27;

BEGIN
  count:=0;
	
	FOR i IN prenorm_result_man_s'HIGH DOWNTO  prenorm_result_man_s'LOW LOOP
		IF prenorm_result_man_s(i)='0' 	THEN
		  count:=count+1;
		ELSE EXIT;
		END IF;
	END LOOP;
	
	leadingzeros	<= count;
END PROCESS leading_zero_detector;


--------------------------------------------------------------------------------------
--normaliser
--The process normalise the result to be a 26 bit output with hidden+mantissa+G+T
--ready for rounding
--------------------------------------------------------------------------------------
normaliser:PROCESS(prenorm_result_man_s,prenorm_result_e_s,leadingzeros)--result_denorm
BEGIN	
    
	postnorm_result_e_s	<=	prenorm_result_e_s;
	
	IF prenorm_result_man_s(26)='1' THEN							--if mantissa has overflowed(1x.man)
	
		postnorm_result_e_s <= slv(usg(prenorm_result_e_s)+1);				--add 1 to exponent
		
    		postnorm_result_man_s(25 downto 1)<= prenorm_result_man_s(26 downto 2);		--shift mantissa 1 bit to the right
		postnorm_result_man_s(0) <= prenorm_result_man_s(1) OR prenorm_result_man_s(0);	--recompute sticky bit

	ELSE											--if mantissa cancellation happens(result is with leading zeros) OR normal operation(01.man)
		postnorm_result_e_s <= slv(usg(prenorm_result_e_s)-leadingzeros+1);		
		
		FOR i IN 0 TO 25 LOOP
			IF i>=leadingzeros-1 AND i<26 THEN 				
				postnorm_result_man_s(i)<=prenorm_result_man_s(i-leadingzeros+1);--left shift
			ELSE
				postnorm_result_man_s(i)<='0';					--pad zeros to the right of significand
			END IF;
		END LOOP;
		
	END IF;	 
END PROCESS normaliser;

--------------------------------------------------------------------------------------
--rounder
--The process round the result to be to be 23 bit mantissa
--------------------------------------------------------------------------------------
rounder:PROCESS(postnorm_result_man_s,postnorm_result_e_s,prenorm_result_man_s,prenorm_result_e_s,result_denorm)

VARIABLE rounded_result_e_s		:exponent_t;
VARIABLE rounded_result_man_s		:slv(23 downto 0);

BEGIN
	rounded_result_e_s			:=postnorm_result_e_s;

	CASE postnorm_result_man_s(2 downto 0) IS						--rounding decoder(LSB+GUARD+STICKY)  RTE rounding mode
	WHEN "000"|"001"|"010"|"100"|"101"	=>rounded_result_man_s := '0'&postnorm_result_man_s(24 downto 2);			--round down
	WHEN "011"|"110"|"111"			=>rounded_result_man_s := slv(RESIZE(usg(postnorm_result_man_s(24 downto 2)),24)+1);	--round up
	WHEN OTHERS => NULL;
	END CASE;
	
	IF rounded_result_man_s(23)='1' THEN							--rounded result with overflow
		finalised_result_man_s	<=	rounded_result_man_s(23 downto 1);		--1 bit shift adjustment
		finalised_result_e_s	<=	slv(usg(rounded_result_e_s)+1);
	ELSE											--otherwise
	  IF result_denorm = '1' THEN 
	      finalised_result_man_s	<=	prenorm_result_man_s(25 downto 3);
	      finalised_result_e_s	  <=	prenorm_result_e_s;
	  ELSE
		    finalised_result_man_s	<=	rounded_result_man_s(22 downto 0);
	      finalised_result_e_s	<=	rounded_result_e_s;
	  END IF;
	END IF;

END PROCESS rounder;

END ARCHITECTURE rtl;
