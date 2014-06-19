--------------------------------------------------------------------------------
--                      FPAddSub_8_23_uid2_RightShifter
--                      (RightShifter_24_by_max_26_uid4)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2011)
--------------------------------------------------------------------------------
-- combinatorial

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity FPAddSub_8_23_uid2_RightShifter is
   port ( X : in  std_logic_vector(23 downto 0);
          S : in  std_logic_vector(4 downto 0);
          R : out  std_logic_vector(49 downto 0)   );
end entity;

architecture arch of FPAddSub_8_23_uid2_RightShifter is
signal level0 :  std_logic_vector(23 downto 0);
signal ps :  std_logic_vector(4 downto 0);
signal level1 :  std_logic_vector(24 downto 0);
signal level2 :  std_logic_vector(26 downto 0);
signal level3 :  std_logic_vector(30 downto 0);
signal level4 :  std_logic_vector(38 downto 0);
signal level5 :  std_logic_vector(54 downto 0);
begin
   level0<= X;
   ps<= S;
   level1<=  (0 downto 0 => '0') & level0 when ps(0) = '1' else    level0 & (0 downto 0 => '0');
   level2<=  (1 downto 0 => '0') & level1 when ps(1) = '1' else    level1 & (1 downto 0 => '0');
   level3<=  (3 downto 0 => '0') & level2 when ps(2) = '1' else    level2 & (3 downto 0 => '0');
   level4<=  (7 downto 0 => '0') & level3 when ps(3) = '1' else    level3 & (7 downto 0 => '0');
   level5<=  (15 downto 0 => '0') & level4 when ps(4) = '1' else    level4 & (15 downto 0 => '0');
   R <= level5(54 downto 5);
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_27_f400_uid7
--                      (IntAdderClassical_27_f400_uid9)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2010)
--------------------------------------------------------------------------------
-- combinatorial

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntAdder_27_f400_uid7 is
   port ( X : in  std_logic_vector(26 downto 0);
          Y : in  std_logic_vector(26 downto 0);
          Cin : in std_logic;
          R : out  std_logic_vector(26 downto 0)   );
end entity;

architecture arch of IntAdder_27_f400_uid7 is
begin
   --Classical
    R <= X + Y + Cin;
end architecture;

--------------------------------------------------------------------------------
--                   LZCShifter_28_to_28_counting_32_uid15
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin, Bogdan Pasca (2007)
--------------------------------------------------------------------------------
-- combinatorial

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity LZCShifter_28_to_28_counting_32_uid15 is
   port ( I : in  std_logic_vector(27 downto 0);
          Count : out  std_logic_vector(4 downto 0);
          O : out  std_logic_vector(27 downto 0)   );
end entity;

architecture arch of LZCShifter_28_to_28_counting_32_uid15 is
signal level5 :  std_logic_vector(27 downto 0);
signal count4 : std_logic;
signal level4 :  std_logic_vector(27 downto 0);
signal count3 : std_logic;
signal level3 :  std_logic_vector(27 downto 0);
signal count2 : std_logic;
signal level2 :  std_logic_vector(27 downto 0);
signal count1 : std_logic;
signal level1 :  std_logic_vector(27 downto 0);
signal count0 : std_logic;
signal level0 :  std_logic_vector(27 downto 0);
signal sCount :  std_logic_vector(4 downto 0);
begin
   level5 <= I ;
   count4<= '1' when level5(27 downto 12) = (27 downto 12=>'0') else '0';
   level4<= level5(27 downto 0) when count4='0' else level5(11 downto 0) & (15 downto 0 => '0');

   count3<= '1' when level4(27 downto 20) = (27 downto 20=>'0') else '0';
   level3<= level4(27 downto 0) when count3='0' else level4(19 downto 0) & (7 downto 0 => '0');

   count2<= '1' when level3(27 downto 24) = (27 downto 24=>'0') else '0';
   level2<= level3(27 downto 0) when count2='0' else level3(23 downto 0) & (3 downto 0 => '0');

   count1<= '1' when level2(27 downto 26) = (27 downto 26=>'0') else '0';
   level1<= level2(27 downto 0) when count1='0' else level2(25 downto 0) & (1 downto 0 => '0');

   count0<= '1' when level1(27 downto 27) = (27 downto 27=>'0') else '0';
   level0<= level1(27 downto 0) when count0='0' else level1(26 downto 0) & (0 downto 0 => '0');

   O <= level0;
   sCount <= count4 & count3 & count2 & count1 & count0;
   Count <= sCount;
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_34_f400_uid18
--                     (IntAdderClassical_34_f400_uid20)
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca, Florent de Dinechin (2008-2010)
--------------------------------------------------------------------------------
-- combinatorial

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity IntAdder_34_f400_uid18 is
   port ( X : in  std_logic_vector(33 downto 0);
          Y : in  std_logic_vector(33 downto 0);
          Cin : in std_logic;
          R : out  std_logic_vector(33 downto 0)   );
