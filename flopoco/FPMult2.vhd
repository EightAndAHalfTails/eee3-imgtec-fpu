--------------------------------------------------------------------------------
--                           IntAdder_51_f400_uid4
--                      (IntAdderClassical_51_f400_uid6)
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

entity IntAdder_51_f400_uid4 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(50 downto 0);
          Y : in  std_logic_vector(50 downto 0);
          Cin : in std_logic;
          R : out  std_logic_vector(50 downto 0)   );
end entity;

architecture arch of IntAdder_51_f400_uid4 is
signal x0 :  std_logic_vector(41 downto 0);
signal y0 :  std_logic_vector(41 downto 0);
signal x1, x1_d1 :  std_logic_vector(8 downto 0);
signal y1, y1_d1 :  std_logic_vector(8 downto 0);
signal sum0, sum0_d1 :  std_logic_vector(42 downto 0);
signal sum1 :  std_logic_vector(9 downto 0);
signal X_d1 :  std_logic_vector(50 downto 0);
signal Y_d1 :  std_logic_vector(50 downto 0);
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
   x1 <= X_d1(50 downto 42);
   y1 <= Y_d1(50 downto 42);
   sum0 <= ( "0" & x0) + ( "0" & y0)  + Cin_d1;
   ----------------Synchro barrier, entering cycle 2----------------
   sum1 <= ( "0" & x1_d1) + ( "0" & y1_d1)  + sum0_d1(42);
   R <= sum1(8 downto 0) & sum0_d1(41 downto 0);
end architecture;

--------------------------------------------------------------------------------
--                            IntKaratsuba_24_f400
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca (2008-2010)
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
library work;
entity IntKaratsuba_24_f400 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(23 downto 0);
          Y : in  std_logic_vector(23 downto 0);
          R : out  std_logic_vector(47 downto 0)   );
end entity;

architecture arch of IntKaratsuba_24_f400 is
   component IntAdder_51_f400_uid4 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(50 downto 0);
             Y : in  std_logic_vector(50 downto 0);
             Cin : in std_logic;
             R : out  std_logic_vector(50 downto 0)   );
   end component;

signal sX :  std_logic_vector(33 downto 0);
signal sY :  std_logic_vector(33 downto 0);
signal x0, x0_d1 :  std_logic_vector(17 downto 0);
signal x1, x1_d1 :  std_logic_vector(17 downto 0);
signal y0, y0_d1 :  std_logic_vector(17 downto 0);
signal y1, y1_d1 :  std_logic_vector(17 downto 0);
signal dx, dx_d1 :  std_logic_vector(17 downto 0);
signal dy, dy_d1 :  std_logic_vector(17 downto 0);
signal p0, p0_d1, p0_d2, p0_d3 :  std_logic_vector(35 downto 0);
signal tp1, tp1_d1 :  std_logic_vector(35 downto 0);
signal p1, p1_d1, p1_d2 :  std_logic_vector(35 downto 0);
signal tp2, tp2_d1, tp2_d2 :  std_logic_vector(35 downto 0);
signal p2, p2_d1 :  std_logic_vector(35 downto 0);
signal t2 :  std_logic_vector(35 downto 0);
signal t0 :  std_logic_vector(35 downto 0);
signal t1 :  std_logic_vector(35 downto 0);
signal a1 :  std_logic_vector(50 downto 0);
signal b1 :  std_logic_vector(50 downto 0);
signal a1pb1 :  std_logic_vector(50 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            x0_d1 <=  x0;
            x1_d1 <=  x1;
            y0_d1 <=  y0;
            y1_d1 <=  y1;
            dx_d1 <=  dx;
            dy_d1 <=  dy;
            p0_d1 <=  p0;
            p0_d2 <=  p0_d1;
            p0_d3 <=  p0_d2;
            tp1_d1 <=  tp1;
            p1_d1 <=  p1;
            p1_d2 <=  p1_d1;
            tp2_d1 <=  tp2;
            tp2_d2 <=  tp2_d1;
            p2_d1 <=  p2;
         end if;
      end process;
   sX <= X & "0000000000";
   sY <= Y & "0000000000";
   x0 <= "0" & sX(16 downto 0);
   x1 <= "0" & sX(33 downto 17);
   y0 <= "0" & sY(16 downto 0);
   y1 <= "0" & sY(33 downto 17);
   dx <= x1 - x0;
   dy <= y1 - y0;
   ----------------Synchro barrier, entering cycle 1----------------
   p0 <= x0_d1 * y0_d1;
   ---------------- cycle 0----------------
   ----------------Synchro barrier, entering cycle 1----------------
   tp1 <= dx_d1 * dy_d1;
   ----------------Synchro barrier, entering cycle 2----------------
   p1 <= p0_d1 - tp1_d1;
   ---------------- cycle 0----------------
   ----------------Synchro barrier, entering cycle 1----------------
   tp2 <= x1_d1 * y1_d1;
   ----------------Synchro barrier, entering cycle 2----------------
   ----------------Synchro barrier, entering cycle 3----------------
   p2 <= p1_d1 + tp2_d2;
   ----------------Synchro barrier, entering cycle 4----------------
   t2 <= p2_d1 - p1_d2;
   t0 <= p0_d3;
   t1 <= p2_d1;
   a1 <= t2(33 downto 0) & t0(33 downto 17);
   b1 <= "000000000000000" & p2_d1;
   finalAdder: IntAdder_51_f400_uid4  -- pipelineDepth=2 maxInDelay=2.37672e-09
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => '0',
                 R => a1pb1   ,
                 X => a1,
                 Y => b1);
   ----------------Synchro barrier, entering cycle 6----------------
   R <= a1pb1(50 downto 3);
