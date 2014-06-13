--------------------------------------------------------------------------------------
--postnorm_add_sub.vhd
--------------------------------------------------------------------------------------
LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.all;
use work.types.all;

ENTITY postnorm_add_sub IS 
	PORT(
		r_sign_i		:	IN		sign_t;
		r_exponent_i		:	IN		std_logic_vector(7 downto 0);
		r_man_i			:	IN		std_logic_vector(28 downto 0);
		leadingzeros:IN integer range 0 to 28;
		result_o			:	OUT 		std_logic_vector(31 downto 0)
		);


END ENTITY postnorm_add_sub;

ARCHITECTURE rtl of postnorm_add_sub IS

SIGNAL prenorm_result_e_s		:exponent_t;
SIGNAL prenorm_result_man_s		:std_logic_vector(28 downto 0);

SIGNAL postnorm_result_e_s		:exponent_t;
SIGNAL postnorm_result_man_s		:std_logic_vector(25 downto 0);

SIGNAL result_denorm  :std_logic;
SIGNAL result         :float32_t;
BEGIN

--signals connecting to port
prenorm_result_e_s		<=	r_exponent_i;
prenorm_result_man_s		<=	r_man_i;


result_o<=float2slv(result);  --packing


result.sign		<=r_sign_i;

--denormal flag
result_denorm<='1'  WHEN  (usg(r_exponent_i)=0 AND r_man_i(28)='0') OR usg(r_exponent_i)<=leadingzeros ELSE '0';                --flag: result is denormal

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
    
    postnorm_result_e_s<=slv(usg(prenorm_result_e_s)+1);
	  postnorm_result_man_s(25 downto 1)<=prenorm_result_man_s(28 downto 4);
		postnorm_result_man_s(0)<=prenorm_result_man_s(3) OR prenorm_result_man_s(2) OR prenorm_result_man_s(1) OR prenorm_result_man_s(0);--recompute sticky bit (merge with round bit)
		
  ELSIF result_denorm='1' THEN                                    --result is denormal
    sft_exp:= (OTHERS=>'0');
    FOR i IN 0 TO 28 LOOP
		    IF i<usg(prenorm_result_e_s) THEN
		      sft_man(i):='0';      --pad zeros to the right of significand
		    ELSE 
		      sft_man(i):=prenorm_result_man_s(i-to_integer(usg(prenorm_result_e_s)));--left shift				
			  END IF;
		 END LOOP;  
		 
		postnorm_result_e_s<=sft_exp;
	  postnorm_result_man_s(25 downto 1)<=sft_man(28 downto 4);
		postnorm_result_man_s(0)<=sft_man(3) OR sft_man(2) OR sft_man(1) OR sft_man(0);--recompute sticky bit (merge with round bit)
		
  ELSE                                                            --if mantissa cancellation happens(result is with leading zeros) OR normal operation(01.man)
    
      sft_exp:= slv(usg(prenorm_result_e_s)-leadingzeros+1);
      FOR i IN 0 TO 28 LOOP
		    IF i<leadingzeros THEN
		      sft_man(i):='0';      --pad zeros to the right of significand
		    ELSE 
		      sft_man(i):=prenorm_result_man_s(i-leadingzeros);--left shift				
			  END IF;
		  END LOOP;
		  
		  if (sft_man(28)='0') then
	     postnorm_result_e_s<=slv(usg(sft_exp)-1);
	     postnorm_result_man_s(25 downto 1)<=sft_man(27 downto 3);
		    postnorm_result_man_s(0)<=sft_man(2) OR sft_man(1) OR sft_man(0);--recompute sticky bit (merge with round bit)
	    else
	     postnorm_result_e_s<=sft_exp;
	     postnorm_result_man_s(25 downto 1)<=sft_man(28 downto 4);
		   postnorm_result_man_s(0)<=sft_man(3) OR sft_man(2) OR sft_man(1) OR sft_man(0);--recompute sticky bit (merge with round bit)
	    end if;
	END IF;
	
	
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
	   result.exponent	 <=	(OTHERS=>'1');
	     IF usg(prenorm_result_man_s) =0 THEN 
	       result.significand	  <=	(OTHERS=>'1');   
	     ELSE
	       result.significand	  <=	(OTHERS=>'0');
	     END IF;
	ELSIF usg(prenorm_result_man_s)=0 THEN                             --result is zero
	   result.exponent	  <=	(OTHERS=>'0');
     result.significand	  <=	(OTHERS=>'0');
  ELSE
        result.exponent	  <=	rounded_result_e_s;
	   IF rounded_result_e_s="11111111" THEN                           --overflow 
	      result.significand	<=(OTHERS=>'0');	     
	   ELSE
	    
		    result.significand	<=	rounded_result_man_s(22 downto 0);	--1 bit shift adjustment

	  END IF;
	END IF;

END PROCESS rounder;

END ARCHITECTURE rtl;
