--------------------------------------------------------------------------------
--                       RightShifter_24_by_max_46_uid4
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2011)
--------------------------------------------------------------------------------
-- Pipeline depth: 1 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity RightShifter_24_by_max_46_uid4 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(23 downto 0);
          S : in  std_logic_vector(5 downto 0);
          R : out  std_logic_vector(69 downto 0)   );
end entity;

architecture arch of RightShifter_24_by_max_46_uid4 is
signal level0 :  std_logic_vector(23 downto 0);
signal ps, ps_d1 :  std_logic_vector(5 downto 0);
signal level1 :  std_logic_vector(24 downto 0);
signal level2 :  std_logic_vector(26 downto 0);
signal level3 :  std_logic_vector(30 downto 0);
signal level4 :  std_logic_vector(38 downto 0);
signal level5, level5_d1 :  std_logic_vector(54 downto 0);
signal level6 :  std_logic_vector(86 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            ps_d1 <=  ps;
            level5_d1 <=  level5;
         end if;
      end process;
   level0<= X;
   ps<= S;
   level1<=  (0 downto 0 => '0') & level0 when ps(0) = '1' else    level0 & (0 downto 0 => '0');
   level2<=  (1 downto 0 => '0') & level1 when ps(1) = '1' else    level1 & (1 downto 0 => '0');
   level3<=  (3 downto 0 => '0') & level2 when ps(2) = '1' else    level2 & (3 downto 0 => '0');
   level4<=  (7 downto 0 => '0') & level3 when ps(3) = '1' else    level3 & (7 downto 0 => '0');
   level5<=  (15 downto 0 => '0') & level4 when ps(4) = '1' else    level4 & (15 downto 0 => '0');
   ----------------Synchro barrier, entering cycle 1----------------
   level6<=  (31 downto 0 => '0') & level5_d1 when ps_d1(5) = '1' else    level5_d1 & (31 downto 0 => '0');
   R <= level6(86 downto 17);
end architecture;

--------------------------------------------------------------------------------
--                       RightShifter_24_by_max_46_uid7
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2011)
--------------------------------------------------------------------------------
-- Pipeline depth: 1 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity RightShifter_24_by_max_46_uid7 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(23 downto 0);
          S : in  std_logic_vector(5 downto 0);
          R : out  std_logic_vector(69 downto 0)   );
end entity;

architecture arch of RightShifter_24_by_max_46_uid7 is
signal level0 :  std_logic_vector(23 downto 0);
signal ps, ps_d1 :  std_logic_vector(5 downto 0);
signal level1 :  std_logic_vector(24 downto 0);
signal level2 :  std_logic_vector(26 downto 0);
signal level3 :  std_logic_vector(30 downto 0);
signal level4 :  std_logic_vector(38 downto 0);
signal level5, level5_d1 :  std_logic_vector(54 downto 0);
signal level6 :  std_logic_vector(86 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            ps_d1 <=  ps;
            level5_d1 <=  level5;
         end if;
      end process;
   level0<= X;
   ps<= S;
   level1<=  (0 downto 0 => '0') & level0 when ps(0) = '1' else    level0 & (0 downto 0 => '0');
   level2<=  (1 downto 0 => '0') & level1 when ps(1) = '1' else    level1 & (1 downto 0 => '0');
   level3<=  (3 downto 0 => '0') & level2 when ps(2) = '1' else    level2 & (3 downto 0 => '0');
   level4<=  (7 downto 0 => '0') & level3 when ps(3) = '1' else    level3 & (7 downto 0 => '0');
   level5<=  (15 downto 0 => '0') & level4 when ps(4) = '1' else    level4 & (15 downto 0 => '0');
   ----------------Synchro barrier, entering cycle 1----------------
   level6<=  (31 downto 0 => '0') & level5_d1 when ps_d1(5) = '1' else    level5_d1 & (31 downto 0 => '0');
   R <= level6(86 downto 17);
end architecture;

--------------------------------------------------------------------------------
--                      RightShifter_24_by_max_46_uid10
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2011)
--------------------------------------------------------------------------------
-- Pipeline depth: 1 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity RightShifter_24_by_max_46_uid10 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(23 downto 0);
          S : in  std_logic_vector(5 downto 0);
          R : out  std_logic_vector(69 downto 0)   );
end entity;

architecture arch of RightShifter_24_by_max_46_uid10 is
signal level0 :  std_logic_vector(23 downto 0);
signal ps, ps_d1 :  std_logic_vector(5 downto 0);
signal level1 :  std_logic_vector(24 downto 0);
signal level2 :  std_logic_vector(26 downto 0);
signal level3 :  std_logic_vector(30 downto 0);
signal level4 :  std_logic_vector(38 downto 0);
signal level5, level5_d1 :  std_logic_vector(54 downto 0);
signal level6 :  std_logic_vector(86 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            ps_d1 <=  ps;
            level5_d1 <=  level5;
         end if;
      end process;
   level0<= X;
   ps<= S;
   level1<=  (0 downto 0 => '0') & level0 when ps(0) = '1' else    level0 & (0 downto 0 => '0');
   level2<=  (1 downto 0 => '0') & level1 when ps(1) = '1' else    level1 & (1 downto 0 => '0');
   level3<=  (3 downto 0 => '0') & level2 when ps(2) = '1' else    level2 & (3 downto 0 => '0');
   level4<=  (7 downto 0 => '0') & level3 when ps(3) = '1' else    level3 & (7 downto 0 => '0');
   level5<=  (15 downto 0 => '0') & level4 when ps(4) = '1' else    level4 & (15 downto 0 => '0');
   ----------------Synchro barrier, entering cycle 1----------------
   level6<=  (31 downto 0 => '0') & level5_d1 when ps_d1(5) = '1' else    level5_d1 & (31 downto 0 => '0');
   R <= level6(86 downto 17);
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_73_f400_uid13
--                     (IntAdderClassical_73_f400_uid15)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2010)
--------------------------------------------------------------------------------
-- Pipeline depth: 2 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntAdder_73_f400_uid13 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(72 downto 0);
          Y : in  std_logic_vector(72 downto 0);
          Cin : in std_logic;
          R : out  std_logic_vector(72 downto 0)   );
end entity;

architecture arch of IntAdder_73_f400_uid13 is
signal x0 :  std_logic_vector(13 downto 0);
signal y0 :  std_logic_vector(13 downto 0);
signal x1, x1_d1 :  std_logic_vector(41 downto 0);
signal y1, y1_d1 :  std_logic_vector(41 downto 0);
signal x2, x2_d1, x2_d2 :  std_logic_vector(16 downto 0);
signal y2, y2_d1, y2_d2 :  std_logic_vector(16 downto 0);
signal sum0, sum0_d1, sum0_d2 :  std_logic_vector(14 downto 0);
signal sum1, sum1_d1 :  std_logic_vector(42 downto 0);
signal sum2 :  std_logic_vector(17 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            x1_d1 <=  x1;
            y1_d1 <=  y1;
            x2_d1 <=  x2;
            x2_d2 <=  x2_d1;
            y2_d1 <=  y2;
            y2_d2 <=  y2_d1;
            sum0_d1 <=  sum0;
            sum0_d2 <=  sum0_d1;
            sum1_d1 <=  sum1;
         end if;
      end process;
   --Classical
   x0 <= X(13 downto 0);
   y0 <= Y(13 downto 0);
   x1 <= X(55 downto 14);
   y1 <= Y(55 downto 14);
   x2 <= X(72 downto 56);
   y2 <= Y(72 downto 56);
   sum0 <= ( "0" & x0) + ( "0" & y0)  + Cin;
   ----------------Synchro barrier, entering cycle 1----------------
   sum1 <= ( "0" & x1_d1) + ( "0" & y1_d1)  + sum0_d1(14);
   ----------------Synchro barrier, entering cycle 2----------------
   sum2 <= ( "0" & x2_d2) + ( "0" & y2_d2)  + sum1_d1(42);
   R <= sum2(16 downto 0) & sum1_d1(41 downto 0) & sum0_d2(13 downto 0);
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_73_f400_uid19
--                     (IntAdderClassical_73_f400_uid21)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2010)
--------------------------------------------------------------------------------
-- Pipeline depth: 2 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntAdder_73_f400_uid19 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(72 downto 0);
          Y : in  std_logic_vector(72 downto 0);
          Cin : in std_logic;
          R : out  std_logic_vector(72 downto 0)   );
end entity;

