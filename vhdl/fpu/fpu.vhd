library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;
use work.types.all;

entity fpu is
  port(
    clk, reset, start, done : in std_logic;
    opcode : in slv(3 downto 0);
    fpu_in1, fpu_in2, fpu_in3 : in slv(31 downto 0);
    fpu_out : out slv(31 downto 0)
    );
end entity fpu;

architecture arch of fpu is
  signal add_result, div_result, mult_result, sqrt_result, isqrt_result, multacc_result, result : slv(31 downto 0);
  signal mult1, mult2 : slv(31 downto 0);
  signal isq_start, isq_done : std_logic;
  
  type state_t is (idle, isq_wait, sqt_wait);
  signal state, nstate : state_t;
begin
  as: entity addsub port map(
    add_in1 => fpu_in1,
    add_in2 => fpu_in2,
    operation_i => opcode(0),
    add_out => add_result
  );
  
  ml: entity mult port map(
    mult_in1 => mult1,
    mult_in2 => mult2,
    mult_out => mult_result
  );
  
  dv : entity div port map(
    div_in1 => fpu_in1,
    div_in2 => fpu_in2,
    div_out => div_result
  );
  
  sq : process(state, isqrt_result, fpu_in1, fpu_in2)
  begin
    mult1 <= fpu_in1;
    mult2 <= fpu_in2;
    sqrt_result <= mult_result;
    if state = sqt_wait then
      mult2 <= isqrt_result;
    end if;
  end process sq;
  
  isq : entity isqrt port map(
    clk => clk,
    reset => reset,
    start => isq_start,
    done => isq_done,
    isqrt_in1 => fpu_in1,
    isqrt_out => isqrt_result
  );
  
  fma : entity multacc port map(
    multacc_in1 => fpu_in1,
    multacc_in2 => fpu_in2,
    multacc_in3 => fpu_in3,
    multacc_out => multacc_result
  );
  
  fsm : process
  begin
    wait until clk'event and clk = '1';
    if reset = '1' then
      state <= idle;
      fpu_out <= (others => '0');
    else
      state <= nstate;
      fpu_out <= result;
    end if;
  end process fsm;
  
  sel : process(state, opcode, mult_result, add_result, multacc_result, div_result, sqrt_result, isqrt_result)
    variable op : integer range 0 to 15;
  begin
    if state = idle and start = '1' then
      op := to_integer(usg(opcode));
      case op is
        when 0 => -- NOP
          result <= float2slv(nan);
          nstate <= idle;
        when 1 => -- MUL
          result <= mult_result;
          nstate <= idle;
        when 2|3 => -- ADD|SUB
          result <= add_result;
          nstate <= idle;
        when 4 => -- FMA
          result <= multacc_result;
          nstate <= idle;
        when 5 => -- DIV
          result <= div_result;
          nstate <= idle;
        when 6 => -- DOT2
          result <= float2slv(nan);
          nstate <= idle;
        when 7 => -- DOT3
          result <= float2slv(nan);
          nstate <= idle;
        when 8 => -- SQRT
          result <= sqrt_result;
          nstate <= sqt_wait;
        when 9 => -- ISQRT
          result <= float2slv(nan);
          nstate <= isq_wait;
        when 10 => -- MAG2
          result <= float2slv(nan);
          nstate <= idle;
        when 11 => -- MAG3
          result <= float2slv(nan);
          nstate <= idle;
        when 12 => -- NORM3
          result <= float2slv(nan);
          nstate <= idle;
        when 13 to 15 => -- unused
          result <= float2slv(nan);
          nstate <= idle;
      end case;
    elsif state = idle then
      result <= float2slv(nan);
      nstate <= idle;
    elsif state = sqt_wait and isq_done = '1' then
      result <= sqrt_result;
      nstate <= idle;
    elsif state = isq_wait and isq_done = '1' then
      result <= isqrt_result;
      nstate <= idle;
    else
      result <= float2slv(nan);
      nstate <= state;
    end if;
  end process sel;
end architecture arch;