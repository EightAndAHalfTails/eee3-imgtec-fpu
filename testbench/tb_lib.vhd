LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real;
USE ieee.float_pkg.ALL;		--ieee floating point package
USE work.ALL;

PACKAGE tb_lib IS
	alias slv IS std_logic_vector;
	CONSTANT NEG_ONE_F  : FLOAT32 := "10111111100000000000000000000000";
	CONSTANT PNAN_F		: FLOAT32 := "01111111100000000000000000000001";
	CONSTANT NNAN_F		: FLOAT32 := "11111111100000000000000000000001";
	CONSTANT PINFINITY_slv	: slv := "01111111100000000000000000000000";
	CONSTANT NINFINITY_slv	: slv := "11111111100000000000000000000000";
	CONSTANT PZERO_slv		: slv := "00000000000000000000000000000000";
	CONSTANT NZERO_slv		: slv := "10000000000000000000000000000000";

  FUNCTION isfinite(x:FLOAT32) RETURN BOOLEAN;
  FUNCTION iszero(x:FLOAT32) RETURN BOOLEAN;

END PACKAGE tb_lib;

PACKAGE BODY tb_lib IS
	-- vector to integer
	FUNCTION v2i( x : STD_LOGIC_VECTOR) RETURN INTEGER IS
	BEGIN
		RETURN to_integer(SIGNED(x));
	END;
   
	-- integer to vector
 	FUNCTION i2v( x : INTEGER) RETURN STD_LOGIC_VECTOR IS
	BEGIN
		RETURN slv(to_signed(x, 32));
	END;

	-- bit to std_logic
	-- used in addsub to read in operation_i
	FUNCTION b2l(b : BIT) return std_logic is	
	BEGIN
		IF b = '0' THEN
			RETURN '0';
		END IF;
		RETURN '1';
	END FUNCTION;

	-- check if finite
	FUNCTION isfinite(x:FLOAT32) RETURN BOOLEAN IS
	BEGIN
		RETURN (x/=pos_inffp AND x/=neg_inffp);
	END;
	
	--check if zero
	FUNCTION iszero(x:FLOAT32) RETURN BOOLEAN IS
	BEGIN
		RETURN (x=zerofp or x = neg_zerofp);
	END;
	
END PACKAGE BODY tb_lib;