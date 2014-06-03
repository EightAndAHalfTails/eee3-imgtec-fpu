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
    mult_in1 => a_in,
    mult_in2 => b_in,
    mult_out => product
    );

  ------------------------------
  -- Placeholder adder.
  ------------------------------
  -- TODO: Either replace this
  -- with the actual adder, or
  -- modify adder to fit this
  -- specification
  ------------------------------
  adder: entity addsub port map(
    add_in1 => product,
    add_in2 => c_in,
    operation_i => '0',
    add_out => x_out
  );
  ------------------------------
end architecture naive;
