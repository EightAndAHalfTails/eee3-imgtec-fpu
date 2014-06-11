library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real;
use ieee.fixed_float_types.all;
use ieee.fixed_pkg.all;
use work.all;
use work.types.all;

entity isqrt is
  generic(iterations : natural := 3);
  port(
    clk, reset, start : in std_logic;
    done : out std_logic;
    isqrt_in1 : in std_logic_vector(31 downto 0);
    isqrt_out : out std_logic_vector(31 downto 0)
    );
end entity isqrt;

architecture fast_newton of isqrt is
  signal input, held_input, half_input, initial_guess, improve_in, improve_out, result, output : float32_t;

  signal cycle, ncycle : integer range 0 to iterations-1 := 0;
begin
isqrt_out <= float2slv(output);
  
when_done: process(cycle)
  begin
    if cycle = 0 then
      done <= '1';
    else
      done <= '0';
    end if;
  end process when_done;
  
  guess: process(input)
    --constant magic: slv(31 downto 0) := x"5f3759df";
    constant magic: slv(31 downto 0) := x"5f375a86";
  begin
    initial_guess <= slv2float(slv(signed(magic) - signed(shift_right(unsigned(float2slv(input)), 1))));
  end process guess;
  
  half: process(input)
  begin
    half_input.sign <= input.sign;
    half_input.exponent <= slv(unsigned(input.exponent) - to_unsigned(1, input.exponent'length));
    half_input.significand <= input.significand;
  end process half;
  
  improve: entity isqrt_iter(newton) port map(
    init => half_input,
    prev => improve_in,
    curr => improve_out
  );
  
  hold_input: process
  begin
    wait until clk'event and clk='1';
    if reset = '1' then
      held_input <= pos_zero;
    elsif cycle = 0 and start = '1' then
      held_input <= slv2float(isqrt_in1);
    end if;
  end process hold_input;
  
  get_input: process(isqrt_in1, held_input, cycle)
  begin
    if cycle = 0 then
      input <= slv2float(isqrt_in1);
    else
      input <= held_input;
    end if;
  end process get_input;
  
  fsm: process
  begin
    wait until clk'event and clk='1';
    if reset = '1' then
      cycle <= 0;
      output <= pos_zero;
    else
      cycle <= ncycle;
      output <= result;
    end if;
  end process fsm;
  
  fsm_comb: process(cycle, initial_guess, output, start)
  begin
    if cycle = 0 and start = '0' then
      improve_in <= initial_guess;
      ncycle <= 0;
    elsif cycle = 0 and start = '1' then
      improve_in <= initial_guess;
      ncycle <= 1;
    elsif cycle = iterations-1 then
      improve_in <= output;
      ncycle <= 0;
    else
      improve_in <= output;
      ncycle <= cycle + 1;
    end if;
  end process fsm_comb;
  
  special_cases: process(improve_out, input)
  begin
    if input = neg_zero then
      result <= neg_inf;
    elsif input.sign = '1' or isNan(input) then
      result <= nan;
    elsif input = pos_inf then
      result <= pos_zero;
    else
      result <= improve_out;
    end if;
  end process special_cases;
  
end architecture fast_newton;