architecture arch of IntAdder_73_f400_uid19 is
signal x0 :  std_logic_vector(13 downto 0);
signal y0 :  std_logic_vector(13 downto 0);
signal x1, x1_d1 :  std_logic_vector(41 downto 0);
signal y1, y1_d1 :  std_logic_vector(41 downto 0);
signal x2, x2_d1, x2_d2 :  std_logic_vector(16 downto 0);
signal y2, y2_d1, y2_d2 :  std_logic_vector(16 downto 0);
signal sum0, sum0_d1, sum0_d2 :  std_logic_vector(14 downto 0);
signal sum1, sum1_d1 :  std_logic_vector(42 downto 0);
signal sum2 :  std_logic_vector(17 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            x1_d1 <=  x1;
            y1_d1 <=  y1;
            x2_d1 <=  x2;
            x2_d2 <=  x2_d1;
            y2_d1 <=  y2;
            y2_d2 <=  y2_d1;
            sum0_d1 <=  sum0;
            sum0_d2 <=  sum0_d1;
            sum1_d1 <=  sum1;
         end if;
      end process;
   --Classical
   x0 <= X(13 downto 0);
   y0 <= Y(13 downto 0);
   x1 <= X(55 downto 14);
   y1 <= Y(55 downto 14);
   x2 <= X(72 downto 56);
   y2 <= Y(72 downto 56);
   sum0 <= ( "0" & x0) + ( "0" & y0)  + Cin;
   ----------------Synchro barrier, entering cycle 1----------------
   sum1 <= ( "0" & x1_d1) + ( "0" & y1_d1)  + sum0_d1(14);
   ----------------Synchro barrier, entering cycle 2----------------
   sum2 <= ( "0" & x2_d2) + ( "0" & y2_d2)  + sum1_d1(42);
   R <= sum2(16 downto 0) & sum1_d1(41 downto 0) & sum0_d2(13 downto 0);
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_73_f400_uid25
--                     (IntAdderClassical_73_f400_uid27)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2010)
--------------------------------------------------------------------------------
-- Pipeline depth: 2 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntAdder_73_f400_uid25 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(72 downto 0);
          Y : in  std_logic_vector(72 downto 0);
          Cin : in std_logic;
          R : out  std_logic_vector(72 downto 0)   );
end entity;

architecture arch of IntAdder_73_f400_uid25 is
signal x0 :  std_logic_vector(13 downto 0);
signal y0 :  std_logic_vector(13 downto 0);
signal x1, x1_d1 :  std_logic_vector(41 downto 0);
signal y1, y1_d1 :  std_logic_vector(41 downto 0);
signal x2, x2_d1, x2_d2 :  std_logic_vector(16 downto 0);
signal y2, y2_d1, y2_d2 :  std_logic_vector(16 downto 0);
signal sum0, sum0_d1, sum0_d2 :  std_logic_vector(14 downto 0);
signal sum1, sum1_d1 :  std_logic_vector(42 downto 0);
signal sum2 :  std_logic_vector(17 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            x1_d1 <=  x1;
            y1_d1 <=  y1;
            x2_d1 <=  x2;
            x2_d2 <=  x2_d1;
            y2_d1 <=  y2;
            y2_d2 <=  y2_d1;
            sum0_d1 <=  sum0;
            sum0_d2 <=  sum0_d1;
            sum1_d1 <=  sum1;
         end if;
      end process;
   --Classical
   x0 <= X(13 downto 0);
   y0 <= Y(13 downto 0);
   x1 <= X(55 downto 14);
   y1 <= Y(55 downto 14);
   x2 <= X(72 downto 56);
   y2 <= Y(72 downto 56);
   sum0 <= ( "0" & x0) + ( "0" & y0)  + Cin;
   ----------------Synchro barrier, entering cycle 1----------------
   sum1 <= ( "0" & x1_d1) + ( "0" & y1_d1)  + sum0_d1(14);
   ----------------Synchro barrier, entering cycle 2----------------
   sum2 <= ( "0" & x2_d2) + ( "0" & y2_d2)  + sum1_d1(42);
   R <= sum2(16 downto 0) & sum1_d1(41 downto 0) & sum0_d2(13 downto 0);
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_73_f400_uid38
--                    (IntAdderAlternative_73_f400_uid42)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2010)
--------------------------------------------------------------------------------
-- Pipeline depth: 2 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntAdder_73_f400_uid38 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(72 downto 0);
          Y : in  std_logic_vector(72 downto 0);
          Cin : in std_logic;
          R : out  std_logic_vector(72 downto 0)   );
end entity;

architecture arch of IntAdder_73_f400_uid38 is
signal s_sum_l0_idx0 :  std_logic_vector(42 downto 0);
signal s_sum_l0_idx1, s_sum_l0_idx1_d1 :  std_logic_vector(31 downto 0);
signal sum_l0_idx0, sum_l0_idx0_d1 :  std_logic_vector(41 downto 0);
signal c_l0_idx0, c_l0_idx0_d1 :  std_logic_vector(0 downto 0);
signal sum_l0_idx1 :  std_logic_vector(30 downto 0);
signal c_l0_idx1 :  std_logic_vector(0 downto 0);
signal s_sum_l1_idx1 :  std_logic_vector(31 downto 0);
signal sum_l1_idx1 :  std_logic_vector(30 downto 0);
signal c_l1_idx1 :  std_logic_vector(0 downto 0);
signal X_d1 :  std_logic_vector(72 downto 0);
signal Y_d1 :  std_logic_vector(72 downto 0);
signal Cin_d1 : std_logic;
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            s_sum_l0_idx1_d1 <=  s_sum_l0_idx1;
            sum_l0_idx0_d1 <=  sum_l0_idx0;
            c_l0_idx0_d1 <=  c_l0_idx0;
            X_d1 <=  X;
            Y_d1 <=  Y;
            Cin_d1 <=  Cin;
         end if;
      end process;
   ----------------Synchro barrier, entering cycle 1----------------
   --Alternative
   s_sum_l0_idx0 <= ( "0" & X_d1(41 downto 0)) + ( "0" & Y_d1(41 downto 0)) + Cin_d1;
   s_sum_l0_idx1 <= ( "0" & X_d1(72 downto 42)) + ( "0" & Y_d1(72 downto 42));
   sum_l0_idx0 <= s_sum_l0_idx0(41 downto 0);
   c_l0_idx0 <= s_sum_l0_idx0(42 downto 42);
   sum_l0_idx1 <= s_sum_l0_idx1(30 downto 0);
   c_l0_idx1 <= s_sum_l0_idx1(31 downto 31);
   ----------------Synchro barrier, entering cycle 2----------------
   s_sum_l1_idx1 <=  s_sum_l0_idx1_d1 + c_l0_idx0_d1(0 downto 0);
   sum_l1_idx1 <= s_sum_l1_idx1(30 downto 0);
   c_l1_idx1 <= s_sum_l1_idx1(31 downto 31);
   R <= sum_l1_idx1(30 downto 0) & sum_l0_idx0_d1(41 downto 0);
end architecture;

--------------------------------------------------------------------------------
--                      IntMultiAdder_73_op3_f400_uid34
--                       (IntCompressorTree_73_3_uid36)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca (2009-2011)
--------------------------------------------------------------------------------
-- Pipeline depth: 2 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntMultiAdder_73_op3_f400_uid34 is
   port ( clk, rst : in std_logic;
          X0 : in  std_logic_vector(72 downto 0);
          X1 : in  std_logic_vector(72 downto 0);
          X2 : in  std_logic_vector(72 downto 0);
          R : out  std_logic_vector(72 downto 0)   );
end entity;

architecture arch of IntMultiAdder_73_op3_f400_uid34 is
   component IntAdder_73_f400_uid38 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(72 downto 0);
             Y : in  std_logic_vector(72 downto 0);
             Cin : in std_logic;
             R : out  std_logic_vector(72 downto 0)   );
   end component;