end entity;

architecture arch of IntAdder_34_f400_uid18 is
begin
   --Classical
    R <= X + Y + Cin;
end architecture;

--------------------------------------------------------------------------------
--                             FPAddSub_8_23_uid2
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Matei Istoan, Florent de Dinechin (2012)
--------------------------------------------------------------------------------
-- combinatorial

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity FPAddSub_8_23_uid2 is
   port ( X : in  std_logic_vector(8+23+2 downto 0);
          Y : in  std_logic_vector(8+23+2 downto 0);
          Radd : out  std_logic_vector(8+23+2 downto 0);
          Rsub : out  std_logic_vector(8+23+2 downto 0)   );
end entity;

architecture arch of FPAddSub_8_23_uid2 is
   component FPAddSub_8_23_uid2_RightShifter is
      port ( X : in  std_logic_vector(23 downto 0);
             S : in  std_logic_vector(4 downto 0);
             R : out  std_logic_vector(49 downto 0)   );
   end component;

   component IntAdder_27_f400_uid7 is
      port ( X : in  std_logic_vector(26 downto 0);
             Y : in  std_logic_vector(26 downto 0);
             Cin : in std_logic;
             R : out  std_logic_vector(26 downto 0)   );
   end component;

   component IntAdder_34_f400_uid18 is
      port ( X : in  std_logic_vector(33 downto 0);
             Y : in  std_logic_vector(33 downto 0);
             Cin : in std_logic;
             R : out  std_logic_vector(33 downto 0)   );
   end component;

   component LZCShifter_28_to_28_counting_32_uid15 is
      port ( I : in  std_logic_vector(27 downto 0);
             Count : out  std_logic_vector(4 downto 0);
             O : out  std_logic_vector(27 downto 0)   );
   end component;

