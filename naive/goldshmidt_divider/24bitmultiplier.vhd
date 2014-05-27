library ieee;
use IEEE.std_logic_1164.all;
use numeric_std.all;
use work.all;
use config_pack.all;

ENTITY 24bitmult IS
  PORT
    (A_in		:IN std_logic_vector(23 downto 0);
     B_in		:IN std_logic_vector(23 downto 0);
     C_out		:OUT std_logic_vector(23 downto 0)
      );
END ENTITY 24bitmult;

ARCHITECTURE rtl OF 24bitmult IS


SIGNAL prenorm_result 	:std_logic_vector(47 downto 0);

BEGIN

compute_significand: PROCESS
BEGIN
	prenorm_result<=A_in*B_in;
END PROCESS compute_significand;

Rounding: PROCESS
BEGIN
	C_out<=prenorm_result(46 downto 23);
END PROCESS rounding;

END ARCHITECTURE rtl;
