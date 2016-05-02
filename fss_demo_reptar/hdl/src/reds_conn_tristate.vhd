------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : reds_conn.vhd
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
-----------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity reds_conn_tristate is
	port(	clk_i						:		in std_logic;
			reset_i					:		in std_logic;
			reds_conn_io			:		inout std_logic_vector(80 downto 1);
			REDS_CONN_REG1_i		:		in std_logic_vector(16 downto 1);
			REDS_CONN_REG2_i		:		in std_logic_vector(16 downto 1);
			REDS_CONN_REG3_i		:		in std_logic_vector(16 downto 1);
			REDS_CONN_REG4_i		:		in std_logic_vector(16 downto 1);
			REDS_CONN_REG5_i		:		in std_logic_vector(16 downto 1);
			REDS_CONN_REG1_o		:		out std_logic_vector(16 downto 1);
			REDS_CONN_REG2_o		:		out std_logic_vector(16 downto 1);
			REDS_CONN_REG3_o		:		out std_logic_vector(16 downto 1);
			REDS_CONN_REG4_o		:		out std_logic_vector(16 downto 1);
			REDS_CONN_REG5_o		:		out std_logic_vector(16 downto 1);
			REDS_CONN_TRIS1_i		:		in std_logic_vector(16 downto 1);	
			REDS_CONN_TRIS2_i		:		in std_logic_vector(16 downto 1);		
			REDS_CONN_TRIS3_i		:		in std_logic_vector(16 downto 1);		
			REDS_CONN_TRIS4_i		:		in std_logic_vector(16 downto 1);		
			REDS_CONN_TRIS5_i		:		in std_logic_vector(16 downto 1)
	);

end reds_conn_tristate; 	
	
architecture Behavioral of reds_conn_tristate is

begin

-- Process de lecture
process(clk_i, reset_i)
begin
	if (reset_i = '1') then
		REDS_CONN_REG1_o	<= (others => '0');
		REDS_CONN_REG2_o	<= (others => '0');
		REDS_CONN_REG3_o	<= (others => '0');
		REDS_CONN_REG4_o	<= (others => '0');
		REDS_CONN_REG5_o	<= (others => '0');
	elsif rising_edge(clk_i) then
		-- ATTENTION, xxxxx_REGx_o est une sortie du module mais ce sont 
		-- des entrées du design qui sont connectées dessus
		REDS_CONN_REG1_o <= reds_conn_io(16 downto 1);	
		REDS_CONN_REG2_o <= reds_conn_io(32 downto 17);
		REDS_CONN_REG3_o <= reds_conn_io(48 downto 33);
		REDS_CONN_REG4_o <= reds_conn_io(64 downto 49);
		REDS_CONN_REG5_o <= reds_conn_io(80 downto 65);	
	end if;
end process;

