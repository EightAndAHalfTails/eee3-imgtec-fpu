library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.types.all;

---------------------------------------------------
-- 3D dot product
---------------------------------------------------
-- This entity implements the 3D dot product
-- instruction, that is, x = ab + cd + ef
---------------------------------------------------
entity dot3 is
  port(
    dot3_in1, dot3_in2, dot3_in3, dot3_in4, dot3_in5, dot3_in6: in std_logic_vector(31 downto 0);
    dot3_out : out std_logic_vector(31 downto 0)
    );
end entity dot3;

architecture chained of dot3 is

  signal result : slv(31 downto 0);

begin  -- chained
  
  d2:entity dot2 port map (
    dot2_in1=> dot3_in1,
    dot2_in2=> dot3_in2,
    dot2_in3=> dot3_in3,
    dot2_in4=> dot3_in4,
    dot2_out=> result
    );
  fma:entity multacc port map (
    multacc_in1 => dot3_in5,
    multacc_in2 => dot3_in6,
    multacc_in3 => result,
    multacc_out => dot3_out
    );
  
end chained;
