------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : gpio_conn_tristate.vhd
-- Author               : Vincent Theurillat
-- Date                 : 09.02.2012
-- Target Devices       : Spartan6 xc6slx150t-3fgg900
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
-- 0.1   15.02.2012	 VTT		  Les GPIOs sur les headers 1 et 2 peuvent être configurées en IO singulièrement
-- 1.0	 28.10.2013  ELR		  Les GPIO_3V3 peuvent être désormais configurées en IO singulièrement,
--								  les inverseurs ont été déplacés vers le top								 
------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity gpio_conn_tristate is
	port(	
			clk_i					:		in std_logic;
			reset_i					:		in std_logic;
			sp6_header1_conn_io		:		inout std_logic_vector(11 downto 1);
			sp6_header2_conn_io		:		inout std_logic_vector(8 downto 1);
			sp6_3V3_conn_io			:		inout std_logic_vector(4 downto 1);
			GPIO_HDR1_REG_i			:		in std_logic_vector(11 downto 1);
			GPIO_HDR2_REG_i			:		in std_logic_vector(8 downto 1);
			GPIO_3V3_REG_i			:		in std_logic_vector(4 downto 1);
			GPIO_HDR1_REG_o			:		out std_logic_vector(11 downto 1);
			GPIO_HDR2_REG_o			:		out std_logic_vector(8 downto 1);
			GPIO_3V3_REG_o			:		out std_logic_vector(4 downto 1);
			GPIO_HDR1_TRIS_i		:		in std_logic_vector(11 downto 1);
			GPIO_HDR2_TRIS_i		:		in std_logic_vector(8 downto 1);
			GPIO_3V3_TRIS_i			:		in std_logic_vector(4 downto 1)
			
	);
end gpio_conn_tristate;

architecture Behavioral of gpio_conn_tristate is

begin

-- Process de lecture des gpios
process(clk_i, reset_i)
begin
	if (reset_i = '1') then
		GPIO_HDR1_REG_o	<= (others => '0');
		GPIO_HDR2_REG_o	<= (others => '0');
		-- ATTENTION : Doivent être en sortie sur SP6 et en entrées sur SP3
		GPIO_3V3_REG_o		<= (others => '0');
		--GPIO_DIFF_REG_o	<= (others => '0');
	elsif rising_edge(clk_i) then
		GPIO_HDR1_REG_o(11 downto 1) 	<= sp6_header1_conn_io;
		GPIO_HDR2_REG_o(8 downto 1) 	<= sp6_header2_conn_io;
		GPIO_3V3_REG_o(4 downto 1)	 	<= sp6_3V3_conn_io;
		--GPIO_DIFF_REG_o(10 downto 1) 	<= sp6_diff_conn_io;
	end if;
end process;

-- Buffers 3State header1
sp6_header1_conn_io(1)	<= 'Z' when GPIO_HDR1_TRIS_i(1) = '1' else GPIO_HDR1_REG_i(1);
sp6_header1_conn_io(2)	<= 'Z' when GPIO_HDR1_TRIS_i(2) = '1' else GPIO_HDR1_REG_i(2);
sp6_header1_conn_io(3)	<= 'Z' when GPIO_HDR1_TRIS_i(3) = '1' else GPIO_HDR1_REG_i(3);
sp6_header1_conn_io(4)	<= 'Z' when GPIO_HDR1_TRIS_i(4) = '1' else GPIO_HDR1_REG_i(4);
sp6_header1_conn_io(5)	<= 'Z' when GPIO_HDR1_TRIS_i(5) = '1' else GPIO_HDR1_REG_i(5);
sp6_header1_conn_io(6)	<= 'Z' when GPIO_HDR1_TRIS_i(6) = '1' else GPIO_HDR1_REG_i(6);
sp6_header1_conn_io(7)	<= 'Z' when GPIO_HDR1_TRIS_i(7) = '1' else GPIO_HDR1_REG_i(7);
sp6_header1_conn_io(8)	<= 'Z' when GPIO_HDR1_TRIS_i(8) = '1' else GPIO_HDR1_REG_i(8);
sp6_header1_conn_io(9)	<= 'Z' when GPIO_HDR1_TRIS_i(9) = '1' else GPIO_HDR1_REG_i(9);
sp6_header1_conn_io(10)	<= 'Z' when GPIO_HDR1_TRIS_i(10) = '1' else GPIO_HDR1_REG_i(10);
sp6_header1_conn_io(11)	<= 'Z' when GPIO_HDR1_TRIS_i(11) = '1' else GPIO_HDR1_REG_i(11);
-- Buffers 3State header2
sp6_header2_conn_io(1) 	<= 'Z' when GPIO_HDR2_TRIS_i(1) = '1' else GPIO_HDR2_REG_i(1);
sp6_header2_conn_io(2) 	<= 'Z' when GPIO_HDR2_TRIS_i(2) = '1' else GPIO_HDR2_REG_i(2);
sp6_header2_conn_io(3) 	<= 'Z' when GPIO_HDR2_TRIS_i(3) = '1' else GPIO_HDR2_REG_i(3);
sp6_header2_conn_io(4) 	<= 'Z' when GPIO_HDR2_TRIS_i(4) = '1' else GPIO_HDR2_REG_i(4);
sp6_header2_conn_io(5) 	<= 'Z' when GPIO_HDR2_TRIS_i(5) = '1' else GPIO_HDR2_REG_i(5);
sp6_header2_conn_io(6) 	<= 'Z' when GPIO_HDR2_TRIS_i(6) = '1' else GPIO_HDR2_REG_i(6);
sp6_header2_conn_io(7) 	<= 'Z' when GPIO_HDR2_TRIS_i(7) = '1' else GPIO_HDR2_REG_i(7);
sp6_header2_conn_io(8) 	<= 'Z' when GPIO_HDR2_TRIS_i(8) = '1' else GPIO_HDR2_REG_i(8);
-- Buffers 3State gpios 3V3
sp6_3V3_conn_io(1) 		<= 'Z' when GPIO_3V3_TRIS_i(1)  = '1' else GPIO_3V3_REG_i(1);
sp6_3V3_conn_io(2) 		<= 'Z' when GPIO_3V3_TRIS_i(2)  = '1' else GPIO_3V3_REG_i(2);
sp6_3V3_conn_io(3) 		<= 'Z' when GPIO_3V3_TRIS_i(3)  = '1' else GPIO_3V3_REG_i(3);
sp6_3V3_conn_io(4) 		<= 'Z' when GPIO_3V3_TRIS_i(4)  = '1' else GPIO_3V3_REG_i(4);


end Behavioral;