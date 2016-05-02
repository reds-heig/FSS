------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : reptar_local_bus_v2.vhd
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
-- 0.1	 07.08.2012  ELR		  Registers REDS_CONN_TRIS are now RW instead of write only
-- 0.2	 16.08.2012  ELR		  Added registers for FMC1 control
-- 0.3   28.02.2013  ELR		  Added bit for enable the touchpad button
-- 0.4	 04.04.2013  ELR		  Added iobuf for LB data on the top
-- 0.5   08.04.2013  ELR		  Registers sizes modified to fit number of useful bits
-- 0.6   10.04.2013  ELR		  Split write process in "write process" and "input register"
--					  				and read process in "read process" and "output setting"
-- 0.7	 15.04.2013  ELR		  Debug output set to '0' to avoid timing errors
-- 0.8   29.04.2013  ELR      	  Added IRQ_CTL register: IRQ generation when a button is pressed, 
--								  added LED_REG read access

-------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Local_Bus_v2 is
	port(	clk_i						:		in std_logic;
				nReset_i				:		in std_logic;
				nCS3_LB_i				:		in std_logic;
				nADV_LB_i				:		in std_logic;
				nOE_LB_i				:		in std_logic;
				nWE_LB_i				:		in std_logic;
				-- 04.04.2013: buffer tri-state is now instantiated on the top 
				Addr_Data_LB_i			:		in std_logic_vector(15 downto 0);
				Addr_Data_LB_o			:		out std_logic_vector(15 downto 0);
				Addr_Data_LB_tris_o		: 		out   STD_LOGIC;		-- '1' input, '0' output
				--------------------------------------------------------------------
				Addr_LB_i				:		in std_logic_vector(24 downto 16);	
				--7Seg
				SP6_7seg1_o				:		out std_logic_vector(6 downto 0);
				SP6_7seg2_o				:		out std_logic_vector(6 downto 0);
				SP6_7seg3_o				:		out std_logic_vector(6 downto 0);
				SP6_7seg1_DP_o			:		out std_logic;
				SP6_7seg2_DP_o			:		out std_logic;
				SP6_7seg3_DP_o			:		out std_logic;	
				--Switch PB
				SW_PB_i					:		in std_logic_vector(8 downto 1);	
				IRQ_o					:		out std_logic;
				--DIPs
				DIP_i					:		in std_logic_vector(10 downto 1);
				--LEDs
				FPGA_LED_o				:		out std_logic_vector(6 downto 1);
				--UART
				SP6_UART1_CTS_o			:		out std_logic;
				SP6_UART1_RTS_i			:		in	std_logic;
				SP6_UART1_RX_i			:		in std_logic;
				SP6_UART1_TX_o			:		out std_logic;
				-- touch pad
				PCB_TB_i				:		in std_logic;
				PCB_TB_en_o				:		out std_logic;
				-- GPIOs bidir.
				REDS_CONN_TRIS1_o		:		out std_logic_vector(16 downto 1);		
				REDS_CONN_TRIS2_o		:		out std_logic_vector(16 downto 1);		
				REDS_CONN_TRIS3_o		:		out std_logic_vector(16 downto 1);		
				REDS_CONN_TRIS4_o		:		out std_logic_vector(16 downto 1);		
				REDS_CONN_TRIS5_o		:		out std_logic_vector(16 downto 1);
				GPIO_HDR1_TRIS_o		:		out std_logic_vector(11 downto 1);
				GPIO_HDR2_TRIS_o		:		out std_logic_vector(8 downto 1);
				GPIO_3V3_TRIS_o		  	:		out std_logic;
				--GPIO_DIFF_TRIS_o		:		out std_logic;
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
				GPIO_HDR1_REG_i		  	:		in std_logic_vector(11 downto 1);
				GPIO_HDR2_REG_i		  	:		in std_logic_vector(8 downto 1);
				GPIO_3V3_REG_i			:		in std_logic_vector(4 downto 1);
				--GPIO_DIFF_REG_i		  	:		in std_logic_vector(16 downto 1);
				GPIO_HDR1_REG_o		  	:		out std_logic_vector(11 downto 1);
				GPIO_HDR2_REG_o		  	:		out std_logic_vector(8 downto 1);
				GPIO_3V3_REG_o			:		out std_logic_vector(4 downto 1);
				--GPIO_DIFF_REG_o		  	:		out std_logic_vector(16 downto 1);
				--FMC1
				FMC1_GPIO_LA_REG1_i		: 		in std_logic_vector(15 downto 0);
				FMC1_GPIO_LA_REG2_i		: 		in std_logic_vector(15 downto 0);
				FMC1_GPIO_LA_REG3_i		: 		in std_logic_vector(15 downto 0);
				FMC1_GPIO_LA_REG4_i		: 		in std_logic_vector(15 downto 0);
				FMC1_GPIO_LA_REG5_i		: 		in std_logic_vector(3 downto 0);
				FMC1_GPIO_LA_REG1_o		: 		out std_logic_vector(15 downto 0);
				FMC1_GPIO_LA_REG2_o		: 		out std_logic_vector(15 downto 0);
				FMC1_GPIO_LA_REG3_o		: 		out std_logic_vector(15 downto 0);
				FMC1_GPIO_LA_REG4_o		: 		out std_logic_vector(15 downto 0);
				FMC1_TRIS1_REG_o		: 		out std_logic_vector(15 downto 0);
				FMC1_TRIS2_REG_o		: 		out std_logic_vector(15 downto 0);
				FMC1_TRIS3_REG_o		: 		out std_logic_vector(15 downto 0);
				FMC1_TRIS4_REG_o		: 		out std_logic_vector(15 downto 0);
				--FMC2		
				FMC2_GPIO_LA_REG1_i		: 		in std_logic_vector(15 downto 0);
				FMC2_GPIO_LA_REG2_i		: 		in std_logic_vector(15 downto 0);
				FMC2_GPIO_LA_REG3_i		: 		in std_logic_vector(15 downto 0);
				FMC2_GPIO_LA_REG4_i		: 		in std_logic_vector(15 downto 0);
				FMC2_GPIO_LA_REG5_i		: 		in std_logic_vector(3 downto 0);
				FMC2_GPIO_LA_REG1_o		: 		out std_logic_vector(15 downto 0);
				FMC2_GPIO_LA_REG2_o		: 		out std_logic_vector(15 downto 0);
				FMC2_GPIO_LA_REG3_o		: 		out std_logic_vector(15 downto 0);
				FMC2_GPIO_LA_REG4_o		: 		out std_logic_vector(15 downto 0);
				FMC2_TRIS1_REG_o		: 		out std_logic_vector(15 downto 0);
				FMC2_TRIS2_REG_o		: 		out std_logic_vector(15 downto 0);
				FMC2_TRIS3_REG_o		: 		out std_logic_vector(15 downto 0);
				FMC2_TRIS4_REG_o		: 		out std_logic_vector(15 downto 0);
				-- FMC_DEBUG_REG(4 DOWNTO 0)
				FMC1_GPIO_LA_REG5_o		: 		out std_logic_vector(3 downto 0);		-- BITS 3..0: LEDS DS4..DS1 DE LA CARTE FMC DEBUG XM105
				FMC1_PRSNT_i			: 		in std_logic;							-- BIT 4: detection de présence depuis la pin H2 du FMC1
				-- FMC_DEBUG_REG(12 DOWNTO 8)
				FMC2_GPIO_LA_REG5_o		: 		out std_logic_vector(3 downto 0);		-- BITS 11..8: LEDS DS4..DS1 DE LA CARTE FMC DEBUG XM105
				FMC2_PRSNT_i			: 		in std_logic;							-- BIT 12: detection de présence depuis la pin H2 du FMC2
				-- SPI nCS
				SPI_nCS1_o				  :		out std_logic;
				SPI_nCS2_o				  :		out std_logic;
				SPI_nCS_AD_o			  :		out std_logic;
				SPI_nCS_DA_o			  :		out std_logic;
				-- Buzzer
				buzzer_en_o				  :		out std_logic;
				fast_mode_o				  :		out std_logic;
				slow_mode_o				  :		out std_logic;
				-- Encoder
				left_rotation_i		  		:		in std_logic;
				right_rotation_i			:		in std_logic;
				pulse_counter_i		  		:		in std_logic_vector(15 downto 0);
				-- LCD
				LCD_cmd_o				    :		out std_logic_vector(7 downto 0);
				LCD_RS_o					: 		out std_logic;
				LCD_RW_o					:		out std_logic;
				LCD_start_cmd_o		  		:		out std_logic;
				LCD_ready_i				  	:		in std_logic;
				LCD_Return_data_i			:		in std_logic_vector(7 downto 0);
				LCD_start_reset_i			:		in std_logic;
				-- AD
				AD_GPIO_io				  	:		out std_logic_vector(3 downto 0);
				-- DA
				DAC_nLDAC_o				  	:		out std_logic;			
				DAC_nRS_o           		:		out std_logic;
				--Debug
				Debug_vector_LB		  		:		out std_logic_vector(7 downto 0)
	);

