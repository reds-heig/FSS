------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : encoder_sens_detector_v2.vhd
-- Author               : Vincent Theurillat
-- Date                 : 17.02.2012
-- Target Devices       : Spartan6 XC6SLX150T-3FGG900
--
-- Context              : Reptar - FPGA design
--
------------------------------------------------------------------------------------------
-- Description : Design qui determine le sens de rotations de l'encodeur
------------------------------------------------------------------------------------------
-- Information :
------------------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Engineer     Comments
-- 0.0   See header  VTT          Initial version
-- 2.0	27.02.2012	VTT			  Méthode plus conventionnel 
-- 2.1  17.10.2013  ELR           file and input/output renamed         
-----------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;	-- synopsys: TODO remove this package
USE IEEE.STD_LOGIC_UNSIGNED.ALL; -- synopsys: TODO remove this package

entity encoder_sens_detector is
	port(	
            clk_i				:		in std_logic;
			reset_i				:		in std_logic;
            -- from incremental encoder
			a_inc_i				:		in std_logic;
			b_inc_i				:		in std_logic;
            -- to/from LBA SP6 registers
			left_rotate_o		:		out std_logic;
			right_rotate_o		:		out std_logic;
			pulse_counter_o		:		out std_logic_vector(15 downto 0)
	);
end encoder_sens_detector;

architecture Behavioral of encoder_sens_detector is

signal	counter_s	:	std_logic_vector(15 downto 0):="1000000000000000";

signal	A_tmp_1_s	:	std_logic;
signal	A_tmp_2_s	:	std_logic;
signal	A_pulse_s	:	std_logic;

begin

-- Creation d'une pulse derive de l'entree A
process(clk_i,reset_i)
begin
	if (reset_i = '1') then
		A_tmp_1_s <= '0';
		A_tmp_2_s <= '0';	
		A_pulse_s <= '0';		
	elsif rising_edge(clk_i) then
		A_tmp_1_s <= a_inc_i;
		A_tmp_2_s <= A_tmp_1_s;
		A_pulse_s <= not(A_tmp_1_s) and A_tmp_2_s;
	end if;
end process;

process(clk_i, reset_i)
begin
	if (reset_i = '1') then
		left_rotate_o <= '0';
		right_rotate_o <= '0';
	elsif rising_edge(clk_i) then
		if (A_pulse_s = '1' and b_inc_i = '0') then -- Pulse -> -> -> ->
			left_rotate_o <= '1';
			right_rotate_o <= '0';
			counter_s <= UNSIGNED(counter_s)-1;
		elsif (A_pulse_s = '1' and b_inc_i = '1') then -- Pulse <- <- <- <-
  			left_rotate_o <= '0';
			right_rotate_o <= '1';
			counter_s <= UNSIGNED(counter_s)+1;
		end if;
	end if;
end process;

pulse_counter_o <= counter_s; 

end Behavioral;