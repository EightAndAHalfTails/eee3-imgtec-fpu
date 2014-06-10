library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;
use work.types.all;

-- For fixed point mult:
use ieee.fixed_float_types.all;
use ieee.fixed_pkg.all;

entity isqrt_iter is
  port(
    init : in float32_t;
    prev : in float32_t;
    curr : out float32_t
  );
end entity isqrt_iter;

architecture newton of isqrt_iter is
  signal s_init, s_prev, s_curr : float32_t;
  signal a, b, c, d : slv(31 downto 0);
  constant threehalves : slv(31 downto 0) := x"3fc00000";
begin
  --------------------------------
  -- Newton's method
  -- xn+1 = xn * (3/2 - (S/2 * xn * xn))
  
  m1: entity mult port map(
    mult_in1 => float2slv(prev),
    mult_in2 => float2slv(prev),
    mult_out => a
  );
  
  m2: entity mult port map(
    mult_in1 => a,
    mult_in2 => float2slv(init),
    mult_out => b
  );
  
  s1: entity addsub port map(
    add_in1 => threehalves,
    add_in2 => b,
    operation_i => '1',
    add_out => c
  );
  
  m3: entity mult port map(
    mult_in1 => c,
    mult_in2 => float2slv(prev),
    mult_out => d
  );
  
  curr <= slv2float(d);
end architecture newton;