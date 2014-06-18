library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.types.all;

---------------------------------------------------
-- 2D Euclidean distance
---------------------------------------------------
-- This entity implements the 2D Euclidean distance
-- instruction, that is, x = sqrt(a^2+b^2)
---------------------------------------------------
entity dist2 is
  port(
    dist2_in1, dist2_in2: in std_logic_vector(31 downto 0);
    dist2_out : out std_logic_vector(31 downto 0)
    );
end entity dist2;

architecture chained of dist2 is

  signal result : slv(31 downto 0);

begin  -- chained
  
  d2:entity dot2 port map (
    dot2_in1=> dist2_in1,
    dot2_in2=> dist2_in1,
    dot2_in3=> dist2_in2,
    dot2_in4=> dist2_in2,
    dot2_out=> result
    );
  s1:entity sqrt port map (
    sqrt_in1=>result,
    sqrt_out=>dist2_out
    );
  
end chained;