end Local_Bus_v2;

architecture Behavioral of Local_Bus_v2 is
signal  REDS_CONN_CTRL_REG1_s		: std_logic_vector(16 downto 1);
signal  REDS_CONN_CTRL_REG2_s		: std_logic_vector(16 downto 1);
signal  REDS_CONN_CTRL_REG3_s		: std_logic_vector(16 downto 1);
signal  REDS_CONN_CTRL_REG4_s		: std_logic_vector(16 downto 1);
signal  REDS_CONN_CTRL_REG5_s		: std_logic_vector(16 downto 1);
signal  REDS_CONN_STAT_REG1_s		: std_logic_vector(16 downto 1);
signal  REDS_CONN_STAT_REG2_s		: std_logic_vector(16 downto 1);
signal  REDS_CONN_STAT_REG3_s		: std_logic_vector(16 downto 1);
signal  REDS_CONN_STAT_REG4_s		: std_logic_vector(16 downto 1);
signal  REDS_CONN_STAT_REG5_s		: std_logic_vector(16 downto 1);
signal	DIP_SW_REG_s			    : std_logic_vector(10 downto 1);
signal	PUSH_BUT_REG_s			  : std_logic_vector(16 downto 1);
signal	LED_REG_s				      : std_logic_vector(6 downto 1);
signal	REG_7SEG1_s				    : std_logic_vector(8 downto 1);
signal	LCD_CONTROL_REG_s		  : std_logic_vector(11 downto 1);
signal	UART_CONTROL_REG_s	  : std_logic_vector(4 downto 1);
signal	AD_DA_CONTROL_REG_s	  : std_logic_vector(7 downto 2);
signal	TRIS_REG_s				    : std_logic_vector(2 downto 1);
signal	TRIS_GPIO_HDR1_REG_s	: std_logic_vector(11 downto 1);
signal	TRIS_GPIO_HDR2_REG_s	: std_logic_vector(8 downto 1);
signal	SPI_CS_REG_s			    : std_logic_vector(4 downto 1);
signal	BUZZER_ENCODER_REG_s  : std_logic_vector(16 downto 1);
signal	ENCODER_COUNT_REG_s	  : std_logic_vector(16 downto 1);
signal	LCD_STATUS_REG_s		  : std_logic_vector(9 downto 1);
signal	REG_7SEG2_s				    : std_logic_vector(8 downto 1);
signal	REG_7SEG3_s				    : std_logic_vector(8 downto 1);
signal	REDS_CONN_TRIS1_REG_s : std_logic_vector(16 downto 1);
signal  REDS_CONN_TRIS2_REG_s : std_logic_vector(16 downto 1);
signal  REDS_CONN_TRIS3_REG_s : std_logic_vector(16 downto 1);
signal  REDS_CONN_TRIS4_REG_s : std_logic_vector(16 downto 1);
signal  REDS_CONN_TRIS5_REG_s : std_logic_vector(16 downto 1);
signal  FMC1_GPIO_LA_CTRL_REG1_s	:  std_logic_vector(15 downto 0);
signal  FMC1_GPIO_LA_CTRL_REG2_s	:  std_logic_vector(15 downto 0);
signal  FMC1_GPIO_LA_CTRL_REG3_s	:  std_logic_vector(15 downto 0);
signal  FMC1_GPIO_LA_CTRL_REG4_s	:  std_logic_vector(15 downto 0);
signal  FMC1_GPIO_LA_CTRL_REG5_s	:  std_logic_vector(3 downto 0);
signal  FMC1_GPIO_LA_STAT_REG1_s	:  std_logic_vector(15 downto 0);
signal  FMC1_GPIO_LA_STAT_REG2_s	:  std_logic_vector(15 downto 0);
signal  FMC1_GPIO_LA_STAT_REG3_s	:  std_logic_vector(15 downto 0);
signal  FMC1_GPIO_LA_STAT_REG4_s	:  std_logic_vector(15 downto 0);
signal  FMC1_GPIO_LA_STAT_REG5_s	:  std_logic_vector(3 downto 0);
signal  FMC1_TRIS1_REG_s		: std_logic_vector(15 downto 0);
signal  FMC1_TRIS2_REG_s		: std_logic_vector(15 downto 0);
signal  FMC1_TRIS3_REG_s		: std_logic_vector(15 downto 0);
signal  FMC1_TRIS4_REG_s		: std_logic_vector(15 downto 0);
signal  FMC2_GPIO_LA_CTRL_REG1_s	:  std_logic_vector(15 downto 0);
signal  FMC2_GPIO_LA_CTRL_REG2_s	:  std_logic_vector(15 downto 0);
signal  FMC2_GPIO_LA_CTRL_REG3_s	:  std_logic_vector(15 downto 0);
signal  FMC2_GPIO_LA_CTRL_REG4_s	:  std_logic_vector(15 downto 0);
signal  FMC2_GPIO_LA_CTRL_REG5_s	:  std_logic_vector(3 downto 0);
signal  FMC2_GPIO_LA_STAT_REG1_s	:  std_logic_vector(15 downto 0);
signal  FMC2_GPIO_LA_STAT_REG2_s	:  std_logic_vector(15 downto 0);
signal  FMC2_GPIO_LA_STAT_REG3_s	:  std_logic_vector(15 downto 0);
signal  FMC2_GPIO_LA_STAT_REG4_s	:  std_logic_vector(15 downto 0);
signal  FMC2_GPIO_LA_STAT_REG5_s	:  std_logic_vector(3 downto 0);
signal  FMC2_TRIS1_REG_s		: std_logic_vector(15 downto 0);
signal  FMC2_TRIS2_REG_s		: std_logic_vector(15 downto 0);
signal  FMC2_TRIS3_REG_s		: std_logic_vector(15 downto 0);
signal  FMC2_TRIS4_REG_s		: std_logic_vector(15 downto 0);
signal	FMC_DEBUG_REG_s		: std_logic_vector(15 downto 0);


