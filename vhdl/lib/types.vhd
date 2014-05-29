library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real;
use work.all;

package types is
  alias sign_t is std_logic;
  subtype exponent_t is std_logic_vector(7 downto 0);
  subtype significand_t is std_logic_vector(22 downto 0);
  type float32_t is record
    sign : sign_t;
    exponent : exponent_t;
    significand : significand_t;
  end record;
end package types;