-- Buffers 3State
reds_conn_io(1)		<=	'Z' when REDS_CONN_TRIS1_i(1) = '1'  else REDS_CONN_REG1_i(1); 
reds_conn_io(2)		<=	'Z' when REDS_CONN_TRIS1_i(2) = '1'  else REDS_CONN_REG1_i(2);  
reds_conn_io(3)		<=	'Z' when REDS_CONN_TRIS1_i(3) = '1'  else REDS_CONN_REG1_i(3);  
reds_conn_io(4)		<=	'Z' when REDS_CONN_TRIS1_i(4) = '1'  else REDS_CONN_REG1_i(4);  
reds_conn_io(5)		<=	'Z' when REDS_CONN_TRIS1_i(5) = '1'  else REDS_CONN_REG1_i(5);  
reds_conn_io(6)		<=	'Z' when REDS_CONN_TRIS1_i(6) = '1'  else REDS_CONN_REG1_i(6);  
reds_conn_io(7)		<=	'Z' when REDS_CONN_TRIS1_i(7) = '1'  else REDS_CONN_REG1_i(7);  
reds_conn_io(8)		<=	'Z' when REDS_CONN_TRIS1_i(8) = '1'  else REDS_CONN_REG1_i(8);  
reds_conn_io(9)		<=	'Z' when REDS_CONN_TRIS1_i(9) = '1'  else REDS_CONN_REG1_i(9);  
reds_conn_io(10)	<=	'Z' when REDS_CONN_TRIS1_i(10) = '1' else REDS_CONN_REG1_i(10); 
reds_conn_io(11)	<=	'Z' when REDS_CONN_TRIS1_i(11) = '1' else REDS_CONN_REG1_i(11); 
reds_conn_io(12)	<=	'Z' when REDS_CONN_TRIS1_i(12) = '1' else REDS_CONN_REG1_i(12); 
reds_conn_io(13)	<=	'Z' when REDS_CONN_TRIS1_i(13) = '1' else REDS_CONN_REG1_i(13); 
reds_conn_io(14)	<=	'Z' when REDS_CONN_TRIS1_i(14) = '1' else REDS_CONN_REG1_i(14); 
reds_conn_io(15)	<=	'Z' when REDS_CONN_TRIS1_i(15) = '1' else REDS_CONN_REG1_i(15); 
reds_conn_io(16)	<=	'Z' when REDS_CONN_TRIS1_i(16) = '1' else REDS_CONN_REG1_i(16); 
reds_conn_io(17)	<=	'Z' when REDS_CONN_TRIS2_i(1)  = '1' else REDS_CONN_REG2_i(1);  
reds_conn_io(18)	<=	'Z' when REDS_CONN_TRIS2_i(2)  = '1' else REDS_CONN_REG2_i(2);  
reds_conn_io(19)	<=	'Z' when REDS_CONN_TRIS2_i(3)  = '1' else REDS_CONN_REG2_i(3);  
reds_conn_io(20)	<=	'Z' when REDS_CONN_TRIS2_i(4)  = '1' else REDS_CONN_REG2_i(4);  
reds_conn_io(21)	<=	'Z' when REDS_CONN_TRIS2_i(5)  = '1' else REDS_CONN_REG2_i(5);  
reds_conn_io(22)	<=	'Z' when REDS_CONN_TRIS2_i(6)  = '1' else REDS_CONN_REG2_i(6);  
reds_conn_io(23)	<=	'Z' when REDS_CONN_TRIS2_i(7)  = '1' else REDS_CONN_REG2_i(7);  
reds_conn_io(24)	<=	'Z' when REDS_CONN_TRIS2_i(8)  = '1' else REDS_CONN_REG2_i(8);  
reds_conn_io(25)	<=	'Z' when REDS_CONN_TRIS2_i(9)  = '1' else REDS_CONN_REG2_i(9);  
reds_conn_io(26)	<=	'Z' when REDS_CONN_TRIS2_i(10) = '1' else REDS_CONN_REG2_i(10); 
reds_conn_io(27)	<=	'Z' when REDS_CONN_TRIS2_i(11) = '1' else REDS_CONN_REG2_i(11); 
reds_conn_io(28)	<=	'Z' when REDS_CONN_TRIS2_i(12) = '1' else REDS_CONN_REG2_i(12); 
reds_conn_io(29)	<=	'Z' when REDS_CONN_TRIS2_i(13) = '1' else REDS_CONN_REG2_i(13); 
reds_conn_io(30)	<=	'Z' when REDS_CONN_TRIS2_i(14) = '1' else REDS_CONN_REG2_i(14); 
reds_conn_io(31)	<=	'Z' when REDS_CONN_TRIS2_i(15) = '1' else REDS_CONN_REG2_i(15); 
reds_conn_io(32)	<=	'Z' when REDS_CONN_TRIS2_i(16) = '1' else REDS_CONN_REG2_i(16); 
reds_conn_io(33)	<=	'Z' when REDS_CONN_TRIS3_i(1)  = '1' else REDS_CONN_REG3_i(1);  
reds_conn_io(34)	<=	'Z' when REDS_CONN_TRIS3_i(2)  = '1' else REDS_CONN_REG3_i(2);  
reds_conn_io(35)	<=	'Z' when REDS_CONN_TRIS3_i(3)  = '1' else REDS_CONN_REG3_i(3);  
reds_conn_io(36)	<=	'Z' when REDS_CONN_TRIS3_i(4)  = '1' else REDS_CONN_REG3_i(4);  
reds_conn_io(37)	<=	'Z' when REDS_CONN_TRIS3_i(5)  = '1' else REDS_CONN_REG3_i(5);  
reds_conn_io(38)	<=	'Z' when REDS_CONN_TRIS3_i(6)  = '1' else REDS_CONN_REG3_i(6);  
reds_conn_io(39)	<=	'Z' when REDS_CONN_TRIS3_i(7)  = '1' else REDS_CONN_REG3_i(7);  
reds_conn_io(40)	<=	'Z' when REDS_CONN_TRIS3_i(8)  = '1' else REDS_CONN_REG3_i(8);  
reds_conn_io(41)	<=	'Z' when REDS_CONN_TRIS3_i(9)  = '1' else REDS_CONN_REG3_i(9);  
reds_conn_io(42)	<=	'Z' when REDS_CONN_TRIS3_i(10) = '1' else REDS_CONN_REG3_i(10); 
reds_conn_io(43)	<=	'Z' when REDS_CONN_TRIS3_i(11) = '1' else REDS_CONN_REG3_i(11); 
reds_conn_io(44)	<=	'Z' when REDS_CONN_TRIS3_i(12) = '1' else REDS_CONN_REG3_i(12); 
reds_conn_io(45)	<=	'Z' when REDS_CONN_TRIS3_i(13) = '1' else REDS_CONN_REG3_i(13); 
reds_conn_io(46)	<=	'Z' when REDS_CONN_TRIS3_i(14) = '1' else REDS_CONN_REG3_i(14); 
reds_conn_io(47)	<=	'Z' when REDS_CONN_TRIS3_i(15) = '1' else REDS_CONN_REG3_i(15); 
reds_conn_io(48)	<=	'Z' when REDS_CONN_TRIS3_i(16) = '1' else REDS_CONN_REG3_i(16); 
reds_conn_io(49)	<=	'Z' when REDS_CONN_TRIS4_i(1)  = '1' else REDS_CONN_REG4_i(1);  
reds_conn_io(50)	<=	'Z' when REDS_CONN_TRIS4_i(2)  = '1' else REDS_CONN_REG4_i(2);  
reds_conn_io(51)	<=	'Z' when REDS_CONN_TRIS4_i(3)  = '1' else REDS_CONN_REG4_i(3);  
reds_conn_io(52)	<=	'Z' when REDS_CONN_TRIS4_i(4)  = '1' else REDS_CONN_REG4_i(4);  
reds_conn_io(53)	<=	'Z' when REDS_CONN_TRIS4_i(5)  = '1' else REDS_CONN_REG4_i(5);  
reds_conn_io(54)	<=	'Z' when REDS_CONN_TRIS4_i(6)  = '1' else REDS_CONN_REG4_i(6);  
reds_conn_io(55)	<=	'Z' when REDS_CONN_TRIS4_i(7)  = '1' else REDS_CONN_REG4_i(7);  
reds_conn_io(56)	<=	'Z' when REDS_CONN_TRIS4_i(8)  = '1' else REDS_CONN_REG4_i(8); 
reds_conn_io(57)	<=	'Z' when REDS_CONN_TRIS4_i(9)  = '1' else REDS_CONN_REG4_i(9);  
reds_conn_io(58)	<=	'Z' when REDS_CONN_TRIS4_i(10) = '1' else REDS_CONN_REG4_i(10); 
reds_conn_io(59)	<=	'Z' when REDS_CONN_TRIS4_i(11) = '1' else REDS_CONN_REG4_i(11); 
reds_conn_io(60)	<=	'Z' when REDS_CONN_TRIS4_i(12) = '1' else REDS_CONN_REG4_i(12); 
reds_conn_io(61)	<=	'Z' when REDS_CONN_TRIS4_i(13) = '1' else REDS_CONN_REG4_i(13); 
reds_conn_io(62)	<=	'Z' when REDS_CONN_TRIS4_i(14) = '1' else REDS_CONN_REG4_i(14); 
reds_conn_io(63)	<=	'Z' when REDS_CONN_TRIS4_i(15) = '1' else REDS_CONN_REG4_i(15); 
reds_conn_io(64)	<=	'Z' when REDS_CONN_TRIS4_i(16) = '1' else REDS_CONN_REG4_i(16); 
reds_conn_io(65)	<=	'Z' when REDS_CONN_TRIS5_i(1) = '1' else REDS_CONN_REG5_i(1);  
reds_conn_io(66)	<=	'Z' when REDS_CONN_TRIS5_i(2)  = '1' else REDS_CONN_REG5_i(2);  
reds_conn_io(67)	<=	'Z' when REDS_CONN_TRIS5_i(3)  = '1' else REDS_CONN_REG5_i(3);  
reds_conn_io(68)	<=	'Z' when REDS_CONN_TRIS5_i(4)  = '1' else REDS_CONN_REG5_i(4);  
reds_conn_io(69)	<=	'Z' when REDS_CONN_TRIS5_i(5)  = '1' else REDS_CONN_REG5_i(5);  
reds_conn_io(70)	<=	'Z' when REDS_CONN_TRIS5_i(6)  = '1' else REDS_CONN_REG5_i(6);  
reds_conn_io(71)	<=	'Z' when REDS_CONN_TRIS5_i(7)  = '1' else REDS_CONN_REG5_i(7);  
reds_conn_io(72)	<=	'Z' when REDS_CONN_TRIS5_i(8)  = '1' else REDS_CONN_REG5_i(8);  
reds_conn_io(73)	<=	'Z' when REDS_CONN_TRIS5_i(9)  = '1' else REDS_CONN_REG5_i(9);  
reds_conn_io(74)	<=	'Z' when REDS_CONN_TRIS5_i(10) = '1' else REDS_CONN_REG5_i(10); 
reds_conn_io(75)	<=	'Z' when REDS_CONN_TRIS5_i(11) = '1' else REDS_CONN_REG5_i(11); 
reds_conn_io(76)	<=	'Z' when REDS_CONN_TRIS5_i(12) = '1' else REDS_CONN_REG5_i(12); 
reds_conn_io(77)	<=	'Z' when REDS_CONN_TRIS5_i(13) = '1' else REDS_CONN_REG5_i(13); 
reds_conn_io(78)	<=	'Z' when REDS_CONN_TRIS5_i(14) = '1' else REDS_CONN_REG5_i(14); 
reds_conn_io(79)	<=	'Z' when REDS_CONN_TRIS5_i(15) = '1' else REDS_CONN_REG5_i(15); 
reds_conn_io(80)	<=	'Z' when REDS_CONN_TRIS5_i(16) = '1' else REDS_CONN_REG5_i(16); 
end Behavioral;