signal l_0_s_0 :  std_logic_vector(72 downto 0);
signal l_0_s_1 :  std_logic_vector(72 downto 0);
signal l_0_s_2 :  std_logic_vector(72 downto 0);
signal sell_1_c_0_cl_0 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_0 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_1 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_1 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_2 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_2 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_3 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_3 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_4 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_4 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_5 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_5 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_6 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_6 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_7 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_7 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_8 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_8 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_9 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_9 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_10 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_10 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_11 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_11 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_12 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_12 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_13 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_13 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_14 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_14 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_15 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_15 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_16 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_16 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_17 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_17 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_18 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_18 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_19 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_19 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_20 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_20 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_21 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_21 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_22 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_22 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_23 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_23 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_24 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_24 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_25 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_25 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_26 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_26 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_27 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_27 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_28 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_28 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_29 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_29 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_30 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_30 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_31 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_31 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_32 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_32 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_33 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_33 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_34 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_34 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_35 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_35 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_36 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_36 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_37 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_37 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_38 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_38 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_39 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_39 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_40 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_40 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_41 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_41 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_42 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_42 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_43 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_43 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_44 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_44 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_45 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_45 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_46 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_46 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_47 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_47 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_48 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_48 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_49 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_49 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_50 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_50 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_51 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_51 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_52 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_52 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_53 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_53 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_54 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_54 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_55 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_55 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_56 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_56 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_57 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_57 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_58 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_58 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_59 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_59 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_60 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_60 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_61 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_61 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_62 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_62 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_63 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_63 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_64 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_64 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_65 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_65 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_66 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_66 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_67 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_67 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_68 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_68 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_69 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_69 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_70 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_70 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_71 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_71 :  std_logic_vector(1 downto 0);
signal sell_1_c_0_cl_72 :  std_logic_vector(2 downto 0);
signal l_1_c_0_cl_72 :  std_logic_vector(1 downto 0);
signal l_1_s_0 :  std_logic_vector(72 downto 0);
signal l_1_s_1 :  std_logic_vector(72 downto 0);
signal myR :  std_logic_vector(72 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
         end if;
      end process;
   l_0_s_0 <= X0;
   l_0_s_1 <= X1;
   l_0_s_2 <= X2;
   sell_1_c_0_cl_0 <= l_0_s_0(0) & l_0_s_1(0) & l_0_s_2(0);
    with sell_1_c_0_cl_0 select
   l_1_c_0_cl_0 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_1 <= l_0_s_0(1) & l_0_s_1(1) & l_0_s_2(1);
    with sell_1_c_0_cl_1 select
   l_1_c_0_cl_1 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_2 <= l_0_s_0(2) & l_0_s_1(2) & l_0_s_2(2);
    with sell_1_c_0_cl_2 select
   l_1_c_0_cl_2 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_3 <= l_0_s_0(3) & l_0_s_1(3) & l_0_s_2(3);
    with sell_1_c_0_cl_3 select
   l_1_c_0_cl_3 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_4 <= l_0_s_0(4) & l_0_s_1(4) & l_0_s_2(4);
    with sell_1_c_0_cl_4 select
   l_1_c_0_cl_4 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_5 <= l_0_s_0(5) & l_0_s_1(5) & l_0_s_2(5);
    with sell_1_c_0_cl_5 select
   l_1_c_0_cl_5 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_6 <= l_0_s_0(6) & l_0_s_1(6) & l_0_s_2(6);
    with sell_1_c_0_cl_6 select
   l_1_c_0_cl_6 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_7 <= l_0_s_0(7) & l_0_s_1(7) & l_0_s_2(7);
    with sell_1_c_0_cl_7 select
   l_1_c_0_cl_7 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_8 <= l_0_s_0(8) & l_0_s_1(8) & l_0_s_2(8);
    with sell_1_c_0_cl_8 select
   l_1_c_0_cl_8 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_9 <= l_0_s_0(9) & l_0_s_1(9) & l_0_s_2(9);
    with sell_1_c_0_cl_9 select
   l_1_c_0_cl_9 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_10 <= l_0_s_0(10) & l_0_s_1(10) & l_0_s_2(10);
    with sell_1_c_0_cl_10 select
   l_1_c_0_cl_10 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_11 <= l_0_s_0(11) & l_0_s_1(11) & l_0_s_2(11);
    with sell_1_c_0_cl_11 select
   l_1_c_0_cl_11 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_12 <= l_0_s_0(12) & l_0_s_1(12) & l_0_s_2(12);
    with sell_1_c_0_cl_12 select
   l_1_c_0_cl_12 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_13 <= l_0_s_0(13) & l_0_s_1(13) & l_0_s_2(13);
    with sell_1_c_0_cl_13 select
   l_1_c_0_cl_13 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_14 <= l_0_s_0(14) & l_0_s_1(14) & l_0_s_2(14);
    with sell_1_c_0_cl_14 select
   l_1_c_0_cl_14 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_15 <= l_0_s_0(15) & l_0_s_1(15) & l_0_s_2(15);
    with sell_1_c_0_cl_15 select
   l_1_c_0_cl_15 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_16 <= l_0_s_0(16) & l_0_s_1(16) & l_0_s_2(16);
    with sell_1_c_0_cl_16 select
   l_1_c_0_cl_16 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_17 <= l_0_s_0(17) & l_0_s_1(17) & l_0_s_2(17);
    with sell_1_c_0_cl_17 select
   l_1_c_0_cl_17 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_18 <= l_0_s_0(18) & l_0_s_1(18) & l_0_s_2(18);
    with sell_1_c_0_cl_18 select
   l_1_c_0_cl_18 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_19 <= l_0_s_0(19) & l_0_s_1(19) & l_0_s_2(19);
    with sell_1_c_0_cl_19 select
   l_1_c_0_cl_19 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_20 <= l_0_s_0(20) & l_0_s_1(20) & l_0_s_2(20);
    with sell_1_c_0_cl_20 select
   l_1_c_0_cl_20 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_21 <= l_0_s_0(21) & l_0_s_1(21) & l_0_s_2(21);
    with sell_1_c_0_cl_21 select
   l_1_c_0_cl_21 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_22 <= l_0_s_0(22) & l_0_s_1(22) & l_0_s_2(22);
    with sell_1_c_0_cl_22 select
   l_1_c_0_cl_22 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_23 <= l_0_s_0(23) & l_0_s_1(23) & l_0_s_2(23);
    with sell_1_c_0_cl_23 select
   l_1_c_0_cl_23 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_24 <= l_0_s_0(24) & l_0_s_1(24) & l_0_s_2(24);
    with sell_1_c_0_cl_24 select
   l_1_c_0_cl_24 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_25 <= l_0_s_0(25) & l_0_s_1(25) & l_0_s_2(25);
    with sell_1_c_0_cl_25 select
   l_1_c_0_cl_25 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_26 <= l_0_s_0(26) & l_0_s_1(26) & l_0_s_2(26);
    with sell_1_c_0_cl_26 select
   l_1_c_0_cl_26 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_27 <= l_0_s_0(27) & l_0_s_1(27) & l_0_s_2(27);
    with sell_1_c_0_cl_27 select
   l_1_c_0_cl_27 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_28 <= l_0_s_0(28) & l_0_s_1(28) & l_0_s_2(28);
    with sell_1_c_0_cl_28 select
   l_1_c_0_cl_28 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_29 <= l_0_s_0(29) & l_0_s_1(29) & l_0_s_2(29);
    with sell_1_c_0_cl_29 select
   l_1_c_0_cl_29 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_30 <= l_0_s_0(30) & l_0_s_1(30) & l_0_s_2(30);
    with sell_1_c_0_cl_30 select
   l_1_c_0_cl_30 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_31 <= l_0_s_0(31) & l_0_s_1(31) & l_0_s_2(31);
    with sell_1_c_0_cl_31 select
   l_1_c_0_cl_31 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_32 <= l_0_s_0(32) & l_0_s_1(32) & l_0_s_2(32);
    with sell_1_c_0_cl_32 select
   l_1_c_0_cl_32 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_33 <= l_0_s_0(33) & l_0_s_1(33) & l_0_s_2(33);
    with sell_1_c_0_cl_33 select
   l_1_c_0_cl_33 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_34 <= l_0_s_0(34) & l_0_s_1(34) & l_0_s_2(34);
    with sell_1_c_0_cl_34 select
   l_1_c_0_cl_34 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_35 <= l_0_s_0(35) & l_0_s_1(35) & l_0_s_2(35);
    with sell_1_c_0_cl_35 select
   l_1_c_0_cl_35 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_36 <= l_0_s_0(36) & l_0_s_1(36) & l_0_s_2(36);
    with sell_1_c_0_cl_36 select
   l_1_c_0_cl_36 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_37 <= l_0_s_0(37) & l_0_s_1(37) & l_0_s_2(37);
    with sell_1_c_0_cl_37 select
   l_1_c_0_cl_37 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_38 <= l_0_s_0(38) & l_0_s_1(38) & l_0_s_2(38);
    with sell_1_c_0_cl_38 select
   l_1_c_0_cl_38 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_39 <= l_0_s_0(39) & l_0_s_1(39) & l_0_s_2(39);
    with sell_1_c_0_cl_39 select
   l_1_c_0_cl_39 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_40 <= l_0_s_0(40) & l_0_s_1(40) & l_0_s_2(40);
    with sell_1_c_0_cl_40 select
   l_1_c_0_cl_40 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_41 <= l_0_s_0(41) & l_0_s_1(41) & l_0_s_2(41);
    with sell_1_c_0_cl_41 select
   l_1_c_0_cl_41 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_42 <= l_0_s_0(42) & l_0_s_1(42) & l_0_s_2(42);
    with sell_1_c_0_cl_42 select
   l_1_c_0_cl_42 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_43 <= l_0_s_0(43) & l_0_s_1(43) & l_0_s_2(43);
    with sell_1_c_0_cl_43 select
   l_1_c_0_cl_43 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_44 <= l_0_s_0(44) & l_0_s_1(44) & l_0_s_2(44);
    with sell_1_c_0_cl_44 select
   l_1_c_0_cl_44 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_45 <= l_0_s_0(45) & l_0_s_1(45) & l_0_s_2(45);
    with sell_1_c_0_cl_45 select
   l_1_c_0_cl_45 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_46 <= l_0_s_0(46) & l_0_s_1(46) & l_0_s_2(46);
    with sell_1_c_0_cl_46 select
   l_1_c_0_cl_46 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_47 <= l_0_s_0(47) & l_0_s_1(47) & l_0_s_2(47);
    with sell_1_c_0_cl_47 select
   l_1_c_0_cl_47 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_48 <= l_0_s_0(48) & l_0_s_1(48) & l_0_s_2(48);
    with sell_1_c_0_cl_48 select
   l_1_c_0_cl_48 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_49 <= l_0_s_0(49) & l_0_s_1(49) & l_0_s_2(49);
    with sell_1_c_0_cl_49 select
   l_1_c_0_cl_49 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_50 <= l_0_s_0(50) & l_0_s_1(50) & l_0_s_2(50);
    with sell_1_c_0_cl_50 select
   l_1_c_0_cl_50 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_51 <= l_0_s_0(51) & l_0_s_1(51) & l_0_s_2(51);
    with sell_1_c_0_cl_51 select
   l_1_c_0_cl_51 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_52 <= l_0_s_0(52) & l_0_s_1(52) & l_0_s_2(52);
    with sell_1_c_0_cl_52 select
   l_1_c_0_cl_52 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_53 <= l_0_s_0(53) & l_0_s_1(53) & l_0_s_2(53);
    with sell_1_c_0_cl_53 select
   l_1_c_0_cl_53 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_54 <= l_0_s_0(54) & l_0_s_1(54) & l_0_s_2(54);
    with sell_1_c_0_cl_54 select
   l_1_c_0_cl_54 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_55 <= l_0_s_0(55) & l_0_s_1(55) & l_0_s_2(55);
    with sell_1_c_0_cl_55 select
   l_1_c_0_cl_55 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_56 <= l_0_s_0(56) & l_0_s_1(56) & l_0_s_2(56);
    with sell_1_c_0_cl_56 select
   l_1_c_0_cl_56 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_57 <= l_0_s_0(57) & l_0_s_1(57) & l_0_s_2(57);
    with sell_1_c_0_cl_57 select
   l_1_c_0_cl_57 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_58 <= l_0_s_0(58) & l_0_s_1(58) & l_0_s_2(58);
    with sell_1_c_0_cl_58 select
   l_1_c_0_cl_58 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_59 <= l_0_s_0(59) & l_0_s_1(59) & l_0_s_2(59);
    with sell_1_c_0_cl_59 select
   l_1_c_0_cl_59 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_60 <= l_0_s_0(60) & l_0_s_1(60) & l_0_s_2(60);
    with sell_1_c_0_cl_60 select
   l_1_c_0_cl_60 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_61 <= l_0_s_0(61) & l_0_s_1(61) & l_0_s_2(61);
    with sell_1_c_0_cl_61 select
   l_1_c_0_cl_61 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_62 <= l_0_s_0(62) & l_0_s_1(62) & l_0_s_2(62);
    with sell_1_c_0_cl_62 select
   l_1_c_0_cl_62 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_63 <= l_0_s_0(63) & l_0_s_1(63) & l_0_s_2(63);
    with sell_1_c_0_cl_63 select
   l_1_c_0_cl_63 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_64 <= l_0_s_0(64) & l_0_s_1(64) & l_0_s_2(64);
    with sell_1_c_0_cl_64 select
   l_1_c_0_cl_64 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_65 <= l_0_s_0(65) & l_0_s_1(65) & l_0_s_2(65);
    with sell_1_c_0_cl_65 select
   l_1_c_0_cl_65 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_66 <= l_0_s_0(66) & l_0_s_1(66) & l_0_s_2(66);
    with sell_1_c_0_cl_66 select
   l_1_c_0_cl_66 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_67 <= l_0_s_0(67) & l_0_s_1(67) & l_0_s_2(67);
    with sell_1_c_0_cl_67 select
   l_1_c_0_cl_67 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_68 <= l_0_s_0(68) & l_0_s_1(68) & l_0_s_2(68);
    with sell_1_c_0_cl_68 select
   l_1_c_0_cl_68 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_69 <= l_0_s_0(69) & l_0_s_1(69) & l_0_s_2(69);
    with sell_1_c_0_cl_69 select
   l_1_c_0_cl_69 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_70 <= l_0_s_0(70) & l_0_s_1(70) & l_0_s_2(70);
    with sell_1_c_0_cl_70 select
   l_1_c_0_cl_70 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_71 <= l_0_s_0(71) & l_0_s_1(71) & l_0_s_2(71);
    with sell_1_c_0_cl_71 select
   l_1_c_0_cl_71 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   sell_1_c_0_cl_72 <= l_0_s_0(72) & l_0_s_1(72) & l_0_s_2(72);
    with sell_1_c_0_cl_72 select
   l_1_c_0_cl_72 <= 
   "00" when "000",   "01" when "001",   "01" when "010",   "10" when "011",   "01" when "100",   "10" when "101",   "10" when "110",   "11" when "111",   "00" when others;
   l_1_s_0 <= l_1_c_0_cl_72(0 downto 0) & l_1_c_0_cl_71(0 downto 0) & l_1_c_0_cl_70(0 downto 0) & l_1_c_0_cl_69(0 downto 0) & l_1_c_0_cl_68(0 downto 0) & l_1_c_0_cl_67(0 downto 0) & l_1_c_0_cl_66(0 downto 0) & l_1_c_0_cl_65(0 downto 0) & l_1_c_0_cl_64(0 downto 0) & l_1_c_0_cl_63(0 downto 0) & l_1_c_0_cl_62(0 downto 0) & l_1_c_0_cl_61(0 downto 0) & l_1_c_0_cl_60(0 downto 0) & l_1_c_0_cl_59(0 downto 0) & l_1_c_0_cl_58(0 downto 0) & l_1_c_0_cl_57(0 downto 0) & l_1_c_0_cl_56(0 downto 0) & l_1_c_0_cl_55(0 downto 0) & l_1_c_0_cl_54(0 downto 0) & l_1_c_0_cl_53(0 downto 0) & l_1_c_0_cl_52(0 downto 0) & l_1_c_0_cl_51(0 downto 0) & l_1_c_0_cl_50(0 downto 0) & l_1_c_0_cl_49(0 downto 0) & l_1_c_0_cl_48(0 downto 0) & l_1_c_0_cl_47(0 downto 0) & l_1_c_0_cl_46(0 downto 0) & l_1_c_0_cl_45(0 downto 0) & l_1_c_0_cl_44(0 downto 0) & l_1_c_0_cl_43(0 downto 0) & l_1_c_0_cl_42(0 downto 0) & l_1_c_0_cl_41(0 downto 0) & l_1_c_0_cl_40(0 downto 0) & l_1_c_0_cl_39(0 downto 0) & l_1_c_0_cl_38(0 downto 0) & l_1_c_0_cl_37(0 downto 0) & l_1_c_0_cl_36(0 downto 0) & l_1_c_0_cl_35(0 downto 0) & l_1_c_0_cl_34(0 downto 0) & l_1_c_0_cl_33(0 downto 0) & l_1_c_0_cl_32(0 downto 0) & l_1_c_0_cl_31(0 downto 0) & l_1_c_0_cl_30(0 downto 0) & l_1_c_0_cl_29(0 downto 0) & l_1_c_0_cl_28(0 downto 0) & l_1_c_0_cl_27(0 downto 0) & l_1_c_0_cl_26(0 downto 0) & l_1_c_0_cl_25(0 downto 0) & l_1_c_0_cl_24(0 downto 0) & l_1_c_0_cl_23(0 downto 0) & l_1_c_0_cl_22(0 downto 0) & l_1_c_0_cl_21(0 downto 0) & l_1_c_0_cl_20(0 downto 0) & l_1_c_0_cl_19(0 downto 0) & l_1_c_0_cl_18(0 downto 0) & l_1_c_0_cl_17(0 downto 0) & l_1_c_0_cl_16(0 downto 0) & l_1_c_0_cl_15(0 downto 0) & l_1_c_0_cl_14(0 downto 0) & l_1_c_0_cl_13(0 downto 0) & l_1_c_0_cl_12(0 downto 0) & l_1_c_0_cl_11(0 downto 0) & l_1_c_0_cl_10(0 downto 0) & l_1_c_0_cl_9(0 downto 0) & l_1_c_0_cl_8(0 downto 0) & l_1_c_0_cl_7(0 downto 0) & l_1_c_0_cl_6(0 downto 0) & l_1_c_0_cl_5(0 downto 0) & l_1_c_0_cl_4(0 downto 0) & l_1_c_0_cl_3(0 downto 0) & l_1_c_0_cl_2(0 downto 0) & l_1_c_0_cl_1(0 downto 0) & l_1_c_0_cl_0(0 downto 0);
   l_1_s_1 <= l_1_c_0_cl_71(1 downto 1) & l_1_c_0_cl_70(1 downto 1) & l_1_c_0_cl_69(1 downto 1) & l_1_c_0_cl_68(1 downto 1) & l_1_c_0_cl_67(1 downto 1) & l_1_c_0_cl_66(1 downto 1) & l_1_c_0_cl_65(1 downto 1) & l_1_c_0_cl_64(1 downto 1) & l_1_c_0_cl_63(1 downto 1) & l_1_c_0_cl_62(1 downto 1) & l_1_c_0_cl_61(1 downto 1) & l_1_c_0_cl_60(1 downto 1) & l_1_c_0_cl_59(1 downto 1) & l_1_c_0_cl_58(1 downto 1) & l_1_c_0_cl_57(1 downto 1) & l_1_c_0_cl_56(1 downto 1) & l_1_c_0_cl_55(1 downto 1) & l_1_c_0_cl_54(1 downto 1) & l_1_c_0_cl_53(1 downto 1) & l_1_c_0_cl_52(1 downto 1) & l_1_c_0_cl_51(1 downto 1) & l_1_c_0_cl_50(1 downto 1) & l_1_c_0_cl_49(1 downto 1) & l_1_c_0_cl_48(1 downto 1) & l_1_c_0_cl_47(1 downto 1) & l_1_c_0_cl_46(1 downto 1) & l_1_c_0_cl_45(1 downto 1) & l_1_c_0_cl_44(1 downto 1) & l_1_c_0_cl_43(1 downto 1) & l_1_c_0_cl_42(1 downto 1) & l_1_c_0_cl_41(1 downto 1) & l_1_c_0_cl_40(1 downto 1) & l_1_c_0_cl_39(1 downto 1) & l_1_c_0_cl_38(1 downto 1) & l_1_c_0_cl_37(1 downto 1) & l_1_c_0_cl_36(1 downto 1) & l_1_c_0_cl_35(1 downto 1) & l_1_c_0_cl_34(1 downto 1) & l_1_c_0_cl_33(1 downto 1) & l_1_c_0_cl_32(1 downto 1) & l_1_c_0_cl_31(1 downto 1) & l_1_c_0_cl_30(1 downto 1) & l_1_c_0_cl_29(1 downto 1) & l_1_c_0_cl_28(1 downto 1) & l_1_c_0_cl_27(1 downto 1) & l_1_c_0_cl_26(1 downto 1) & l_1_c_0_cl_25(1 downto 1) & l_1_c_0_cl_24(1 downto 1) & l_1_c_0_cl_23(1 downto 1) & l_1_c_0_cl_22(1 downto 1) & l_1_c_0_cl_21(1 downto 1) & l_1_c_0_cl_20(1 downto 1) & l_1_c_0_cl_19(1 downto 1) & l_1_c_0_cl_18(1 downto 1) & l_1_c_0_cl_17(1 downto 1) & l_1_c_0_cl_16(1 downto 1) & l_1_c_0_cl_15(1 downto 1) & l_1_c_0_cl_14(1 downto 1) & l_1_c_0_cl_13(1 downto 1) & l_1_c_0_cl_12(1 downto 1) & l_1_c_0_cl_11(1 downto 1) & l_1_c_0_cl_10(1 downto 1) & l_1_c_0_cl_9(1 downto 1) & l_1_c_0_cl_8(1 downto 1) & l_1_c_0_cl_7(1 downto 1) & l_1_c_0_cl_6(1 downto 1) & l_1_c_0_cl_5(1 downto 1) & l_1_c_0_cl_4(1 downto 1) & l_1_c_0_cl_3(1 downto 1) & l_1_c_0_cl_2(1 downto 1) & l_1_c_0_cl_1(1 downto 1) & l_1_c_0_cl_0(1 downto 1) & "0";
   FinalAdder_CompressorTree: IntAdder_73_f400_uid38  -- pipelineDepth=2 maxInDelay=2.52276e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => '0',
                 R => myR,
                 X => l_1_s_0,
                 Y => l_1_s_1);

   ----------------Synchro barrier, entering cycle 2----------------
   R <= myR;
 -- delay at adder output 1.381e-09
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_72_f400_uid46
--                     (IntAdderClassical_72_f400_uid48)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2010)
--------------------------------------------------------------------------------
-- Pipeline depth: 2 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntAdder_72_f400_uid46 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(71 downto 0);
          Y : in  std_logic_vector(71 downto 0);
          Cin : in std_logic;
          R : out  std_logic_vector(71 downto 0)   );
