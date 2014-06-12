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
  signal s_init, s_prev, negx, a, b, c, s_curr : slv(31 downto 0);
  constant threehalves : slv(31 downto 0) := x"3fc00000";
begin
  --------------------------------
  -- Newton's method
  -- xn+1 = xn * (3/2 + (S/2 * xn * -xn))
  
  s_init <= float2slv(init);
  s_prev <= float2slv(prev);
  
  negx(31) <= not s_prev(31);
  negx(30 downto 0) <= s_prev(30 downto 0);
  
  m1: entity mult port map(
    mult_in1 => s_prev,
    mult_in2 => s_init,
    mult_out => a
  );
  
  --m2: entity mult port map(
  --  mult_in1 => a,
  --  mult_in2 => float2slv(prev),
  --  mult_out => b
  --);
  
  --s1: entity addsub port map(
  --  add_in1 => threehalves,
  --  add_in2 => b,
  --  operation_i => '1',
  --  add_out => c
  --);
  
  fma: entity multacc port map(
    multacc_in1 => negx,
    multacc_in2 => a,
    multacc_in3 => threehalves,
    multacc_out => c
  );
  
  m3: entity mult port map(
    mult_in1 => c,
    mult_in2 => s_prev,
    mult_out => s_curr
  );
  
  curr <= slv2float(s_curr);
end architecture newton;