-- Internal signals
signal	read_en_s					: std_logic;
signal	write_en_s					: std_logic;
signal	addr_en_s					: std_logic;
signal 	Data_out_s 				    : std_logic_vector(16 downto 1);
signal 	Data_in_s 				    : std_logic_vector(16 downto 1);
signal	Addr_s					      : std_logic_vector(5 downto 0);
signal	nOE_Delay_s				    : std_logic;
signal	SP6_LB_ENA_s				  : std_logic;

signal	local_bus_en_s		    : std_logic;

-- signals fir IRQ generation ----------------------------------------------------------
signal  IRQ_CTL_REG_s				: std_logic_vector(15 downto 0);
-- number of the button that has generated the IRQ
signal  IRQ_BUTTON_s			: std_logic_vector(2 downto 0);
signal  IRQ_PRESS_BUT_s			: std_logic_vector(2 downto 0);
-- button pressure detection
signal  IRQ_STATUS_s			: std_logic;
signal  IRQ_event_s				: std_logic;
-- registers for SW_PB_i
signal  PUSH_BUT_REG1_s			: std_logic_vector(7 downto 0);
signal  PUSH_BUT_REG2_s			: std_logic_vector(7 downto 0);
signal  PUSH_BUT_REG3_s			: std_logic_vector(7 downto 0);
----------------------
signal  p_state_s, f_state_s     : std_logic;

-- Address registers
constant	REDS_CONN_REG1_c		  : std_logic_vector(5 downto 0) := "000000"; --0x0000000 RW
constant	REDS_CONN_REG2_c		  : std_logic_vector(5 downto 0) := "000001"; --0x0000001 RW
constant	REDS_CONN_REG3_c		  : std_logic_vector(5 downto 0) := "000010"; --0x0000002 RW
constant	REDS_CONN_REG4_c		  : std_logic_vector(5 downto 0) := "000011"; --0x0000003 RW
constant	REDS_CONN_REG5_c		  : std_logic_vector(5 downto 0) := "000100"; --0x0000004 RW
constant	DIP_SW_REG_c			    : std_logic_vector(5 downto 0) := "000101"; --0x0000005 R
constant	PUSH_BUT_REG_c			  : std_logic_vector(5 downto 0) := "000110"; --0x0000006 R
constant	LED_REG_c				      : std_logic_vector(5 downto 0) := "000111"; --0x0000007 W
constant	REG_7SEG1_c				    : std_logic_vector(5 downto 0) := "001000"; --0x0000008 W
constant	LCD_CONTROL_REG_c		  : std_logic_vector(5 downto 0) := "001001"; --0x0000009 W
constant	UART_CONTROL_REG_c	  : std_logic_vector(5 downto 0) := "001010"; --0x000000A RW
constant	AD_DA_CONTROL_REG_c	  : std_logic_vector(5 downto 0) := "001011"; --0x000000B RW
constant	GPIO_HEADER_REG_c		  : std_logic_vector(5 downto 0) := "001100"; --0x000000C RW
constant	GPIO_3V3_REG_c			  : std_logic_vector(5 downto 0) := "001101"; --0x000000D RW
constant	GPIO_CPU_REG_c			  : std_logic_vector(5 downto 0) := "001110"; --0x000000E RW
constant	GPIO_HEADER2_REG_c  	: std_logic_vector(5 downto 0) := "001111"; --0x000000F R
constant	TRIS_REG_c				    : std_logic_vector(5 downto 0) := "010000"; --0x0000010 RW
constant	TRIS_GPIO_HDR1_REG_c  : std_logic_vector(5 downto 0) := "010001"; --0x0000011 RW
constant	TRIS_GPIO_HDR2_REG_c  : std_logic_vector(5 downto 0) := "010010"; --0x0000012 W
constant	SPI_CS_REG_c			    : std_logic_vector(5 downto 0) := "010011"; --0x0000013 W
constant	BUZZER_ENCODER_REG_c  : std_logic_vector(5 downto 0) := "010100"; --0x0000014 W
constant	ENCODER_COUNT_REG_c	  : std_logic_vector(5 downto 0) := "010101"; --0x0000015 W
constant	LCD_STATUS_REG_c		  : std_logic_vector(5 downto 0) := "010110"; --0x0000016 W
constant	REG_7SEG2_c				    : std_logic_vector(5 downto 0) := "010111"; --0x0000017 W
constant	REG_7SEG3_c				    : std_logic_vector(5 downto 0) := "011000"; --0x0000018 W
constant	REDS_CONN_TRIS1_REG_c : std_logic_vector(5 downto 0) := "011001"; --0x0000019 RW
constant	REDS_CONN_TRIS2_REG_c : std_logic_vector(5 downto 0) := "011010"; --0x000001A RW
constant	REDS_CONN_TRIS3_REG_c : std_logic_vector(5 downto 0) := "011011"; --0x000001B RW
constant	REDS_CONN_TRIS4_REG_c : std_logic_vector(5 downto 0) := "011100"; --0x000001C RW
constant	REDS_CONN_TRIS5_REG_c : std_logic_vector(5 downto 0) := "011101"; --0x000001D RW
-- les adresses 0x000001E à 0x0000027 sont réservées pour les registres pour les démos 
constant	FMC1_GPIO_LA_REG1_c		: std_logic_vector(5 downto 0) := "101000"; --0x0000028  RW
constant	FMC1_GPIO_LA_REG2_c		: std_logic_vector(5 downto 0) := "101001"; --0x0000029  RW
constant	FMC1_GPIO_LA_REG3_c		: std_logic_vector(5 downto 0) := "101010"; --0x000002A  RW
constant	FMC1_GPIO_LA_REG4_c		: std_logic_vector(5 downto 0) := "101011"; --0x000002B  RW
constant	FMC_DEBUG_REG_c		: std_logic_vector(5 downto 0) := "101100"; --0x000002C  RW
constant	FMC2_GPIO_LA_REG1_c		: std_logic_vector(5 downto 0) := "101101"; --0x000002D  RW
constant	FMC2_GPIO_LA_REG2_c		: std_logic_vector(5 downto 0) := "101110"; --0x000002E  RW
constant	FMC2_GPIO_LA_REG3_c		: std_logic_vector(5 downto 0) := "101111"; --0x000002F  RW
constant	FMC2_GPIO_LA_REG4_c		: std_logic_vector(5 downto 0) := "110000"; --0x0000030  RW
constant	FMC1_TRIS1_REG_c		: std_logic_vector(5 downto 0) := "110001"; --0x0000031  RW
constant	FMC1_TRIS2_REG_c		: std_logic_vector(5 downto 0) := "110010"; --0x0000032  RW
constant	FMC1_TRIS3_REG_c		: std_logic_vector(5 downto 0) := "110011"; --0x0000033  RW
constant	FMC1_TRIS4_REG_c		: std_logic_vector(5 downto 0) := "110100"; --0x0000034  RW
constant	FMC2_TRIS1_REG_c		: std_logic_vector(5 downto 0) := "110101"; --0x0000035  RW
constant	FMC2_TRIS2_REG_c		: std_logic_vector(5 downto 0) := "110110"; --0x0000036  RW
constant	FMC2_TRIS3_REG_c		: std_logic_vector(5 downto 0) := "110111"; --0x0000037  RW
constant	FMC2_TRIS4_REG_c		: std_logic_vector(5 downto 0) := "111000"; --0x0000038  RW
constant	IRQ_CTL_REG_c			: std_logic_vector(5 downto 0) := "111001"; --0x0000039  RW
				 
begin            	

-- Les timings pris en compte pour le design du local bus sont 
-- tirés du fichier \GIT\reptar\doc\datasheet\DM3730\DM3730_TRM.pdf
-- section 10.1.5.9 