end entity;

architecture arch of IntAdder_72_f400_uid46 is
signal x0 :  std_logic_vector(41 downto 0);
signal y0 :  std_logic_vector(41 downto 0);
signal x1, x1_d1 :  std_logic_vector(29 downto 0);
signal y1, y1_d1 :  std_logic_vector(29 downto 0);
signal sum0, sum0_d1 :  std_logic_vector(42 downto 0);
signal sum1 :  std_logic_vector(30 downto 0);
signal X_d1 :  std_logic_vector(71 downto 0);
signal Y_d1 :  std_logic_vector(71 downto 0);
signal Cin_d1 : std_logic;
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            x1_d1 <=  x1;
            y1_d1 <=  y1;
            sum0_d1 <=  sum0;
            X_d1 <=  X;
            Y_d1 <=  Y;
            Cin_d1 <=  Cin;
         end if;
      end process;
   --Classical
   ----------------Synchro barrier, entering cycle 1----------------
   x0 <= X_d1(41 downto 0);
   y0 <= Y_d1(41 downto 0);
   x1 <= X_d1(71 downto 42);
   y1 <= Y_d1(71 downto 42);
   sum0 <= ( "0" & x0) + ( "0" & y0)  + Cin_d1;
   ----------------Synchro barrier, entering cycle 2----------------
   sum1 <= ( "0" & x1_d1) + ( "0" & y1_d1)  + sum0_d1(42);
   R <= sum1(29 downto 0) & sum0_d1(41 downto 0);
