library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;
use work.types.all;

entity fpu is
  port(
    clk, reset : in std_logic;
    opcode : in slv(3 downto 0);
    fpu_in1, fpu_in2, fpu_in3, fpu_in4, fpu_in5, fpu_in6 : in slv(31 downto 0);
    fpu_out : out slv(31 downto 0)
    );
end entity fpu;

architecture arch of fpu is
  signal a, b, c, d, e, f, div_in1, div_in2, sqrt_in1, dot3_in1, dot3_in2, dot3_in3, dot3_in4, dot3_in5, dot3_in6, div_out, sqrt_out, dot3_out, result : slv(31 downto 0);
  signal isq_start, isq_done, s_busy, s_done : std_logic;
  signal op : integer range 0 to 15;
  
  type state_t is (idle, isq_wait, sqt_wait);
  signal state, nstate : state_t;
  
  constant one : slv(31 downto 0) := x"00000001"; 
  constant neg_one : slv(31 downto 0) := x"80000001";
  constant nan : slv(31 downto 0) := float2slv(nan);
begin
  
  dv : entity div port map(
    div_in1 => div_in1,
    div_in2 => div_in2,
    div_out => div_out
  );
  div_in: process(op, a, b, sqrt_out)
  begin
    if op = 5 then
      div_in1 <= a;
      div_in2 <= b;
    elsif op = 9 then
      div_in1 <= one;
      div_in2 <= sqrt_out;
    elsif op = 12 then
      div_in1 <= a;
      div_in2 <= sqrt_out;
    else
      div_in1 <= nan;
      div_in2 <= nan;
    end if;
  end process div_in;
  
  sq : entity sqrt port map(
    sqrt_in1 => sqrt_in1,
    sqrt_out => sqrt_out
  );
  sq_in: process(op, dot3_out)
  begin
    if op = 8 or op = 9 then
      sqrt_in1 <= a;
    elsif op = 10 or op = 11 or op = 12 then
      sqrt_in1 <= dot3_out;
    end if;
  end process sq_in;
  
  dot : entity dot3 port map(
    dot3_in1 => dot3_in1,
    dot3_in2 => dot3_in2,
    dot3_in3 => dot3_in3,
    dot3_in4 => dot3_in4,
    dot3_in5 => dot3_in5,
    dot3_in6 => dot3_in6,
    dot3_out => dot3_out
  );
  dot3_in: process(op)
    constant zero : slv(31 downto 0) := float2slv(pos_zero);
  begin
    case op is
    when 1 => --MUL
      dot3_in1 <= a;
      dot3_in2 <= b;
      dot3_in3 <= zero;
      dot3_in4 <= zero;
      dot3_in5 <= zero;
      dot3_in6 <= zero;
    when 2 => -- ADD
      dot3_in1 <= a;
      dot3_in2 <= one;
      dot3_in3 <= b;
      dot3_in4 <= one;
      dot3_in5 <= zero;
      dot3_in6 <= zero;
    when 3 => -- SUB
      dot3_in1 <= a;
      dot3_in2 <= one;
      dot3_in3 <= b;
      dot3_in4 <= neg_one;
      dot3_in5 <= zero;
      dot3_in6 <= zero;
    when 4 => -- FMA
      dot3_in1 <= a;
      dot3_in2 <= b;
      dot3_in3 <= one;
      dot3_in4 <= c;
      dot3_in5 <= zero;
      dot3_in6 <= zero;
    when 6 => -- DOT2
      dot3_in1 <= a;
      dot3_in2 <= b;
      dot3_in3 <= c;
      dot3_in4 <= d;
      dot3_in5 <= zero;
      dot3_in6 <= zero;
    when 7 => -- DOT3
      dot3_in1 <= a;
      dot3_in2 <= b;
      dot3_in3 <= c;
      dot3_in4 <= d;
      dot3_in5 <= e;
      dot3_in6 <= f;
    when 10 => -- MAG2
      dot3_in1 <= a;
      dot3_in2 <= a;
      dot3_in3 <= b;
      dot3_in4 <= b;
      dot3_in5 <= zero;
      dot3_in6 <= zero;
    when 11 => -- MAG3
      dot3_in1 <= a;
      dot3_in2 <= a;
      dot3_in3 <= b;
      dot3_in4 <= b;
      dot3_in5 <= c;
      dot3_in6 <= c;
    when 12 => -- NORM3
      dot3_in1 <= a;
      dot3_in2 <= a;
      dot3_in3 <= b;
      dot3_in4 <= b;
      dot3_in5 <= c;
      dot3_in6 <= c;
    when others =>
      dot3_in1 <= nan;
      dot3_in2 <= nan;
      dot3_in3 <= nan;
      dot3_in4 <= nan;
      dot3_in5 <= nan;
      dot3_in6 <= nan;
    end case;
  end process dot3_in;
  
  select_output : process(op, dot3_out, sqrt_out, div_out) --removed isqrt_out from sensitivity list since it gives warning -R
  begin
    case op is
      when 1|2|3|4|6|7 =>
        result <= dot3_out;
      when 8|10|11 =>
        result <= sqrt_out;
      when 5|9|12 =>
        result <= div_out;
      when others => -- DIV
        result <= nan;
    end case;
  end process select_output;
  
  register_inputs: process
  begin
    wait until clk'event and clk = '1';
      op <= to_integer(usg(opcode));
      a <= fpu_in1;
      b <= fpu_in2;
      c <= fpu_in3;
      d <= fpu_in4;
      e <= fpu_in5;
      f <= fpu_in6;
      fpu_out <= result;
    end process register_inputs;
end architecture arch;