-- /////// Timing config to set in CPU config register /////// 
-- Read :
-- CSONTIME = 1
-- CSRDOFFTIME = 10
-- ADVONTIME = 1
-- ADVRDOFFTIME = 2
-- OEONTIME = 2
-- OEOFFTIME = 10
-- RDACCESSTIME = 5
-- RDCYCLETIME = 12

-- Write :
-- CSONTIME = 1
-- CSWROFFTIME = 10
-- ADVONTIME = 1
-- ADVWROFFTIME = 3
-- WEONTIME = 3
-- WEOFFTIME = 10
-- WRDATAONADMUXBUS = 3
-- WRCYCLETIME = 12

-- outputs/inputs to Buff. 3-state on the top
local_bus_en_s 		<= DIP_i(1);
Data_in_s 			<= Addr_Data_LB_i(15 downto 0);
Addr_Data_LB_o 		<= Data_out_s;
-- '1' input, '0' output
Addr_Data_LB_tris_o <= '0' when (local_bus_en_s = '1' and read_en_s = '1') else '1';

Debug_vector_LB <= (others => '0');

-- get address from bus
addr_en_s  <= '1' when nADV_LB_i = '0' and nOE_LB_i = '1' and nWE_LB_i = '1' else '0';

process(clk_i, nReset_i, nCS3_LB_i)
begin
	if (nReset_i = '0' or nCS3_LB_i = '1') then
		Addr_s 				<= (others => '0');
		SP6_LB_ENA_s 		<= '0';
	elsif rising_edge(clk_i) then
	-- nReset_i = '1' and nCS3_LB_i = '0' 
	    if addr_en_s = '1' and Addr_LB_i(23) = '0' then
			Addr_s 		<= Addr_Data_LB_i(5 downto 0);			
			-- Addr_LB_i(23) is the bit A24 of the CPU (difference between 0x18 -> SP6 and 0x19 -> SP3)
			SP6_LB_ENA_s <= '1';
		end if;
	end if;
end process;

-- write access detection
process(clk_i, nReset_i, nCS3_LB_i)
begin
	if (nReset_i = '0' or nCS3_LB_i = '1') then
		write_en_s <= '0';
	elsif rising_edge(clk_i) then
	  if nWE_LB_i = '0' and SP6_LB_ENA_s = '1' then
		write_en_s <= '1';
	  end if;
	end if;
end process;

-- read access detection
read_en_s  <= '1' when nOE_Delay_s = '0' and SP6_LB_ENA_s = '1' else '0';

-- nOE delayed of one clock
process(clk_i, nReset_i, nCS3_LB_i)
begin
	if (nReset_i = '0') then
		nOE_Delay_s <= '1';
	elsif rising_edge(clk_i) then
		nOE_Delay_s <= nOE_LB_i;
	end if;
end process;