end architecture;

--------------------------------------------------------------------------------
--                   LZCShifter_50_to_50_counting_64_uid53
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin, Bogdan Pasca (2007)
--------------------------------------------------------------------------------
-- Pipeline depth: 6 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity LZCShifter_50_to_50_counting_64_uid53 is
   port ( clk, rst : in std_logic;
          I : in  std_logic_vector(49 downto 0);
          Count : out  std_logic_vector(5 downto 0);
          O : out  std_logic_vector(49 downto 0)   );
end entity;

architecture arch of LZCShifter_50_to_50_counting_64_uid53 is
signal level6, level6_d1 :  std_logic_vector(49 downto 0);
signal count5, count5_d1, count5_d2, count5_d3, count5_d4, count5_d5 : std_logic;
signal level5, level5_d1 :  std_logic_vector(49 downto 0);
signal count4, count4_d1, count4_d2, count4_d3, count4_d4 : std_logic;
signal level4, level4_d1 :  std_logic_vector(49 downto 0);
signal count3, count3_d1, count3_d2, count3_d3 : std_logic;
signal level3, level3_d1 :  std_logic_vector(49 downto 0);
signal count2, count2_d1, count2_d2 : std_logic;
signal level2, level2_d1 :  std_logic_vector(49 downto 0);
signal count1, count1_d1 : std_logic;
signal level1, level1_d1 :  std_logic_vector(49 downto 0);
signal count0 : std_logic;
signal level0 :  std_logic_vector(49 downto 0);
signal sCount :  std_logic_vector(5 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            level6_d1 <=  level6;
            count5_d1 <=  count5;
            count5_d2 <=  count5_d1;
            count5_d3 <=  count5_d2;
            count5_d4 <=  count5_d3;
            count5_d5 <=  count5_d4;
            level5_d1 <=  level5;
            count4_d1 <=  count4;
            count4_d2 <=  count4_d1;
            count4_d3 <=  count4_d2;
            count4_d4 <=  count4_d3;
            level4_d1 <=  level4;
            count3_d1 <=  count3;
            count3_d2 <=  count3_d1;
            count3_d3 <=  count3_d2;
            level3_d1 <=  level3;
            count2_d1 <=  count2;
            count2_d2 <=  count2_d1;
            level2_d1 <=  level2;
            count1_d1 <=  count1;
            level1_d1 <=  level1;
         end if;
      end process;
   level6 <= I ;
   ----------------Synchro barrier, entering cycle 1----------------
   count5<= '1' when level6_d1(49 downto 18) = (49 downto 18=>'0') else '0';
   level5<= level6_d1(49 downto 0) when count5='0' else level6_d1(17 downto 0) & (31 downto 0 => '0');

   ----------------Synchro barrier, entering cycle 2----------------
   count4<= '1' when level5_d1(49 downto 34) = (49 downto 34=>'0') else '0';
   level4<= level5_d1(49 downto 0) when count4='0' else level5_d1(33 downto 0) & (15 downto 0 => '0');

   ----------------Synchro barrier, entering cycle 3----------------
   count3<= '1' when level4_d1(49 downto 42) = (49 downto 42=>'0') else '0';
   level3<= level4_d1(49 downto 0) when count3='0' else level4_d1(41 downto 0) & (7 downto 0 => '0');

   ----------------Synchro barrier, entering cycle 4----------------
   count2<= '1' when level3_d1(49 downto 46) = (49 downto 46=>'0') else '0';
   level2<= level3_d1(49 downto 0) when count2='0' else level3_d1(45 downto 0) & (3 downto 0 => '0');

   ----------------Synchro barrier, entering cycle 5----------------
   count1<= '1' when level2_d1(49 downto 48) = (49 downto 48=>'0') else '0';
   level1<= level2_d1(49 downto 0) when count1='0' else level2_d1(47 downto 0) & (1 downto 0 => '0');

   ----------------Synchro barrier, entering cycle 6----------------
   count0<= '1' when level1_d1(49 downto 49) = (49 downto 49=>'0') else '0';
   level0<= level1_d1(49 downto 0) when count0='0' else level1_d1(48 downto 0) & (0 downto 0 => '0');

   O <= level0;
   sCount <= count5_d5 & count4_d4 & count3_d3 & count2_d2 & count1_d1 & count0;
   Count <= sCount;
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_33_f400_uid56
--                     (IntAdderClassical_33_f400_uid58)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2010)
--------------------------------------------------------------------------------
-- Pipeline depth: 1 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntAdder_33_f400_uid56 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(32 downto 0);
          Y : in  std_logic_vector(32 downto 0);
          Cin : in std_logic;
          R : out  std_logic_vector(32 downto 0)   );
