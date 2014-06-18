LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real;
USE ieee.float_pkg.ALL;		--ieee floating point package
USE work.ALL;

PACKAGE tb_lib IS

	alias slv IS std_logic_vector;
	
	TYPE line_numbers IS ARRAY(0 to 9) OF INTEGER;
	
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
	FUNCTION to_opcode( x : STRING(1 TO 4)) RETURN STD_LOGIC_VECTOR;
	
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
	
	PROCEDURE getRightLeftBound(
		x	: IN FLOAT32; 
		ulp	: IN INTEGER;
		x_right	: OUT FLOAT32;
		x_left	: OUT FLOAT32
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
	
	--cmd to opcode
	FUNCTION to_opcode( x : STRING(1 TO 4)) RETURN slv IS
	BEGIN
		CASE x IS
			WHEN "nop_" => RETURN "0000";
			WHEN "mul_" => RETURN "0001";
			WHEN "add_" => RETURN "0010";
			WHEN "sub_" => RETURN "0011";
			WHEN "fma_" => RETURN "0100";
			WHEN "div_" => RETURN "0101";
			WHEN "dot2" => RETURN "0110";
			WHEN "dot3" => RETURN "0111";
			WHEN "sqrt" => RETURN "1000";
			WHEN "isqr" => RETURN "1001";
			WHEN "mag2" => RETURN "1010";
			WHEN "mag3" => RETURN "1011";
			WHEN "norm" => RETURN "1100";
			WHEN OTHERS => RETURN "1111";
		END CASE;
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
	
		-- REPORT "x is " & to_string(x);
		-- REPORT "y = " & to_string(y);
		
		veltkampSplit(x, x_high, x_low);
		veltkampSplit(y, y_high, y_low);

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

		-- REPORT "gamma is " & to_string(gamma);
		-- REPORT "delta is " & to_string(delta);
		x_high := sum;
		x_low := x-sum;

	END veltkampSplit;
	
	PROCEDURE getRightLeftBound(
		x	: IN FLOAT32; 
		ulp	: IN INTEGER;
		x_right	: OUT FLOAT32;
		x_left	: OUT FLOAT32
		) IS
		
		VARIABLE exponent_l, exponent_r	: unsigned(8 DOWNTO 0);
		VARIABLE mantissa_l, mantissa_r	: unsigned(24 DOWNTO 0); --25 bits for overflow, left and right bound error interval
		VARIABLE x_right_slv, x_left_slv	: slv(31 DOWNTO 0);
		VARIABLE temp : unsigned(22 DOWNTO 0);
		
	BEGIN
		----------------------------------------------------------------------
		-- check x for zeros, infinities or NaNs
		-- else find right boundaries of x
		IF (not(isfinite(x))) or isnan(x) THEN
			REPORT "x is not normal number";
			x_left_slv := to_slv(x);
			x_right_slv := to_slv(x);
		ELSE
			exponent_r := '0'& unsigned(x(7 DOWNTO 0));
			exponent_l := '0'& unsigned(x(7 DOWNTO 0));				
			temp:=unsigned(to_slv(x(-1 DOWNTO -23)));
			
			-- if x is positive, then x_right_slv is greater than x and x_left_slv is smaller than x
			IF x(8) = '0' THEN  
				mantissa_r := unsigned("01" & temp) + to_unsigned(4, 25);
				mantissa_l := unsigned("01" & temp) - to_unsigned(4, 25);
				
				-- find x_right_slv
				-- if mantissa overflow, increment exp
				-- check if exponent overflow
				IF mantissa_r(24) = '1' THEN
					exponent_r := exponent_r + to_unsigned(1, 9);
					
					IF exponent_r(8) = '1' THEN
						x_right_slv := PINFINITY_slv;
					ELSE
						x_right_slv := slv('0'&exponent_r(7 DOWNTO 0) & mantissa_r(23 DOWNTO 1));
					END IF;
				ELSE
					x_right_slv := slv('0'&exponent_r(7 DOWNTO 0) &  mantissa_r(22 DOWNTO 0));
				END IF;
				
				-- find x_left_slv
				-- if mantissa underflow, decrement exponent
				-- if x is denormal and mantissa underflow, x_left_slv will be set to positive zero
				IF mantissa_l(23) = '0' THEN
					IF exponent_l = "00000000" THEN
						x_left_slv := PZERO_slv;
					ELSE
						exponent_l := exponent_l - to_unsigned(1,9);
						x_left_slv := slv('0' & exponent_l(7 DOWNTO 0) & mantissa_l(21 DOWNTO 0) & '0');
					END IF;
				ELSE
					x_left_slv := slv('0' & exponent_l(7 DOWNTO 0) & mantissa_l(22 DOWNTO 0));
				END IF;	
				
			ELSE 
			-- if x is negative, then x_right_slv is less negative than x and x_left_slv is more negative than x
				mantissa_r := unsigned("01" & temp) - to_unsigned(4, 25);
				mantissa_l := unsigned("01" & temp) + to_unsigned(4, 25);
				
				-- find x_right_slv
				IF mantissa_r(23) = '0' THEN
					IF exponent_r = "00000000" THEN
						x_right_slv := NZERO_slv;
					ELSE
						exponent_r := exponent_r - to_unsigned(1,9);
						x_right_slv := slv('1' & exponent_r(7 DOWNTO 0) & mantissa_r(21 DOWNTO 0) & '0');
					END IF;
				ELSE 
					x_right_slv := slv('1' & exponent_r(7 DOWNTO 0) & mantissa_r(22 DOWNTO 0));
				END IF;
				
				-- find x_left_slv
				IF mantissa_l(24) = '1' THEN
					exponent_l := exponent_l + to_unsigned(1, 9);
					
					IF exponent_l(8) = '1' THEN
						x_left_slv := NINFINITY_slv;
					ELSE
						x_left_slv := slv('1'&exponent_l(7 DOWNTO 0) & mantissa_l(23 DOWNTO 1));
					END IF;
				ELSE
					x_left_slv := slv('1'&exponent_l(7 DOWNTO 0) &  mantissa_l(22 DOWNTO 0));
				END IF;
				
			END IF;
		END IF;
		
		x_right := to_float(x_right_slv);
		x_left := to_float(x_left_slv);
	END getRightLeftBound;
	
END PACKAGE BODY tb_lib;