------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : lcd_ctrl.vhd
-- Author               : Vincent Theurillat
-- Date                 : 21.02.2012
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
-- 0.1   18.04.2013  ELR	  LCD data tri-state moved to top level
-----------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity lcd_ctrl is
	port(	
        clk_i		:	in std_logic;
		reset_i		:	in std_logic;
        -- to/from LBA SP6 registers
		rs_up_i		:	in std_logic;
		rw_up_i		:	in std_logic;
		start_i		:	in std_logic;
        ready_o		:	out std_logic;
		start_rst_o	:	out std_logic;
            -- data returned to LB
		data_up_o	:	out std_logic_vector(7 downto 0);
            -- data/cmd received from LB
		data_up_i	:	in std_logic_vector(7 downto 0);
		-- to/from LCD
		rs_o			:	out std_logic;
		rw_o			:	out std_logic;
		e_o			    :	out std_logic;
		-- to/from tri-state buffer on top level
		data_lcd_i	    :	in std_logic_vector(7 downto 0);
		data_lcd_o	    :	out std_logic_vector(7 downto 0);
		data_lcd_oe_o   :	out std_logic
	);
end lcd_ctrl;

architecture Behavioral of lcd_ctrl is

-- Definition des etats
--constant Wait_start_c	: std_logic_vector(2 downto 0) := "000";
--constant Wait_Setup_c	: std_logic_vector(2 downto 0) := "001";
--constant Write_Wait_c	: std_logic_vector(2 downto 0) := "010";
--constant Read_Wait_c		: std_logic_vector(2 downto 0) := "011";
--constant Final_Wait_c	: std_logic_vector(2 downto 0) := "100";
--constant Stop_Wait_c		: std_logic_vector(2 downto 0) := "101";

type	state_t is(
		Wait_start_c,
      Wait_Setup_c,
      Write_Wait_c,
      Read_Wait_c,	
      Final_Wait_c,
      Stop_Wait_c	
);

constant Setup_Time_c	: std_logic_vector(8 downto 0) := "000010010";	-- 60ns 	=> min. 18
constant Write_Time_c	: std_logic_vector(8 downto 0) := "010000111";	-- 450ns => min. 135
constant Read_Time_c		: std_logic_vector(8 downto 0) := "001101100";	-- 360ns => min. 108
constant Final_Time_c	: std_logic_vector(8 downto 0) := "000111100";	-- 200ns => env. 60
constant Stop_Time_c		: std_logic_vector(8 downto 0) := "100101100"; 	-- 1us 	=> min. 300

-- signal etat present, etat futur
signal	Etat_Present_s, Etat_futur_s : state_t;
--signal Etat_Present_s, Etat_futur_s : std_logic_vector(2 downto 0);  

signal	End_cnt_s	:	std_logic;
signal	Start_cnt_s	: 	std_logic;
signal   Value_cnt_s	:	std_logic_vector(8 downto 0); 

signal	Ready_s		:	std_logic;
signal	start_s		:	std_logic;
signal   value_s		:	std_logic_vector(8 downto 0); 
signal	RS_s			:	std_logic;
signal	RW_s			:	std_logic;
signal	E_s			:	std_logic;
signal	oe_s			:	std_logic;
signal	Data_up_s	:	std_logic_vector(7 downto 0);
signal  Data_CE_s	:	std_logic;

component timer
	port(	clk_i			:	in std_logic;
			reset_i		:	in std_logic;
			Start_cnt_i	:	in std_logic;
			Value_cnt_i	:	in std_logic_vector(8 downto 0);
			End_cnt_o	:	out std_logic
	);
	
end component;

begin

	u0: timer
	port map( clk_i			=> clk_i,			
	          reset_i		=> reset_i,		
	          Start_cnt_i	=>	Start_cnt_s,
	          Value_cnt_i	=> Value_cnt_s,
	          End_cnt_o		=> End_cnt_s	
	);

