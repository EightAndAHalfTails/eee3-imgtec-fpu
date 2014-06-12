library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;
use work.types.all;

entity fpu is
  port(
    clk, reset : in std_logic;
    opcode : in slv(3 downto 0);
    fpu_in1, fpu_in2 : in slv(31 downto 0);
    fpu_out : out slv(31 downto 0)
    );
end entity fpu;

architecture arch of fpu is
  signal add_result, div_result, mult_result, sqrt_result, multacc_result : slv(31 downto 0);
begin
  as: entity addsub port map(
    add_in1 => fpu_in1,
    add_in2 => fpu_in2,
    operation_i => opcode(0),
    add_out => add_result
  );
  
  ml: entity mult port map(
    mult_in1 => fpu_in1,
    mult_in2 => fpu_in2,
    mult_out => mult_result
  );
  
  dv : entity div port map(
    div_in1 => fpu_in1,
    div_in2 => fpu_in2,
    div_out => div_result
  );
  
  sq : entity sqrt port map(
    sqrt_in1 => fpu_in1,
    sqrt_out => sqrt_result
  );
  
  fma : entity multacc port map(
    multacc_in1 => fpu_in1,
    multacc_out => multacc_result
  );
  
  sel : process
    variable op : integer range 0 to 15;
  begin
    wait until clk'event and clk = '1';
    op := to_integer(usg(opcode));
    case op is
      when 0 => -- NOP
        fpu_out <= float2slv(nan);
      when 1 => -- MUL
        fpu_out <= mult_result;
      when 2|3 => -- ADD|SUB
        fpu_out <= add_result;
      when 4 => -- FMA
        fpu_out <= multacc_result;
      when 5 => -- DIV
        fpu_out <= div_result;
      when 6 => -- DOT2
        fpu_out <= float2slv(nan);
      when 7 => -- DOT3
        fpu_out <= float2slv(nan);
      when 8 => -- SQRT
        fpu_out <= sqrt_result;
      when 9 => -- ISQRT
        fpu_out <= float2slv(nan);
      when 10 => -- MAG2
        fpu_out <= float2slv(nan);
      when 11 => -- MAG3
        fpu_out <= float2slv(nan);
      when 12 => -- NORM3
        fpu_out <= float2slv(nan);
      when 13 to 15 => -- unused
        fpu_out <= float2slv(nan);
    end case;
    
    if reset = '1' then
      fpu_out <= (others => '0');
    end if;
  end process sel;
end architecture arch;