-- Write process
process(clk_i, nReset_i)
begin
	if (nReset_i = '0') then
		REDS_CONN_CTRL_REG1_s		<= (others => '0');
		REDS_CONN_CTRL_REG2_s		<= (others => '0');
		REDS_CONN_CTRL_REG3_s		<= (others => '0');
		REDS_CONN_CTRL_REG4_s		<= (others => '0');
		REDS_CONN_CTRL_REG5_s		<= (others => '0');
		PUSH_BUT_REG_s(15)			<=	'0';
		LED_REG_s					<=	(others => '0');
		REG_7SEG1_s					<=	(others => '0');
		LCD_CONTROL_REG_s(10 downto 1)	<=	(others => '0');
		UART_CONTROL_REG_s(2)		<= '0';
		UART_CONTROL_REG_s(4)       <= '0';		
		AD_DA_CONTROL_REG_s			<=	(others => '0');
		GPIO_HDR1_REG_o				<=  (others => '0');
		GPIO_3V3_REG_o				<=  (others => '0');
		--GPIO_DIFF_REG_o				<=  (others => '0');
		GPIO_HDR2_REG_o				<=  (others => '0');
		TRIS_REG_s					<=	(others => '0');
		TRIS_GPIO_HDR1_REG_s		<=	(others => '0');
		TRIS_GPIO_HDR2_REG_s		<=	(others => '0');
		SPI_CS_REG_s				<=	(others => '0');
		BUZZER_ENCODER_REG_s(3 downto 1) <=	(others => '0');
		REG_7SEG2_s					<=	(others => '0');
		REG_7SEG3_s					<=	(others => '0');
		REDS_CONN_TRIS1_REG_s		<=	(others => '0');
		REDS_CONN_TRIS2_REG_s		<=	(others => '0');
		REDS_CONN_TRIS3_REG_s		<=	(others => '0');
		REDS_CONN_TRIS4_REG_s		<=	(others => '0');
		REDS_CONN_TRIS5_REG_s		<=	(others => '0');
		FMC1_GPIO_LA_CTRL_REG1_s	<=	(others => '0');
		FMC1_GPIO_LA_CTRL_REG2_s	<=	(others => '0');
		FMC1_GPIO_LA_CTRL_REG3_s	<=	(others => '0');
		FMC1_GPIO_LA_CTRL_REG4_s	<=	(others => '0');
		FMC1_GPIO_LA_CTRL_REG5_s	<=	(others => '0');
		FMC2_GPIO_LA_CTRL_REG5_s	<=	(others => '0');
		FMC2_GPIO_LA_CTRL_REG1_s	<=	(others => '0');
		FMC2_GPIO_LA_CTRL_REG2_s	<=	(others => '0');
		FMC2_GPIO_LA_CTRL_REG3_s	<=	(others => '0');
		FMC2_GPIO_LA_CTRL_REG4_s	<=	(others => '0');
		FMC1_TRIS1_REG_s			<= (others =>'0');
		FMC1_TRIS2_REG_s			<= (others =>'0');
		FMC1_TRIS3_REG_s			<= (others =>'0');
		FMC1_TRIS4_REG_s			<= (others =>'0');
		FMC2_TRIS1_REG_s			<= (others =>'0');
		FMC2_TRIS2_REG_s			<= (others =>'0');
		FMC2_TRIS3_REG_s			<= (others =>'0');
		FMC2_TRIS4_REG_s			<= (others =>'0');
		IRQ_CTL_REG_s(0)			<= '0';
		
	elsif rising_edge(clk_i) then
	  if  write_en_s = '1' then
		case Addr_s is
				when REDS_CONN_REG1_c		=>
					REDS_CONN_CTRL_REG1_s 	<= Data_in_s;
				when REDS_CONN_REG2_c		=>
					REDS_CONN_CTRL_REG2_s 	<= Data_in_s;
				when REDS_CONN_REG3_c		=>
					REDS_CONN_CTRL_REG3_s 	<= Data_in_s;
				when REDS_CONN_REG4_c		=>
					REDS_CONN_CTRL_REG4_s 	<= Data_in_s;
				when REDS_CONN_REG5_c		=>
					REDS_CONN_CTRL_REG5_s 	<= Data_in_s;
				when PUSH_BUT_REG_c			=>
					PUSH_BUT_REG_s(15) 		<= Data_in_s(15);
				when LED_REG_c					=>
					LED_REG_s 				<= Data_in_s(6 downto 1);
				when REG_7SEG1_c				=>
					REG_7SEG1_s 			<= Data_in_s(8 downto 1);
				when LCD_CONTROL_REG_c		=>
					LCD_CONTROL_REG_s(10 downto 1) 	<= Data_in_s(10 downto 1);						
				when UART_CONTROL_REG_c		=>
					UART_CONTROL_REG_s(2)<= Data_in_s(2);
					UART_CONTROL_REG_s(4)<= Data_in_s(4);
				when AD_DA_CONTROL_REG_c	=>
					AD_DA_CONTROL_REG_s 	<= Data_in_s(7 downto 2);
				when GPIO_HEADER_REG_c		=>
					GPIO_HDR1_REG_o		<= Data_in_s(11 downto 1);
				when GPIO_3V3_REG_c			=>
					GPIO_3V3_REG_o			<= Data_in_s(4 downto 1);
				-- when GPIO_CPU_REG_c			=>
					-- GPIO_DIFF_REG_o		<= Data_in_s;
				when GPIO_HEADER2_REG_c		=>
					GPIO_HDR2_REG_o 		<= Data_in_s(8 downto 1);
				when TRIS_REG_c				=>
					TRIS_REG_s 				<= Data_in_s(2 downto 1);
				when TRIS_GPIO_HDR1_REG_c	=>
					TRIS_GPIO_HDR1_REG_s <= Data_in_s(11 downto 1);
				when TRIS_GPIO_HDR2_REG_c	=>
					TRIS_GPIO_HDR2_REG_s <= Data_in_s(8 downto 1);
				when SPI_CS_REG_c				=>
					SPI_CS_REG_s 			<= Data_in_s(4 downto 1);			
				when BUZZER_ENCODER_REG_c 	=>
					BUZZER_ENCODER_REG_s(3 downto 1)<= Data_in_s(3 downto 1);					
				when REG_7SEG2_c 				=>
					REG_7SEG2_s 			<= Data_in_s(8 downto 1);
				when REG_7SEG3_c 				=>
					REG_7SEG3_s 			<= Data_in_s(8 downto 1);
				when REDS_CONN_TRIS1_REG_c	=>
					REDS_CONN_TRIS1_REG_s	<= Data_in_s;
				when REDS_CONN_TRIS2_REG_c	=>
					REDS_CONN_TRIS2_REG_s	<= Data_in_s;
				when REDS_CONN_TRIS3_REG_c	=>
					REDS_CONN_TRIS3_REG_s	<= Data_in_s;
				when REDS_CONN_TRIS4_REG_c	=>
					REDS_CONN_TRIS4_REG_s	<= Data_in_s;
				when REDS_CONN_TRIS5_REG_c	=>
					REDS_CONN_TRIS5_REG_s	<= Data_in_s;
				when FMC1_GPIO_LA_REG1_c	=>
					FMC1_GPIO_LA_CTRL_REG1_s	<= Data_in_s;
				when FMC1_GPIO_LA_REG2_c	=>
					FMC1_GPIO_LA_CTRL_REG2_s	<= Data_in_s;
				when FMC1_GPIO_LA_REG3_c	=>
					FMC1_GPIO_LA_CTRL_REG3_s	<= Data_in_s;
				when FMC1_GPIO_LA_REG4_c	=>
					FMC1_GPIO_LA_CTRL_REG4_s	<= Data_in_s;
				when FMC1_TRIS1_REG_c		=>
					FMC1_TRIS1_REG_s		<= Data_in_s;
				when FMC1_TRIS2_REG_c		=>
					FMC1_TRIS2_REG_s		<= Data_in_s;
				when FMC1_TRIS3_REG_c		=>
					FMC1_TRIS3_REG_s		<= Data_in_s;
				when FMC1_TRIS4_REG_c		=>
					FMC1_TRIS4_REG_s		<= Data_in_s;
				when FMC_DEBUG_REG_c		=>
					FMC1_GPIO_LA_CTRL_REG5_s	<= Data_in_s(4 downto 1);
					FMC2_GPIO_LA_CTRL_REG5_s	<= Data_in_s(12 downto 9);
				when FMC2_GPIO_LA_REG1_c	=>
					FMC2_GPIO_LA_CTRL_REG1_s	<= Data_in_s;
				when FMC2_GPIO_LA_REG2_c	=>
					FMC2_GPIO_LA_CTRL_REG2_s	<= Data_in_s;
				when FMC2_GPIO_LA_REG3_c	=>
					FMC2_GPIO_LA_CTRL_REG3_s	<= Data_in_s;
				when FMC2_GPIO_LA_REG4_c	=>
					FMC2_GPIO_LA_CTRL_REG4_s	<= Data_in_s;
				when FMC2_TRIS1_REG_c		=>
					FMC2_TRIS1_REG_s		<= Data_in_s;
				when FMC2_TRIS2_REG_c		=>
					FMC2_TRIS2_REG_s		<= Data_in_s;
				when FMC2_TRIS3_REG_c		=>
					FMC2_TRIS3_REG_s		<= Data_in_s;
				when FMC2_TRIS4_REG_c		=>
					FMC2_TRIS4_REG_s		<= Data_in_s;
				when IRQ_CTL_REG_c		=>
					-- IRQ_clear
					IRQ_CTL_REG_s(0)		<= Data_in_s(1);
				when others			=>	null;			
			end case;
	-- elsif (LCD_start_reset_i = '1') then
			-- LCD_CONTROL_REG_s(11) <= '0';
		end if;
	end if;
		
end process;



-- Lecture synchrone des entrées

process(clk_i, nReset_i)
begin
	if (nReset_i = '0') then
		DIP_SW_REG_s			  		<= (others => '0');
		PUSH_BUT_REG_s(16) 				<= '0';
		UART_CONTROL_REG_s(1) 			<= '0';
		UART_CONTROL_REG_s(3) 			<= '0';
		BUZZER_ENCODER_REG_s(16)		<= '0';
		BUZZER_ENCODER_REG_s(15)		<= '0';
		ENCODER_COUNT_REG_s				<= (others => '0');
		LCD_STATUS_REG_s				<= (others => '0');
		FMC_DEBUG_REG_s(4)				<= '0';
		FMC_DEBUG_REG_s(12)				<= '0';	
		REDS_CONN_STAT_REG1_s			<=  (others => '0');
		REDS_CONN_STAT_REG2_s			<=  (others => '0');
		REDS_CONN_STAT_REG3_s			<=  (others => '0');
		REDS_CONN_STAT_REG4_s			<=  (others => '0');
		REDS_CONN_STAT_REG5_s			<=  (others => '0');
		FMC1_GPIO_LA_STAT_REG1_s		<=  (others => '0');
		FMC1_GPIO_LA_STAT_REG2_s		<=  (others => '0');
		FMC1_GPIO_LA_STAT_REG3_s		<=  (others => '0');
		FMC1_GPIO_LA_STAT_REG4_s		<=  (others => '0');
		FMC1_GPIO_LA_STAT_REG5_s		<=  (others => '0');
		FMC2_GPIO_LA_STAT_REG1_s		<=  (others => '0');
		FMC2_GPIO_LA_STAT_REG2_s		<=  (others => '0');
		FMC2_GPIO_LA_STAT_REG3_s		<=  (others => '0');
		FMC2_GPIO_LA_STAT_REG4_s		<=  (others => '0');
		FMC2_GPIO_LA_STAT_REG5_s		<= 	(others => '0');	
	elsif rising_edge(clk_i) then
		REDS_CONN_STAT_REG1_s			<= REDS_CONN_REG1_i;
		REDS_CONN_STAT_REG2_s			<= REDS_CONN_REG2_i;
		REDS_CONN_STAT_REG3_s			<= REDS_CONN_REG3_i;
		REDS_CONN_STAT_REG4_s			<= REDS_CONN_REG4_i;
		REDS_CONN_STAT_REG5_s			<= REDS_CONN_REG5_i;
		DIP_SW_REG_s			  		<= DIP_i;
		PUSH_BUT_REG_s(8 downto 1) 		<= SW_PB_i;
		-- touch pad
		PUSH_BUT_REG_s(16)				<= PCB_TB_i;
		UART_CONTROL_REG_s(1) 			<= SP6_UART1_RX_i;
		UART_CONTROL_REG_s(3) 			<= SP6_UART1_RTS_i;
		BUZZER_ENCODER_REG_s(16)		<= left_rotation_i;
		BUZZER_ENCODER_REG_s(15)		<= right_rotation_i;
		ENCODER_COUNT_REG_s				<= pulse_counter_i;
		LCD_STATUS_REG_s(8 downto 1)	<= LCD_Return_data_i;
		LCD_STATUS_REG_s(9)				<= LCD_ready_i;
		FMC_DEBUG_REG_s(4)				<= FMC1_PRSNT_i;
		FMC_DEBUG_REG_s(12)				<= FMC2_PRSNT_i;
		FMC1_GPIO_LA_STAT_REG1_s		<= FMC1_GPIO_LA_REG1_i;
		FMC1_GPIO_LA_STAT_REG2_s		<= FMC1_GPIO_LA_REG2_i;
		FMC1_GPIO_LA_STAT_REG3_s		<= FMC1_GPIO_LA_REG3_i;
		FMC1_GPIO_LA_STAT_REG4_s		<= FMC1_GPIO_LA_REG4_i;
		FMC1_GPIO_LA_STAT_REG5_s		<= FMC1_GPIO_LA_REG5_i;
		FMC2_GPIO_LA_STAT_REG1_s		<= FMC2_GPIO_LA_REG1_i;
		FMC2_GPIO_LA_STAT_REG2_s		<= FMC2_GPIO_LA_REG2_i;
		FMC2_GPIO_LA_STAT_REG3_s		<= FMC2_GPIO_LA_REG3_i;
		FMC2_GPIO_LA_STAT_REG4_s		<= FMC2_GPIO_LA_REG4_i;
		FMC2_GPIO_LA_STAT_REG5_s		<= FMC2_GPIO_LA_REG5_i;
		
	end if;
