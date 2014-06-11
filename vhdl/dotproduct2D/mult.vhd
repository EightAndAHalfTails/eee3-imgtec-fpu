library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;
use work.types.all;

entity multiply is
	port(
	a,b			:in  float32_t;
	post_mult_sign 		:out std_logic;
  	post_mult_exp 		:out unsigned(8 downto 0);
  	post_mult_significand 	:out unsigned(47 downto 0) --with 2 integer bits
	);
end entity multiply;
architecture rtl of multiply is

begin

mult : process(a,b)
    variable sig_a, sig_b : unsigned(23 downto 0);
    constant zeros : exponent_t := (others => '0');
  begin

    post_mult_sign <= a.sign xor b.sign;
    post_mult_exp <= resize(unsigned(a.exponent), 9) + resize(unsigned(b.exponent), 9);
    if a.exponent = zeros then
      sig_a := unsigned(a.significand & '0');
    else
      sig_a := unsigned('1' & a.significand);
    end if;
    if b.exponent = zeros then
      sig_b := unsigned(b.significand & '0');
    else
      sig_b := unsigned('1' & b.significand);
    end if;
    post_mult_significand <= sig_a * sig_b;

  end process mult;

end architecture rtl;
