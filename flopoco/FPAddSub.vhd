--------------------------------------------------------------------------------
--                      FPAddSub_8_23_uid2_RightShifter
--                      (RightShifter_24_by_max_26_uid4)
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

entity FPAddSub_8_23_uid2_RightShifter is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(23 downto 0);
          S : in  std_logic_vector(4 downto 0);
          R : out  std_logic_vector(49 downto 0)   );
end entity;

architecture arch of FPAddSub_8_23_uid2_RightShifter is
signal level0, level0_d1 :  std_logic_vector(23 downto 0);
signal ps, ps_d1 :  std_logic_vector(4 downto 0);
signal level1 :  std_logic_vector(24 downto 0);
signal level2 :  std_logic_vector(26 downto 0);
signal level3 :  std_logic_vector(30 downto 0);
signal level4 :  std_logic_vector(38 downto 0);
signal level5 :  std_logic_vector(54 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            level0_d1 <=  level0;
            ps_d1 <=  ps;
         end if;
      end process;
   level0<= X;
   ps<= S;
   ----------------Synchro barrier, entering cycle 1----------------
   level1<=  (0 downto 0 => '0') & level0_d1 when ps_d1(0) = '1' else    level0_d1 & (0 downto 0 => '0');
   level2<=  (1 downto 0 => '0') & level1 when ps_d1(1) = '1' else    level1 & (1 downto 0 => '0');
   level3<=  (3 downto 0 => '0') & level2 when ps_d1(2) = '1' else    level2 & (3 downto 0 => '0');
   level4<=  (7 downto 0 => '0') & level3 when ps_d1(3) = '1' else    level3 & (7 downto 0 => '0');
   level5<=  (15 downto 0 => '0') & level4 when ps_d1(4) = '1' else    level4 & (15 downto 0 => '0');
   R <= level5(54 downto 5);
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_27_f400_uid7
--                      (IntAdderClassical_27_f400_uid9)
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

entity IntAdder_27_f400_uid7 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(26 downto 0);
          Y : in  std_logic_vector(26 downto 0);
          Cin : in std_logic;
          R : out  std_logic_vector(26 downto 0)   );
end entity;

architecture arch of IntAdder_27_f400_uid7 is
signal X_d1 :  std_logic_vector(26 downto 0);
signal Y_d1 :  std_logic_vector(26 downto 0);
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
--                   LZCShifter_28_to_28_counting_32_uid15
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin, Bogdan Pasca (2007)
--------------------------------------------------------------------------------
-- Pipeline depth: 4 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity LZCShifter_28_to_28_counting_32_uid15 is
   port ( clk, rst : in std_logic;
          I : in  std_logic_vector(27 downto 0);
          Count : out  std_logic_vector(4 downto 0);
          O : out  std_logic_vector(27 downto 0)   );
end entity;

architecture arch of LZCShifter_28_to_28_counting_32_uid15 is
signal level5, level5_d1 :  std_logic_vector(27 downto 0);
signal count4, count4_d1, count4_d2, count4_d3, count4_d4 : std_logic;
signal level4 :  std_logic_vector(27 downto 0);
signal count3, count3_d1, count3_d2, count3_d3 : std_logic;
signal level3, level3_d1 :  std_logic_vector(27 downto 0);
signal count2, count2_d1, count2_d2 : std_logic;
signal level2, level2_d1 :  std_logic_vector(27 downto 0);
signal count1, count1_d1 : std_logic;
signal level1, level1_d1 :  std_logic_vector(27 downto 0);
signal count0 : std_logic;
signal level0 :  std_logic_vector(27 downto 0);
signal sCount :  std_logic_vector(4 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            level5_d1 <=  level5;
            count4_d1 <=  count4;
            count4_d2 <=  count4_d1;
            count4_d3 <=  count4_d2;
            count4_d4 <=  count4_d3;
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
   level5 <= I ;
   count4<= '1' when level5(27 downto 12) = (27 downto 12=>'0') else '0';
   ----------------Synchro barrier, entering cycle 1----------------
   level4<= level5_d1(27 downto 0) when count4_d1='0' else level5_d1(11 downto 0) & (15 downto 0 => '0');

   count3<= '1' when level4(27 downto 20) = (27 downto 20=>'0') else '0';
   level3<= level4(27 downto 0) when count3='0' else level4(19 downto 0) & (7 downto 0 => '0');

   ----------------Synchro barrier, entering cycle 2----------------
   count2<= '1' when level3_d1(27 downto 24) = (27 downto 24=>'0') else '0';
   level2<= level3_d1(27 downto 0) when count2='0' else level3_d1(23 downto 0) & (3 downto 0 => '0');

   ----------------Synchro barrier, entering cycle 3----------------
   count1<= '1' when level2_d1(27 downto 26) = (27 downto 26=>'0') else '0';
   level1<= level2_d1(27 downto 0) when count1='0' else level2_d1(25 downto 0) & (1 downto 0 => '0');

   ----------------Synchro barrier, entering cycle 4----------------
   count0<= '1' when level1_d1(27 downto 27) = (27 downto 27=>'0') else '0';
   level0<= level1_d1(27 downto 0) when count0='0' else level1_d1(26 downto 0) & (0 downto 0 => '0');

   O <= level0;
   sCount <= count4_d4 & count3_d3 & count2_d2 & count1_d1 & count0;
   Count <= sCount;
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_34_f400_uid18
--                     (IntAdderClassical_34_f400_uid20)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2010)
--------------------------------------------------------------------------------
-- Pipeline depth: 0 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntAdder_34_f400_uid18 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(33 downto 0);
          Y : in  std_logic_vector(33 downto 0);
          Cin : in std_logic;
          R : out  std_logic_vector(33 downto 0)   );