end entity;

architecture arch of IntAdder_33_f400_uid56 is
signal X_d1 :  std_logic_vector(32 downto 0);
signal Y_d1 :  std_logic_vector(32 downto 0);
signal Cin_d1 : std_logic;
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            X_d1 <=  X;
            Y_d1 <=  Y;
            Cin_d1 <=  Cin;
         end if;
      end process;
   --Classical
   ----------------Synchro barrier, entering cycle 1----------------
    R <= X_d1 + Y_d1 + Cin_d1;
end architecture;

--------------------------------------------------------------------------------
--                          FPAdder3Input_8_23_uid2
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca (2010)
--------------------------------------------------------------------------------
-- Pipeline depth: 19 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity FPAdder3Input_8_23_uid2 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(8+23+2 downto 0);
          Y : in  std_logic_vector(8+23+2 downto 0);
          Z : in  std_logic_vector(8+23+2 downto 0);
          R : out  std_logic_vector(8+23+2 downto 0)   );
end entity;

architecture arch of FPAdder3Input_8_23_uid2 is
   component IntAdder_33_f400_uid56 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(32 downto 0);
             Y : in  std_logic_vector(32 downto 0);
             Cin : in std_logic;
             R : out  std_logic_vector(32 downto 0)   );
   end component;

   component IntAdder_72_f400_uid46 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(71 downto 0);
             Y : in  std_logic_vector(71 downto 0);
             Cin : in std_logic;
             R : out  std_logic_vector(71 downto 0)   );
   end component;

   component IntAdder_73_f400_uid13 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(72 downto 0);
             Y : in  std_logic_vector(72 downto 0);
             Cin : in std_logic;
             R : out  std_logic_vector(72 downto 0)   );
   end component;

   component IntAdder_73_f400_uid19 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(72 downto 0);
             Y : in  std_logic_vector(72 downto 0);
             Cin : in std_logic;
             R : out  std_logic_vector(72 downto 0)   );
   end component;

   component IntAdder_73_f400_uid25 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(72 downto 0);
             Y : in  std_logic_vector(72 downto 0);
             Cin : in std_logic;
             R : out  std_logic_vector(72 downto 0)   );
   end component;

   component IntMultiAdder_73_op3_f400_uid34 is
      port ( clk, rst : in std_logic;
             X0 : in  std_logic_vector(72 downto 0);
             X1 : in  std_logic_vector(72 downto 0);
             X2 : in  std_logic_vector(72 downto 0);
             R : out  std_logic_vector(72 downto 0)   );
   end component;

   component LZCShifter_50_to_50_counting_64_uid53 is
      port ( clk, rst : in std_logic;
             I : in  std_logic_vector(49 downto 0);
             Count : out  std_logic_vector(5 downto 0);
             O : out  std_logic_vector(49 downto 0)   );
   end component;

   component RightShifter_24_by_max_46_uid10 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(23 downto 0);
             S : in  std_logic_vector(5 downto 0);
             R : out  std_logic_vector(69 downto 0)   );
   end component;

   component RightShifter_24_by_max_46_uid4 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(23 downto 0);
             S : in  std_logic_vector(5 downto 0);
             R : out  std_logic_vector(69 downto 0)   );
   end component;

   component RightShifter_24_by_max_46_uid7 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(23 downto 0);
             S : in  std_logic_vector(5 downto 0);
             R : out  std_logic_vector(69 downto 0)   );
   end component;

