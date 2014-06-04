library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;
use work.types.all;

-- For fixed point division:
use ieee.fixed_float_types.all;
use ieee.fixed_pkg.all;

entity iter is
  port(
    init : in std_logic_vector(24 downto 0);
    prev : in std_logic_vector(24 downto 0);
    curr : out std_logic_vector(24 downto 0)
  );
end entity iter;

architecture baby of iter is
begin
  curr <= std_logic_vector(resize((to_ufixed(prev, 0, -24) + to_ufixed(init, 0, -24) / to_ufixed(prev, 0, -24)) / 2, 0, -24));
end architecture baby;  