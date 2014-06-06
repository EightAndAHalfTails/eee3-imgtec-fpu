library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real;
use work.all;

package types is

  alias slv IS std_logic_vector;
  alias usg IS unsigned;
  alias sgn IS signed;
  alias sign_t is std_logic;

  subtype exponent_t is std_logic_vector(7 downto 0);
  subtype significand_t is std_logic_vector(22 downto 0);
  type float32_t is record
    sign : sign_t;
    exponent : exponent_t;
    significand : significand_t;
  end record;
  
  constant pos_zero : float32_t := (sign => '0', exponent => (others => '0'), significand => (others => '0'));
  constant neg_zero : float32_t := (sign => '1', exponent => (others => '0'), significand => (others => '0'));
  constant pos_inf : float32_t := (sign => '0', exponent => (others => '1'), significand => (others => '0'));
  constant neg_inf : float32_t := (sign => '1', exponent => (others => '1'), significand => (others => '0'));
  constant nan : float32_t := (sign => '1', exponent => (others => '1'), significand => (others => '1'));
  
  function isInf(inp: float32_t) return boolean;
  function isZero(inp: float32_t) return boolean;
  function isNan(inp: float32_t) return boolean;
  function float2slv(inp: float32_t) return slv;
  function slv2float(inp: slv) return float32_t;
  function leading_one(inp: std_logic_vector) return integer;
  function v2s(inp: std_logic_vector) return string;
end package types;

package body types is
  function isInf(inp: float32_t) return boolean is
  begin
    return inp = pos_inf or inp = neg_inf;
  end function isInf;
  
  function isZero(inp: float32_t) return boolean is
  begin
    return inp = pos_zero or inp = neg_zero;
  end function isZero;
  
  function isNan(inp: float32_t) return boolean is
    constant exp_ones : exponent_t := (others => '1');
    constant sig_zeros : significand_t := (others => '0');    
  begin
    return inp.exponent = exp_ones and inp.significand /= sig_zeros;
  end function isNan;
  
  function float2slv(inp: float32_t) return slv is
  begin
    return inp.sign & inp.exponent & inp.significand;
  end function float2slv;
    
  function slv2float(inp: slv) return float32_t is
    variable result : float32_t;
  begin
    result.sign := inp(31);
    result.exponent := inp(30 downto 23);
    result.significand := inp(22 downto 0);
    return result;
  end function slv2float;
  
  function leading_one(inp: std_logic_vector) return integer is
    variable result, count: integer; 
  begin
    count := 0;
    result := 0;
    for i in inp'left downto inp'right loop
      count := count + 1;
      if inp(i) = '1' then 
        result := count;
        exit;
      end if;
    end loop;
    return result;
  end function leading_one;
    
  function v2s(inp: std_logic_vector) return string is
    variable result: string(1 to inp'length);
    variable bit: string(1 to 3);
  begin
    for i in inp'left downto inp'right loop
      bit := std_logic'image(inp(i));
      result(1+inp'left-i) := bit(2);
    end loop;
    return result;
  end function v2s;
end package body types;