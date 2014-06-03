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
    multacc_in1, multacc_in2, multacc_in3 : in std_logic_vector(31 downto 0);
    multacc_out : out std_logic_vector(31 downto 0)
    );
end entity multacc;

architecture naive of multacc is
  signal product : std_logic_vector(31 downto 0);  
begin
  multiplier: entity mult port map(
    mult_in1 => multacc_in1,
    mult_in2 => multacc_in2,
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
    add_in2 => multacc_in3,
    add_out => multacc_out
  );
  ------------------------------
end architecture naive;

architecture fused of multacc is
  signal post_mult_sign : std_logic;
  signal post_mult_biased_exp : signed(8 downto 0);
  signal post_mult_significand : unsigned(47 downto 0); --with 2 integer bits
begin
  multiply : process(multacc_in1, multacc_in2)
    variable mult1, mult2 : float32;
  begin
    mult1 := slv2float(multacc_in1);
    mult2 := slv2float(multacc_in2);
    
    post_mult_sign <= mult1.sign xor mult2.sign;
    post_mult_biased_exp <= null;
    post_mult_significand <= null;
  end process multiply;
    
  
end architecture fused;
