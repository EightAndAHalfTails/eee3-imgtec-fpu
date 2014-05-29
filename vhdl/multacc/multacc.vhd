library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

---------------------------------------------------
-- Multiply-Accumulate
---------------------------------------------------
-- This entity implements the multiply-accumulate
-- instruction, that is, x = ab + c
---------------------------------------------------

entity multacc is
  port(
    a_in, b_in, c_in : in std_logic_vector(31 downto 0);
    x_out : out std_logic_vector(31 downto 0)
    );
end entity multacc;

architecture naive of multacc is
  signal product : std_logic_vector(31 downto 0);  
begin
  multiplier: entity mult port map(
    a_in => a_in,
    b_in => b_in,
    product_out => product
    );

  ------------------------------
  -- Placeholder adder.
  ------------------------------
  -- TODO: Either replace this
  -- with the actual adder, or
  -- modify adder to fit this
  -- specification
  ------------------------------
  adder: entity add port map(
    a_in => product,
    b_in => c_in,
    sum_out => x_out
  );
  ------------------------------
end architecture naive;
