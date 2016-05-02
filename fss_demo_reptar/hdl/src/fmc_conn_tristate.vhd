------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : fmc_conn_tristate.vhd
-- Author               : Evangelina LOLIVIER-EXLER
-- Date                 : 16.08.2012
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
-- 0.0   See header  ELR          Initial version
-- 0.1	 28.10.2013	 ELR		  Inverters moved to top level, file renamed
-----------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fmc_conn_tristate is
	port(	
			clk_i					: in std_logic;
			reset_i					: in std_logic;
			FMC_LA_P_io				: inout std_logic_vector(33 downto 0);
			FMC_LA_N_io				: inout std_logic_vector(33 downto 0);
			FMC_GPIO_LA_REG1_i		: in std_logic_vector(15 downto 0);
			FMC_GPIO_LA_REG2_i		: in std_logic_vector(15 downto 0);
			FMC_GPIO_LA_REG3_i		: in std_logic_vector(15 downto 0);
			FMC_GPIO_LA_REG4_i		: in std_logic_vector(15 downto 0);
			FMC_GPIO_LA_REG5_i		: in std_logic_vector(3 downto 0);	-- FMC_DEBUG_REG(3 DOWNTO 0): LEDS DS4..DS1 DE LA CARTE FMC DEBUG XM105
			FMC_GPIO_LA_REG1_o		: out std_logic_vector(15 downto 0);
			FMC_GPIO_LA_REG2_o		: out std_logic_vector(15 downto 0);
			FMC_GPIO_LA_REG3_o		: out std_logic_vector(15 downto 0);
			FMC_GPIO_LA_REG4_o		: out std_logic_vector(15 downto 0);
			FMC_GPIO_LA_REG5_o		: out std_logic_vector(3 downto 0);
			FMC_TRIS1_REG_i			: in std_logic_vector(15 downto 0);
			FMC_TRIS2_REG_i			: in std_logic_vector(15 downto 0);
			FMC_TRIS3_REG_i			: in std_logic_vector(15 downto 0);
			FMC_TRIS4_REG_i			: in std_logic_vector(15 downto 0);
			FMC_TRIS5_REG_i			: in std_logic_vector(3 downto 0)
						
	);

end fmc_conn_tristate; 	
	
architecture Behavioral of fmc_conn_tristate is

signal FMC_GPIO_LA_REG1_s : std_logic_vector(15 downto 0);
signal FMC_GPIO_LA_REG2_s : std_logic_vector(15 downto 0);
signal FMC_GPIO_LA_REG3_s : std_logic_vector(15 downto 0);
signal FMC_GPIO_LA_REG4_s : std_logic_vector(15 downto 0);
signal FMC_GPIO_LA_REG5_s : std_logic_vector(3 downto 0);


begin

-- syncronisation des entrées
process(clk_i, reset_i)
begin
	if (reset_i = '1') then
		FMC_GPIO_LA_REG1_s	<= (others => '0');
		FMC_GPIO_LA_REG2_s	<= (others => '0');
		FMC_GPIO_LA_REG3_s	<= (others => '0');
		FMC_GPIO_LA_REG4_s	<= (others => '0');
		FMC_GPIO_LA_REG5_s <= (others => '0');
	elsif rising_edge(clk_i) then
		FMC_GPIO_LA_REG1_s	<= FMC_GPIO_LA_REG1_i;
		FMC_GPIO_LA_REG2_s	<= FMC_GPIO_LA_REG2_i;
		FMC_GPIO_LA_REG3_s	<= FMC_GPIO_LA_REG3_i;
		FMC_GPIO_LA_REG4_s	<= FMC_GPIO_LA_REG4_i;
		FMC_GPIO_LA_REG5_s  <= FMC_GPIO_LA_REG5_i;
	end if;
end process;

