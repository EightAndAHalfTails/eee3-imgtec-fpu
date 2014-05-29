library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;
use work.types.all;

entity iter is
  port(
    init : in std_logic_vector(24 downto 0);
    prev : in std_logic_vector(24 downto 0);
    curr : out std_logic_vector(24 downto 0)
  );
end entity iter;

architecture baby of iter is
begin
  curr <= std_logic_vector((unsigned(prev) + unsigned(init) / unsigned(prev)) / 2);
end architecture baby;  