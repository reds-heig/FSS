------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : buzzer_ctrl.vhd
-- Author               : Vincent Theurillat
-- Date                 : 20.02.2012
-- Target Devices       : Spartan6 XC6SLX150T-3FGG900
--
-- Context              : Reptar - FPGA design
--
------------------------------------------------------------------------------------------
-- Description : 
------------------------------------------------------------------------------------------
-- Information :
------------------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Engineer     Comments
-- 0.0   See header  VTT          Initial version
-- 0.1   07.11.2013  ELR		  changed reset to active high signal
-----------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity buzzer_ctrl is
	port(		clk_i			:		in std_logic;
				reset_i		:		in std_logic;
				buzzer_en_i	:		in std_logic;
				fast_mode_i	:		in std_logic;
				slow_mode_i	:		in std_logic;
				Buz_osc_o	:		out std_logic
	);
end buzzer_ctrl;

architecture Behavioral of buzzer_ctrl is

signal	counter_s	: unsigned(18 downto 0);
signal	div_s			: std_logic;

-- !! Constante à modifier !!
constant fast_mode_div_c 	: unsigned(18 downto 0) := "0001100100111011110"; -- 2670Hz (275MHz/51678)/2
constant slow_mode_div_c 	: unsigned(18 downto 0) := "1001100100011111000"; -- 440Hz  (275MHz/313592)/2

begin

process(clk_i, reset_i)
begin
	if (reset_i = '1') then
		counter_s <= "0000000000000000000";
		div_s <= '0';
	elsif rising_edge(clk_i) then
		if (buzzer_en_i = '1') then
			if (fast_mode_i = '1') then
				if (counter_s = 0) then
					counter_s <= fast_mode_div_c;
					div_s <= not(div_s);
				else
					counter_s <= counter_s-1;
				end if;
			elsif (slow_mode_i = '1') then
				if (counter_s = 0) then
					counter_s <= slow_mode_div_c;
					div_s <= not(div_s);
				else
					counter_s <= counter_s-1;
				end if;
			end if;
		end if;
	end if;
end process;

Buz_osc_o <= div_s;

end Behavioral;