signal excExpFracX :  std_logic_vector(32 downto 0);
signal excExpFracY :  std_logic_vector(32 downto 0);
signal eXmeY :  std_logic_vector(8 downto 0);
signal eYmeX :  std_logic_vector(8 downto 0);
signal swap : std_logic;
signal newX :  std_logic_vector(33 downto 0);
signal newY :  std_logic_vector(33 downto 0);
signal expX :  std_logic_vector(7 downto 0);
signal excX :  std_logic_vector(1 downto 0);
signal excY :  std_logic_vector(1 downto 0);
signal signX : std_logic;
signal signY : std_logic;
signal diffSigns : std_logic;
signal sXsYExnXY :  std_logic_vector(5 downto 0);
signal fracY :  std_logic_vector(23 downto 0);
signal excRtRAdd :  std_logic_vector(1 downto 0);
signal excRtRSub :  std_logic_vector(1 downto 0);
signal signRAdd : std_logic;
signal signRSub : std_logic;
signal expDiff :  std_logic_vector(8 downto 0);
signal shiftedOut : std_logic;
signal shiftVal :  std_logic_vector(4 downto 0);
signal shiftedFracY :  std_logic_vector(49 downto 0);
signal sticky : std_logic;
signal shiftedFracYext :  std_logic_vector(26 downto 0);
signal fracYAdd :  std_logic_vector(26 downto 0);
signal fracYSub :  std_logic_vector(26 downto 0);
signal fracX :  std_logic_vector(26 downto 0);
signal cInFracAdderSub : std_logic;
signal fracAdderResultAdd :  std_logic_vector(26 downto 0);
signal fracAdderResultSub :  std_logic_vector(26 downto 0);
signal extendedExp :  std_logic_vector(9 downto 0);
signal extendedExpInc :  std_logic_vector(9 downto 0);
signal fracGRSSub :  std_logic_vector(27 downto 0);
signal nZerosNew :  std_logic_vector(4 downto 0);
signal shiftedFracSub :  std_logic_vector(27 downto 0);
signal updatedExpSub :  std_logic_vector(9 downto 0);
signal eqdiffsign : std_logic;
signal expFracSub :  std_logic_vector(33 downto 0);
signal stkSub : std_logic;
signal rndSub : std_logic;
signal grdSub : std_logic;
signal lsbSub : std_logic;
signal addToRoundBitSub : std_logic;
signal RoundedExpFracSub :  std_logic_vector(33 downto 0);
signal upExcSub :  std_logic_vector(1 downto 0);
signal fracRSub :  std_logic_vector(22 downto 0);
signal expRSub :  std_logic_vector(7 downto 0);
signal excRtEffSub :  std_logic_vector(1 downto 0);
signal exExpExcSub :  std_logic_vector(3 downto 0);
signal excRt2Sub :  std_logic_vector(1 downto 0);
signal excRSub :  std_logic_vector(1 downto 0);
signal computedRSub :  std_logic_vector(30 downto 0);
signal fracGRSAdd :  std_logic_vector(27 downto 0);
signal updatedFracAdd :  std_logic_vector(23 downto 0);
signal updatedExpAdd :  std_logic_vector(9 downto 0);
signal expFracAdd :  std_logic_vector(33 downto 0);
signal stkAdd : std_logic;
signal rndAdd : std_logic;
signal grdAdd : std_logic;
signal lsbAdd : std_logic;
signal addToRoundBitAdd : std_logic;
signal RoundedExpFracAdd :  std_logic_vector(33 downto 0);
signal upExcAdd :  std_logic_vector(1 downto 0);
signal fracRAdd :  std_logic_vector(22 downto 0);
signal expRAdd :  std_logic_vector(7 downto 0);
signal excRtEffAdd :  std_logic_vector(1 downto 0);
signal exExpExcAdd :  std_logic_vector(3 downto 0);
signal excRt2Add :  std_logic_vector(1 downto 0);
signal excRAdd :  std_logic_vector(1 downto 0);
signal computedRAdd :  std_logic_vector(30 downto 0);
begin
-- Exponent difference and swap  --
   excExpFracX <= X(33 downto 32) & X(30 downto 0);
   excExpFracY <= Y(33 downto 32) & Y(30 downto 0);
   eXmeY <= ("0" & X(30 downto 23)) - ("0" & Y(30 downto 23));
   eYmeX <= ("0" & Y(30 downto 23)) - ("0" & X(30 downto 23));
   swap <= '0' when excExpFracX >= excExpFracY else '1';
   newX <= X     when swap = '0' else Y;
   newY <= Y     when swap = '0' else X;
   expX<= newX(30 downto 23);
   excX<= newX(33 downto 32);
   excY<= newY(33 downto 32);
   signX<= newX(31);
   signY<= newY(31);
   diffSigns <= signX xor signY;
   sXsYExnXY <= signX & signY & excX & excY;
   fracY <= "000000000000000000000000" when excY="00" else ('1' & newY(22 downto 0));
   with sXsYExnXY select 
   excRtRAdd <= "00" when "000000"|"010000"|"100000"|"110000",
      "01" when "000101"|"010101"|"100101"|"110101"|"000100"|"010100"|"100100"|"110100"|"000001"|"010001"|"100001"|"110001",
      "10" when "111010"|"001010"|"001000"|"011000"|"101000"|"111000"|"000010"|"010010"|"100010"|"110010"|"001001"|"011001"|"101001"|"111001"|"000110"|"010110"|"100110"|"110110", 
      "11" when others;
   with sXsYExnXY select 
   excRtRSub <= "00" when "000000"|"010000"|"100000"|"110000",
      "01" when "000101"|"010101"|"100101"|"110101"|"000100"|"010100"|"100100"|"110100"|"000001"|"010001"|"100001"|"110001",
      "10" when "001000"|"011000"|"101000"|"111000"|"000010"|"010010"|"100010"|"110010"|"001001"|"011001"|"101001"|"111001"|"000110"|"010110"|"100110"|"110110"|"101010"|"011010", 
      "11" when others;
   signRAdd<= '0' when (sXsYExnXY="100000" or sXsYExnXY="010000") else signX;
   signRSub<= '0' when (sXsYExnXY="000000" or sXsYExnXY="110000") else (signX and (not swap)) or ((not signX) and swap);
   expDiff <= eXmeY when (swap = '0') else eYmeX;
   shiftedOut <= '1' when (expDiff >= 25) else '0';
   shiftVal <= expDiff(4 downto 0) when shiftedOut='0' else CONV_STD_LOGIC_VECTOR(26,5);
   RightShifterComponent: FPAddSub_8_23_uid2_RightShifter
      port map ( R => shiftedFracY,
                 S => shiftVal,
                 X => fracY);
   sticky <= '0' when (shiftedFracY(23 downto 0)=CONV_STD_LOGIC_VECTOR(0,23)) else '1';
   shiftedFracYext <= "0" & shiftedFracY(49 downto 24);
   fracYAdd <= shiftedFracYext;
   fracYSub <= shiftedFracYext xor ( 26 downto 0 => '1');
   fracX <= "01" & (newX(22 downto 0)) & "00";
   cInFracAdderSub <= not sticky;
   fracAdderAdd: IntAdder_27_f400_uid7
      port map ( Cin => '0',
                 R => fracAdderResultAdd,
                 X => fracX,
                 Y => fracYAdd);
   fracAdderSub: IntAdder_27_f400_uid7
      port map ( Cin => cInFracAdderSub,
                 R => fracAdderResultSub,
                 X => fracX,
                 Y => fracYSub);
   extendedExp<= "00" & expX;
   extendedExpInc<= ("00" & expX) + '1';
   fracGRSSub<= fracAdderResultSub & sticky; 
   LZC_component: LZCShifter_28_to_28_counting_32_uid15
      port map ( Count => nZerosNew,
                 I => fracGRSSub,
                 O => shiftedFracSub);
   updatedExpSub <= extendedExpInc - ("00000" & nZerosNew);
   eqdiffsign <= '1' when nZerosNew="11111" else '0';
   expFracSub<= updatedExpSub & shiftedFracSub(26 downto 3);
   stkSub<= shiftedFracSub(1) or shiftedFracSub(0);
   rndSub<= shiftedFracSub(2);
   grdSub<= shiftedFracSub(3);
   lsbSub<= shiftedFracSub(4);
   addToRoundBitSub<= '0' when (lsbSub='0' and grdSub='1' and rndSub='0' and stkSub='0')  else '1';
   roundingAdderSub: IntAdder_34_f400_uid18
      port map ( Cin => addToRoundBitSub,
                 R => RoundedExpFracSub,
                 X => expFracSub,
                 Y => "0000000000000000000000000000000000");
   upExcSub <= RoundedExpFracSub(33 downto 32);
   fracRSub <= RoundedExpFracSub(23 downto 1);
   expRSub <= RoundedExpFracSub(31 downto 24);
   excRtEffSub <= excRtRAdd when (diffSigns='1') else excRtRSub;
   exExpExcSub <= upExcSub & excRtEffSub;
   with (exExpExcSub) select 
   excRt2Sub<= "00" when "0000"|"0100"|"1000"|"1100"|"1001"|"1101",
      "01" when "0001",
      "10" when "0010"|"0110"|"0101",
      "11" when others;
   excRSub <= "00" when (eqdiffsign='1') else excRt2Sub;
   computedRSub <= expRSub & fracRSub;
   Rsub <= excRSub & signRSub & computedRSub when (diffSigns='0') else excRAdd & signRSub & computedRAdd;
   fracGRSAdd<= fracAdderResultAdd & sticky; 
   updatedFracAdd <= fracGRSAdd(26 downto 3) when (fracAdderResultAdd(26)='1') else fracGRSAdd(25 downto 2);
   updatedExpAdd <= extendedExpInc when (fracAdderResultAdd(26)='1') else extendedExp;
   expFracAdd<= updatedExpAdd & updatedFracAdd;
   stkAdd<= fracGRSAdd(1) or fracGRSAdd(0);
   rndAdd<= fracGRSAdd(2);
   grdAdd<= fracGRSAdd(3);
   lsbAdd<= fracGRSAdd(4);
   addToRoundBitAdd<= (grdAdd and rndAdd) or (grdAdd and (not rndAdd) and lsbAdd) or ((not grdAdd) and rndAdd and stkAdd) or (grdAdd and (not rndAdd) and stkAdd);
   roundingAdderAdd: IntAdder_34_f400_uid18
      port map ( Cin => addToRoundBitAdd,
                 R => RoundedExpFracAdd,
                 X => expFracAdd,
                 Y => "0000000000000000000000000000000000");
   upExcAdd <= RoundedExpFracAdd(33 downto 32);
   fracRAdd <= RoundedExpFracAdd(23 downto 1);
   expRAdd <= RoundedExpFracAdd(31 downto 24);
   excRtEffAdd <= excRtRAdd when (diffSigns='0') else excRtRSub;
   exExpExcAdd <= upExcAdd & excRtEffAdd;
   with (exExpExcAdd) select 
   excRt2Add<= "00" when "0000"|"0100"|"1000"|"1100"|"1001",
      "01" when "0001",
      "10" when "0010"|"0110"|"0101",
      "11" when others;
   excRAdd <=  excRt2Add;
   computedRAdd <= expRAdd & fracRAdd;
   Radd <= excRAdd & signRAdd & computedRAdd when (diffSigns='0') else excRSub & signRAdd & computedRSub;
end architecture;

