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
		r_man_i			:	IN		std_logic_vector(28 downto 0);
		result_o			:	OUT 		float32_t
		);


END ENTITY postnorm_add_sub;

ARCHITECTURE rtl of postnorm_add_sub IS

SIGNAL prenorm_result_e_s		:exponent_t;
SIGNAL prenorm_result_man_s		:std_logic_vector(28 downto 0);

SIGNAL postnorm_result_e_s		:exponent_t;
SIGNAL postnorm_result_man_s		:std_logic_vector(25 downto 0);

SIGNAL finalised_result_e_s		:exponent_t;
SIGNAL finalised_result_man_s		:significand_t;

SIGNAL leadingzeros			:integer range 0 to 29;

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
result_denorm<='1'  WHEN  (usg(r_exponent_i)=0 AND r_man_i(28)='0') OR usg(r_exponent_i)<leadingzeros ELSE '0';                --flag: result is denormal
--------------------------------------------------------------------------------------
--leading zero detector
--The process detect the number of leading zeros in result to enable
--normalization in later stage
--------------------------------------------------------------------------------------

leading_zero_detector:PROCESS(prenorm_result_man_s)

VARIABLE count		:integer range 0 to 29;

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
normaliser:PROCESS(prenorm_result_man_s,prenorm_result_e_s,leadingzeros,result_denorm)
    VARIABLE sft_man: slv(28 downto 0);
    VARIABLE sft_exp: slv(7 downto 0);
BEGIN	
  
  IF prenorm_result_man_s(28)='1' THEN	                           --if mantissa has overflowed(1x.man)
    sft_exp:=slv(usg(prenorm_result_e_s)+1);                      --add 1 to exponent
    sft_man:=prenorm_result_man_s;
  ELSIF result_denorm='1' THEN                                    --result is denormal
    sft_exp:= (OTHERS=>'0');
    FOR i IN 0 TO 28 LOOP
		    IF i<usg(prenorm_result_e_s) THEN
		      sft_man(i):='0';      --pad zeros to the right of significand
		    ELSE 
		      sft_man(i):=prenorm_result_man_s(i-to_integer(usg(prenorm_result_e_s)));--left shift				
			  END IF;
		 END LOOP;  
  ELSE                                                            --if mantissa cancellation happens(result is with leading zeros) OR normal operation(01.man)
    
      sft_exp:= slv(usg(prenorm_result_e_s)-leadingzeros+1);
      FOR i IN 0 TO 28 LOOP
		    IF i<leadingzeros THEN
		      sft_man(i):='0';      --pad zeros to the right of significand
		    ELSE 
		      sft_man(i):=prenorm_result_man_s(i-leadingzeros);--left shift				
			  END IF;
		  END LOOP;
		  		
	END IF;
	
	  postnorm_result_e_s<=sft_exp;
	  
	  postnorm_result_man_s(25 downto 1)<=sft_man(28 downto 4);
		postnorm_result_man_s(0)<=sft_man(3) OR sft_man(2) OR sft_man(1) OR sft_man(0);--recompute sticky bit (merge with round bit)
END PROCESS normaliser;

--------------------------------------------------------------------------------------
--rounder
--The process round the result to be to be 23 bit mantissa
--------------------------------------------------------------------------------------
rounder:PROCESS(postnorm_result_man_s,postnorm_result_e_s,prenorm_result_man_s,prenorm_result_e_s)

VARIABLE rounded_result_e_s		:exponent_t;
VARIABLE rounded_result_man_s		:slv(23 downto 0);

BEGIN
	
	CASE postnorm_result_man_s(2 downto 0) IS						--rounding decoder(LSB+GUARD+STICKY)  RTE rounding mode
	WHEN "000"|"001"|"010"|"100"|"101"	=>rounded_result_man_s := '0'&postnorm_result_man_s(24 downto 2);			--round down
	WHEN "011"|"110"|"111"			=>rounded_result_man_s := slv(RESIZE(usg(postnorm_result_man_s(24 downto 2)),24)+1);	--round up
	WHEN OTHERS => NULL;
	END CASE;
	IF rounded_result_man_s(23)='1' THEN
	  rounded_result_e_s:=slv(usg(postnorm_result_e_s)+1);
	ELSE
	  rounded_result_e_s			:=postnorm_result_e_s;
	END IF;
	
	IF usg(prenorm_result_e_s)=255 THEN                                --INPUT NaN or infinity
	   finalised_result_e_s	  <=	(OTHERS=>'1');
	     IF usg(prenorm_result_man_s) =0 THEN 
	       finalised_result_man_s	  <=	(0=>'1',OTHERS=>'0');   
	     ELSE
	        finalised_result_man_s	  <=	(OTHERS=>'0');
	     END IF;
	ELSIF usg(prenorm_result_man_s)=0 THEN                             --result is zero
	   finalised_result_e_s	  <=	(OTHERS=>'0');
     finalised_result_man_s	  <=	(OTHERS=>'0');
  ELSE
        finalised_result_e_s	  <=	rounded_result_e_s;
	   IF rounded_result_e_s="11111111" THEN                           --overflow 
	      finalised_result_man_s	<=(OTHERS=>'0');	     
	   ELSE
	    IF rounded_result_man_s(23)='1' THEN						                     --mantissa overflow
		    finalised_result_man_s	<=	rounded_result_man_s(23 downto 1);	--1 bit shift adjustment
	    ELSE											                                             --otherwise
		    finalised_result_man_s	<=	rounded_result_man_s(22 downto 0);
	    END IF;
	  END IF;
	END IF;

END PROCESS rounder;

END ARCHITECTURE rtl;
