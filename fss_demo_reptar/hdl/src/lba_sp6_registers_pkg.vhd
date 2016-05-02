 ------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : lba_sp6_registers_pkg.vhd
-- Author               : Evangelina Lolivier-Exler
-- Date                 : 24.10.2013
-- Target Devices       : Spartan6 xc6slx150t-3fgg900
--
-- Context              : Reptar - FPGA design
--
---------------------------------------------------------------------------------------------
-- Description : constants defining the  registers offset adresses of INTERNAL LAYOUT V2 on SP6
---------------------------------------------------------------------------------------------
-- Information : The registers functionnalities are described in the document 
--				Spartan6_registers.xlsx, tab "Summary_Layout_v2_prop"
---------------------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Engineer     Comments
-- 0.0   See header  ELR          Initial version
---------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

package lba_sp6_registers_pkg is

-- version																						 -- CPU byte offset
	constant	VERSION1_REG_ADD_c		  		: std_logic_vector(15 downto 0) := x"00_00"; --0x0000 RW
	constant	VERSION2_REG_ADD_c		  		: std_logic_vector(15 downto 0) := x"00_01"; --0x0002 RW
-- test
	constant	CONSTANT_REG_ADD_c		  		: std_logic_vector(15 downto 0) := x"00_02"; --0x0004 R
-- peripherals descriptor address                              
	constant	PERIPHERAL_DESCRIPTOR_H_ADD_c		: std_logic_vector(15 downto 0) := x"00_04"; --0x0008 RW
	constant	PERIPHERAL_DESCRIPTOR_L_ADD_c		: std_logic_vector(15 downto 0) := x"00_05"; --0x000A RW
	constant	SCRATCH1_REG_ADD_c			  		: std_logic_vector(15 downto 0) := x"00_06"; --0x000C R
	constant	SCRATCH2_REG_ADD_c				  	: std_logic_vector(15 downto 0) := x"00_07"; --0x000E RW
-- input                                    		                   
	constant	DIP_SW_REG_ADD_c		  			: std_logic_vector(15 downto 0) := x"00_08"; --0x0010 R
	constant	PUSH_BUT_REG_ADD_c		  			: std_logic_vector(15 downto 0) := x"00_09"; --0x0012 RW
	constant	ENCODER_DIRECTION_REG_ADD_c			: std_logic_vector(15 downto 0) := x"00_0A"; --0x0014 R
	constant	ENCODER_COUNT_REG_ADD_c				: std_logic_vector(15 downto 0) := x"00_0B"; --0x0016 R
	constant	IRQ_CTL_REG_ADD_c		  			: std_logic_vector(15 downto 0) := x"00_0C"; --0x0018 RW
-- output
	constant	DISP_7SEG1_REG_ADD_c	  			: std_logic_vector(15 downto 0) := x"00_18"; --0x0030 RW                        
	constant	DISP_7SEG2_REG_ADD_c	  			: std_logic_vector(15 downto 0) := x"00_19"; --0x0032 RW
	constant	DISP_7SEG3_REG_ADD_c  				: std_logic_vector(15 downto 0) := x"00_1A"; --0x0034 RW
	constant	LCD_CONTROL_REG_ADD_c	    		: std_logic_vector(15 downto 0) := x"00_1B"; --0x0036 W
	constant	LCD_STATUS_REG_ADD_c  				: std_logic_vector(15 downto 0) := x"00_1C"; --0x0038 R
	constant	LED_REG_ADD_c		  				: std_logic_vector(15 downto 0) := x"00_1D"; --0x003A RW
	constant	BUZZER_REG_ADD_c		    		: std_logic_vector(15 downto 0) := x"00_1E"; --0x003C RW
-- GPIOs			
	constant	GPIO_X_REG_ADD_c	  				: std_logic_vector(15 downto 0) := x"00_28"; --0x0050 RW
	constant	GPIO_X_OE_REG_ADD_c	  				: std_logic_vector(15 downto 0) := x"00_29"; --0x0052 RW
	constant	GPIO_H_REG_ADD_c		  			: std_logic_vector(15 downto 0) := x"00_2A"; --0x0054 RW                                                       
	constant	GPIO_H_OE_REG_ADD_c				   	: std_logic_vector(15 downto 0) := x"00_2B"; --0x0056 RW
	constant	GPIO_3V3_REG_ADD_c				    : std_logic_vector(15 downto 0) := x"00_2C"; --0x0058 RW
	constant	GPIO_3V3_OE_REG_ADD_c 				: std_logic_vector(15 downto 0) := x"00_2D"; --0x005A RW
