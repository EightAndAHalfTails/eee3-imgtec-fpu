-------------------------------------------------------------------------------
-- Goldschmidt's method
-- div.vhd
-------------------------------------------------------------------------------

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;
use config_pack.all;

ENTITY div IS
  GENERIC (lsize :integer :=3);
  PORT
    (div_IN1:IN std_logic_vector(31 downto 0);
     div_IN2:IN std_logic_vector(31 downto 0);
     div_OUT:OUT std_logic_vector(31 downto 0)
      );
END ENTITY div;

ARCHITECTURE rtl of div is 

  type rom is array (0 to 15) of std_logic_vector(26 downto 0);
  type intermediate is array (0 to lsize) of std_logic_vector(26 downto 0);  -- intermediate signals

    
  SIGNAL A_si_s ,B_si_s  : std_logic;
  SIGNAL A_e_s,B_e_s 	 : std_logic_vector(7 downto 0);
  SIGNAL A_significand_s,B_significand_s,sft_B_significand_s: std_logic_vector(26 downto 0);

  signal selection       : integer range 0 to 15;          -- select rom content

  SIGNAL n,d,f           : intermediate;
  
  SIGNAL x_0		 : slv(26 downto 0);
  SIGNAL leadingzeros: integer range 0 to 27;
  SIGNAL prenorm_result_exception:std_logic;
  SIGNAL div_opA_is_zero,div_opB_is_zero,div_opA_is_infinity,div_opB_is_infinity,div_opA_is_normal,div_opB_is_normal:std_logic;
  
  SIGNAL prenorm_e_s	 :slv(8 downto 0);
  SIGNAL prenorm_significand_s  : slv(26 downto 0);

  SIGNAL postnorm_e_s	 :slv(7 downto 0);
  SIGNAL postnorm_man_s	 :slv(24 downto 0);

  SIGNAL finalised_si_s  : std_logic;
  SIGNAL finalised_e_s   : std_logic_vector(7 downto 0);
  SIGNAL finalised_man_s : std_logic_vector(22 downto 0);

  CONSTANT lut :rom := (                 --1/1.B(22 downto 19)
    0=> "100000000000000000000000000",       --1/1.0000=>
    1=> "011110000111100001111000100",       --1/1.0001=>
    2=> "011100011100011100011100100",       --1/1.0010=>
    3=> "011010111100101000011011000",       --1/1.0011=>
    4=> "011001100110011001100110011",       --1/1.0100=>
    5=> "011000011000011000011000011",       --1/1.0101=>
    6=> "010111010001011101000101111",       --1/1.0110=>
    7=> "010110010000101100100001011",       --1/1.0111=>
    8=> "010101010101010101010101011",       --1/1.1000=>
    9=> "010100011110101110000101001",       --1/1.1001=>
    10=>"010011101100010011101100010",       --1/1.1010=>
    11=>"010010111101101000010011000",       --1/1.1011=>
    12=>"010010010010010010010010010",       --1/1.1100=>
    13=>"010001101001111011100101100",       --1/1.1101=>
    14=>"010001000100010001000100010",       --1/1.1110=>
    15=>"010000100001000010000100001"        --1/1.1111=>
);


BEGIN
------------------------------------------------------
--flag signals
------------------------------------------------------
div_opA_is_zero<='1' WHEN usg(div_IN1(30 downto 0))=0 ELSE '0'; 
div_opB_is_zero<='1' WHEN usg(div_IN2(30 downto 0))=0 ELSE '0'; 
div_opA_is_infinity<='1' WHEN div_IN1(30 downto 0)="1111111100000000000000000000000" ELSE '0'; 
div_opB_is_infinity<='1' WHEN div_IN2(30 downto 0)="1111111100000000000000000000000" ELSE '0'; 
div_opA_is_normal<='0' WHEN usg(div_IN1(30 downto 23))=0 AND usg(div_IN1(22 DOWNTO 0))/=0 ELSE '1'; 
div_opB_is_normal<='0' WHEN usg(div_IN2(30 downto 23))=0 AND usg(div_IN2(22 DOWNTO 0))/=0 ELSE '1'; 


prenorm_result_exception<='1' WHEN prenorm_e_s(8)='1' OR usg(prenorm_e_s)=0 ELSE '0';
------------------------------------------------------
--unpack the inputs
------------------------------------------------------
unpack:BLOCK
  BEGIN
    A_si_s<=div_IN1(31);
    A_e_s<=div_IN1(30 downto 23);
    A_significand_s<=div_opA_is_normal&div_IN1(22 downto 0)&"000";  --modified to 27 bits(Hidden+man+3bit guard)
      
    B_si_s<=div_IN2(31);
    B_e_s<=div_IN2(30 downto 23);
    B_significand_s<=div_opb_is_normal&div_IN2(22 downto 0)&"000";

