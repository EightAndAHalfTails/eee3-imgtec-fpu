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
    init : in std_logic_vector(24 downto 0);
    prev : in std_logic_vector(24 downto 0);
    curr : out std_logic_vector(24 downto 0)
  );
end entity isqrt_iter;

architecture halley of isqrt_iter is
  signal s_init, s_prev, s_curr : ufixed(0 downto -24);
  signal y : ufixed(0 downto -24);
  constant eighth : ufixed(0 downto -3) := to_ufixed(1/8, 0, -3);
  constant three : ufixed(1 downto 0) := to_ufixed(3, 1, 0);
  constant ten : ufixed (3 downto 0) := to_ufixed(10, 3, 0);
  constant fifteen : ufixed (3 downto 0) := to_ufixed(15, 3, 0);
begin
  --------------------------------
  -- Halley's method
  -- yn = S * xn^2
  -- xn+1 = xn/8 * (15 - yn(10 - 3yn))
  s_init <= to_ufixed(init, 0, -24); -- S
  s_prev <= to_ufixed(prev, 0, -24); -- xn
  curr <= to_slv(s_curr); -- xn+1
  
  y <= resize(s_init * s_prev * s_prev, y'left, y'right);
  s_curr <= resize(s_prev * eighth * (fifteen - y*(ten - 3*y)), s_curr'left, s_curr'right);
end architecture halley;