-- Process de lecture
process(clk_i, reset_i)
begin
	if (reset_i = '1') then
		FMC_GPIO_LA_REG1_o	<= (others => '0');
		FMC_GPIO_LA_REG2_o	<= (others => '0');
		FMC_GPIO_LA_REG3_o	<= (others => '0');
		FMC_GPIO_LA_REG4_o	<= (others => '0');
		FMC_GPIO_LA_REG5_o <= (others => '0');
	elsif rising_edge(clk_i) then
		-- ATTENTION, xxxxx_REGx_o est une sortie du module mais ce sont 
		-- des entrées du design qui sont connectées dessus
		FMC_GPIO_LA_REG1_o	 <= FMC_LA_N_io(7) & FMC_LA_P_io(7) & FMC_LA_N_io(6) & FMC_LA_P_io(6) & FMC_LA_N_io(5) & FMC_LA_P_io(5) & FMC_LA_N_io(4) & FMC_LA_P_io(4) &
								FMC_LA_N_io(3) & FMC_LA_P_io(3) & FMC_LA_N_io(2) & FMC_LA_P_io(2) & FMC_LA_N_io(1) & FMC_LA_P_io(1) & FMC_LA_N_io(0) & FMC_LA_P_io(0);
		FMC_GPIO_LA_REG2_o	 <= FMC_LA_N_io(15) & FMC_LA_P_io(15) & FMC_LA_N_io(14) & FMC_LA_P_io(14) & FMC_LA_N_io(13) & FMC_LA_P_io(13) & FMC_LA_N_io(12) & FMC_LA_P_io(12) &
								FMC_LA_N_io(11) & FMC_LA_P_io(11) & FMC_LA_N_io(10) & FMC_LA_P_io(10) & FMC_LA_N_io(9) 	& FMC_LA_P_io(9)  & FMC_LA_N_io(8)  & FMC_LA_P_io(8);
		FMC_GPIO_LA_REG3_o	 <= FMC_LA_N_io(23) & FMC_LA_P_io(23) & FMC_LA_N_io(22) & FMC_LA_P_io(22) & FMC_LA_N_io(21) & FMC_LA_P_io(21) & FMC_LA_N_io(20) & FMC_LA_P_io(20) &
								FMC_LA_N_io(19) & FMC_LA_P_io(19) & FMC_LA_N_io(18) & FMC_LA_P_io(18) & FMC_LA_N_io(17) & FMC_LA_P_io(17) & FMC_LA_N_io(16) & FMC_LA_P_io(16);
		FMC_GPIO_LA_REG4_o	 <= FMC_LA_N_io(31) & FMC_LA_P_io(31) & FMC_LA_N_io(30) & FMC_LA_P_io(30) & FMC_LA_N_io(29) & FMC_LA_P_io(29) & FMC_LA_N_io(28) & FMC_LA_P_io(28) &
								FMC_LA_N_io(27) & FMC_LA_P_io(27) & FMC_LA_N_io(26) & FMC_LA_P_io(26) & FMC_LA_N_io(25) & FMC_LA_P_io(25) & FMC_LA_N_io(24) & FMC_LA_P_io(24);
		FMC_GPIO_LA_REG5_o  <= FMC_LA_P_io(32) & FMC_LA_N_io(32) & FMC_LA_P_io(33) & FMC_LA_N_io(33);	
	end if;
end process;

-- Buffers 3State

G1: for i in 0 to 7 generate
		FMC_LA_P_io(i)  <= 'Z' when FMC_TRIS1_REG_i(2*i) = '1'  	else FMC_GPIO_LA_REG1_s(2*i); 
		FMC_LA_N_io(i)  <= 'Z' when FMC_TRIS1_REG_i(2*i+1) = '1'  else FMC_GPIO_LA_REG1_s(2*i+1); 
	end generate G1;
	
G2: for i in 0 to 7 generate
		FMC_LA_P_io(i+8)  <= 'Z' when  FMC_TRIS2_REG_i(2*i) = '1'  	else FMC_GPIO_LA_REG2_s(2*i); 
		FMC_LA_N_io(i+8)  <= 'Z' when  FMC_TRIS2_REG_i(2*i+1) = '1'  	else FMC_GPIO_LA_REG2_s(2*i+1); 
	end generate G2;                   
	                                   
G3: for i in 0 to 7 generate           
		FMC_LA_P_io(i+16)  <= 'Z' when FMC_TRIS3_REG_i(2*i) = '1'  	else FMC_GPIO_LA_REG3_s(2*i); 
		FMC_LA_N_io(i+16)  <= 'Z' when FMC_TRIS3_REG_i(2*i+1) = '1'  else FMC_GPIO_LA_REG3_s(2*i+1); 
	end generate G3;                                                           
	                                                                           
G4: for i in 0 to 7 generate                                                   
		FMC_LA_P_io(i+24)  <= 'Z' when FMC_TRIS4_REG_i(2*i) = '1'  	else FMC_GPIO_LA_REG4_s(2*i); 
		FMC_LA_N_io(i+24)  <= 'Z' when FMC_TRIS4_REG_i(2*i+1) = '1'  else FMC_GPIO_LA_REG4_s(2*i+1); 
	end generate G4;
	

	FMC_LA_N_io(32)  <= 'Z' when FMC_TRIS5_REG_i(2) = '1'  else FMC_GPIO_LA_REG5_s(2); 
	FMC_LA_P_io(32)  <= 'Z' when FMC_TRIS5_REG_i(3) = '1'  else FMC_GPIO_LA_REG5_s(3); 
	FMC_LA_N_io(33)  <= 'Z' when FMC_TRIS5_REG_i(0) = '1'  else FMC_GPIO_LA_REG5_s(0); 
	FMC_LA_P_io(33)  <= 'Z' when FMC_TRIS5_REG_i(1) = '1'  else FMC_GPIO_LA_REG5_s(1); 
	
end Behavioral;
	