--    selection<=to_integer(usg(div_IN2(22 downto 19))); --choose initial guess 
  END BLOCK unpack;

--------------------------------------------------------------------------------------
--leading zero detector
--The process detect the number of leading zeros in result to enable
--normalization in later stage
--------------------------------------------------------------------------------------

leading_zero_detector:PROCESS(B_significand_s)

VARIABLE count		:integer range 0 to 27;
VARIABLE sft_B  :usg(26 downto 0);
BEGIN
  count:=0;
  sft_B:=usg(B_significand_s);
	FOR i IN B_significand_s'HIGH DOWNTO  B_significand_s'LOW LOOP
		IF B_significand_s(i)='0' 	THEN
		  count:=count+1;
		  sft_B:=sft_B sll 1;
		ELSE EXIT;
		END IF;
	END LOOP;
	sft_B_significand_s<=slv(sft_B);
	selection<=to_integer(sft_B(25 downto 22));          --choose initial guess 
	leadingzeros	<= count;
END PROCESS leading_zero_detector;
------------------------------------------------------
--pack outputs
------------------------------------------------------
div_OUT(31)<=finalised_si_s;
div_OUT(30 downto 23)<=finalised_e_s;
div_OUT(22 downto 0)<=finalised_man_s;

x_0<=lut(selection);

------------------------------------------------------
--significand division (range of result: 0.5<x<2)
--    	   N f(0) f(1) f(2) f(3)
--compute -*----*----*----*---- such that the dividend 
--        D f(0) f(1) f(2) f(3)  
--converges to 1.
------------------------------------------------------
div_gen:FOR i in 0 to lsize GENERATE	
	case0: IF i=0 GENERATE                                 -- first iteration
    		mult0:ENTITY mult27bit 	-- d(0)=x_0*b              -- multiplied by a initial guess of 
		PORT MAP (                                           -- 1/b to try to set dividend to 1  
   		    A_in  => x_0,                                   
        	B_in  => sft_B_significand_s,
        	C_out => d(0)
		);

    		f(0)<=NOT d(0); 	                                  -- f=1-d(0)                      

	   	mult1:ENTITY mult27bit 	-- n(0)=a*x_0              -- multiply with initial guess accordingly
		PORT MAP (
        	A_in  => x_0,
        	B_in  => A_significand_s,
        	C_out => n(0)
		); 
    	end generate case0;
	
	case1: IF i>0 GENERATE                                 --multiply with f
		mult3:ENTITY mult27bit 	-- d=d*f                     
		PORT MAP (
        	A_in  => d(i-1),
        	B_in  => f(i-1),
        	C_out => d(i)
		);
		f(i)<= NOT d(i);	                                    -- f=1-d                            
		mult4:ENTITY mult27bit 	-- n=n*f                     --multiply with f
		PORT MAP (
        	A_in  => n(i-1),
        	B_in  => f(i-1),
        	C_out => n(i)
		);
	END GENERATE case1;
END GENERATE div_gen;

------------------------------------------------------
--ready for normalization
------------------------------------------------------
prenorm_significand_s	<=n(lsize);	--use the final result as output
prenorm_e_s		<=slv(RESIZE(usg(A_e_s),9)-RESIZE(usg(B_e_s),9)+127);


------------------------------------------------------
--normalization
------------------------------------------------------
normalise:PROCESS (prenorm_e_s,prenorm_significand_s,prenorm_result_exception,A_e_s)
--VARIABLE sticky_b :std_logic;
--VARIABLE sft_man  :slv(24 downto 0);
VARIABLE sft_unit   :integer range 0 to 255;
BEGIN
  sft_unit:=to_integer(usg(NOT prenorm_e_s(7 downto 0))+1);--TO_INTEGER(abs(sgn(prenorm_e_s)));
  IF prenorm_result_exception='1' AND A_e_s(7)='0' THEN
    postnorm_e_s<=(OTHERS=>'0');
    FOR i in 0 to 24 LOOP
      --IF i<abs(sgn(prenorm_e_s))+2 THEN
       -- sticky_b:=sticky_b&prenorm_significand_s(i)
      IF i+sft_unit<25 THEN
        postnorm_man_s(i)<=prenorm_significand_s(i+sft_unit+2);
      ELSE
        postnorm_man_s(i)<='0';
      END IF;
      
    END LOOP;