end process;

-- registers bits not used
	PUSH_BUT_REG_s(14 downto 9)		<= (others => '0');
	BUZZER_ENCODER_REG_s(14 downto 4) <= (others => '0');
	FMC_DEBUG_REG_s(15 downto 13)	<= (others => '0');	
	FMC_DEBUG_REG_s(7 downto 5)		<= (others => '0');
	
	
-- Read process
process(clk_i, nReset_i)
begin
	if (nReset_i = '0') then
		Data_out_s	<= (others => '0');
	elsif rising_edge(clk_i) then
	    if read_en_s = '1' then
			Data_out_s	<= (others => '0');
			case Addr_s is
				when REDS_CONN_REG1_c		=>
					Data_out_s <= REDS_CONN_STAT_REG1_s;
				when REDS_CONN_REG2_c		=>
					Data_out_s <= REDS_CONN_STAT_REG2_s;
				when REDS_CONN_REG3_c		=>
					Data_out_s <= REDS_CONN_STAT_REG3_s;
				when REDS_CONN_REG4_c		=>
					Data_out_s <= REDS_CONN_STAT_REG4_s;
				when REDS_CONN_REG5_c		=>
					Data_out_s <= REDS_CONN_STAT_REG5_s;
				when DIP_SW_REG_c				=>
					Data_out_s <= "000000" & DIP_SW_REG_s;
				when PUSH_BUT_REG_c			=>
					Data_out_s <= PUSH_BUT_REG_s;
				when LED_REG_c				=>
					Data_out_s <= "0000000000" & LED_REG_s;
				when UART_CONTROL_REG_c		=>
					Data_out_s <= "000000000000" & UART_CONTROL_REG_s;					
				when AD_DA_CONTROL_REG_c	=>
					Data_out_s <= "000000000" & AD_DA_CONTROL_REG_s & '0';
				when GPIO_HEADER_REG_c		=>
					Data_out_s <= "00000" & GPIO_HDR1_REG_i;
				when GPIO_3V3_REG_c			=>
					Data_out_s <= "000000000000" & GPIO_3V3_REG_i;
				--when GPIO_CPU_REG_c			=>
					--Data_out_s <= GPIO_DIFF_REG_i;
				when GPIO_HEADER2_REG_c		=>
					Data_out_s <= "00000000" & GPIO_HDR2_REG_i;
				when TRIS_REG_c				=>
					Data_out_s <= "00000000000000" & TRIS_REG_s;
				when TRIS_GPIO_HDR1_REG_c	=>
					Data_out_s <= "00000" & TRIS_GPIO_HDR1_REG_s;
				when TRIS_GPIO_HDR2_REG_c	=>
					Data_out_s <= "00000000" & TRIS_GPIO_HDR2_REG_s;
				when BUZZER_ENCODER_REG_c 	=>
					Data_out_s <= BUZZER_ENCODER_REG_s;
					Data_out_s <= BUZZER_ENCODER_REG_s;
				when ENCODER_COUNT_REG_c 	=>
					Data_out_s <= ENCODER_COUNT_REG_s;
				when LCD_STATUS_REG_c 		=>
					Data_out_s <= "0000000" & LCD_STATUS_REG_s;
	            when REDS_CONN_TRIS1_REG_c      =>
                    Data_out_s <= REDS_CONN_TRIS1_REG_s;
                when REDS_CONN_TRIS2_REG_c      =>
                    Data_out_s <= REDS_CONN_TRIS2_REG_s;
                when REDS_CONN_TRIS3_REG_c      =>
                    Data_out_s <= REDS_CONN_TRIS3_REG_s;
                when REDS_CONN_TRIS4_REG_c      =>
                    Data_out_s <= REDS_CONN_TRIS4_REG_s;
                when REDS_CONN_TRIS5_REG_c      =>
                    Data_out_s <= REDS_CONN_TRIS5_REG_s;
				when FMC1_GPIO_LA_REG1_c	=>
					Data_out_s <= FMC1_GPIO_LA_STAT_REG1_s;		
				when FMC1_GPIO_LA_REG2_c	=>    
					Data_out_s <= FMC1_GPIO_LA_STAT_REG2_s;		
				when FMC1_GPIO_LA_REG3_c	=>    
					Data_out_s <= FMC1_GPIO_LA_STAT_REG3_s;		
				when FMC1_GPIO_LA_REG4_c	=>   
					Data_out_s <= FMC1_GPIO_LA_STAT_REG4_s;		
				when FMC1_TRIS1_REG_c		=>
					Data_out_s <= FMC1_TRIS1_REG_s;		
				when FMC1_TRIS2_REG_c		=>
					Data_out_s <= FMC1_TRIS2_REG_s;		
				when FMC1_TRIS3_REG_c		=>  
					Data_out_s <= FMC1_TRIS3_REG_s;		
				when FMC1_TRIS4_REG_c		=>  
					Data_out_s <= FMC1_TRIS4_REG_s;		
				when FMC_DEBUG_REG_c		=>  
					Data_out_s <= "000" & FMC_DEBUG_REG_s(12) & FMC2_GPIO_LA_STAT_REG5_s & "000" & FMC_DEBUG_REG_s(4) & FMC1_GPIO_LA_STAT_REG5_s;	
				when FMC2_GPIO_LA_REG1_c	=>
					Data_out_s <= FMC2_GPIO_LA_STAT_REG1_s;		
				when FMC2_GPIO_LA_REG2_c	=>    
					Data_out_s <= FMC2_GPIO_LA_STAT_REG2_s;		
				when FMC2_GPIO_LA_REG3_c	=>    
					Data_out_s <= FMC2_GPIO_LA_STAT_REG3_s;		
				when FMC2_GPIO_LA_REG4_c	=>   
					Data_out_s <= FMC2_GPIO_LA_STAT_REG4_s;		
				when FMC2_TRIS1_REG_c		=>
					Data_out_s <= FMC2_TRIS1_REG_s;		
				when FMC2_TRIS2_REG_c		=>
					Data_out_s <= FMC2_TRIS2_REG_s;		
				when FMC2_TRIS3_REG_c		=>  
					Data_out_s <= FMC2_TRIS3_REG_s;		
				when FMC2_TRIS4_REG_c		=>  
					Data_out_s <= FMC2_TRIS4_REG_s;	
				when IRQ_CTL_REG_c			=>  
					Data_out_s <= IRQ_CTL_REG_s;					
				when others						=>
					Data_out_s <= (others => '0');
			end case;
		end if;
						
	end if;