signal neX :  std_logic_vector(7 downto 0);
signal neY :  std_logic_vector(7 downto 0);
signal neZ :  std_logic_vector(7 downto 0);
signal mX, mX_d1, mX_d2 :  std_logic_vector(22 downto 0);
signal mY, mY_d1, mY_d2 :  std_logic_vector(22 downto 0);
signal mZ, mZ_d1, mZ_d2 :  std_logic_vector(22 downto 0);
signal sX, sX_d1, sX_d2, sX_d3, sX_d4 : std_logic;
signal sY, sY_d1, sY_d2, sY_d3, sY_d4 : std_logic;
signal sZ, sZ_d1, sZ_d2, sZ_d3, sZ_d4 : std_logic;
signal excX, excX_d1, excX_d2 :  std_logic_vector(1 downto 0);
signal excY, excY_d1, excY_d2 :  std_logic_vector(1 downto 0);
signal excZ, excZ_d1, excZ_d2 :  std_logic_vector(1 downto 0);
signal eX :  std_logic_vector(7 downto 0);
signal eY :  std_logic_vector(7 downto 0);
signal eZ :  std_logic_vector(7 downto 0);
signal expRes1, expRes1_d1, expRes1_d2, expRes1_d3, expRes1_d4, expRes1_d5, expRes1_d6, expRes1_d7, expRes1_d8, expRes1_d9, expRes1_d10, expRes1_d11, expRes1_d12, expRes1_d13, expRes1_d14, expRes1_d15, expRes1_d16, expRes1_d17, expRes1_d18, expRes1_d19 : std_logic;
signal expRes0, expRes0_d1, expRes0_d2, expRes0_d3, expRes0_d4, expRes0_d5, expRes0_d6, expRes0_d7, expRes0_d8, expRes0_d9, expRes0_d10, expRes0_d11, expRes0_d12, expRes0_d13, expRes0_d14, expRes0_d15, expRes0_d16, expRes0_d17, expRes0_d18, expRes0_d19 : std_logic;
signal sgn, sgn_d1, sgn_d2, sgn_d3, sgn_d4, sgn_d5, sgn_d6, sgn_d7, sgn_d8, sgn_d9, sgn_d10, sgn_d11, sgn_d12, sgn_d13, sgn_d14, sgn_d15, sgn_d16, sgn_d17, sgn_d18, sgn_d19 : std_logic;
signal dexy, dexy_d1 :  std_logic_vector(8 downto 0);
signal deyz, deyz_d1 :  std_logic_vector(8 downto 0);
signal dezx, dezx_d1 :  std_logic_vector(8 downto 0);
signal cdexy : std_logic;
signal cdeyz : std_logic;
signal cdezx : std_logic;
signal eMaxSel :  std_logic_vector(2 downto 0);
signal eMax, eMax_d1, eMax_d2, eMax_d3, eMax_d4, eMax_d5, eMax_d6, eMax_d7, eMax_d8, eMax_d9, eMax_d10, eMax_d11, eMax_d12, eMax_d13, eMax_d14, eMax_d15, eMax_d16, eMax_d17 :  std_logic_vector(7 downto 0);
signal m1, m1_d1 : std_logic;
signal m2, m2_d1 : std_logic;
signal m3, m3_d1 : std_logic;
signal alpha, alpha_d1, alpha_d2 :  std_logic_vector(1 downto 0);
signal beta, beta_d1, beta_d2 :  std_logic_vector(1 downto 0);
signal gama, gama_d1, gama_d2 :  std_logic_vector(1 downto 0);
signal mux1out, mux1out_d1 :  std_logic_vector(8 downto 0);
signal mux2out, mux2out_d1 :  std_logic_vector(8 downto 0);
signal mux3out, mux3out_d1 :  std_logic_vector(8 downto 0);
signal nmux1out, nmux1out_d1 :  std_logic_vector(8 downto 0);
signal nmux2out, nmux2out_d1 :  std_logic_vector(8 downto 0);
signal nmux3out, nmux3out_d1 :  std_logic_vector(8 downto 0);
signal amx :  std_logic_vector(8 downto 0);
signal bmx :  std_logic_vector(8 downto 0);
signal gmx :  std_logic_vector(8 downto 0);
signal sval0 :  std_logic_vector(5 downto 0);
signal sval1 :  std_logic_vector(5 downto 0);
signal sval2 :  std_logic_vector(5 downto 0);
signal sout0, sout0_d1, sout0_d2 : std_logic;
signal sout1, sout1_d1, sout1_d2 : std_logic;
signal sout2, sout2_d1, sout2_d2 : std_logic;
signal nfX :  std_logic_vector(23 downto 0);
signal nfY :  std_logic_vector(23 downto 0);
signal nfZ :  std_logic_vector(23 downto 0);
signal fX :  std_logic_vector(23 downto 0);
signal fY :  std_logic_vector(23 downto 0);
signal fZ :  std_logic_vector(23 downto 0);
signal sfX, sfX_d1 :  std_logic_vector(69 downto 0);
signal sfY, sfY_d1 :  std_logic_vector(69 downto 0);
signal sfZ, sfZ_d1 :  std_logic_vector(69 downto 0);
signal efX :  std_logic_vector(72 downto 0);
signal efY :  std_logic_vector(72 downto 0);
signal efZ :  std_logic_vector(72 downto 0);
signal xsefX :  std_logic_vector(72 downto 0);
signal xsefY :  std_logic_vector(72 downto 0);
signal xsefZ :  std_logic_vector(72 downto 0);
signal sefX :  std_logic_vector(72 downto 0);
signal sefY :  std_logic_vector(72 downto 0);
signal sefZ :  std_logic_vector(72 downto 0);
signal addRes :  std_logic_vector(72 downto 0);
signal trSign, trSign_d1, trSign_d2, trSign_d3, trSign_d4, trSign_d5, trSign_d6, trSign_d7, trSign_d8, trSign_d9, trSign_d10, trSign_d11 : std_logic;
signal xposExtF :  std_logic_vector(71 downto 0);
signal posExtF, posExtF_d1 :  std_logic_vector(71 downto 0);
signal sticky : std_logic;
signal posExtFsticky :  std_logic_vector(49 downto 0);
signal nZerosNew :  std_logic_vector(5 downto 0);
signal shiftedFrac :  std_logic_vector(49 downto 0);
signal stk : std_logic;
signal rnd : std_logic;
signal grd : std_logic;
signal lsb : std_logic;
signal tfracR :  std_logic_vector(23 downto 0);
signal biasedZeros, biasedZeros_d1, biasedZeros_d2 :  std_logic_vector(8 downto 0);
signal addToRoundBit : std_logic;
signal xroundedExpFrac :  std_logic_vector(32 downto 0);
signal roundedExpFrac, roundedExpFrac_d1 :  std_logic_vector(32 downto 0);
signal tnexp, tnexp_d1 :  std_logic_vector(8 downto 0);
signal upexp :  std_logic_vector(8 downto 0);
signal path1_exp :  std_logic_vector(7 downto 0);
signal path1_frac :  std_logic_vector(22 downto 0);
signal path1_exc :  std_logic_vector(1 downto 0);
signal path1_sign : std_logic;
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            mX_d1 <=  mX;
            mX_d2 <=  mX_d1;
            mY_d1 <=  mY;
            mY_d2 <=  mY_d1;
            mZ_d1 <=  mZ;
            mZ_d2 <=  mZ_d1;
            sX_d1 <=  sX;
            sX_d2 <=  sX_d1;
            sX_d3 <=  sX_d2;
            sX_d4 <=  sX_d3;
            sY_d1 <=  sY;
            sY_d2 <=  sY_d1;
            sY_d3 <=  sY_d2;
            sY_d4 <=  sY_d3;
            sZ_d1 <=  sZ;
            sZ_d2 <=  sZ_d1;
            sZ_d3 <=  sZ_d2;
            sZ_d4 <=  sZ_d3;
            excX_d1 <=  excX;
            excX_d2 <=  excX_d1;
            excY_d1 <=  excY;
            excY_d2 <=  excY_d1;
            excZ_d1 <=  excZ;
            excZ_d2 <=  excZ_d1;
            expRes1_d1 <=  expRes1;
            expRes1_d2 <=  expRes1_d1;
            expRes1_d3 <=  expRes1_d2;
            expRes1_d4 <=  expRes1_d3;
            expRes1_d5 <=  expRes1_d4;
            expRes1_d6 <=  expRes1_d5;
            expRes1_d7 <=  expRes1_d6;
            expRes1_d8 <=  expRes1_d7;
            expRes1_d9 <=  expRes1_d8;
            expRes1_d10 <=  expRes1_d9;
            expRes1_d11 <=  expRes1_d10;
            expRes1_d12 <=  expRes1_d11;
            expRes1_d13 <=  expRes1_d12;
            expRes1_d14 <=  expRes1_d13;
            expRes1_d15 <=  expRes1_d14;
            expRes1_d16 <=  expRes1_d15;
            expRes1_d17 <=  expRes1_d16;
            expRes1_d18 <=  expRes1_d17;
            expRes1_d19 <=  expRes1_d18;
            expRes0_d1 <=  expRes0;
            expRes0_d2 <=  expRes0_d1;
            expRes0_d3 <=  expRes0_d2;
            expRes0_d4 <=  expRes0_d3;
            expRes0_d5 <=  expRes0_d4;
            expRes0_d6 <=  expRes0_d5;
            expRes0_d7 <=  expRes0_d6;
            expRes0_d8 <=  expRes0_d7;
            expRes0_d9 <=  expRes0_d8;
            expRes0_d10 <=  expRes0_d9;
            expRes0_d11 <=  expRes0_d10;
            expRes0_d12 <=  expRes0_d11;
            expRes0_d13 <=  expRes0_d12;
            expRes0_d14 <=  expRes0_d13;
            expRes0_d15 <=  expRes0_d14;
            expRes0_d16 <=  expRes0_d15;
            expRes0_d17 <=  expRes0_d16;
            expRes0_d18 <=  expRes0_d17;
            expRes0_d19 <=  expRes0_d18;
            sgn_d1 <=  sgn;
            sgn_d2 <=  sgn_d1;
            sgn_d3 <=  sgn_d2;
            sgn_d4 <=  sgn_d3;
            sgn_d5 <=  sgn_d4;
            sgn_d6 <=  sgn_d5;
            sgn_d7 <=  sgn_d6;
            sgn_d8 <=  sgn_d7;
            sgn_d9 <=  sgn_d8;
            sgn_d10 <=  sgn_d9;
            sgn_d11 <=  sgn_d10;
            sgn_d12 <=  sgn_d11;
            sgn_d13 <=  sgn_d12;
            sgn_d14 <=  sgn_d13;
            sgn_d15 <=  sgn_d14;
            sgn_d16 <=  sgn_d15;
            sgn_d17 <=  sgn_d16;
            sgn_d18 <=  sgn_d17;
            sgn_d19 <=  sgn_d18;
            dexy_d1 <=  dexy;
            deyz_d1 <=  deyz;
            dezx_d1 <=  dezx;
            eMax_d1 <=  eMax;
            eMax_d2 <=  eMax_d1;
            eMax_d3 <=  eMax_d2;
            eMax_d4 <=  eMax_d3;
            eMax_d5 <=  eMax_d4;
            eMax_d6 <=  eMax_d5;
            eMax_d7 <=  eMax_d6;
            eMax_d8 <=  eMax_d7;
            eMax_d9 <=  eMax_d8;
            eMax_d10 <=  eMax_d9;
            eMax_d11 <=  eMax_d10;
            eMax_d12 <=  eMax_d11;
            eMax_d13 <=  eMax_d12;
            eMax_d14 <=  eMax_d13;
            eMax_d15 <=  eMax_d14;
            eMax_d16 <=  eMax_d15;
            eMax_d17 <=  eMax_d16;
            m1_d1 <=  m1;
            m2_d1 <=  m2;
            m3_d1 <=  m3;
            alpha_d1 <=  alpha;
            alpha_d2 <=  alpha_d1;
            beta_d1 <=  beta;
            beta_d2 <=  beta_d1;
            gama_d1 <=  gama;
            gama_d2 <=  gama_d1;
            mux1out_d1 <=  mux1out;
            mux2out_d1 <=  mux2out;
            mux3out_d1 <=  mux3out;
            nmux1out_d1 <=  nmux1out;
            nmux2out_d1 <=  nmux2out;
            nmux3out_d1 <=  nmux3out;
            sout0_d1 <=  sout0;
            sout0_d2 <=  sout0_d1;
            sout1_d1 <=  sout1;
            sout1_d2 <=  sout1_d1;
            sout2_d1 <=  sout2;
            sout2_d2 <=  sout2_d1;
            sfX_d1 <=  sfX;
            sfY_d1 <=  sfY;
            sfZ_d1 <=  sfZ;
            trSign_d1 <=  trSign;
            trSign_d2 <=  trSign_d1;
            trSign_d3 <=  trSign_d2;
            trSign_d4 <=  trSign_d3;
            trSign_d5 <=  trSign_d4;
            trSign_d6 <=  trSign_d5;
            trSign_d7 <=  trSign_d6;
            trSign_d8 <=  trSign_d7;
            trSign_d9 <=  trSign_d8;
            trSign_d10 <=  trSign_d9;
            trSign_d11 <=  trSign_d10;
            posExtF_d1 <=  posExtF;
            biasedZeros_d1 <=  biasedZeros;
            biasedZeros_d2 <=  biasedZeros_d1;
            roundedExpFrac_d1 <=  roundedExpFrac;
            tnexp_d1 <=  tnexp;
         end if;
      end process;
   neX<= X(30 downto 23);
   neY<= Y(30 downto 23);
   neZ<= Z(30 downto 23);
   mX<= X(22 downto 0);
   mY<= Y(22 downto 0);
   mZ<= Z(22 downto 0);
   sX<= X(31);
   sY<= Y(31);
   sZ<= Z(31);
   excX <= X(33 downto 32);
   excY <= Y(33 downto 32);
   excZ <= Z(33 downto 32);

   eX <= "00000000" when excX="00" else neX;
   eY <= "00000000" when excY="00" else neY;
   eZ <= "00000000" when excZ="00" else neZ;
   expRes1 <= '1' when (excX(1)='1' or excY(1)='1' or excZ(1)='1') else '0';
   expRes0 <= '1' when (((excX(1)='0' and excY(1)='0' and excZ(1)='0') and (excX(0)='1' or excY(0)='1' or excZ(0)='1') ) or 
      (excX="10" and sX='1' and excY="10" and sY='0') or 
      (excX="10" and sX='0' and excY="10" and sY='1') or 
      (excZ="10" and sZ='1' and excY="10" and sY='0') or 
      (excZ="10" and sZ='0' and excY="10" and sY='1') or 
      (excX="10" and sX='1' and excZ="10" and sZ='0') or 
      (excX="10" and sX='0' and excZ="10" and sZ='1') or 
      (excX="11" or excY="11" or excZ="11")) else '0';
   sgn<= '1' when ((excX="10" and sX='1') or (excY="10" and sY='1') or (excZ="10" and sZ='1') ) else '0';
   ---------------- cycle 0----------------
   dexy <= ("0" & eX) - ("0" & eY);
   deyz <= ("0" & eY) - ("0" & eZ);
   dezx <= ("0" & eZ) - ("0" & eX);
   cdexy <= dexy(8);
   cdeyz <= deyz(8);
   cdezx <= dezx(8);
   eMaxSel <= cdexy & cdeyz & cdezx;
   with (eMaxSel) select 
   eMax <= eX when "001"|"011",
       eY when "100"|"101",
       eZ when "010"|"110",
       eX when others;
   with (eMaxSel) select 
   m1 <=  '1' when "010"|"110", '0' when others;
   with (eMaxSel) select 
   m2 <= '1' when "001"|"011", '0' when others;
   with (eMaxSel) select 
   m3 <= '1' when "100"|"101", '0' when others;
   with (eMaxSel) select 
   alpha <= "00" when "010"|"110",
       "01" when "100"|"101",
       "10" when "001"|"011",
       "11" when others;
   with (eMaxSel) select 
   beta <= "00" when "001"|"011",
       "01" when "010"|"110",
       "10" when "100"|"101",
       "11" when others;
   with (eMaxSel) select 
   gama <= "00" when "100"|"101",
       "01" when "001"|"011",
       "10" when "010"|"110",
       "11" when others;
   ----------------Synchro barrier, entering cycle 1----------------
   mux1out <= dexy_d1 when m1_d1='0' else dezx_d1;
   mux2out <= deyz_d1 when m2_d1='0' else dexy_d1;
   mux3out <= dezx_d1 when m3_d1='0' else deyz_d1;
   nmux1out <=  not(mux1out) + '1';
   nmux2out <=  not(mux2out) + '1';
   nmux3out <=  not(mux3out) + '1';
   ----------------Synchro barrier, entering cycle 2----------------
   with (alpha_d2) select 
   amx <= mux1out_d1 when "00",
      nmux1out_d1 when "01", 
      "000000000" when "10",
   "000000000" when others;
   with (beta_d2) select 
   bmx <= mux2out_d1 when "00",
      nmux2out_d1 when "01", 
      "000000000" when "10",
   "000000000" when others;
   with (gama_d2) select 
   gmx <= mux3out_d1 when "00",
      nmux3out_d1 when "01", 
      "000000000" when "10",
   "000000000" when others;
   sval0<= amx(5 downto 0);
   sval1<= bmx(5 downto 0);
   sval2<= gmx(5 downto 0);
   sout0 <=  '1' when amx(8 downto 6)>0 else '0';
   sout1 <=  '1' when bmx(8 downto 6)>0 else '0';
   sout2 <=  '1' when gmx(8 downto 6)>0 else '0';
   nfX <=  "1" & mX_d2;
   nfY <=  "1" & mY_d2;
   nfZ <=  "1" & mZ_d2;
   fX <= "000000000000000000000000" when excX_d2="00" else nfX;
   fY <= "000000000000000000000000" when excY_d2="00" else nfY;
   fZ <= "000000000000000000000000" when excZ_d2="00" else nfZ;
   fxShifter: RightShifter_24_by_max_46_uid4  -- pipelineDepth=1 maxInDelay=9.7544e-10
      port map ( clk  => clk,
                 rst  => rst,
                 R => sfX,
                 S => sval0,
                 X => fX);
   fyShifter: RightShifter_24_by_max_46_uid7  -- pipelineDepth=1 maxInDelay=9.7544e-10
      port map ( clk  => clk,
                 rst  => rst,
                 R => sfY,
                 S => sval1,
                 X => fY);
   fzShifter: RightShifter_24_by_max_46_uid10  -- pipelineDepth=1 maxInDelay=9.7544e-10
      port map ( clk  => clk,
                 rst  => rst,
                 R => sfZ,
                 S => sval2,
                 X => fZ);
   ----------------Synchro barrier, entering cycle 3----------------
   ----------------Synchro barrier, entering cycle 4----------------
   efX <= ("000" & sfX_d1) when sout0_d2='0' else "0000000000000000000000000000000000000000000000000000000000000000000000000";
   efY <= ("000" & sfY_d1) when sout1_d2='0' else "0000000000000000000000000000000000000000000000000000000000000000000000000";
   efZ <= ("000" & sfZ_d1) when sout2_d2='0' else "0000000000000000000000000000000000000000000000000000000000000000000000000";
   xsefX <= (efX xor (72 downto 0 => sX_d4));
   xsefY <= (efY xor (72 downto 0 => sY_d4));
   xsefZ <= (efZ xor (72 downto 0 => sZ_d4));
   Twoscompl0: IntAdder_73_f400_uid13  -- pipelineDepth=2 maxInDelay=1.50616e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => sX_d4,
                 R => sefX   ,
                 X => xsefX,
                 Y => "0000000000000000000000000000000000000000000000000000000000000000000000000");

   Twoscompl1: IntAdder_73_f400_uid19  -- pipelineDepth=2 maxInDelay=1.50616e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => sY_d4,
                 R => sefY   ,
                 X => xsefY,
                 Y => "0000000000000000000000000000000000000000000000000000000000000000000000000");

   Twoscompl2: IntAdder_73_f400_uid25  -- pipelineDepth=2 maxInDelay=1.50616e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => sZ_d4,
                 R => sefZ   ,
                 X => xsefZ,
                 Y => "0000000000000000000000000000000000000000000000000000000000000000000000000");

   ----------------Synchro barrier, entering cycle 6----------------
   Adder3Op: IntMultiAdder_73_op3_f400_uid34  -- pipelineDepth=2 maxInDelay=1.50372e-09
      port map ( clk  => clk,
                 rst  => rst,
                 R => addRes   ,
                 X0 => sefX,
                 X1 => sefY,
                 X2 => sefZ);

   ----------------Synchro barrier, entering cycle 8----------------
   trSign <= addRes(72);
   xposExtF <= (addRes(71 downto 0) xor (71 downto 0 => trSign));
   AdderSignMag: IntAdder_72_f400_uid46  -- pipelineDepth=2 maxInDelay=2.35644e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => trSign,
                 R => posExtF   ,
                 X => xposExtF,
                 Y => "000000000000000000000000000000000000000000000000000000000000000000000000");

   ----------------Synchro barrier, entering cycle 10----------------
   ----------------Synchro barrier, entering cycle 11----------------
   sticky <=  '1' when posExtF_d1(21 downto 0)>"0000000000000000000000" else '0';
   posExtFsticky <= posExtF_d1(71 downto 23) & sticky;
   LZC_component: LZCShifter_50_to_50_counting_64_uid53  -- pipelineDepth=6 maxInDelay=1.37244e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Count => nZerosNew,
                 I => posExtFsticky,
                 O => shiftedFrac);
   ----------------Synchro barrier, entering cycle 17----------------
   stk<= '1' when shiftedFrac(23 downto 0)>"000000000000000000000000"else '0';
   rnd<= shiftedFrac(24);
   grd<= shiftedFrac(25);
   lsb<= shiftedFrac(26);
   tfracR<= shiftedFrac(48 downto 25);
   biasedZeros <= CONV_STD_LOGIC_VECTOR(2,9) - ("000" & nZerosNew);
   addToRoundBit<= '0' when (lsb='0' and grd='1' and rnd='0' and stk='0')  else '1';
   xroundedExpFrac<= ("0" & eMax_d17 & tfracR);
   Rounding_Adder: IntAdder_33_f400_uid56  -- pipelineDepth=1 maxInDelay=1.90316e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => addToRoundBit,
                 R => roundedExpFrac   ,
                 X => xroundedExpFrac,
                 Y => "000000000000000000000000000000000");

   ----------------Synchro barrier, entering cycle 18----------------
   tnexp<= roundedExpFrac(32 downto 24);
   ----------------Synchro barrier, entering cycle 19----------------
   upexp  <=  tnexp_d1 + biasedZeros_d2;
   path1_exp <= upexp(7 downto 0);
   path1_frac <= roundedExpFrac_d1(23 downto 1);
   path1_exc<= expRes1_d19 & expRes0_d19;
   path1_sign<= sgn_d19 when path1_exc>"01" else trSign_d11;
   R <= path1_exc & path1_sign & path1_exp & path1_frac;
end architecture;

