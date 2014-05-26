-------------------------------------------------------------------------------
-- Goldschmidt's method
-- div.vhd
-------------------------------------------------------------------------------

library ieee;
use IEEE.std_logic_1164<package name>.all;
use numeric_std.all;
use work..all;
use config_pack.all;

ENTITY div IS
  PORT
    (div_IN1:IN std_logic_vector(31 downto 0);
     div_IN2:IN std_logic_vector(31 downto 0);
     div_OUT:OUT std_logic_vector(31 downto 0)
      );
END ENTITY div;

ARCHITECTURE rtl of div is 

  type rom is array (0 to 15) of std_logic_vector(23 downto 0);
  

    
  SIGNAL A_si_s ,B_si_s  : std_logic;
  SIGNAL A_exp_s,B_exp_s : std_logic;
  SIGNAL A_man_s,B_man_s : std_logic_vector(22 downto 0);

  SIGNAL 


  constant lut:rom :=                     --A(22 downto 21)&B(22 downto 21)
(
    0=> "100000000000000000000000";       --0000=>1.0
    1=> "011001100110011001100110";       --0001=>0.8
    2=> "010101010101010101010101";       --0010=>0.66...
    3=> "010010010010010010010010";       --0011=>0.57142857
    4=> "101000000000000000000000";       --0100=>1.25
    5=> "100000000000000000000000";       --0101=>1.0
    6=> "011010101010101010101010";       --0110=>0.83..
    7=> "010110110110110110110110";       --0111=>0.71428571
    8=> "110000000000000000000000";       --1000=>1.5
    9=> "100110011001100110011001";       --1001=>1.2
    10=>"100000000000000000000000";       --1010=>1.0
    11=>"011011011011011011011011";       --1011=>0.85714286
    12=>"111000000000000000000000";       --1100=>1.75
    13=>"101100110011001100110011";       --1101=>1.4
    14=>"100101010101010101010101";       --1110=>1.16..
    15=>"100000000000000000000000";       --1111=>1.0
)


BEGIN
unpack:BLOCK
  BEGIN
    A_si_s<=div_IN1(31);
    A_e_s<=div_IN1(30 downto 23);
    A_man_s<=div_IN1(22 downto 0);
      
    B_si_s<=div_IN2(31);
    B_e_s<=div_IN2(30 downto 23);
    B_man_s<=div_IN2(22 downto 0);    
  END BLOCK unpack;

expo_logic:PROCESS()
  BEGIN
    



  END PROCESS expo_logic; 



  
  

END rtl;