end process;

-- Ecriture synchrone sur les sorties
process(clk_i, nReset_i)
begin
	if (nReset_i = '0') then
		REDS_CONN_REG1_o			<= (others => '0');
		REDS_CONN_REG2_o			<= (others => '0');
		REDS_CONN_REG3_o			<= (others => '0');
		REDS_CONN_REG4_o			<= (others => '0');
		REDS_CONN_REG5_o			<= (others => '0');
		PCB_TB_en_o					<= '0';
		FPGA_LED_o(6 downto 1)		<= (others => '1');
		SP6_7seg1_o 				<= (others => '1');
		SP6_7seg1_DP_o 				<= '1';
		SP6_7seg2_o 				<= (others => '1');
		SP6_7seg2_DP_o 				<= '1';
		SP6_7seg3_o 				<= (others => '1');
		SP6_7seg3_DP_o 				<= '1';
		LCD_cmd_o					<= (others => '0');
		LCD_RS_o			        <= '1';
		LCD_RW_o			        <= '0';
		LCD_start_cmd_o       		<= '0';
		SP6_UART1_TX_o 				<= '0';
		SP6_UART1_CTS_o 		  	<= '0';
		AD_GPIO_io					<= (others => '0');
		DAC_nLDAC_o					<= '1';
		DAC_nRS_o  					<= '0';
		GPIO_3V3_TRIS_o 			<= '0';
		--GPIO_DIFF_TRIS_o 			<= '0';
		GPIO_HDR1_TRIS_o			<= (others => '0');
		GPIO_HDR2_TRIS_o			<= (others => '0');
		SPI_nCS1_o					<= '1';
		SPI_nCS2_o					<= '1';
		SPI_nCS_AD_o				<= '1';
		SPI_nCS_DA_o				<= '1';
		buzzer_en_o					<= '0';
		fast_mode_o           		<= '0';
		slow_mode_o           		<= '0';
		REDS_CONN_TRIS1_o			<= (others => '0');
		REDS_CONN_TRIS2_o			<= (others => '0');
		REDS_CONN_TRIS3_o			<= (others => '0');
		REDS_CONN_TRIS4_o			<= (others => '0');
		REDS_CONN_TRIS5_o			<= (others => '0');
		FMC1_GPIO_LA_REG1_o			<= (others => '0');
		FMC1_GPIO_LA_REG2_o			<= (others => '0');
		FMC1_GPIO_LA_REG3_o			<= (others => '0');
		FMC1_GPIO_LA_REG4_o			<= (others => '0');
		FMC1_GPIO_LA_REG5_o			<= (others => '0');
		FMC1_TRIS1_REG_o	    	<= (others => '0');
		FMC1_TRIS2_REG_o	    	<= (others => '0');
		FMC1_TRIS3_REG_o	    	<= (others => '0');
		FMC1_TRIS4_REG_o	    	<= (others => '0');
		FMC2_GPIO_LA_REG1_o			<= (others => '0');
		FMC2_GPIO_LA_REG2_o			<= (others => '0');
		FMC2_GPIO_LA_REG3_o			<= (others => '0');
		FMC2_GPIO_LA_REG4_o			<= (others => '0');
		FMC2_GPIO_LA_REG5_o			<= (others => '0');
		FMC2_TRIS1_REG_o	    	<= (others => '0');
		FMC2_TRIS2_REG_o	    	<= (others => '0');
		FMC2_TRIS3_REG_o	    	<= (others => '0');
		FMC2_TRIS4_REG_o			<= (others => '0');
		IRQ_o					<= '0';
		
	elsif rising_edge(clk_i) then
		REDS_CONN_REG1_o			<= REDS_CONN_CTRL_REG1_s;
		REDS_CONN_REG2_o			<= REDS_CONN_CTRL_REG2_s;
		REDS_CONN_REG3_o			<= REDS_CONN_CTRL_REG3_s;
		REDS_CONN_REG4_o			<= REDS_CONN_CTRL_REG4_s;
		REDS_CONN_REG5_o			<= REDS_CONN_CTRL_REG5_s;
		PCB_TB_en_o					<= PUSH_BUT_REG_s(15);
		FPGA_LED_o					<= not LED_REG_s;
		SP6_7seg1_o 				<= not(REG_7SEG1_s(7 downto 1));
		SP6_7seg1_DP_o 				<= not(REG_7SEG1_s(8));
		SP6_7seg2_o 				<= not(REG_7SEG2_s(7 downto 1));
		SP6_7seg2_DP_o 				<= not(REG_7SEG2_s(8));
		SP6_7seg3_o 				<= not(REG_7SEG3_s(7 downto 1));
		SP6_7seg3_DP_o 				<= not(REG_7SEG3_s(8));
		LCD_cmd_o					<= LCD_CONTROL_REG_s(8 downto 1);		
		LCD_RS_o			        <= LCD_CONTROL_REG_s(10);
		LCD_RW_o			        <= LCD_CONTROL_REG_s(9);
		LCD_start_cmd_o       		<= LCD_CONTROL_REG_s(11);
		SP6_UART1_TX_o 				<= UART_CONTROL_REG_s(2);
		SP6_UART1_CTS_o 		  	<= UART_CONTROL_REG_s(4);
		AD_GPIO_io					<= AD_DA_CONTROL_REG_s(5 downto 2);
		DAC_nLDAC_o					<= AD_DA_CONTROL_REG_s(7);
		DAC_nRS_o  					<= AD_DA_CONTROL_REG_s(6);
		GPIO_3V3_TRIS_o 			<= TRIS_REG_s(1);	
		--GPIO_DIFF_TRIS_o 			<= TRIS_REG_s(2);
		GPIO_HDR1_TRIS_o			<= TRIS_GPIO_HDR1_REG_s(11 downto 1);
		GPIO_HDR2_TRIS_o			<= TRIS_GPIO_HDR2_REG_s(8 downto 1);
		SPI_nCS1_o					<= not SPI_CS_REG_s(1);
		SPI_nCS2_o					<= not SPI_CS_REG_s(2);
		SPI_nCS_AD_o				<= not SPI_CS_REG_s(3);
		SPI_nCS_DA_o				<= not SPI_CS_REG_s(4);
		buzzer_en_o					<= BUZZER_ENCODER_REG_s(1);
		fast_mode_o           		<= BUZZER_ENCODER_REG_s(2);
		slow_mode_o           		<= BUZZER_ENCODER_REG_s(3);
		REDS_CONN_TRIS1_o			<= REDS_CONN_TRIS1_REG_s;
		REDS_CONN_TRIS2_o			<= REDS_CONN_TRIS2_REG_s;
		REDS_CONN_TRIS3_o			<= REDS_CONN_TRIS3_REG_s;
		REDS_CONN_TRIS4_o			<= REDS_CONN_TRIS4_REG_s;
		REDS_CONN_TRIS5_o			<= REDS_CONN_TRIS5_REG_s;
		FMC1_GPIO_LA_REG1_o			<= FMC1_GPIO_LA_CTRL_REG1_s;
		FMC1_GPIO_LA_REG2_o			<= FMC1_GPIO_LA_CTRL_REG2_s;
		FMC1_GPIO_LA_REG3_o			<= FMC1_GPIO_LA_CTRL_REG3_s;
		FMC1_GPIO_LA_REG4_o			<= FMC1_GPIO_LA_CTRL_REG4_s;
		FMC1_GPIO_LA_REG5_o			<= FMC1_GPIO_LA_CTRL_REG5_s;		
		FMC1_TRIS1_REG_o	    	<= FMC1_TRIS1_REG_s;	
		FMC1_TRIS2_REG_o	    	<= FMC1_TRIS2_REG_s;	
		FMC1_TRIS3_REG_o	    	<= FMC1_TRIS3_REG_s;	
		FMC1_TRIS4_REG_o	    	<= FMC1_TRIS4_REG_s;
		FMC2_GPIO_LA_REG1_o			<= FMC2_GPIO_LA_CTRL_REG1_s;
        FMC2_GPIO_LA_REG2_o			<= FMC2_GPIO_LA_CTRL_REG2_s;
        FMC2_GPIO_LA_REG3_o			<= FMC2_GPIO_LA_CTRL_REG3_s;
        FMC2_GPIO_LA_REG4_o			<= FMC2_GPIO_LA_CTRL_REG4_s;
		FMC2_GPIO_LA_REG5_o			<= FMC2_GPIO_LA_CTRL_REG5_s;	
		FMC2_TRIS1_REG_o	    	<= FMC2_TRIS1_REG_s;	
		FMC2_TRIS2_REG_o	    	<= FMC2_TRIS2_REG_s;	
		FMC2_TRIS3_REG_o	    	<= FMC2_TRIS3_REG_s;	
		FMC2_TRIS4_REG_o	    	<= FMC2_TRIS4_REG_s;
