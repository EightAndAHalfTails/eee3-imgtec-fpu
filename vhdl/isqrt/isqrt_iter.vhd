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
    init : in ufixed(0 downto -24);
    prev : in ufixed(0 downto -24);
    curr : out ufixed(0 downto -24)
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
  
  y <= resize(init * prev * prev, y'left, y'right);
  curr <= resize(prev * eighth * (fifteen - y*(ten - 3*y)), curr'left, curr'right);
end architecture halley;