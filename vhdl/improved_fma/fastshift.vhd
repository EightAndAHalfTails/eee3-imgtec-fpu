library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.all;
use work.types.all;

entity fast_shifter is
  generic(vsize: integer := 0);
  port(
	shift_op :in std_logic;
	shift_unit:in std_logic_vector(5 downto 0);
	shift_in : in std_logic_vector(vsize-1 downto 0);
	shift_out : out std_logic_vector(vsize-1 downto 0)
    );
end entity fast_shifter;

architecture shift of fast_shifter is

  
  type amount_t is array (0 to 4) of integer;

  constant sft_amount : amount_t := {1,2,4,8,16,32};  -- shift amount

  signal shifted_input :std_logic_vector(vsize-1 downto 0);
begin
  shift:process()
    shifted_v: usg(vsize-1 downto 0);
  begin
    shifted_v:=usg(shift_in);
    if 
    for i in 4 downto 0 loop
      if shift_unit(i)='1' then
        shifted_v:= shifted_v srl sft_amount(i);
      end if;
    end loop;
		

end process shift;





end architecture shift;
