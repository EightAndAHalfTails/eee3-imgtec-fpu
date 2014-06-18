library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.types.all;

---------------------------------------------------
-- 3D Euclidean distance
---------------------------------------------------
-- This entity implements the 3D Euclidean distance
-- instruction, that is, x = sqrt(a^2+b^2)
---------------------------------------------------
entity dist3 is
  port(
    dist3_in1,dist3_in2,dist3_in3: in std_logic_vector(31 downto 0);
    dist3_out : out std_logic_vector(31 downto 0)
    );
end entity dist3;

architecture chained of dist3 is

  signal result : slv(31 downto 0);

begin  -- chained
  
  d3:entity dot3 port map (
    dot3_in1=> dist3_in1,
    dot3_in2=> dist3_in1,
    dot3_in3=> dist3_in2,
    dot3_in4=> dist3_in2,
    dot3_in5=> dist3_in3,
    dot3_in6=> dist3_in3,
    dot3_out=> result
    );
  s1:entity sqrt port map (
    sqrt_in1=>result,
    sqrt_out=>dist2_out
    );
  
end chained;
