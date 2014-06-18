library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.types.all;

---------------------------------------------------
-- Normalised vector
---------------------------------------------------
-- This entity implements the Normalised vector
-- instruction, that is, x = a/sqrt(a^2+b^2+c^2)
---------------------------------------------------
entity vec is
  port(
    vec_in1,vec_in2,vec_in3: in std_logic_vector(31 downto 0);
    vec_out : out std_logic_vector(31 downto 0)
    );
end entity vec;

architecture chained of vec is

  signal result1,result2 : slv(31 downto 0);

begin  -- chained
  
  d3:entity dot3 port map (
    dot3_in1=> vec_in1,
    dot3_in2=> vec_in1,
    dot3_in3=> vec_in2,
    dot3_in4=> vec_in2,
    dot3_in5=> vec_in3,
    dot3_in6=> vec_in3,
    dot3_out=> result1
    );
  s1:entity isqrt port map (
    sqrt_in1=>result1,
    sqrt_out=>result2
    );
  m2:entity mult port map(
    mult_in1=>vec_in1,
    mult_in2=>result2,
    mult_out=>vec_out
    );
  
end vec;
