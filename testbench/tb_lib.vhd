LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real;
USE ieee.float_pkg.ALL;		--ieee floating point package
USE work.ALL;

PACKAGE tb_lib IS

	alias slv IS std_logic_vector;
	
	CONSTANT NEG_ONE_F  	: FLOAT32 := "10111111100000000000000000000000";
	CONSTANT PNAN_F			: FLOAT32 := "01111111100000000000000000000001";
	CONSTANT NNAN_F			: FLOAT32 := "11111111100000000000000000000001";
	CONSTANT PINFINITY_F	: FLOAT32 := "01111111100000000000000000000000";
	CONSTANT NINFINITY_F	: FLOAT32 := "11111111100000000000000000000000";
	CONSTANT PZERO_F		: FLOAT32 := "00000000000000000000000000000000";
	CONSTANT NZERO_F		: FLOAT32 := "10000000000000000000000000000000";
	
	CONSTANT PINFINITY_slv	: slv := "01111111100000000000000000000000";
	CONSTANT NINFINITY_slv	: slv := "11111111100000000000000000000000";
	CONSTANT PZERO_slv		: slv := "00000000000000000000000000000000";
	CONSTANT NZERO_slv		: slv := "10000000000000000000000000000000";
	CONSTANT random_nan_slv	: slv := "01111111100000000000110000000000";
	
	CONSTANT SHIFT_POW	: INTEGER := 12; --for dekker product

	FUNCTION isfinite(x:FLOAT32) RETURN BOOLEAN;
	FUNCTION iszero(x:FLOAT32) RETURN BOOLEAN;
	FUNCTION b2l(b : BIT) return std_logic;
	FUNCTION v2i( x : STD_LOGIC_VECTOR) RETURN INTEGER;
	FUNCTION i2v( x : INTEGER) RETURN STD_LOGIC_VECTOR;
	
	PROCEDURE twoSum(
		x			: IN FLOAT32;
		y			: IN FLOAT32;
		r1			: OUT FLOAT32;
		r2			: OUT FLOAT32
	);
	
	PROCEDURE dekkerMult(
		x			: IN FLOAT32;
		y			: IN FLOAT32;
		r1			: OUT FLOAT32;
		r2			: OUT FLOAT32
	);
	
	PROCEDURE veltkampSplit(
		x			: IN FLOAT32;
		x_high		: OUT FLOAT32;
		x_low		: OUT FLOAT32
	);
	
 
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
	
	--x+y = r1+r2
	PROCEDURE twoSum(
		x			: IN FLOAT32;
		y			: IN FLOAT32;
		r1			: OUT FLOAT32;
		r2			: OUT FLOAT32
		) IS
		
		VARIABLE x1, y1, delta_x, delta_y	: FLOAT32;
		VARIABLE sum						: FLOAT32;
	BEGIN
		sum := x+y;
		r1 := sum;
		x1 := sum - y;
		y1 := sum - x1;
		delta_x := x - x1;
		delta_y := y - y1;
		r2 := delta_x + delta_y;	
	
	END twoSum;
	
	-- xy = r1+r2
	PROCEDURE dekkerMult(
		x			: IN FLOAT32;
		y			: IN FLOAT32;
		r1			: OUT FLOAT32;
		r2			: OUT FLOAT32
		) IS
	
		VARIABLE x_high, x_low, y_high, y_low	: FLOAT32;
		VARIABLE t_1, t_2, t_3					: FLOAT32;
		VARIABLE product						: FLOAT32;
	
	BEGIN
		veltkampSplit(x, x_high, x_low);
		veltkampSplit(y, y_high, y_low);

		-- REPORT "x = " & to_string(x);
		-- REPORT "y = " & to_string(y);
		-- REPORT "x_high = " & to_string(x_high);
		-- REPORT "x_low = " & to_string(x_low);
		-- REPORT "y_high = " & to_string(y_high);
		-- REPORT "y_low = " & to_string(y_low);
			
		product := x*y;
		t_1 := x_high*y_high - product;
		t_2 := x_high * y_low + t_1;
		t_3 := x_low * y_high + t_2;

		r1 := product;
		r2 := x_low * y_low + t_3;

	END dekkerMult;
	
	--split x into x_high and x_low
	PROCEDURE veltkampSplit(
		x			: IN FLOAT32;
		x_high		: OUT FLOAT32;
		x_low		: OUT FLOAT32
		) IS
		
		VARIABLE c	: INTEGER;
		VARIABLE gamma	: FLOAT32;
		VARIABLE delta	: FLOAT32;
		VARIABLE sum	: FLOAT32;
		
	BEGIN
		c := 8193;
		gamma := c*x;
		delta := x - gamma;
		sum := gamma + delta;
		
		x_high := sum;
		x_low := x-sum;

	END veltkampSplit;
	
END PACKAGE BODY tb_lib;