end architecture;

--------------------------------------------------------------------------------
--                           IntAdder_33_f400_uid12
--                     (IntAdderClassical_33_f400_uid14)
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

entity IntAdder_33_f400_uid12 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(32 downto 0);
          Y : in  std_logic_vector(32 downto 0);
          Cin : in std_logic;
          R : out  std_logic_vector(32 downto 0)   );
end entity;

architecture arch of IntAdder_33_f400_uid12 is
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
--                    FPMultiplierKaratsuba_8_23_8_23_8_23
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: 
--------------------------------------------------------------------------------
-- Pipeline depth: 10 cycles

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity FPMultiplierKaratsuba_8_23_8_23_8_23 is
   port ( clk, rst : in std_logic;
          X : in  std_logic_vector(8+23+2 downto 0);
          Y : in  std_logic_vector(8+23+2 downto 0);
          R : out  std_logic_vector(8+23+2 downto 0)   );
end entity;

architecture arch of FPMultiplierKaratsuba_8_23_8_23_8_23 is
   component IntAdder_33_f400_uid12 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(32 downto 0);
             Y : in  std_logic_vector(32 downto 0);
             Cin : in std_logic;
             R : out  std_logic_vector(32 downto 0)   );
   end component;

   component IntKaratsuba_24_f400 is
      port ( clk, rst : in std_logic;
             X : in  std_logic_vector(23 downto 0);
             Y : in  std_logic_vector(23 downto 0);
             R : out  std_logic_vector(47 downto 0)   );
   end component;

