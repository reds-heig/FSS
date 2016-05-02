------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : Timer.vhd
-- Author               : Vincent Theurillat
-- Date                 : 21.02.2012
-- Target Devices       : Spartan6 XC6SLX150T-3FGG900
--
-- Context              : Reptar - FPGA design
--
------------------------------------------------------------------------------------------
-- Description : Timer programmable pour generer les timings utile à la gestion du LCD
------------------------------------------------------------------------------------------
-- Information :
------------------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Engineer     Comments
-- 0.0   See header  VTT          Initial version
-----------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity timer is
	port(	clk_i			:	in std_logic;
			reset_i		:	in std_logic;
			Start_cnt_i	:	in std_logic;
			Value_cnt_i	:	in std_logic_vector(8 downto 0);
			End_cnt_o	:	out std_logic
	);
end timer;

architecture Behavioral of timer is

signal	counter_s	:	unsigned(8 downto 0);
signal	count_en_s	:	std_logic;

begin


process(clk_i, reset_i)
begin
	if (reset_i = '1') then
		counter_s <= "000000000";
    End_cnt_o <= '0';
		count_en_s <= '0';
	elsif rising_edge(clk_i) then
		if (Start_cnt_i = '1') then
			counter_s <= unsigned(Value_cnt_i);
			count_en_s <= '1';
			End_cnt_o <= '0';
		elsif (count_en_s = '1') then
			if (counter_s = 0) then
        counter_s <= "000000000";
				count_en_s <= '0';
				End_cnt_o <= '1';
			else
				counter_s <= counter_s-1;
        count_en_s <= '1';
				End_cnt_o <= '0';
			end if;
		else
      count_en_s <= '0';
      End_cnt_o <= '0';
    end if;
    
  end if;
end process;

end Behavioral;