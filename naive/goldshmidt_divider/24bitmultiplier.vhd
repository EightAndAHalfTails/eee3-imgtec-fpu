library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;
use config_pack.all;

ENTITY mult24bit IS
  PORT
    (A_in		:IN std_logic_vector(23 downto 0);
     B_in		:IN std_logic_vector(23 downto 0);
     C_out		:OUT std_logic_vector(23 downto 0)
      );
END ENTITY mult24bit;

ARCHITECTURE rtl OF mult24bit IS

SIGNAL prenorm_result 	:usg(47 downto 0);

BEGIN

compute_significand: PROCESS(A_in,B_in)
BEGIN
	prenorm_result<=usg(A_in)*usg(B_in);
END PROCESS compute_significand;

Rounding: PROCESS(prenorm_result)
BEGIN
	C_out<=slv(prenorm_result(46 downto 23));
END PROCESS rounding;

END ARCHITECTURE rtl;
