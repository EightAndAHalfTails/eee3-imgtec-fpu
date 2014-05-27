-------------------------------------------------------------------------------
-- Goldschmidt's method
-- div.vhd
-------------------------------------------------------------------------------

library ieee;
use IEEE.std_logic_1164.all;
use numeric_std.all;
use work.all;
use config_pack.all;

ENTITY div IS
  GENERIC (lsize :integer :=10);
  PORT
    (div_IN1:IN std_logic_vector(31 downto 0);
     div_IN2:IN std_logic_vector(31 downto 0);
     div_OUT:OUT std_logic_vector(31 downto 0)
      );
END ENTITY div;

ARCHITECTURE rtl of div is 

  type rom is array (0 to 15) of std_logic_vector(23 downto 0);
  type intermediate is array (0 to lsize) of std_logic_vector(23 downto 0);  -- intermediate signals

    
  SIGNAL A_si_s ,B_si_s  : std_logic;
  SIGNAL A_e_s,B_e_s 	 : std_logic_vector(7 downto 0);
  SIGNAL A_significand_s,B_significand_s : std_logic_vector(23 downto 0);

  signal selection       : interger range in 0 to 15;          -- select rom content

  SIGNAL n,d,f           : intermediate;
  
  SIGNAL x_0		 : slv(23 downto 0);

  SIGNAL prenorm_e_s	 :slv(7 downto 0)
  SIGNAL prenorm_significand_s  : slv(23 downto 0);

  SIGNAL postnorm_e_s	 :slv(7 downto 0);
  SIGNAL postnorm_man_s	 :slv(22 downto 0);

  SIGNAL finalised_si_s  : std_logic;
  SIGNAL finalised_e_s   : std_logic_vector(7 downto 0);
  SIGNAL finalised_man_s : std_logic_vector(22 downto 0);

    constant lut2:rom :=                  --1/B(22 downto 19)
(
    0=> "100000000000000000000000";       --0000=>
    1=> "011110000111100001111000";       --0001=>
    2=> "011100011100011100011100";       --0010=>
    3=> "011010111100101000011011";       --0011=>
    4=> "011001100110011001100110";       --0100=>
    5=> "011000011000011000011000";       --0101=>
    6=> "010111010001011101000110";       --0110=>
    7=> "010110010000101100100001";       --0111=>
    8=> "010101010101010101010101";       --1000=>
    9=> "010100011110101110000101";       --1001=>
    10=>"010011101100010011101100";       --1010=>
    11=>"010010111101101000010011";       --1011=>
    12=>"010010010010010010010010";       --1100=>
    13=>"010001101001111011100110";       --1101=>
    14=>"010001000100010001000100";       --1110=>
    15=>"010000100001000010000100";       --1111=>
)


BEGIN
------------------------------------------------------
--unpack the inputs
------------------------------------------------------
unpack:BLOCK
  BEGIN
    A_si_s<=div_IN1(31);
    A_e_s<=div_IN1(30 downto 23);
    A_significand_s<=div_IN1(22 downto 0);
      
    B_si_s<=div_IN2(31);
    B_e_s<=div_IN2(30 downto 23);
    B_significand_s<=div_IN2(22 downto 0);

    selection<=to_integer(div_IN2(22 downto 19));
  END BLOCK unpack;

------------------------------------------------------
--pack outputs
------------------------------------------------------
div_OUT(31)<=finalised_si_s;
div_OUT(30 downto 23)<=finalised_e_s;
div_OUT(22 downto 0)<=finalised_man_s;

------------------------------------------------------
--significand division (range of result: 0.5<x<2)
------------------------------------------------------
div_gen:FOR i in 0 to lsize GENERATE	
	case0: IF i=0 GENERATE
      		mult0:ENTITY 24bitmult 	-- d(0)=x_0*b
		PORT MAP (
     		A_in  => x_0,
        	B_in  => B_significand_s,
        	C_out => d(0)
		);

    		f(0)<=NOT d(0); 	-- f=1-d(0)

	   	mult1:ENTITY 24bitmult 	-- n(0)=a*x_0
		PORT MAP (
        	A_in  => x_0,
        	B_in  => A_significand_s,
        	C_out => n(0)
		); 
    	end generate case0;
	
	case1: IF i>0 GENERATE
		mult3:ENTITY 24bitmult 	-- d=d*f
		PORT MAP (
        	A_in  => d(i-1),
        	B_in  => f(i-1),
        	C_out => d(i)
		);
		f(i)<= NOT d(i);	-- f=1-d
		mult4:ENTITY 24bitmult 	-- n=n*f
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
prenorm_e_s		<=slv(usg(A_e_s)-usg(B_e_s)+127);
------------------------------------------------------
--normalization
------------------------------------------------------
normalise:PROCESS 

	IF prenorm_result(24)='1' THEN 
		postnorm_e_s<=prenorm_e_s;
		postnorm_man_s<=prenorm_significand_s(22 downto 0);
	ELSE
		postnorm_e_s<=slv(prenorm_e_s-1);
		postnorm_man_s<=prenorm_significand_s(21 downto 0)&'0';
	END IF;

END PROCESS normalise;
 
------------------------------------------------------
--rounding
------------------------------------------------------
--rounding: PROCESS
--BEGIN
	finalised_si_s<=A_si_s XOR B_si_s;
	finalised_e_s<=postnorm_e_s;
	finalised_man_s<=postnorm_man_s;	
--END PROCESS rounding;

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