-- Decodeur d'etat futur et de sortie
process(Etat_Present_s, start_i, End_cnt_s, rw_up_i,value_s,rs_up_i)
begin
	Start_rst_o <= '0';
	Ready_s <= '0';
	oe_s <= '1';
	E_s <= '0';
	start_s <= '0';
	value_s <= Setup_Time_c;
	RS_s <= not(rs_up_i);
	RW_s <= not(rw_up_i);
	Data_CE_s <= '0';


	case Etat_Present_s is
		---------------------------------------
		when Wait_start_c =>
			Ready_s <= '1';
			
			if start_i = '1' then
				value_s <= Setup_Time_c;
				start_s <= '1';
				Start_rst_o <= '1';
				Etat_futur_s <= Wait_Setup_c;
			else
				-- value_s <= value_s;
				-- start_s <= '0';
				Etat_futur_s <= Wait_start_c;
			end if;
		---------------------------------------
		when Wait_Setup_c =>
			RS_s <= rs_up_i;
			RW_s <= rw_up_i;
			Start_rst_o <= '1';
      
			if (End_cnt_s = '1' and rw_up_i = '0') then
				value_s <= Write_Time_c;
				start_s <= '1';
				Etat_futur_s <= Write_Wait_c;
			elsif (End_cnt_s = '1' and rw_up_i = '1') then
				value_s <= Read_Time_c;
				start_s <= '1';
				Etat_futur_s <= Read_Wait_c;
			else
				-- value_s <= value_s;
				-- start_s <= '0';
				Etat_futur_s <= Wait_Setup_c;
			end if;
		---------------------------------------
		when Write_Wait_c =>
			RS_s <= rs_up_i;
			RW_s <= rw_up_i;
			E_s <= '1';
      Start_rst_o <= '1';
      
			if End_cnt_s = '1' then
				value_s <= Final_Time_c;  
				start_s <= '1'; 
				Etat_futur_s <= Final_Wait_c;
			else
				-- value_s <= value_s;  
				-- start_s <= '0'; 
				Etat_futur_s <= Write_Wait_c;
			end if;
		---------------------------------------	
		when Read_Wait_c =>
			E_s <= '1';
			oe_s <= '0';
			RS_s <= rs_up_i;
			RW_s <= rw_up_i;
      Start_rst_o <= '1';
			
			if End_cnt_s = '1' then
			--	Data_up_s <= Data_LCD_i
				Data_CE_s <= '1';
				value_s <= Final_Time_c;  
				start_s <= '1'; 
				Etat_futur_s <= Final_Wait_c;
			else
				Etat_futur_s <= Read_Wait_c;
			end if;
		---------------------------------------	
		when Final_Wait_c =>
			RS_s <= rs_up_i;
			RW_s <= rw_up_i;
      Start_rst_o <= '1';
      
			if (rw_up_i = '1') then
				oe_s <= '0';
			end if;
			
			if End_cnt_s = '1' then
				value_s <= Stop_Time_c;  
				start_s <= '1'; 
				Etat_futur_s <= Stop_Wait_c;
			else
				-- value_s <= value_s;  
				-- start_s <= '0'; 
				Etat_futur_s <= Final_Wait_c;
			end if;
		---------------------------------------
		when Stop_Wait_c =>
			RS_s <= not(rs_up_i);
			RW_s <= not(rw_up_i);
      Start_rst_o <= '1';
			--start_s <= '0';
      
			if End_cnt_s = '1' then
				Etat_futur_s <= Wait_start_c;
			else
				Etat_futur_s <= Stop_Wait_c;
			end if;
		---------------------------------------
		when others =>
			Etat_futur_s <= Wait_start_c;
			
	end case;
end process;

-- element memoire
process(clk_i, reset_i)
begin

	if reset_i = '1' then
		Etat_Present_s <= Wait_start_c;
		Data_up_s <= (others => '1');
		Ready_o		<=	'0';
		Start_cnt_s	<=	'0';
		RS_o      	<=	'0';
		RW_o      	<=	'0';
		E_o      	<=	'0';
		Data_LCD_oe_o <=	'0';
	elsif Rising_Edge(clk_i) then
		Etat_Present_s <= Etat_futur_s;
		Ready_o		<=	Ready_s;	
		Start_cnt_s	<=	start_s;	
		RS_o      	<=	RS_s;		
		RW_o      	<=	RW_s;		
		E_o      	<=	E_s;		
		Data_LCD_oe_o 	<= oe_s;		
		Data_up_o 	<=	Data_up_s;
		Value_cnt_s <= value_s;
		
		if Data_CE_s = '1' then
			Data_up_s <= Data_LCD_i;
		else
			Data_up_s <= Data_up_s;
		end if;
	end if;
end process;


-- to tri-state buffer on the top
Data_LCD_o 		<= Data_up_i;

end Behavioral;