end entity;

architecture arch of IntAdder_34_f400_uid18 is
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
         end if;
      end process;
   --Classical
    R <= X + Y + Cin;
end architecture;

--------------------------------------------------------------------------------
--                             FPAddSub_8_23_uid2
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Matei Istoan, Florent de Dinechin (2012)
--------------------------------------------------------------------------------
-- Pipeline depth: 13 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity FPAddSub_8_23_uid2 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(8+23+2 downto 0);
          Y : in  std_logic_vector(8+23+2 downto 0);
          Radd : out  std_logic_vector(8+23+2 downto 0);
          Rsub : out  std_logic_vector(8+23+2 downto 0)   );
end entity;

architecture arch of FPAddSub_8_23_uid2 is
   component FPAddSub_8_23_uid2_RightShifter is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(23 downto 0);
             S : in  std_logic_vector(4 downto 0);
             R : out  std_logic_vector(49 downto 0)   );
   end component;

   component IntAdder_27_f400_uid7 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(26 downto 0);
             Y : in  std_logic_vector(26 downto 0);
             Cin : in std_logic;
             R : out  std_logic_vector(26 downto 0)   );
   end component;

   component IntAdder_34_f400_uid18 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(33 downto 0);
             Y : in  std_logic_vector(33 downto 0);
             Cin : in std_logic;
             R : out  std_logic_vector(33 downto 0)   );
   end component;

   component LZCShifter_28_to_28_counting_32_uid15 is
      port ( clk, rst : in std_logic;
             I : in  std_logic_vector(27 downto 0);
             Count : out  std_logic_vector(4 downto 0);
             O : out  std_logic_vector(27 downto 0)   );
   end component;