signal sign, sign_d1, sign_d2, sign_d3, sign_d4, sign_d5, sign_d6, sign_d7, sign_d8, sign_d9, sign_d10 : std_logic;
signal expX :  std_logic_vector(7 downto 0);
signal expY :  std_logic_vector(7 downto 0);
signal expSumPreSub, expSumPreSub_d1 :  std_logic_vector(9 downto 0);
signal bias :  std_logic_vector(9 downto 0);
signal expSum, expSum_d1, expSum_d2, expSum_d3, expSum_d4, expSum_d5, expSum_d6 :  std_logic_vector(9 downto 0);
signal sigX :  std_logic_vector(23 downto 0);
signal sigY :  std_logic_vector(23 downto 0);
signal sigProd, sigProd_d1, sigProd_d2 :  std_logic_vector(47 downto 0);
signal excSel :  std_logic_vector(3 downto 0);
signal exc, exc_d1, exc_d2, exc_d3, exc_d4, exc_d5, exc_d6, exc_d7, exc_d8, exc_d9, exc_d10 :  std_logic_vector(1 downto 0);
signal norm, norm_d1 : std_logic;
signal expPostNorm, expPostNorm_d1 :  std_logic_vector(9 downto 0);
signal sigProdExt :  std_logic_vector(47 downto 0);
signal expSig, expSig_d1 :  std_logic_vector(32 downto 0);
signal sticky : std_logic;
signal guard : std_logic;
signal round, round_d1 : std_logic;
signal expSigPostRound, expSigPostRound_d1 :  std_logic_vector(32 downto 0);
signal excPostNorm :  std_logic_vector(1 downto 0);
signal finalExc :  std_logic_vector(1 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            sign_d1 <=  sign;
            sign_d2 <=  sign_d1;
            sign_d3 <=  sign_d2;
            sign_d4 <=  sign_d3;
            sign_d5 <=  sign_d4;
            sign_d6 <=  sign_d5;
            sign_d7 <=  sign_d6;
            sign_d8 <=  sign_d7;
            sign_d9 <=  sign_d8;
            sign_d10 <=  sign_d9;
            expSumPreSub_d1 <=  expSumPreSub;
            expSum_d1 <=  expSum;
            expSum_d2 <=  expSum_d1;
            expSum_d3 <=  expSum_d2;
            expSum_d4 <=  expSum_d3;
            expSum_d5 <=  expSum_d4;
            expSum_d6 <=  expSum_d5;
            sigProd_d1 <=  sigProd;
            sigProd_d2 <=  sigProd_d1;
            exc_d1 <=  exc;
            exc_d2 <=  exc_d1;
            exc_d3 <=  exc_d2;
            exc_d4 <=  exc_d3;
            exc_d5 <=  exc_d4;
            exc_d6 <=  exc_d5;
            exc_d7 <=  exc_d6;
            exc_d8 <=  exc_d7;
            exc_d9 <=  exc_d8;
            exc_d10 <=  exc_d9;
            norm_d1 <=  norm;
            expPostNorm_d1 <=  expPostNorm;
            expSig_d1 <=  expSig;
            round_d1 <=  round;
            expSigPostRound_d1 <=  expSigPostRound;
         end if;
      end process;
   sign <= X(31) xor Y(31);
   expX <= X(30 downto 23);
   expY <= Y(30 downto 23);
   expSumPreSub <= ("00" & expX) + ("00" & expY);
   ----------------Synchro barrier, entering cycle 1----------------
   bias <= CONV_STD_LOGIC_VECTOR(127,10);
   expSum <= expSumPreSub_d1 - bias;
   ----------------Synchro barrier, entering cycle 0----------------
   sigX <= "1" & X(22 downto 0);
   sigY <= "1" & Y(22 downto 0);
   SignificandMultiplication: IntKaratsuba_24_f400  -- pipelineDepth=6 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 R => sigProd,
                 X => sigX,
                 Y => sigY);
   ----------------Synchro barrier, entering cycle 0----------------
   excSel <= X(33 downto 32) & Y(33 downto 32);
   with excSel select 
   exc <= "00" when  "0000" | "0001" | "0100", 
          "01" when "0101",
          "10" when "0110" | "1001" | "1010" ,
          "11" when others;
   ----------------Synchro barrier, entering cycle 6----------------
   ----------------Synchro barrier, entering cycle 7----------------
   norm <= sigProd_d1(47);
   expPostNorm <= expSum_d6 + ("000000000" & norm);
   ----------------Synchro barrier, entering cycle 8----------------
   sigProdExt <= sigProd_d2(46 downto 0) & "0" when norm_d1='1' else
                         sigProd_d2(45 downto 0) & "00";
   expSig <= expPostNorm_d1 & sigProdExt(47 downto 25);
   sticky <= sigProdExt(24);
   guard <= '0' when sigProdExt(23 downto 0)="000000000000000000000000" else '1';
   round <= sticky and ( (guard and not(sigProdExt(25))) or (sigProdExt(25) ))  ;
   ----------------Synchro barrier, entering cycle 9----------------
   RoundingAdder: IntAdder_33_f400_uid12  -- pipelineDepth=0 maxInDelay=0
      port map ( clk  => clk,
                 rst  => rst,
                 Cin => round_d1,
                 R => expSigPostRound   ,
                 X => expSig_d1,
                 Y => "000000000000000000000000000000000");
   ----------------Synchro barrier, entering cycle 10----------------
   with expSigPostRound_d1(32 downto 31) select
   excPostNorm <=  "01"  when  "00",
                               "10"             when "01", 
                               "00"             when "11"|"10",
                               "11"             when others;
   with exc_d10 select 
   finalExc <= exc_d10 when  "11"|"10"|"00",
                       excPostNorm when others; 
   R <= finalExc & sign_d10 & expSigPostRound_d1(30 downto 0);
end architecture;

