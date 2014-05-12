library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;

entity mult is
  port(
    clk, reset, start : in std_logic;
    a_in, b_in : in std_logic_vector(31 downto 0);
    done : out std_logic;
    product_out : out std_logic_vector(31 downto 0)
  );
end entity mult;

architecture arch of mult is
  alias sign_t is std_logic;
  subtype exponent_t is std_logic_vector(7 downto 0);
  subtype significand_t is std_logic_vector(22 downto 0);
  type float32_t is record
    sign : sign_t;
    exponent : exponent_t;
    significand : significand_t;
  end record;
  
  signal a, b, product : float32_t;
  
begin
  a.sign <= a_in(31);
  a.exponent <= a_in(30 downto 23);
  a.significand <= a_in(22 downto 0);
  
  b.sign <= b_in(31);
  b.exponent <= b_in(30 downto 23);
  b.significand <= b_in(22 downto 0);
  
  product_out(31) <= product.sign;
  product_out(30 downto 23) <= product.exponent;
  product_out(22 downto 0) <= product.significand;
  
  magic:process
  begin
    wait until clk'event and clk='1';
    --product <= a*b;
  end process magic;
end architecture arch;