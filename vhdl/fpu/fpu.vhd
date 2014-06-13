library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;
use work.types.all;

entity fpu is
  port(
    clk, reset, start : in std_logic;
    busy, done : out std_logic;
    opcode : in slv(3 downto 0);
    fpu_in1, fpu_in2, fpu_in3 : in slv(31 downto 0);
    fpu_out : out slv(31 downto 0)
    );
end entity fpu;

architecture arch of fpu is
  signal a, b, c, add_result, div_result, mult_result, sqrt_result, isqrt_result, multacc_result, result : slv(31 downto 0);
  signal isq_start, isq_done, s_busy : std_logic;
  signal op : integer range 0 to 15;
  
  type state_t is (idle, isq_wait, sqt_wait);
  signal state, nstate : state_t;
begin
  as: entity addsub port map(
    add_in1 => a,
    add_in2 => b,
    operation_i => opcode(0),
    add_out => add_result
  );
  
  ml: entity mult port map(
    mult_in1 => a,
    mult_in2 => b,
    mult_out => mult_result
  );
  
  dv : entity div port map(
    div_in1 => a,
    div_in2 => b,
    div_out => div_result
  );
  
  sqrt: entity mult port map(
    mult_in1 => a,
    mult_in2 => isqrt_result,
    mult_out => sqrt_result
  );
  
  isq : entity isqrt port map(
    clk => clk,
    reset => reset,
    start => isq_start,
    done => isq_done,
    isqrt_in1 => a,
    isqrt_out => isqrt_result
  );
  
  fma : entity multacc port map(
    multacc_in1 => a,
    multacc_in2 => b,
    multacc_in3 => c,
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
  
  next_state: process(state)
  begin
    if state = idle and start = '1' and op = 8 then
      nstate <= sqt_wait;
    elsif state = idle and start = '1' and op = 9 then
      nstate <= isq_wait;
    else
      nstate <= idle;
    end if;
  end process next_state;
  
  sel : process(op, mult_result, add_result, multacc_result, div_result, sqrt_result, isqrt_result)
  begin
    case op is
      when 0 => -- NOP
        result <= float2slv(nan);
      when 1 => -- MUL
        result <= mult_result;
      when 2|3 => -- ADD|SUB
        result <= add_result;
      when 4 => -- FMA
        result <= multacc_result;
      when 5 => -- DIV
        result <= div_result;
      when 6 => -- DOT2
        result <= float2slv(nan);
      when 7 => -- DOT3
        result <= float2slv(nan);
      when 8 => -- SQRT
        result <= sqrt_result;
      when 9 => -- ISQRT
        result <= float2slv(nan);
      when 10 => -- MAG2
        result <= float2slv(nan);
      when 11 => -- MAG3
        result <= float2slv(nan);
      when 12 => -- NORM3
        result <= float2slv(nan);
      when 13 to 15 => -- unused
        result <= float2slv(nan);
    end case;
  end process sel;
  
  busy <= s_busy;
  when_busy: process(nstate)
  begin
    if nstate = idle then
      s_busy <= '0';
    else s_busy <= '1';
    end if;
  end process when_busy;
  
  register_inputs: process
  begin
    wait until clk'event and clk = '1';
    if s_busy = '0' and start = '1' then
      op <= to_integer(usg(opcode));
      a <= fpu_in1;
      b <= fpu_in2;
      c <= fpu_in3;
    end if;
    end process register_inputs;
end architecture arch;