signal excExpFracX :  std_logic_vector(32 downto 0);
signal excExpFracY :  std_logic_vector(32 downto 0);
signal eXmeY, eXmeY_d1 :  std_logic_vector(8 downto 0);
signal eYmeX, eYmeX_d1 :  std_logic_vector(8 downto 0);
signal swap, swap_d1, swap_d2 : std_logic;
signal newX, newX_d1, newX_d2 :  std_logic_vector(33 downto 0);
signal newY :  std_logic_vector(33 downto 0);
signal expX, expX_d1, expX_d2, expX_d3, expX_d4 :  std_logic_vector(7 downto 0);
signal excX :  std_logic_vector(1 downto 0);
signal excY :  std_logic_vector(1 downto 0);
signal signX, signX_d1 : std_logic;
signal signY : std_logic;
signal diffSigns, diffSigns_d1, diffSigns_d2, diffSigns_d3, diffSigns_d4, diffSigns_d5, diffSigns_d6, diffSigns_d7, diffSigns_d8, diffSigns_d9, diffSigns_d10, diffSigns_d11, diffSigns_d12 : std_logic;
signal sXsYExnXY, sXsYExnXY_d1 :  std_logic_vector(5 downto 0);
signal fracY :  std_logic_vector(23 downto 0);
signal excRtRAdd, excRtRAdd_d1, excRtRAdd_d2, excRtRAdd_d3, excRtRAdd_d4, excRtRAdd_d5, excRtRAdd_d6, excRtRAdd_d7, excRtRAdd_d8, excRtRAdd_d9, excRtRAdd_d10 :  std_logic_vector(1 downto 0);
signal excRtRSub, excRtRSub_d1, excRtRSub_d2, excRtRSub_d3, excRtRSub_d4, excRtRSub_d5, excRtRSub_d6, excRtRSub_d7, excRtRSub_d8, excRtRSub_d9, excRtRSub_d10 :  std_logic_vector(1 downto 0);
signal signRAdd, signRAdd_d1, signRAdd_d2, signRAdd_d3, signRAdd_d4, signRAdd_d5, signRAdd_d6 : std_logic;
signal signRSub, signRSub_d1, signRSub_d2, signRSub_d3, signRSub_d4, signRSub_d5, signRSub_d6, signRSub_d7, signRSub_d8, signRSub_d9, signRSub_d10, signRSub_d11 : std_logic;
signal expDiff :  std_logic_vector(8 downto 0);
signal shiftedOut : std_logic;
signal shiftVal :  std_logic_vector(4 downto 0);
signal shiftedFracY, shiftedFracY_d1 :  std_logic_vector(49 downto 0);
signal sticky, sticky_d1, sticky_d2, sticky_d3 : std_logic;
signal shiftedFracYext :  std_logic_vector(26 downto 0);
signal fracYAdd :  std_logic_vector(26 downto 0);
signal fracYSub :  std_logic_vector(26 downto 0);
signal fracX :  std_logic_vector(26 downto 0);
signal cInFracAdderSub : std_logic;
signal fracAdderResultAdd, fracAdderResultAdd_d1 :  std_logic_vector(26 downto 0);
signal fracAdderResultSub, fracAdderResultSub_d1, fracAdderResultSub_d2 :  std_logic_vector(26 downto 0);
signal extendedExp :  std_logic_vector(9 downto 0);
signal extendedExpInc, extendedExpInc_d1, extendedExpInc_d2, extendedExpInc_d3, extendedExpInc_d4, extendedExpInc_d5, extendedExpInc_d6 :  std_logic_vector(9 downto 0);
signal fracGRSSub :  std_logic_vector(27 downto 0);
signal nZerosNew, nZerosNew_d1 :  std_logic_vector(4 downto 0);
signal shiftedFracSub :  std_logic_vector(27 downto 0);
signal updatedExpSub :  std_logic_vector(9 downto 0);
signal eqdiffsign, eqdiffsign_d1 : std_logic;
signal expFracSub, expFracSub_d1 :  std_logic_vector(33 downto 0);
signal stkSub, stkSub_d1 : std_logic;
signal rndSub, rndSub_d1 : std_logic;
signal grdSub, grdSub_d1 : std_logic;
signal lsbSub, lsbSub_d1 : std_logic;
signal addToRoundBitSub : std_logic;
signal RoundedExpFracSub, RoundedExpFracSub_d1 :  std_logic_vector(33 downto 0);
signal upExcSub :  std_logic_vector(1 downto 0);
signal fracRSub, fracRSub_d1 :  std_logic_vector(22 downto 0);
signal expRSub, expRSub_d1 :  std_logic_vector(7 downto 0);
signal excRtEffSub :  std_logic_vector(1 downto 0);
signal exExpExcSub :  std_logic_vector(3 downto 0);
signal excRt2Sub :  std_logic_vector(1 downto 0);
signal excRSub, excRSub_d1 :  std_logic_vector(1 downto 0);
signal computedRSub :  std_logic_vector(30 downto 0);
signal fracGRSAdd :  std_logic_vector(27 downto 0);
signal updatedFracAdd, updatedFracAdd_d1 :  std_logic_vector(23 downto 0);
signal updatedExpAdd, updatedExpAdd_d1 :  std_logic_vector(9 downto 0);
signal expFracAdd :  std_logic_vector(33 downto 0);
signal stkAdd, stkAdd_d1 : std_logic;
signal rndAdd, rndAdd_d1 : std_logic;
signal grdAdd, grdAdd_d1 : std_logic;
signal lsbAdd, lsbAdd_d1 : std_logic;
signal addToRoundBitAdd : std_logic;
signal RoundedExpFracAdd, RoundedExpFracAdd_d1 :  std_logic_vector(33 downto 0);
signal upExcAdd :  std_logic_vector(1 downto 0);
signal fracRAdd, fracRAdd_d1 :  std_logic_vector(22 downto 0);
signal expRAdd, expRAdd_d1 :  std_logic_vector(7 downto 0);
signal excRtEffAdd :  std_logic_vector(1 downto 0);
signal exExpExcAdd :  std_logic_vector(3 downto 0);
signal excRt2Add, excRt2Add_d1 :  std_logic_vector(1 downto 0);
signal excRAdd, excRAdd_d1, excRAdd_d2, excRAdd_d3, excRAdd_d4, excRAdd_d5 :  std_logic_vector(1 downto 0);
signal computedRAdd, computedRAdd_d1, computedRAdd_d2, computedRAdd_d3, computedRAdd_d4, computedRAdd_d5 :  std_logic_vector(30 downto 0);
signal X_d1 :  std_logic_vector(8+23+2 downto 0);
signal Y_d1 :  std_logic_vector(8+23+2 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            eXmeY_d1 <=  eXmeY;
            eYmeX_d1 <=  eYmeX;
            swap_d1 <=  swap;
            swap_d2 <=  swap_d1;
            newX_d1 <=  newX;
            newX_d2 <=  newX_d1;
            expX_d1 <=  expX;
            expX_d2 <=  expX_d1;
            expX_d3 <=  expX_d2;
            expX_d4 <=  expX_d3;
            signX_d1 <=  signX;
            diffSigns_d1 <=  diffSigns;
            diffSigns_d2 <=  diffSigns_d1;
            diffSigns_d3 <=  diffSigns_d2;
            diffSigns_d4 <=  diffSigns_d3;
            diffSigns_d5 <=  diffSigns_d4;
            diffSigns_d6 <=  diffSigns_d5;
            diffSigns_d7 <=  diffSigns_d6;
            diffSigns_d8 <=  diffSigns_d7;
            diffSigns_d9 <=  diffSigns_d8;
            diffSigns_d10 <=  diffSigns_d9;
            diffSigns_d11 <=  diffSigns_d10;
            diffSigns_d12 <=  diffSigns_d11;
            sXsYExnXY_d1 <=  sXsYExnXY;
            excRtRAdd_d1 <=  excRtRAdd;
            excRtRAdd_d2 <=  excRtRAdd_d1;
            excRtRAdd_d3 <=  excRtRAdd_d2;
            excRtRAdd_d4 <=  excRtRAdd_d3;
            excRtRAdd_d5 <=  excRtRAdd_d4;
            excRtRAdd_d6 <=  excRtRAdd_d5;
            excRtRAdd_d7 <=  excRtRAdd_d6;
            excRtRAdd_d8 <=  excRtRAdd_d7;
            excRtRAdd_d9 <=  excRtRAdd_d8;
            excRtRAdd_d10 <=  excRtRAdd_d9;
            excRtRSub_d1 <=  excRtRSub;
            excRtRSub_d2 <=  excRtRSub_d1;
            excRtRSub_d3 <=  excRtRSub_d2;
            excRtRSub_d4 <=  excRtRSub_d3;
            excRtRSub_d5 <=  excRtRSub_d4;
            excRtRSub_d6 <=  excRtRSub_d5;
            excRtRSub_d7 <=  excRtRSub_d6;
            excRtRSub_d8 <=  excRtRSub_d7;
            excRtRSub_d9 <=  excRtRSub_d8;
            excRtRSub_d10 <=  excRtRSub_d9;
            signRAdd_d1 <=  signRAdd;
            signRAdd_d2 <=  signRAdd_d1;
            signRAdd_d3 <=  signRAdd_d2;
            signRAdd_d4 <=  signRAdd_d3;
            signRAdd_d5 <=  signRAdd_d4;
            signRAdd_d6 <=  signRAdd_d5;
            signRSub_d1 <=  signRSub;
            signRSub_d2 <=  signRSub_d1;
            signRSub_d3 <=  signRSub_d2;
            signRSub_d4 <=  signRSub_d3;
            signRSub_d5 <=  signRSub_d4;
            signRSub_d6 <=  signRSub_d5;
            signRSub_d7 <=  signRSub_d6;
            signRSub_d8 <=  signRSub_d7;
            signRSub_d9 <=  signRSub_d8;
            signRSub_d10 <=  signRSub_d9;
            signRSub_d11 <=  signRSub_d10;
            shiftedFracY_d1 <=  shiftedFracY;
            sticky_d1 <=  sticky;
            sticky_d2 <=  sticky_d1;
            sticky_d3 <=  sticky_d2;
            fracAdderResultAdd_d1 <=  fracAdderResultAdd;
            fracAdderResultSub_d1 <=  fracAdderResultSub;
            fracAdderResultSub_d2 <=  fracAdderResultSub_d1;
            extendedExpInc_d1 <=  extendedExpInc;
            extendedExpInc_d2 <=  extendedExpInc_d1;
            extendedExpInc_d3 <=  extendedExpInc_d2;
            extendedExpInc_d4 <=  extendedExpInc_d3;
            extendedExpInc_d5 <=  extendedExpInc_d4;
            extendedExpInc_d6 <=  extendedExpInc_d5;
            nZerosNew_d1 <=  nZerosNew;
            eqdiffsign_d1 <=  eqdiffsign;
            expFracSub_d1 <=  expFracSub;
            stkSub_d1 <=  stkSub;
            rndSub_d1 <=  rndSub;
            grdSub_d1 <=  grdSub;
            lsbSub_d1 <=  lsbSub;
            RoundedExpFracSub_d1 <=  RoundedExpFracSub;
            fracRSub_d1 <=  fracRSub;
            expRSub_d1 <=  expRSub;
            excRSub_d1 <=  excRSub;
            updatedFracAdd_d1 <=  updatedFracAdd;
            updatedExpAdd_d1 <=  updatedExpAdd;
            stkAdd_d1 <=  stkAdd;
            rndAdd_d1 <=  rndAdd;
            grdAdd_d1 <=  grdAdd;
            lsbAdd_d1 <=  lsbAdd;
            RoundedExpFracAdd_d1 <=  RoundedExpFracAdd;
            fracRAdd_d1 <=  fracRAdd;
            expRAdd_d1 <=  expRAdd;
            excRt2Add_d1 <=  excRt2Add;
            excRAdd_d1 <=  excRAdd;
            excRAdd_d2 <=  excRAdd_d1;
            excRAdd_d3 <=  excRAdd_d2;
            excRAdd_d4 <=  excRAdd_d3;
            excRAdd_d5 <=  excRAdd_d4;
            computedRAdd_d1 <=  computedRAdd;
            computedRAdd_d2 <=  computedRAdd_d1;
            computedRAdd_d3 <=  computedRAdd_d2;
            computedRAdd_d4 <=  computedRAdd_d3;
            computedRAdd_d5 <=  computedRAdd_d4;
            X_d1 <=  X;
            Y_d1 <=  Y;
         end if;
      end process;
-- Exponent difference and swap  --
   excExpFracX <= X(33 downto 32) & X(30 downto 0);
   excExpFracY <= Y(33 downto 32) & Y(30 downto 0);
   eXmeY <= ("0" & X(30 downto 23)) - ("0" & Y(30 downto 23));
   eYmeX <= ("0" & Y(30 downto 23)) - ("0" & X(30 downto 23));
   swap <= '0' when excExpFracX >= excExpFracY else '1';
   ----------------Synchro barrier, entering cycle 1----------------
   newX <= X_d1     when swap_d1 = '0' else Y_d1;
   newY <= Y_d1     when swap_d1 = '0' else X_d1;
   expX<= newX(30 downto 23);
   excX<= newX(33 downto 32);
   excY<= newY(33 downto 32);
   signX<= newX(31);
   signY<= newY(31);
   diffSigns <= signX xor signY;
   sXsYExnXY <= signX & signY & excX & excY;
   fracY <= "000000000000000000000000" when excY="00" else ('1' & newY(22 downto 0));
   ----------------Synchro barrier, entering cycle 2----------------
   with sXsYExnXY_d1 select 
   excRtRAdd <= "00" when "000000"|"010000"|"100000"|"110000",
      "01" when "000101"|"010101"|"100101"|"110101"|"000100"|"010100"|"100100"|"110100"|"000001"|"010001"|"100001"|"110001",
      "10" when "111010"|"001010"|"001000"|"011000"|"101000"|"111000"|"000010"|"010010"|"100010"|"110010"|"001001"|"011001"|"101001"|"111001"|"000110"|"010110"|"100110"|"110110", 
      "11" when others;
   with sXsYExnXY_d1 select 
   excRtRSub <= "00" when "000000"|"010000"|"100000"|"110000",
      "01" when "000101"|"010101"|"100101"|"110101"|"000100"|"010100"|"100100"|"110100"|"000001"|"010001"|"100001"|"110001",
      "10" when "001000"|"011000"|"101000"|"111000"|"000010"|"010010"|"100010"|"110010"|"001001"|"011001"|"101001"|"111001"|"000110"|"010110"|"100110"|"110110"|"101010"|"011010", 
      "11" when others;
   signRAdd<= '0' when (sXsYExnXY_d1="100000" or sXsYExnXY_d1="010000") else signX_d1;
   signRSub<= '0' when (sXsYExnXY_d1="000000" or sXsYExnXY_d1="110000") else (signX_d1 and (not swap_d2)) or ((not signX_d1) and swap_d2);
   ---------------- cycle 0----------------
   ----------------Synchro barrier, entering cycle 1----------------
   expDiff <= eXmeY_d1 when (swap_d1 = '0') else eYmeX_d1;
   shiftedOut <= '1' when (expDiff >= 25) else '0';
   shiftVal <= expDiff(4 downto 0) when shiftedOut='0' else CONV_STD_LOGIC_VECTOR(26,5);
   RightShifterComponent: FPAddSub_8_23_uid2_RightShifter  -- pipelineDepth=1 maxInDelay=2.0478e-09
      port map ( clk  => clk,
                 rst  => rst,
                 R => shiftedFracY,
                 S => shiftVal,
                 X => fracY);
   ----------------Synchro barrier, entering cycle 2----------------
   ----------------Synchro barrier, entering cycle 3----------------
   sticky <= '0' when (shiftedFracY_d1(23 downto 0)=CONV_STD_LOGIC_VECTOR(0,23)) else '1';
   ---------------- cycle 2----------------
   ----------------Synchro barrier, entering cycle 3----------------
   shiftedFracYext <= "0" & shiftedFracY_d1(49 downto 24);
   fracYAdd <= shiftedFracYext;
   fracYSub <= shiftedFracYext xor ( 26 downto 0 => '1');
   fracX <= "01" & (newX_d2(22 downto 0)) & "00";
   cInFracAdderSub <= not sticky;
   fracAdderAdd: IntAdder_27_f400_uid7  -- pipelineDepth=1 maxInDelay=1.69388e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => '0',
                 R => fracAdderResultAdd,
                 X => fracX,
                 Y => fracYAdd);
   fracAdderSub: IntAdder_27_f400_uid7  -- pipelineDepth=1 maxInDelay=1.69388e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => cInFracAdderSub,
                 R => fracAdderResultSub,
                 X => fracX,
                 Y => fracYSub);
   ---------------- cycle 4----------------
   ----------------Synchro barrier, entering cycle 5----------------
   extendedExp<= "00" & expX_d4;
   extendedExpInc<= ("00" & expX_d4) + '1';
   ----------------Synchro barrier, entering cycle 6----------------
   fracGRSSub<= fracAdderResultSub_d2 & sticky_d3; 
   LZC_component: LZCShifter_28_to_28_counting_32_uid15  -- pipelineDepth=4 maxInDelay=7.6616e-10
      port map ( clk  => clk,
                 rst  => rst,
                 Count => nZerosNew,
                 I => fracGRSSub,
                 O => shiftedFracSub);
   ----------------Synchro barrier, entering cycle 10----------------
   ----------------Synchro barrier, entering cycle 11----------------
   updatedExpSub <= extendedExpInc_d6 - ("00000" & nZerosNew_d1);
   eqdiffsign <= '1' when nZerosNew_d1="11111" else '0';
   ---------------- cycle 10----------------
   expFracSub<= updatedExpSub & shiftedFracSub(26 downto 3);
   ---------------- cycle 10----------------
   stkSub<= shiftedFracSub(1) or shiftedFracSub(0);
   rndSub<= shiftedFracSub(2);
   grdSub<= shiftedFracSub(3);
   lsbSub<= shiftedFracSub(4);
   ---------------- cycle 10----------------
   ----------------Synchro barrier, entering cycle 11----------------
   addToRoundBitSub<= '0' when (lsbSub_d1='0' and grdSub_d1='1' and rndSub_d1='0' and stkSub_d1='0')  else '1';
   roundingAdderSub: IntAdder_34_f400_uid18  -- pipelineDepth=0 maxInDelay=7.0272e-10
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => addToRoundBitSub,
                 R => RoundedExpFracSub,
                 X => expFracSub_d1,
                 Y => "0000000000000000000000000000000000");
   ----------------Synchro barrier, entering cycle 12----------------
   upExcSub <= RoundedExpFracSub_d1(33 downto 32);
   fracRSub <= RoundedExpFracSub_d1(23 downto 1);
   expRSub <= RoundedExpFracSub_d1(31 downto 24);
   excRtEffSub <= excRtRAdd_d10 when (diffSigns_d11='1') else excRtRSub_d10;
   exExpExcSub <= upExcSub & excRtEffSub;
   with (exExpExcSub) select 
   excRt2Sub<= "00" when "0000"|"0100"|"1000"|"1100"|"1001"|"1101",
      "01" when "0001",
      "10" when "0010"|"0110"|"0101",
      "11" when others;
   excRSub <= "00" when (eqdiffsign_d1='1') else excRt2Sub;
   ----------------Synchro barrier, entering cycle 13----------------
   computedRSub <= expRSub_d1 & fracRSub_d1;
   Rsub <= excRSub_d1 & signRSub_d11 & computedRSub when (diffSigns_d12='0') else excRAdd_d5 & signRSub_d11 & computedRAdd_d5;
   ---------------- cycle 5----------------
   fracGRSAdd<= fracAdderResultAdd_d1 & sticky_d2; 
   updatedFracAdd <= fracGRSAdd(26 downto 3) when (fracAdderResultAdd_d1(26)='1') else fracGRSAdd(25 downto 2);
   updatedExpAdd <= extendedExpInc when (fracAdderResultAdd_d1(26)='1') else extendedExp;
   ----------------Synchro barrier, entering cycle 6----------------
   expFracAdd<= updatedExpAdd_d1 & updatedFracAdd_d1;
   ---------------- cycle 5----------------
   stkAdd<= fracGRSAdd(1) or fracGRSAdd(0);
   rndAdd<= fracGRSAdd(2);
   grdAdd<= fracGRSAdd(3);
   lsbAdd<= fracGRSAdd(4);
   ----------------Synchro barrier, entering cycle 6----------------
   addToRoundBitAdd<= (grdAdd_d1 and rndAdd_d1) or (grdAdd_d1 and (not rndAdd_d1) and lsbAdd_d1) or ((not grdAdd_d1) and rndAdd_d1 and stkAdd_d1) or (grdAdd_d1 and (not rndAdd_d1) and stkAdd_d1);
   roundingAdderAdd: IntAdder_34_f400_uid18  -- pipelineDepth=0 maxInDelay=7.0272e-10
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => addToRoundBitAdd,
                 R => RoundedExpFracAdd,
                 X => expFracAdd,
                 Y => "0000000000000000000000000000000000");
   ---------------- cycle 6----------------
   ----------------Synchro barrier, entering cycle 7----------------
   upExcAdd <= RoundedExpFracAdd_d1(33 downto 32);
   fracRAdd <= RoundedExpFracAdd_d1(23 downto 1);
   expRAdd <= RoundedExpFracAdd_d1(31 downto 24);
   excRtEffAdd <= excRtRAdd_d5 when (diffSigns_d6='0') else excRtRSub_d5;
   exExpExcAdd <= upExcAdd & excRtEffAdd;
   with (exExpExcAdd) select 
   excRt2Add<= "00" when "0000"|"0100"|"1000"|"1100"|"1001",
      "01" when "0001",
      "10" when "0010"|"0110"|"0101",
      "11" when others;
   ----------------Synchro barrier, entering cycle 8----------------
   excRAdd <=  excRt2Add_d1;
   computedRAdd <= expRAdd_d1 & fracRAdd_d1;
   Radd <= excRAdd & signRAdd_d6 & computedRAdd when (diffSigns_d7='0') else excRSub & signRAdd_d6 & computedRSub;
   ----------------Synchro barrier, entering cycle 13----------------
end architecture;