-- peripheral devices			
	constant	UART_CONTROL_REG_ADD_c 				: std_logic_vector(15 downto 0) := x"00_38"; --0x0070 RW
	constant	AD_GPIO_REG_ADD_c 					: std_logic_vector(15 downto 0) := x"00_39"; --0x0072 RW
	constant	DA_CONTROL_REG_ADD_c 				: std_logic_vector(15 downto 0) := x"00_3A"; --0x0074 W
	constant	SPI_CS_REG_ADD_c					: std_logic_vector(15 downto 0) := x"00_3B"; --0x0076 RW
-- DKK 80-p connector (REDS connector)      		                                   
	constant	REDS_CONN1_REG_ADD_c				: std_logic_vector(15 downto 0) := x"00_80"; --0x0100  RW
	constant	REDS_CONN2_REG_ADD_c				: std_logic_vector(15 downto 0) := x"00_81"; --0x0102  RW
	constant	REDS_CONN3_REG_ADD_c				: std_logic_vector(15 downto 0) := x"00_82"; --0x0104  RW
	constant	REDS_CONN4_REG_ADD_c				: std_logic_vector(15 downto 0) := x"00_83"; --0x0106  RW
	constant	REDS_CONN5_REG_ADD_c				: std_logic_vector(15 downto 0) := x"00_84"; --0x0108  RW
	constant	REDS_CONN1_OE_REG_ADD_c				: std_logic_vector(15 downto 0) := x"00_85"; --0x010A  RW
	constant	REDS_CONN2_OE_REG_ADD_c				: std_logic_vector(15 downto 0) := x"00_86"; --0x010C  RW                    
	constant	REDS_CONN3_OE_REG_ADD_c				: std_logic_vector(15 downto 0) := x"00_87"; --0x010E  RW
	constant	REDS_CONN4_OE_REG_ADD_c				: std_logic_vector(15 downto 0) := x"00_88"; --0x0110  RW
	constant	REDS_CONN5_OE_REG_ADD_c				: std_logic_vector(15 downto 0) := x"00_89"; --0x0112  RW
-- FMC1 connector	
	constant	FMC1_GPIO1_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_00"; --0x0200  RW
	constant	FMC1_GPIO2_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_01"; --0x0202  RW
	constant	FMC1_GPIO3_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_02"; --0x0204  RW
	constant	FMC1_GPIO4_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_03"; --0x0206  RW
	constant	FMC1_GPIO5_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_04"; --0x0208  RW
	constant	FMC1_GPIO1_OE_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_05"; --0x020A  RW
	constant	FMC1_GPIO2_OE_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_06"; --0x020C  RW
	constant	FMC1_GPIO3_OE_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_07"; --0x020E  RW
	constant	FMC1_GPIO4_OE_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_08"; --0x0210  RW
	constant	FMC1_GPIO5_OE_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_09"; --0x0212  RW	
-- FMC2 connector		
	constant	FMC2_GPIO1_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_80"; --0x0300  RW
	constant	FMC2_GPIO2_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_81"; --0x0302  RW
	constant	FMC2_GPIO3_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_82"; --0x0304  RW
	constant	FMC2_GPIO4_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_83"; --0x0306  RW
	constant	FMC2_GPIO5_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_84"; --0x0308  RW
	constant	FMC2_GPIO1_OE_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_85"; --0x030A  RW
	constant	FMC2_GPIO2_OE_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_86"; --0x030C  RW
	constant	FMC2_GPIO3_OE_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_87"; --0x030E  RW
	constant	FMC2_GPIO4_OE_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_88"; --0x0310  RW
	constant	FMC2_GPIO5_OE_REG_ADD_c				: std_logic_vector(15 downto 0) := x"01_89"; --0x0312  RW	
    
    
-- Spartan 6 Versioning
-- versionning VERSION1_REG
    constant HW_version_c           : std_logic_vector (3 downto 0):= "0001"; -- 0000 proto2, 0001 series1
    constant ID_FPGA_c              : std_logic_vector (2 downto 0):= "001"; -- 000 Spartan3, 001 Spartan6
    constant ID_design_FPGA_c       : std_logic_vector (8 downto 0):= "000000000"; 

-- versionning VERSION2_REG
    constant ID_SUB_DESIGN_c         : std_logic_vector (7 downto 0):= "00000000"; 
    constant VERSION_NUMBER_c        : std_logic_vector (7 downto 0):= "00000000";
    
-- switch debouncing constants
-- CONSTANT TIMER_1MILISECOND_C : std_logic_vector(19 downto 0):= x"30D40";  -- 200'000 *5ns;    
CONSTANT TIMER_1MILISECOND_C : std_logic_vector(19 downto 0):= x"00001";  -- 1 *5ns; for simulation
    
end lba_sp6_registers_pkg;
	
package body lba_sp6_registers_pkg is
end lba_sp6_registers_pkg;