ELSE
	   IF prenorm_significand_s(26)='1' THEN 
		    postnorm_e_s<=prenorm_e_s(7 downto 0);
		    postnorm_man_s(24 downto 1)<=prenorm_significand_s(25 downto 2);
		    postnorm_man_s(0)<=prenorm_significand_s(1) OR prenorm_significand_s(0);
	   ELSE
		    postnorm_e_s<=slv(usg(prenorm_e_s(7 downto 0))-1);
		    postnorm_man_s<=prenorm_significand_s(24 downto 0);
	   END IF;
END IF;

END PROCESS normalise;
 
------------------------------------------------------
--rounding
------------------------------------------------------
rounding: PROCESS(postnorm_man_s,postnorm_e_s,A_e_s,prenorm_result_exception,div_opA_is_zero,div_opB_is_zero,div_opA_is_infinity,div_opB_is_infinity)
  VARIABLE rounded_result_man_s :slv(23 downto 0);
  VARIABLE rounded_result_e_s   :slv(7 downto 0);
  
BEGIN
  CASE postnorm_man_s(2 downto 0) IS						--rounding decoder(LSB+GUARD+STICKY)  RTE rounding mode
	WHEN "000"|"001"|"010"|"100"|"101"	=>rounded_result_man_s := '0'&postnorm_man_s(24 downto 2);			--round down
	WHEN "011"|"110"|"111"			=>rounded_result_man_s := slv(RESIZE(usg(postnorm_man_s(24 downto 2)),24)+1);	--round up
	WHEN OTHERS => NULL;
	END CASE;   
	
	   IF rounded_result_man_s(23)='1' THEN
	     rounded_result_e_s:=slv(usg(postnorm_e_s)+1);
	   ELSE
	     rounded_result_e_s			:=postnorm_e_s;
	   END IF;
IF (div_opA_is_zero OR div_opA_is_infinity)='1' THEN
    IF (div_opA_is_zero AND div_opB_is_zero)='1' OR (div_opA_is_infinity AND div_opB_is_zero)='1' THEN
       finalised_e_s<= (OTHERS=>'1');
       finalised_man_s<= (0=>'1',OTHERS=>'0');
    ELSE
       finalised_e_s<= (OTHERS=>'0');
       finalised_man_s<= (OTHERS=>'0');
    END IF;    
ELSIF (div_opB_is_zero OR div_opA_is_infinity) = '1'THEN
       finalised_e_s<= (OTHERS=>'1');
       finalised_man_s<= (OTHERS=>'0');
ELSE
	IF prenorm_result_exception ='1' THEN
	   IF  A_e_s(7) ='1' THEN
       finalised_e_s<= (OTHERS=>'1');
	     finalised_man_s<=(OTHERS=>'0');
	   ELSE
	     finalised_e_s<= (OTHERS=>'0'); 
	     finalised_man_s<=rounded_result_man_s(22 downto 0);	
	   END IF;	
	ELSE
	   finalised_e_s<=rounded_result_e_s;
	   finalised_man_s<=rounded_result_man_s(22 downto 0);	
	END IF;
END IF;
END PROCESS rounding;

finalised_si_s<=A_si_s XOR B_si_s;

END rtl;



--  constant lut1:rom :=                     --A(22 downto 21)&B(22 downto 21)
--(
--    0=> "100000000000000000000000";       --0000=>1.0
--    1=> "011001100110011001100110";       --0001=>0.8
--    2=> "010101010101010101010101";       --0010=>0.66...
--    3=> "010010010010010010010010";       --0011=>0.57142857
--    4=> "101000000000000000000000";       --0100=>1.25
--    5=> "100000000000000000000000";       --0101=>1.0
--    6=> "011010101010101010101010";       --0110=>0.83..
--    7=> "010110110110110110110110";       --0111=>0.71428571
--    8=> "110000000000000000000000";       --1000=>1.5
--    9=> "100110011001100110011001";       --1001=>1.2
--    10=>"100000000000000000000000";       --1010=>1.0
--    11=>"011011011011011011011011";       --1011=>0.85714286
--    12=>"111000000000000000000000";       --1100=>1.75
--    13=>"101100110011001100110011";       --1101=>1.4
--    14=>"100101010101010101010101";       --1110=>1.16..
--    15=>"100000000000000000000000";       --1111=>1.0
--)
