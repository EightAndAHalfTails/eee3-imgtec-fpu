LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

PACKAGE config_pack IS

ALIAS slv IS std_logic_vector;
ALIAS usg IS unsigned;
ALIAS sgn IS signed;

ALIAS sign_t IS std_logic;
SUBTYPE exponent_t IS std_logic_vector(7 downto 0);
SUBTYPE significand_t IS std_logic_vector(22 downto 0);

TYPE float32_t IS RECORD
    sign : sign_t;
    exponent : exponent_t;
    significand : significand_t;
END RECORD;

END;