-- IRQ generation on a button pressure (SW_PB_i)
		IRQ_o				<= IRQ_STATUS_s;
	end if;
end process;

-- LCD start bit --------------------------------------------------------------------------------------------------------
FSM_start_LCD: process(p_state_s, write_en_s, Addr_s, LCD_start_reset_i)
begin
  -- state 0: init
  if (p_state_s = '0') then
    -- output decoder
    LCD_CONTROL_REG_s(11) <= '0';
	-- futur state decoder
	if (write_en_s = '1' and Addr_s = LCD_CONTROL_REG_c) then
	  -- go to next state
      f_state_s <= '1';
	else
	  -- stay in the same state
	  f_state_s <= '0';
	end if;
  -- state 1
  elsif (p_state_s = '1') then
    -- output decoder
    LCD_CONTROL_REG_s(11) <= '1';
	-- futur state decoder
	if (LCD_start_reset_i = '1') then
	  -- go to init state
      f_state_s <= '0';
	else
	  -- stay in the same state
	  f_state_s <= '1';
	end if;
  else
  -- default
    LCD_CONTROL_REG_s(11) <= '0';
	f_state_s <= '0';
  end if;
end process;

FSM_LCD_mem: process(clk_i, nReset_i)
begin
	if (nReset_i = '0') then
		p_state_s <= '0';
	elsif rising_edge(clk_i) then
		p_state_s <= f_state_s;
	end if;
end process FSM_LCD_mem;
-------------------------------------------------------------------------------------------------------------------------
  

-- IRQ generation on a button pressure (SW_PB_i) 
-- registers
push_but_reg1: process(clk_i, nReset_i)
begin
	if (nReset_i = '0') then
		PUSH_BUT_REG1_s <= (others => '0');
	elsif rising_edge(clk_i) then
		PUSH_BUT_REG1_s <=  PUSH_BUT_REG_s(8 downto 1);
	end if;
end process push_but_reg1;

push_but_reg2: process(clk_i, nReset_i)
begin
	if (nReset_i = '0') then
		PUSH_BUT_REG2_s <= (others => '0');
	elsif rising_edge(clk_i) then
		PUSH_BUT_REG2_s <=  PUSH_BUT_REG1_s;
	end if;
end process push_but_reg2;

push_but_reg3: process(clk_i, nReset_i)
begin
	if (nReset_i = '0') then
		PUSH_BUT_REG3_s <= (others => '0');
	elsif rising_edge(clk_i) then
		PUSH_BUT_REG3_s <=  PUSH_BUT_REG2_s;
	end if;
end process push_but_reg3;

-- button pressure event detection

-- IRQ_event_s signal is set to '1' while a button is hold pressed and is reset to '0' when the button is released
 IRQ_event_s	<= '1' when IRQ_PRESS_BUT_s > "000" or (PUSH_BUT_REG1_s(0)='1' and PUSH_BUT_REG2_s(0)='1' and PUSH_BUT_REG3_s(0)='1') else '0';
 
 IRQ_PRESS_BUT_s <= "000" when PUSH_BUT_REG1_s(0)='1' and PUSH_BUT_REG2_s(0)='1' and PUSH_BUT_REG3_s(0)='1' else
					"001" when PUSH_BUT_REG1_s(1)='1' and PUSH_BUT_REG2_s(1)='1' and PUSH_BUT_REG3_s(1)='1' else
					"010" when PUSH_BUT_REG1_s(2)='1' and PUSH_BUT_REG2_s(2)='1' and PUSH_BUT_REG3_s(2)='1' else
					"011" when PUSH_BUT_REG1_s(3)='1' and PUSH_BUT_REG2_s(3)='1' and PUSH_BUT_REG3_s(3)='1' else
					"100" when PUSH_BUT_REG1_s(4)='1' and PUSH_BUT_REG2_s(4)='1' and PUSH_BUT_REG3_s(4)='1' else
					"101" when PUSH_BUT_REG1_s(5)='1' and PUSH_BUT_REG2_s(5)='1' and PUSH_BUT_REG3_s(5)='1' else
					"110" when PUSH_BUT_REG1_s(6)='1' and PUSH_BUT_REG2_s(6)='1' and PUSH_BUT_REG3_s(6)='1' else
					"111" when PUSH_BUT_REG1_s(7)='1' and PUSH_BUT_REG2_s(7)='1' and PUSH_BUT_REG3_s(7)='1' else
					"000";
 
 -- register event and button number
 
 process(clk_i, nReset_i)
begin
	if (nReset_i = '0') then
		IRQ_STATUS_s <= '0';
		IRQ_BUTTON_s <= (others => '0');
	elsif rising_edge(clk_i) then
		if IRQ_event_s = '1' then
			IRQ_STATUS_s <= '1';
			IRQ_BUTTON_s <= IRQ_PRESS_BUT_s;
		elsif IRQ_CTL_REG_s(0) = '1' then
			IRQ_STATUS_s <= '0';
			IRQ_BUTTON_s <= IRQ_BUTTON_s;
		end if;
	end if;
end process;

-- write to the IRQ_CTL_REG
 IRQ_CTL_REG_s(3 downto 1) 	<= IRQ_BUTTON_s;
 IRQ_CTL_REG_s(4)			<= IRQ_STATUS_s;
 IRQ_CTL_REG_s(15 downto 5) <= (others => '0');	



end Behavioral;