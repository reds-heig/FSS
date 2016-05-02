------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : Spartan6_Top.vhd
-- Author               : Vincent Theurillat
-- Date                 : 06.02.2012
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
-- 0.0   See header   VTT           Initial version
-- 0.1	12.12.2012	  ELR			adaptation for serial version boards
-- 0.2  18.02.2013    HTG		    new touch pad controller
-- 0.3  05.03.2013	  ELR			added enable to touch pad controller
-- 0.4  04.04.2013    ELR			iobuf for LB added on the top
-- 0.5  09.04.2013    ELR			Replaced Clk_pll by Clk_PLL_200 (output 200MHz instead 300MHz)
--									SPI data output bug fix: multiple drivers
--									FMC instantiation warning suppression: not aggregate
-- 0.6  18.04.2013    ELR	                Moved tri-state from LCD component to the top
-- 0.7  29.04.2013    ELR                       added IRQ generation on SP6_GPIO18_1 = GPIO_10 of the CPU
-- 0.8 	30.04.2013 	  CMR 			Added interface gpmc-ddr
-- 0.9  10.07.2013    ELR			Timing errors fix
----------------------------------------------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_ARITH.ALL;	-- synopsys
--USE IEEE.STD_LOGIC_UNSIGNED.ALL; -- synopsys
Library UNISIM;
use UNISIM.vcomponents.all;
use work.touch_pad_controller_pkg.all;
use work.mcb_ddr2_pkg.all;

entity Spartan6_Top is
	port(	
			-- CLOCK
			SP6_Clk_100MHz_i		:		in std_logic;
			CLK_25MHz_SP6_i			:		in std_logic;			
			-- LOCAL BUS
			SP6_LB_RE_nOE_i			:		in std_logic;
			SP6_LB_nWE_i			  :		in std_logic;
			SP6_LB_WAIT3_o			:		out std_logic;
			SP6_LB_nCS3_i			  :		in std_logic;
			SP6_LB_nCS4_i			  :		in std_logic;
			SP6_LB_nADV_ALE_i		:		in std_logic;
			SP6_LB_nBE0_CLE_i		:		in std_logic;
			SP6_LB_WAIT0_o			:		out std_logic;
			SP6_LB_CLK_i			  :		in std_logic;
			Addr_Data_LB_io			:		inout std_logic_vector(15 downto 0);
			Addr_LB_i				    :		in std_logic_vector(24 downto 16);	
			--7SEG
			SP6_7seg1_o				  :		out std_logic_vector(6 downto 0);
			SP6_7seg2_o				  :		out std_logic_vector(6 downto 0);
			SP6_7seg3_o				  :		out std_logic_vector(6 downto 0);
			SP6_7seg1_DP_o			:		out std_logic;
			SP6_7seg2_DP_o			:		out std_logic;
			SP6_7seg3_DP_o			:		out std_logic;			
			-- SWITCH PB
			SW_PB_i					    :		in std_logic_vector(8 downto 1);			
			-- MICTOR
			MICTOR_SP6_A0_o		:		out std_logic_vector(7 downto 0);
			MICTOR_SP6_A1_o		:		out std_logic_vector(7 downto 0);
			MICTOR_SP6_A2_o		:		out std_logic_vector(7 downto 0);
			MICTOR_SP6_A3_o		:		out std_logic_vector(7 downto 0);
			MICTOR_SP6_CLK_0_o	:		out std_logic;
			MICTOR_SP6_CLK_1_o	:		out std_logic;			
			--GPIOs (diffs, called gpio_1_n/p - gpio_5_n/p on schematics):
				-- gpio_1_n, 1_p, 2_n, 2_p and 3_p , used for sp6 configuration from sp3, 
				-- gpio_3_n et 4_p connected to leds on CPU board, 
				-- gpio_4_n, 5_p and 5_n connected to switches on CPU board
			SP6_GPIO_DIFFS_i  : in std_logic_vector(9 downto 0);		
			                    
			--Conn REDS 80p
			SP6_DKK_io				  :		inout std_logic_vector(80 downto 1);		
			--I2C: to FMC boards
			I2C_SCL_1V8_o			:		out std_logic;
			I2C_SDA_1V8_o			:		out std_logic;
			SP6_I2C_SCL_i		  :		in std_logic;
			SP6_I2C_SDA_i		  :		in std_logic;
			--SPI
				-- cs2: to w3 connector
			SP6_SPI_nCS2_o			:		out std_logic;
				-- cs3: from cpu
			SP6_SPI_nCS3_i			:		in std_logic;
				-- cs4: to BTB connector, not connected to CPU!, reserved for futur version of cpu boards with more spi cs outputs
			SP6_SPI_nCS4_i			:		in std_logic;
				-- from cpu
			SP6_SPI_SDO_i			  :		in std_logic;
			SP6_SPI_SDI_o			  :		out std_logic;
			SP6_SPI_SCLK_i			:		in std_logic;
				-- accelerometer interrupts
			SP6_ACC_INT1_i			:		in std_logic;
			SP6_ACC_INT2_i			:		in std_logic;
				-- accelerometer SPI
			SP6_SPI_nCS1_o 	   		:	out std_logic;
			SP6_ACC_SPI_SDI_o    	:	out std_logic;
			SP6_ACC_SPI_SCL_o    	:	out std_logic;
			SP6_ACC_SPI_SDO_i		: 	in std_logic;
			--FTDI
			FTDI_TX_i				  :		in std_logic;
			FTDI_RX_o				  :		out std_logic;
			FTDI_nRESET_o			  :		out std_logic;
			-- FTDI_nRTS_i input, not tested!!
			FTDI_nRTS_i                :    in  std_logic;
			FTDI_nCTS_o                :	out std_logic;
			--FMC1	
			FMC1_PRSNT_M2C_L_i			: in  std_logic;
			FMC1_LA_P_io				: inout std_logic_vector(33 downto 0);
			FMC1_LA_N_io				: inout std_logic_vector(33 downto 0);
			FMC1_CLK1_M2C_P_i			: in std_logic;		-- FMC1_CLK0_C2M_P dans schéma
			FMC1_CLK1_M2C_N_i			: in std_logic;
			FMC1_CLK0_M2C_P_i			: in std_logic;
			FMC1_CLK0_M2C_N_i			: in std_logic;
			--FMC2
			FMC2_PRSNT_M2C_L_i			: in  std_logic;
			FMC2_LA_P_io				: inout std_logic_vector(33 downto 0);
			FMC2_LA_N_io				: inout std_logic_vector(33 downto 0);
			FMC2_CLK1_M2C_P_i			: in std_logic;		-- FMC2_CLK0_C2M_P dans schéma
			FMC2_CLK1_M2C_N_i			: in std_logic;
			FMC2_CLK0_M2C_P_i			: in std_logic;
			FMC2_CLK0_M2C_N_i			: in std_logic;			
			--GPIO connected to the BTB but not connected to the CPU, not used (3.3V)
			SP6_GPIO_22_i			:		in std_logic;
			--AD
			AD_GPIO_o				  :		out std_logic_vector(3 downto 0);
			AD_SDI_o				    :		out std_logic;
			AD_nCS_o				    :		out std_logic;
			AD_CLK_o				    :		out std_logic;
			AD_SDO_i				    :		in std_logic;
			--GPIOs: connector labeled "GPIO_x" on the board silkscreen
			SP6_GPIO_io				:		inout std_logic_vector(11 downto 1);
			--DIPs
			-- modified 16.10.2013 ELR: 9..0 instead of 10..1
			DIP_i					:		in std_logic_vector(9 downto 0);
			--LEDs
			FPGA_LED_o				:		out std_logic_vector(7 downto 0);
				
			--Encoder
			Inc_Enc_A_i				:		in std_logic;
			Inc_Enc_B_i				:		in std_logic;
			--Digital audio
			Digital_Audio_TX_o		:		out std_logic;
			Digital_Audio_RX_i		:		in std_logic;
			--PCI PERST, not tested!!
			PCI_PERST_o			:		out std_logic;
			--CAN, not tested!!
			CAN_RXD_i				:		in std_logic;
			CAN_TXD_o				:		out std_logic;
			--GPIOs 1V8 -> connected between FPGA and CPU 
			-- SP6_GPIO18_1_o: SYS_CLKOUT1 from CPU (can be used as GPIO), not tested!!
			-- in this version: used as GPIO for IRQ generation when a switch is pressed			
			SP6_GPIO18_1_o			:		out std_logic;
			-- uP_nRESET_OUT_i: (SP6_GPIO18_2 on schematics) nRESET_OUT from CPU
			uP_nRESET_OUT_i			:		in std_logic;
			--GPIOs 3V3: CONNECTED TO BTB AND SP3
			SP6_GPIO33_io			:		inout	std_logic_vector(4 downto 1);
			-- reset from SP6 Config button, resets only the SP6 flip-flops
			SP6_nReset_i        	:   	in std_logic;
			--UART
			SP6_UART1_CTS_o			:		out std_logic;
			SP6_UART1_RTS_i			:		in	std_logic;
			SP6_UART1_RX_i			:		in std_logic;
			SP6_UART1_TX_o			:		out std_logic;
			--DA
			DAC_nRS_o				:		out std_logic;
			DAC_nCS_o				:		out std_logic;
			DAC_nLDAC_o				:		out std_logic;
			DAC_CLK_o				:		out std_logic;
			DAC_SDI_o				:		out std_logic;
			--Buzzer
			Buz_osc_o				:		out std_logic;
			--Touch pad
			PCB_TB_io				:		inout std_logic;
			--GPIOs header: labeled "GPIO_Hx" on the board silkscreen
			SP6_GPIO_H_io			:		inout std_logic_vector(8 downto 1);
			--LCD
			LCD_DB_io				:		inout std_logic_vector(7 downto 0);
			LCD_R_nW_o				:		out std_logic;
			LCD_RS_o				:		out std_logic;
			LCD_E_o					:		out std_logic;
			--DDR2
			DDR2_A_o				:		out std_logic_vector(13 downto 0);
			DDR2_BA_o				:		out std_logic_vector(2 downto 0);
			DDR2_DQ_io				:		inout std_logic_vector(15 downto 0);
			DDR2_CKE_o				:		out std_logic;
			DDR2_WE_o				:		out std_logic;
			DDR2_ODT_o				:		out std_logic;
			DDR2_nRAS_o				:		out std_logic;
			DDR2_nCAS_o				:		out std_logic;
			DDR2_LDM_o				:		out std_logic;
			DDR2_UDM_o				:		out std_logic;
			DDR2_LDQS_P_o 			:		inout std_logic;
			DDR2_LDQS_N_o			:		inout std_logic;
			DDR2_UDQS_P_o			:		inout std_logic;
			DDR2_UDQS_N_o			:		inout std_logic;
			DDR2_CK_P_o  			:		out std_logic;
			DDR2_CK_N_o				:		out std_logic;
			mcb5_rzq             	: 		inout  std_logic;                
			mcb5_zio             	: 		inout  std_logic; 
			-- not used (RFU on the chip: reserved for futur use)
			DDR2_A14_i				: 		in  std_logic

			--SMB
			--PCIe
			--SATA
	);
end Spartan6_Top;
	
architecture Behavioral of Spartan6_Top is

	-- Signaux internes pour le PLL
	signal	CLK_200MHz_s			: 		std_logic;
	signal	PLL_locked_s			:		std_logic;
	signal	nReset_s				:		std_logic;
	signal	Reset_s				:		std_logic;
	signal	CLK_100MHz_s			:		std_logic;
	
	-- Signaux utilis pour les buffers 3State
	signal	REDS_CONN_TRIS1_s		: 		std_logic_vector(16 downto 1);	
	signal   REDS_CONN_TRIS2_s		:		std_logic_vector(16 downto 1);
	signal   REDS_CONN_TRIS3_s		:		std_logic_vector(16 downto 1);
	signal   REDS_CONN_TRIS4_s		:		std_logic_vector(16 downto 1);
	signal   REDS_CONN_TRIS5_s		: 		std_logic_vector(16 downto 1);
	signal   GPIO_HDR1_TRIS_s		:		std_logic_vector(11 downto 1);
	signal   GPIO_HDR2_TRIS_s		:		std_logic_vector(8  downto 1);
	signal   GPIO_3V3_TRIS_s		:		std_logic;
	-- signal   GPIO_DIFF_TRIS_s		:		std_logic;
	
	-- Registres internes I/O du connecteur REDS
	signal 	REDS_CONN_REG1_o_s		:		std_logic_vector(16 downto 1);
	signal 	REDS_CONN_REG2_o_s		:		std_logic_vector(16 downto 1);
	signal 	REDS_CONN_REG3_o_s		:		std_logic_vector(16 downto 1);
	signal 	REDS_CONN_REG4_o_s		:		std_logic_vector(16 downto 1);
	signal 	REDS_CONN_REG5_o_s		:		std_logic_vector(16 downto 1);
	signal 	REDS_CONN_REG1_i_s		:		std_logic_vector(16 downto 1);
	signal 	REDS_CONN_REG2_i_s		:		std_logic_vector(16 downto 1);
	signal 	REDS_CONN_REG3_i_s		:		std_logic_vector(16 downto 1);
	signal 	REDS_CONN_REG4_i_s		:		std_logic_vector(16 downto 1);
	signal 	REDS_CONN_REG5_i_s		:		std_logic_vector(16 downto 1);
	
	-- Registres internes I/O des GPIOs bidir.
	signal	GPIO_HDR1_REG_LBOUT_s		:		std_logic_vector(11 downto 1);
	signal	GPIO_HDR2_REG_LBOUT_s    	:		std_logic_vector(8 downto 1);
	signal	GPIO_3V3_REG_LBOUT_s		:		std_logic_vector(4 downto 1);
	--signal	GPIO_DIFF_REG_LBOUT_s   	:		std_logic_vector(16 downto 1);
	signal	GPIO_HDR1_REG_LBIN_s   	:		std_logic_vector(11 downto 1);
	signal	GPIO_HDR2_REG_LBIN_s    	:		std_logic_vector(8 downto 1);
	signal	GPIO_3V3_REG_LBIN_s     	:		std_logic_vector(4 downto 1);
	--signal	GPIO_DIFF_REG_LBIN_s    	:		std_logic_vector(16 downto 1);
	
	-- Signaux nCS SPI
	signal	SPI_nCS1_s				:		std_logic;
	signal	SPI_nCS2_s				:		std_logic;
	signal	SPI_nCS_AD_s			:		std_logic;
	signal	SPI_nCS_DA_s			:		std_logic;
	
	-- Signaux pour l'encoder
	signal	left_rotation_s			:		std_logic;
	signal	right_rotation_s		:		std_logic;
	signal	pulse_counter_s			:		std_logic_vector(15 downto 0);
	
	-- Signaux pour le buzzer
	signal	buzzer_en_s				:		std_logic;
	signal	fast_mode_s				:		std_logic;
	signal	slow_mode_s				:		std_logic;
	
	-- Signaux pour le LCD
	signal	LCD_cmd_s				:		std_logic_vector(7 downto 0);
	signal	LCD_RS_s				:		std_logic;
	signal	LCD_RW_s				:		std_logic;
	signal	LCD_start_cmd_s			:		std_logic;	
	signal	LCD_ready_s				:		std_logic;
	signal	LCD_Return_data_s		:		std_logic_vector(7 downto 0);
	signal	LCD_start_reset_s		:		std_logic;
	signal  Data_LCD_in_s           :		std_logic_vector(7 downto 0);
	signal  Data_LCD_out_s          :		std_logic_vector(7 downto 0);
	signal  Data_LCD_oe_s           :		std_logic;
	signal  lcd_tris_s           	:		std_logic;
	-- Signaux pour le DA
	signal	DAC_nLDAC_s				:		std_logic;
	signal	DAC_nRS_s            	:		std_logic;
	
	-- Touch pad 
	signal	TPB_Det_finger_s				:		std_logic;
	signal LB_PCB_TB_en_s	:		std_logic;
	signal	Cap_s								:		std_logic;
	signal	Cmd_Cap_s	:		std_logic;
  signal  buzzer_s          :		std_logic;
  
  --signal  debug_LB_s        : std_logic_vector(7 downto 0);
	
	-- DDR2
	signal  ddr2_calib_done_s      : std_logic;
	signal  ddr2_clk0_s            : std_logic;
	signal  ddr2_rst0_s            : std_logic;
	signal  ddr2_cmd_en_s          : std_logic;                
	signal  ddr2_cmd_instr_s       : std_logic_vector(2 downto 0);                
	signal  ddr2_cmd_bl_s          : std_logic_vector(5 downto 0);                
	signal  ddr2_cmd_byte_addr_s   : std_logic_vector(29 downto 0);                
	signal  ddr2_cmd_full_s        : std_logic;                
	signal  ddr2_wr_clk_s          : std_logic;                
	signal  ddr2_wr_en_s           : std_logic;                
	signal  ddr2_wr_mask_s         : std_logic_vector(DDR2_P0_MASK_SIZE - 1 downto 0);      
	signal  ddr2_wr_data_s         : std_logic_vector(DDR2_P0_DATA_PORT_SIZE - 1 downto 0); 
	signal  ddr2_wr_full_s         : std_logic;                
	signal  ddr2_wr_empty_s        : std_logic;                
	signal  ddr2_wr_count_s        : std_logic_vector(6 downto 0);                
	signal  ddr2_wr_underrun_s     : std_logic;                
	signal  ddr2_wr_error_s        : std_logic;                
	signal  ddr2_rd_clk_s          : std_logic;                
	signal  ddr2_rd_en_s           : std_logic;                
	signal  ddr2_rd_data_s         : std_logic_vector(DDR2_P0_DATA_PORT_SIZE - 1 downto 0);
	signal  ddr2_rd_full_s         : std_logic;                
	signal  ddr2_rd_empty_s        : std_logic;                
	signal  ddr2_rd_count_s        : std_logic_vector(6 downto 0);                
	signal  ddr2_rd_overflow_s     : std_logic;
	signal  ddr2_rd_error_s        : std_logic;   

	signal ddr2_async_rst_s         : std_logic;
	signal ddr2_sysclk_2x_s         : std_logic;
	signal ddr2_sysclk_2x_180_s     : std_logic;
	signal ddr2_pll_ce_0_s          : std_logic;
	signal ddr2_pll_ce_90_s         : std_logic;
	signal ddr2_pll_lock_s          : std_logic;
	signal ddr2_mcb_drp_clk_s       : std_logic;  

	-- IOBUF for Addr_Data_LB_io
	signal Addr_Data_LB_in_s		:		std_logic_vector(15 downto 0);
	signal Addr_Data_LB_out_s		:		std_logic_vector(15 downto 0);      
	signal local_bus_tris_s			:		std_logic;
	signal cs3_data_tris_s			: 		std_logic;
	
	-- Local Bus
	signal   nCS4_nCS3_s          	:		std_logic_vector(1 downto 0);
		
	-- SP6 registers access (local bus controller on CS3)
	signal	nCS3_LB_s				:		std_logic;		
	signal	sp6_reg_data_s			:		std_logic_vector(15 downto 0);     
	
	-- FMC1_TRISTATE
	signal  FMC1_GPIO_LA_REG1_LB2FMC_s	: 		std_logic_vector(15 downto 0);	
	signal  FMC1_GPIO_LA_REG2_LB2FMC_s	: 		std_logic_vector(15 downto 0);	
	signal  FMC1_GPIO_LA_REG3_LB2FMC_s	: 		std_logic_vector(15 downto 0);	
	signal  FMC1_GPIO_LA_REG4_LB2FMC_s	: 		std_logic_vector(15 downto 0);	
	signal  FMC1_GPIO_LA_REG5_LB2FMC_s	: 		std_logic_vector(3 downto 0);	
	signal  FMC1_GPIO_LA_REG1_FMC2LB_s	: 		std_logic_vector(15 downto 0);	
	signal  FMC1_GPIO_LA_REG2_FMC2LB_s	: 		std_logic_vector(15 downto 0);	
	signal  FMC1_GPIO_LA_REG3_FMC2LB_s	: 		std_logic_vector(15 downto 0);	
	signal  FMC1_GPIO_LA_REG4_FMC2LB_s	: 		std_logic_vector(15 downto 0);	
	signal  FMC1_GPIO_LA_REG5_FMC2LB_s	: 		std_logic_vector(3 downto 0);	
	signal  FMC1_TRIS1_REG_s			: 		std_logic_vector(15 downto 0);			
	signal  FMC1_TRIS2_REG_s			: 		std_logic_vector(15 downto 0);			
	signal  FMC1_TRIS3_REG_s			: 		std_logic_vector(15 downto 0);			
	signal  FMC1_TRIS4_REG_s			: 		std_logic_vector(15 downto 0);	
	signal	FMC1_CLK0_LOOP_s			:		std_logic;
	signal	FMC1_CLK1_LOOP_s			:		std_logic;
	signal  FMC1_GPIO_LA_4_s 			:		std_logic_vector(15 downto 0);	
	signal  FMC1_TRIS4_s				:		std_logic_vector(15 downto 0);	
	
	-- FMC2_TRISTATE
	signal  FMC2_GPIO_LA_REG1_LB2FMC_s	: 		std_logic_vector(15 downto 0);	
	signal  FMC2_GPIO_LA_REG2_LB2FMC_s	: 		std_logic_vector(15 downto 0);	
	signal  FMC2_GPIO_LA_REG3_LB2FMC_s	: 		std_logic_vector(15 downto 0);	
	signal  FMC2_GPIO_LA_REG4_LB2FMC_s	: 		std_logic_vector(15 downto 0);	
	signal  FMC2_GPIO_LA_REG5_LB2FMC_s	: 		std_logic_vector(3 downto 0);	
	signal  FMC2_GPIO_LA_REG1_FMC2LB_s	: 		std_logic_vector(15 downto 0);	
	signal  FMC2_GPIO_LA_REG2_FMC2LB_s	: 		std_logic_vector(15 downto 0);	
	signal  FMC2_GPIO_LA_REG3_FMC2LB_s	: 		std_logic_vector(15 downto 0);	
	signal  FMC2_GPIO_LA_REG4_FMC2LB_s	: 		std_logic_vector(15 downto 0);	
	signal  FMC2_GPIO_LA_REG5_FMC2LB_s	: 		std_logic_vector(3 downto 0);	
	signal  FMC2_TRIS1_REG_s			: 		std_logic_vector(15 downto 0);			
	signal  FMC2_TRIS2_REG_s			: 		std_logic_vector(15 downto 0);			
	signal  FMC2_TRIS3_REG_s			: 		std_logic_vector(15 downto 0);			
	signal  FMC2_TRIS4_REG_s			: 		std_logic_vector(15 downto 0);	
	signal	FMC2_CLK0_LOOP_s			:		std_logic;
	signal	FMC2_CLK1_LOOP_s			:		std_logic;
	signal  FMC2_GPIO_LA_4_s 			:		std_logic_vector(15 downto 0);	
	signal  FMC2_TRIS4_s				:		std_logic_vector(15 downto 0);	
		

	-- GPMC-DDR interface (CS4 on local bus)
	signal SP6_LB_CLK_s			: std_logic;
	signal SP6_LB_WAIT0_s      : std_logic;
	signal interface_state_s 	: STD_LOGIC_VECTOR (3 downto 0);
	signal cs4_data_tris_s		: std_logic;
	signal data_to_fifo_s		: std_logic_vector(31 downto 0);
    signal mcb_wr_en_s			: std_logic;
    signal mcb_delay_rd_en_s	: std_logic;
    signal fifo_dout_s			: std_logic_vector(31 downto 0);
    signal fifo_full_s			: std_logic;
	signal mcb_rd_en_s			: std_logic;
    signal fifo_data_count_s	: std_logic_vector(3 downto 0);
	signal end_delay_s			: std_logic;
	signal fifo_empty_s			: std_logic;
	signal ddr2_data_s 			: std_logic_vector(15 downto 0);

	--| Component declarations |------------------------------------------------------------
	
	-- Component local bus instanciated
	component Local_Bus_v2
		port(	clk_i					:		in std_logic;
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
				PCB_TB_en_o					:		out std_logic;
				-- GPIOs bidir.
				REDS_CONN_TRIS1_o		:		out std_logic_vector(16 downto 1);		
				REDS_CONN_TRIS2_o		:		out std_logic_vector(16 downto 1);		
				REDS_CONN_TRIS3_o		:		out std_logic_vector(16 downto 1);		
				REDS_CONN_TRIS4_o		:		out std_logic_vector(16 downto 1);		
				REDS_CONN_TRIS5_o		:		out std_logic_vector(16 downto 1);
				GPIO_HDR1_TRIS_o		:		out std_logic_vector(11 downto 1);
				GPIO_HDR2_TRIS_o		:		out std_logic_vector(8 downto 1);
				GPIO_3V3_TRIS_o			:		out std_logic;
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
				GPIO_HDR1_REG_i			:		in std_logic_vector(11 downto 1);
				GPIO_HDR2_REG_i			:		in std_logic_vector(8 downto 1);
				GPIO_3V3_REG_i			:		in std_logic_vector(4 downto 1);
				--GPIO_DIFF_REG_i			:		in std_logic_vector(16 downto 1);
				GPIO_HDR1_REG_o			:		out std_logic_vector(11 downto 1);
				GPIO_HDR2_REG_o			:		out std_logic_vector(8 downto 1);
				GPIO_3V3_REG_o			:		out std_logic_vector(4 downto 1);
				--GPIO_DIFF_REG_o			:		out std_logic_vector(16 downto 1);
				--FMC1
				FMC1_GPIO_LA_REG1_i		: in std_logic_vector(15 downto 0);
				FMC1_GPIO_LA_REG2_i		: in std_logic_vector(15 downto 0);
				FMC1_GPIO_LA_REG3_i		: in std_logic_vector(15 downto 0);
				FMC1_GPIO_LA_REG4_i		: in std_logic_vector(15 downto 0);
				FMC1_GPIO_LA_REG5_i		: in std_logic_vector(3 downto 0);
				FMC1_GPIO_LA_REG1_o		: out std_logic_vector(15 downto 0);
				FMC1_GPIO_LA_REG2_o		: out std_logic_vector(15 downto 0);
				FMC1_GPIO_LA_REG3_o		: out std_logic_vector(15 downto 0);
				FMC1_GPIO_LA_REG4_o		: out std_logic_vector(15 downto 0);
				FMC1_TRIS1_REG_o		: out std_logic_vector(15 downto 0);
				FMC1_TRIS2_REG_o		: out std_logic_vector(15 downto 0);
				FMC1_TRIS3_REG_o		: out std_logic_vector(15 downto 0);
				FMC1_TRIS4_REG_o		: out std_logic_vector(15 downto 0);
				--FMC2
				FMC2_GPIO_LA_REG1_i		: in std_logic_vector(15 downto 0);
				FMC2_GPIO_LA_REG2_i		: in std_logic_vector(15 downto 0);
				FMC2_GPIO_LA_REG3_i		: in std_logic_vector(15 downto 0);
				FMC2_GPIO_LA_REG4_i		: in std_logic_vector(15 downto 0);
				FMC2_GPIO_LA_REG5_i		: in std_logic_vector(3 downto 0);
				FMC2_GPIO_LA_REG1_o		: out std_logic_vector(15 downto 0);
				FMC2_GPIO_LA_REG2_o		: out std_logic_vector(15 downto 0);
				FMC2_GPIO_LA_REG3_o		: out std_logic_vector(15 downto 0);
				FMC2_GPIO_LA_REG4_o		: out std_logic_vector(15 downto 0);
				FMC2_TRIS1_REG_o		: out std_logic_vector(15 downto 0);
				FMC2_TRIS2_REG_o		: out std_logic_vector(15 downto 0);
				FMC2_TRIS3_REG_o		: out std_logic_vector(15 downto 0);
				FMC2_TRIS4_REG_o		: out std_logic_vector(15 downto 0);
				-- FMC_DEBUG_REG(4 DOWNTO 0)
				FMC1_GPIO_LA_REG5_o		: out std_logic_vector(3 downto 0);		-- BITS 3..0: LEDS DS4..DS1 DE LA CARTE FMC DEBUG XM105
				FMC1_PRSNT_i			: in std_logic;							-- BIT 4: detection de prsence depuis la pin H2 du FMC1
				-- FMC_DEBUG_REG(12 DOWNTO 8)
				FMC2_GPIO_LA_REG5_o		: out std_logic_vector(3 downto 0);		-- BITS 11..8: LEDS DS4..DS1 DE LA CARTE FMC DEBUG XM105
				FMC2_PRSNT_i			: in std_logic;							-- BIT 12: detection de prsence depuis la pin H2 du FMC2
				-- SPI nCS
				SPI_nCS1_o				:		out std_logic;
				SPI_nCS2_o				:		out std_logic;
				SPI_nCS_AD_o			:		out std_logic;
				SPI_nCS_DA_o			:		out std_logic;
				-- Buzzer
				buzzer_en_o				:		out std_logic;
				fast_mode_o				:		out std_logic;
				slow_mode_o				:		out std_logic;
				-- Encoder
				left_rotation_i			:		in std_logic;
				right_rotation_i		:		in std_logic;
				pulse_counter_i			:		in std_logic_vector(15 downto 0);
				-- LCD
				LCD_cmd_o				:		out std_logic_vector(7 downto 0);
				LCD_RS_o				:		out std_logic;
				LCD_RW_o				:		out std_logic;
				LCD_start_cmd_o			:		out std_logic;
				LCD_ready_i				:		in std_logic;
				LCD_start_reset_i		:		in std_logic;
				LCD_Return_data_i		:		in std_logic_vector(7 downto 0);
				-- AD
				AD_GPIO_io				:		out std_logic_vector(3 downto 0);
				-- DA
				DAC_nLDAC_o				:		out std_logic;			
				DAC_nRS_o            	:		out std_logic;
				--Debug
				Debug_vector_LB			:		out std_logic_vector(7 downto 0)
	);
	end component;

	-- Composant reds_conn instanci	
	component reds_conn
		port(	clk_i					:		in std_logic;
				nReset_i				:		in std_logic;
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
	end component;
	
	component FMC_tristate is
	port(	clk_i					: in std_logic;
			nReset_i				: in std_logic;
			FMC_LA_P_io			: inout std_logic_vector(33 downto 0);
			FMC_LA_N_io			: inout std_logic_vector(33 downto 0);
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
			FMC_TRIS1_REG_i		: in std_logic_vector(15 downto 0);
			FMC_TRIS2_REG_i		: in std_logic_vector(15 downto 0);
			FMC_TRIS3_REG_i		: in std_logic_vector(15 downto 0);
			FMC_TRIS4_REG_i		: in std_logic_vector(15 downto 0);
			FMC_TRIS5_REG_i		: in std_logic_vector(3 downto 0)
						
	);
	end component FMC_tristate; 	
	

	-- Component PLL instanciated		
	component clk_PLL_200 is
  port( -- Clock in ports
        PLL_IN_i           : in     std_logic;
        -- Clock out ports
        PLL_200MHz_o       : out    std_logic;
        PLL_100MHz_o       : out    std_logic;
        -- Status and control signals
        Reset_i            : in     std_logic;
        locked_o           : out    std_logic
   );
  end component;
	
	-- Component external_gpio instanciated	
	component external_gpio
		port(	
				-- global
				clk_i					:		in std_logic;
				nReset_i				:		in std_logic;
				-- from/to the pins
				-- GPIO_x
				sp6_header1_conn_io		:		inout std_logic_vector(11 downto 1);
				-- GPIO_Hx
				sp6_header2_conn_io		:		inout std_logic_vector(8 downto 1);
				-- GPIO33_x
				sp6_3V3_conn_io			:		inout std_logic_vector(4 downto 1);
				-- signals to drive the pins (only when tristate='1')
				GPIO_HDR1_REG_i			:		in std_logic_vector(11 downto 1);
				GPIO_HDR2_REG_i			:		in std_logic_vector(8 downto 1);
				GPIO_3V3_REG_i			:		in std_logic_vector(4 downto 1);
				-- values read on the pins (always)
				GPIO_HDR1_REG_o			:		out std_logic_vector(11 downto 1);
				GPIO_HDR2_REG_o			:		out std_logic_vector(8 downto 1);
				GPIO_3V3_REG_o			:		out std_logic_vector(4 downto 1);
				-- tristates: put '1' for output, '0' for input
				GPIO_HDR1_TRIS_i		:		in std_logic_vector(11 downto 1);
				GPIO_HDR2_TRIS_i		:		in std_logic_vector(8 downto 1);
				GPIO_3V3_TRIS_i			:		in std_logic
				
		);
	end component;
	
	-- Decodage de l'encoder
	component encoder_sens_detector_v2
		port(	clk_i					:		in std_logic;
				nReset_i				:		in std_logic;
				Inc_Enc_A_i				:		in std_logic;
				Inc_Enc_B_i				:		in std_logic;
				left_rotate_o			:		out std_logic;
				right_rotate_o			:		out std_logic;
				pulse_counter_o			:		out std_logic_vector(15 downto 0)
		);
	end component;
	
	-- Gestion du buzzer
	component buzzer
		port(	clk_i				:		in std_logic;
				nReset_i			:		in std_logic;
				buzzer_en_i			:		in std_logic;
				fast_mode_i			:		in std_logic;
				slow_mode_i			:		in std_logic;
				Buz_osc_o			:		out std_logic
		);
	end component;
	
	-- Gestion du LCD
	component LCD_Controller
		port(	clk_i			:	in std_logic;
			nReset_i		:	in std_logic;
			RS_up_i		:	in std_logic;
			RW_up_i		:	in std_logic;
			Start_i		:	in std_logic;
			RS_o			:	out std_logic;
			RW_o			:	out std_logic;
			E_o			:	out std_logic;
			Ready_o		:	out std_logic;
			Start_rst_o	:	out std_logic;
			-- data returned to LB
			Data_up_o	:	out std_logic_vector(7 downto 0);
			-- data/cmd received from LB
			Data_up_i	:	in std_logic_vector(7 downto 0);
			-- LCD data bus
			Data_LCD_i	:	in std_logic_vector(7 downto 0);
			Data_LCD_o	:	out std_logic_vector(7 downto 0);
			Data_LCD_oe_o :	out std_logic
	);
	end component;
	
	-- Touch Pad controller
component touch_pad_controller_top is
  generic(
     N_Top_g : positive range 1 to 32 := 3);  -- valeur par default
  port( 
    Clock_i                 : in    std_logic;
    Reset_i                 : in    std_logic;
	En_i					: in    std_logic;
	 Cap_i					: in 	std_logic;
    TPB_Det_Finger_o        : out   std_logic;
	 Cmd_Cap_o				: out	std_logic
  );
end component touch_pad_controller_top;

	
  component Open_Collector
    port(
      nOE_i         : in    std_logic;
      InOut_io      : inout std_logic;
      In_o          : out   std_logic
    );
  end component; -- Open_Collector
	

	-- GPMC-DDR interface
	component interface_gpmc_ipddr 
	  generic (
	    GPMC_BURST_LEN  : integer;
	    GPMC_DATA_SIZE  : integer;
	    MCB_PORT_SIZE   : integer
	  );
	  port (  
	    rst_i             : in      STD_LOGIC;
		mcb_calib_done_i  : in      STD_LOGIC;
	    error_o           : out   STD_LOGIC;
	    
	    gpmc_ckl_i        : in		STD_LOGIC;
	    gpmc_a_i          : in      STD_LOGIC_VECTOR (8 downto 0);
	    gpmc_d_i          : in      STD_LOGIC_VECTOR (GPMC_DATA_SIZE-1 downto 0);
	    gpmc_d_o          : out   STD_LOGIC_VECTOR (GPMC_DATA_SIZE-1 downto 0);
	    gpmc_d_tris_o     : out   STD_LOGIC;		-- '1' input, '0' output
	    gpmc_nCS_i        : in      STD_LOGIC;
	    gpmc_nADV_i       : in      STD_LOGIC;
	    gpmc_nWE_i        : in      STD_LOGIC;
	    gpmc_nOE_i        : in      STD_LOGIC;
	    gpmc_nWait_o      : out   STD_LOGIC;
	    
	    mcb_cmd_addr_o    : out   STD_LOGIC_VECTOR (29 downto 0);
	    mcb_cmd_bl_o      : out   STD_LOGIC_VECTOR (5 downto 0);
	    mcb_cmd_en_o      :   out   STD_LOGIC;
	    mcb_cmd_full_i    : in      STD_LOGIC;
	    mcb_cmd_instr_o   :   out   STD_LOGIC_VECTOR (2 downto 0);
	    mcb_wr_data_o     :   out   STD_LOGIC_VECTOR (MCB_PORT_SIZE-1 downto 0);
	    mcb_wr_en_o       :   out   STD_LOGIC;
	    mcb_wr_full_i     : in      STD_LOGIC;
	    mcb_wr_mask_o     :   out   STD_LOGIC_VECTOR (MCB_PORT_SIZE/8-1 downto 0);
	    mcb_rd_en_o       :   out   STD_LOGIC;
	    mcb_rd_data_i     : in      STD_LOGIC_VECTOR (MCB_PORT_SIZE-1 downto 0);
	    mcb_rd_empty_i    : in      STD_LOGIC;
	    mcb_rd_count_i    : in      STD_LOGIC_VECTOR (6 downto 0);
		-- debug
		interface_state_o : out     STD_LOGIC_VECTOR (3 downto 0)
	    	    
	  );
	end component interface_gpmc_ipddr;


	-- Gestion du MCB pour la DDR2
	component memc5_wrapper is
		generic (
			C_MEMCLK_PERIOD      : integer;
			C_CALIB_SOFT_IP      : string;
			C_SIMULATION         : string;
			C_P0_MASK_SIZE       : integer;
			C_P0_DATA_PORT_SIZE   : integer;
			C_P1_MASK_SIZE       : integer;
			C_P1_DATA_PORT_SIZE   : integer;
			C_ARB_NUM_TIME_SLOTS   : integer;
			C_ARB_TIME_SLOT_0    : bit_vector(11 downto 0);
			C_ARB_TIME_SLOT_1    : bit_vector(11 downto 0);
			C_ARB_TIME_SLOT_2    : bit_vector(11 downto 0);
			C_ARB_TIME_SLOT_3    : bit_vector(11 downto 0);
			C_ARB_TIME_SLOT_4    : bit_vector(11 downto 0);
			C_ARB_TIME_SLOT_5    : bit_vector(11 downto 0);
			C_ARB_TIME_SLOT_6    : bit_vector(11 downto 0);
			C_ARB_TIME_SLOT_7    : bit_vector(11 downto 0);
			C_ARB_TIME_SLOT_8    : bit_vector(11 downto 0);
			C_ARB_TIME_SLOT_9    : bit_vector(11 downto 0);
			C_ARB_TIME_SLOT_10   : bit_vector(11 downto 0);
			C_ARB_TIME_SLOT_11   : bit_vector(11 downto 0);
			C_MEM_TRAS           : integer;
			C_MEM_TRCD           : integer;
			C_MEM_TREFI          : integer;
			C_MEM_TRFC           : integer;
			C_MEM_TRP            : integer;
			C_MEM_TWR            : integer;
			C_MEM_TRTP           : integer;
			C_MEM_TWTR           : integer;
			C_MEM_ADDR_ORDER     : string;
			C_NUM_DQ_PINS        : integer;
			C_MEM_TYPE           : string;
			C_MEM_DENSITY        : string;
			C_MEM_BURST_LEN      : integer;
			C_MEM_CAS_LATENCY    : integer;
			C_MEM_ADDR_WIDTH     : integer;
			C_MEM_BANKADDR_WIDTH : integer;
			C_MEM_NUM_COL_BITS   : integer;
			C_MEM_DDR1_2_ODS     : string;
			C_MEM_DDR2_RTT       : string;
			C_MEM_DDR2_DIFF_DQS_EN   : string;
			C_MEM_DDR2_3_PA_SR   : string;
			C_MEM_DDR2_3_HIGH_TEMP_SR   : string;
			C_MEM_DDR3_CAS_LATENCY   : integer;
			C_MEM_DDR3_ODS       : string;
			C_MEM_DDR3_RTT       : string;
			C_MEM_DDR3_CAS_WR_LATENCY   : integer;
			C_MEM_DDR3_AUTO_SR   : string;
			C_MEM_DDR3_DYN_WRT_ODT   : string;
			C_MEM_MOBILE_PA_SR   : string;
			C_MEM_MDDR_ODS       : string;
			C_MC_CALIB_BYPASS    : string;
			C_MC_CALIBRATION_MODE   : string;
			C_MC_CALIBRATION_DELAY   : string;
			C_SKIP_IN_TERM_CAL   : integer;
			C_SKIP_DYNAMIC_CAL   : integer;
			C_LDQSP_TAP_DELAY_VAL  : integer;
			C_LDQSN_TAP_DELAY_VAL  : integer;
			C_UDQSP_TAP_DELAY_VAL  : integer;
			C_UDQSN_TAP_DELAY_VAL  : integer;
			C_DQ0_TAP_DELAY_VAL    : integer;
			C_DQ1_TAP_DELAY_VAL    : integer;
			C_DQ2_TAP_DELAY_VAL    : integer;
			C_DQ3_TAP_DELAY_VAL    : integer;
			C_DQ4_TAP_DELAY_VAL    : integer;
			C_DQ5_TAP_DELAY_VAL    : integer;
			C_DQ6_TAP_DELAY_VAL    : integer;
			C_DQ7_TAP_DELAY_VAL    : integer;
			C_DQ8_TAP_DELAY_VAL    : integer;
			C_DQ9_TAP_DELAY_VAL    : integer;
			C_DQ10_TAP_DELAY_VAL   : integer;
			C_DQ11_TAP_DELAY_VAL   : integer;
			C_DQ12_TAP_DELAY_VAL   : integer;
			C_DQ13_TAP_DELAY_VAL   : integer;
			C_DQ14_TAP_DELAY_VAL   : integer;
			C_DQ15_TAP_DELAY_VAL   : integer
		);
		port (
			mcb5_dram_dq           : inout  std_logic_vector((C_NUM_DQ_PINS-1) downto 0);
			mcb5_dram_a            : out  std_logic_vector((C_MEM_ADDR_WIDTH-1) downto 0);
			mcb5_dram_ba           : out  std_logic_vector((C_MEM_BANKADDR_WIDTH-1) downto 0);
			mcb5_dram_ras_n        : out  std_logic;
			mcb5_dram_cas_n        : out  std_logic;
			mcb5_dram_we_n         : out  std_logic;
			mcb5_dram_odt          : out  std_logic;
			mcb5_dram_cke          : out  std_logic;
			mcb5_dram_dm           : out  std_logic;
			mcb5_dram_udqs         : inout  std_logic;
			mcb5_dram_udqs_n       : inout  std_logic;
			mcb5_rzq               : inout  std_logic;
			mcb5_zio               : inout  std_logic;
			mcb5_dram_udm          : out  std_logic;
			calib_done             : out  std_logic;
			async_rst              : in  std_logic;
			sysclk_2x              : in  std_logic;
			sysclk_2x_180          : in  std_logic;
			pll_ce_0               : in  std_logic;
			pll_ce_90              : in  std_logic;
			pll_lock               : in  std_logic;
			mcb_drp_clk            : in  std_logic;
			mcb5_dram_dqs          : inout  std_logic;
			mcb5_dram_dqs_n        : inout  std_logic;
			mcb5_dram_ck           : out  std_logic;
			mcb5_dram_ck_n         : out  std_logic;
			p0_cmd_clk             : in std_logic;
			p0_cmd_en              : in std_logic;
			p0_cmd_instr           : in std_logic_vector(2 downto 0);
			p0_cmd_bl              : in std_logic_vector(5 downto 0);
			p0_cmd_byte_addr       : in std_logic_vector(29 downto 0);
			p0_cmd_empty           : out std_logic;
			p0_cmd_full            : out std_logic;
			p0_wr_clk              : in std_logic;
			p0_wr_en               : in std_logic;
			p0_wr_mask             : in std_logic_vector(C_P0_MASK_SIZE - 1 downto 0);
			p0_wr_data             : in std_logic_vector(C_P0_DATA_PORT_SIZE - 1 downto 0);
			p0_wr_full             : out std_logic;
			p0_wr_empty            : out std_logic;
			p0_wr_count            : out std_logic_vector(6 downto 0);
			p0_wr_underrun         : out std_logic;
			p0_wr_error            : out std_logic;
			p0_rd_clk              : in std_logic;
			p0_rd_en               : in std_logic;
			p0_rd_data             : out std_logic_vector(C_P0_DATA_PORT_SIZE - 1 downto 0);
			p0_rd_full             : out std_logic;
			p0_rd_empty            : out std_logic;
			p0_rd_count            : out std_logic_vector(6 downto 0);
			p0_rd_overflow         : out std_logic;
			p0_rd_error            : out std_logic;
			p1_cmd_clk             : in std_logic;
			p1_cmd_en              : in std_logic;
			p1_cmd_instr           : in std_logic_vector(2 downto 0);
			p1_cmd_bl              : in std_logic_vector(5 downto 0);
			p1_cmd_byte_addr       : in std_logic_vector(29 downto 0);
			p1_cmd_empty           : out std_logic;
			p1_cmd_full            : out std_logic;
			p1_wr_clk              : in std_logic;
			p1_wr_en               : in std_logic;
			p1_wr_mask             : in std_logic_vector(C_P1_MASK_SIZE - 1 downto 0);
			p1_wr_data             : in std_logic_vector(C_P1_DATA_PORT_SIZE - 1 downto 0);
			p1_wr_full             : out std_logic;
			p1_wr_empty            : out std_logic;
			p1_wr_count            : out std_logic_vector(6 downto 0);
			p1_wr_underrun         : out std_logic;
			p1_wr_error            : out std_logic;
			p1_rd_clk              : in std_logic;
			p1_rd_en               : in std_logic;
			p1_rd_data             : out std_logic_vector(C_P1_DATA_PORT_SIZE - 1 downto 0);
			p1_rd_full             : out std_logic;
			p1_rd_empty            : out std_logic;
			p1_rd_count            : out std_logic_vector(6 downto 0);
			p1_rd_overflow         : out std_logic;
			p1_rd_error            : out std_logic;
			p2_cmd_clk             : in std_logic;
			p2_cmd_en              : in std_logic;
			p2_cmd_instr           : in std_logic_vector(2 downto 0);
			p2_cmd_bl              : in std_logic_vector(5 downto 0);
			p2_cmd_byte_addr       : in std_logic_vector(29 downto 0);
			p2_cmd_empty           : out std_logic;
			p2_cmd_full            : out std_logic;
			p2_wr_clk              : in std_logic;
			p2_wr_en               : in std_logic;
			p2_wr_mask             : in std_logic_vector(3 downto 0);
			p2_wr_data             : in std_logic_vector(31 downto 0);
			p2_wr_full             : out std_logic;
			p2_wr_empty            : out std_logic;
			p2_wr_count            : out std_logic_vector(6 downto 0);
			p2_wr_underrun         : out std_logic;
			p2_wr_error            : out std_logic;
			p2_rd_clk              : in std_logic;
			p2_rd_en               : in std_logic;
			p2_rd_data             : out std_logic_vector(31 downto 0);
			p2_rd_full             : out std_logic;
			p2_rd_empty            : out std_logic;
			p2_rd_count            : out std_logic_vector(6 downto 0);
			p2_rd_overflow         : out std_logic;
			p2_rd_error            : out std_logic;
			p3_cmd_clk             : in std_logic;
			p3_cmd_en              : in std_logic;
			p3_cmd_instr           : in std_logic_vector(2 downto 0);
			p3_cmd_bl              : in std_logic_vector(5 downto 0);
			p3_cmd_byte_addr       : in std_logic_vector(29 downto 0);
			p3_cmd_empty           : out std_logic;
			p3_cmd_full            : out std_logic;
			p3_wr_clk              : in std_logic;
			p3_wr_en               : in std_logic;
			p3_wr_mask             : in std_logic_vector(3 downto 0);
			p3_wr_data             : in std_logic_vector(31 downto 0);
			p3_wr_full             : out std_logic;
			p3_wr_empty            : out std_logic;
			p3_wr_count            : out std_logic_vector(6 downto 0);
			p3_wr_underrun         : out std_logic;
			p3_wr_error            : out std_logic;
			p3_rd_clk              : in std_logic;
			p3_rd_en               : in std_logic;
			p3_rd_data             : out std_logic_vector(31 downto 0);
			p3_rd_full             : out std_logic;
			p3_rd_empty            : out std_logic;
			p3_rd_count            : out std_logic_vector(6 downto 0);
			p3_rd_overflow         : out std_logic;
			p3_rd_error            : out std_logic;
			selfrefresh_enter      : in std_logic;
			selfrefresh_mode       : out std_logic
		);
    end component;
  
	component memc5_infrastructure is
		generic (
			C_RST_ACT_LOW          : integer;
			C_INPUT_CLK_TYPE       : string;
			C_CLKOUT0_DIVIDE       : integer;
			C_CLKOUT1_DIVIDE       : integer;
			C_CLKOUT2_DIVIDE       : integer;
			C_CLKOUT3_DIVIDE       : integer;
			C_CLKFBOUT_MULT        : integer;
			C_DIVCLK_DIVIDE        : integer;
			C_INCLK_PERIOD         : integer
		);
		port (
			sys_clk_p              : in    std_logic;
			sys_clk_n              : in    std_logic;
			sys_clk                : in    std_logic;
			sys_rst_i              : in    std_logic;
			clk0                   : out   std_logic;
			rst0                   : out   std_logic;
			async_rst              : out   std_logic;
			sysclk_2x              : out   std_logic;
			sysclk_2x_180          : out   std_logic;
			pll_ce_0               : out   std_logic;
			pll_ce_90              : out   std_logic;
			pll_lock               : out   std_logic;
			mcb_drp_clk            : out   std_logic
		);
	end component;

 	
begin
	
	-- Signaux globaux
	nReset_s	<= SP6_nReset_i and uP_nRESET_OUT_i;
	Reset_s <= not(nReset_s);

	-- test toslink 
	Digital_Audio_TX_o <= Digital_Audio_RX_i;

	CAN_TXD_o <= '0';
	FTDI_nRESET_o <= '1';
	FTDI_nCTS_o <= '1';
	PCI_PERST_o <= '0';

	-- i2c
	I2C_SCL_1V8_o <= SP6_I2C_SCL_i;	-- from cpu to fmc
	I2C_SDA_1V8_o <= SP6_I2C_SDA_i;
   
	-- LOCAL BUS      
	SP6_LB_WAIT0_o 		<= SP6_LB_WAIT0_s;
	SP6_LB_WAIT3_o 		<= '1';
	
	
	U_BUFG_gpmc_clk : BUFG
    port map
    (
     O => SP6_LB_CLK_s,
     I => SP6_LB_CLK_i
     );
	
	-- MICTOR
	MICTOR_SP6_A0_o <= (others => '1');
	MICTOR_SP6_A1_o	<= (others => '1');
	MICTOR_SP6_A2_o	<= (others => '1');
 	MICTOR_SP6_A3_o <= (others => '1');
	
	MICTOR_SP6_CLK_0_o	<= '1';
	MICTOR_SP6_CLK_1_o	<= '1';
	

------------- DEBUG MCB-DDR ----------------------------------------------------------------------------------------------------------

	-- MICTOR_SP6_A0_o(0) <= '1';
	-- MICTOR_SP6_A0_o(1) <= SP6_LB_CLK_s;
	-- MICTOR_SP6_A0_o(2) <= SP6_LB_nCS4_i;
	-- MICTOR_SP6_A0_o(3) <= SP6_LB_nWE_i;
	-- MICTOR_SP6_A0_o(4) <= SP6_LB_nADV_ALE_i;
	-- MICTOR_SP6_A0_o(5) <= SP6_LB_RE_nOE_i;
	-- MICTOR_SP6_A0_o(6) <= SP6_LB_WAIT0_s;
	-- MICTOR_SP6_A0_o(7) <= nReset_s;	

	-- MICTOR_SP6_A1_o <= Addr_Data_LB_in_s(7 downto 0);
	-- --MICTOR_SP6_A1_o <= ddr2_rd_data_s(23 downto 16);
	-- --when Addr_Data_LB_tris_s(7 downto 0) = "11111111" else Addr_Data_LB_out_s(7 downto 0);
	-- --MICTOR_SP6_A1_o <= data_sent_to_DDR2_s(7 downto 0);
	-- MICTOR_SP6_A2_o <= Addr_Data_LB_in_s(15 downto 8);
	-- --MICTOR_SP6_A2_o <= ddr2_rd_data_s(31 downto 24);
	-- --when Addr_Data_LB_tris_s(15 downto 8) = "11111111" else Addr_Data_LB_out_s(15 downto 8);
	-- --MICTOR_SP6_A2_o <= data_sent_to_DDR2_s(15 downto 8);

	-- MICTOR_SP6_A3_o(0) <= ddr2_cmd_en_s;
	-- MICTOR_SP6_A3_o(1) <= ddr2_wr_en_s;
	-- MICTOR_SP6_A3_o(2) <= ddr2_rd_en_s;

	-- MICTOR_SP6_A3_o(3)	<= '1';

	-- MICTOR_SP6_A3_o(7 downto 4) <= interface_state_s;

	-- MICTOR_SP6_CLK_0_o	<= '0';
	-- MICTOR_SP6_CLK_1_o	<= CLK_25MHz_SP6_i;
	 	
-----------------------------------------------------------------------------------------------------------------------------------



	-- CS accelerometre actif bas
	SP6_SPI_nCS1_o <= SPI_nCS1_s or SP6_SPI_nCS3_i;
	-- CS connecteur W3 actif bas
	SP6_SPI_nCS2_o <= SPI_nCS2_s or SP6_SPI_nCS3_i;
	-- CS AD actif bas
	AD_nCS_o <= SPI_nCS_AD_s or SP6_SPI_nCS3_i;
	-- CS DA actif bas
	DAC_nCS_o <= SPI_nCS_DA_s or SP6_SPI_nCS3_i;
	
	-- SPI DATA TO AD
	AD_SDI_o 		<= SP6_SPI_SDO_i 	when SPI_nCS_AD_s = '0' else '1';
	AD_CLK_o 		<= SP6_SPI_SCLK_i 	when SPI_nCS_AD_s = '0' else '1';
		
	-- SPI DATA TO accelerometer		
	SP6_ACC_SPI_SDI_o 		<= SP6_SPI_SDO_i 		when SPI_nCS1_s = '0' else '1';
	SP6_ACC_SPI_SCL_o 		<= SP6_SPI_SCLK_i 		when SPI_nCS1_s = '0' else '1';
	
	-- SPI DATA TO CPU
	SP6_SPI_SDI_o 			<= SP6_ACC_SPI_SDO_i 	when SPI_nCS1_s = '0' else AD_SDO_i when SPI_nCS_AD_s = '0' else '1';
	
	
	-- SPI DATA TO DA
	DAC_nRS_o 		<= DAC_nRS_s; 	
	DAC_nLDAC_o 	<= DAC_nLDAC_s;	
	DAC_CLK_o 		<= SP6_SPI_SCLK_i 	when SPI_nCS_DA_s = '0' else '1';
	DAC_SDI_o 		<= SP6_SPI_SDO_i 	when SPI_nCS_DA_s = '0' else '1';		
	
	-- FTDI
	FTDI_RX_o <= FTDI_TX_i;
	
	-- Affichage du sens de rotation de l'encoder
	FPGA_LED_o(6) <= not left_rotation_s;	-- les leds s'allument avec un '0'
	FPGA_LED_o(7) <= not right_rotation_s; 
	
	-- Sortie d'interruption de l'accelerometre
	--SP6_GPIO_DIFFS_io(8) <= SP6_ACC_INT1_i;
	--SP6_GPIO_DIFFS_io(9) <= SP6_ACC_INT2_i;
	
	-- iobuf for LB data
	-- IOBUF: Single-ended Bi-directional Buffer
	-- Xilinx HDL Libraries Guide, version 12.4
	 IOBUF_Addresses_Datas : for i in 0 to Addr_Data_LB_io'length-1 generate
    IOBUF_Addresse_Data : IOBUF
    generic map (
      DRIVE => 12,
	  IOSTANDARD => "LVCMOS18",
      SLEW => "FAST"
    )
    port map (
      O => Addr_Data_LB_in_s(i), -- Buffer output
      IO => Addr_Data_LB_io(i), -- Buffer inout port (connect directly to top-level port)
      I => Addr_Data_LB_out_s(i), -- Buffer input
      T => local_bus_tris_s -- 3-state enable input, high=input, low=output
    );
  end generate;
 
 nCS4_nCS3_s <= SP6_LB_nCS4_i & SP6_LB_nCS3_i;

mux_gpmc_data:	process (nCS4_nCS3_s, cs4_data_tris_s, cs3_data_tris_s, ddr2_data_s, sp6_reg_data_s) is
   begin
      case (nCS4_nCS3_s) is
         
         when "01"  =>  -- data output from synchronous local bus controller 
						local_bus_tris_s 	<= cs4_data_tris_s;
						Addr_Data_LB_out_s 	<= ddr2_data_s;
         when "10"  =>  -- data output from asynchronous local bus controller
						local_bus_tris_s 	<= cs3_data_tris_s;
						Addr_Data_LB_out_s 	<= sp6_reg_data_s;
         when others => -- input
						local_bus_tris_s 	<= '1';
						Addr_Data_LB_out_s 	<= (others => '0');
      end case;
   end process;
    
 	
		
		-- Gestion du local bus
	u0: Local_Bus_v2
	port map(	clk_i				=>	CLK_200MHz_s,
                nReset_i			=> nReset_s,
	            nCS3_LB_i			=> SP6_LB_nCS3_i,
	            nADV_LB_i			=> SP6_LB_nADV_ALE_i,
	            nOE_LB_i			=> SP6_LB_RE_nOE_i,
	            nWE_LB_i			=> SP6_LB_nWE_i,
	            -- 04.04.2013: buffer tri-state is now instantiated on the top 
				Addr_Data_LB_i		=> Addr_Data_LB_in_s,
				Addr_Data_LB_o		=> sp6_reg_data_s,
				Addr_Data_LB_tris_o	=> cs3_data_tris_s, -- '1' input, '0' output
				--------------------------------------------------------------------
				Addr_LB_i			=> Addr_LB_i,
	            SP6_7seg1_o			=> SP6_7seg1_o,		
	            SP6_7seg2_o			=> SP6_7seg2_o,
	            SP6_7seg3_o			=> SP6_7seg3_o,
	            SP6_7seg1_DP_o		=> SP6_7seg1_DP_o,
	            SP6_7seg2_DP_o		=> SP6_7seg2_DP_o,
	            SP6_7seg3_DP_o		=> SP6_7seg3_DP_o,
	            SW_PB_i				=> SW_PB_i,	
		    IRQ_o				=> SP6_GPIO18_1_o,
	            DIP_i				=> DIP_i,
	            FPGA_LED_o			=> FPGA_LED_o(5 downto 0),
	            SP6_UART1_CTS_o	  	=> SP6_UART1_CTS_o,	
	            SP6_UART1_RTS_i	  	=> SP6_UART1_RTS_i,
	            SP6_UART1_RX_i		=> SP6_UART1_RX_i,
	            SP6_UART1_TX_o		=> SP6_UART1_TX_o,
	            PCB_TB_i			=> TPB_Det_finger_s,	
				PCB_TB_en_o	        => LB_PCB_TB_en_s,
	            REDS_CONN_TRIS1_o	=> REDS_CONN_TRIS1_s,
	            REDS_CONN_TRIS2_o	=> REDS_CONN_TRIS2_s,
	            REDS_CONN_TRIS3_o	=> REDS_CONN_TRIS3_s,
	            REDS_CONN_TRIS4_o	=> REDS_CONN_TRIS4_s,
	            REDS_CONN_TRIS5_o	=> REDS_CONN_TRIS5_s,
	            GPIO_HDR1_TRIS_o	=> GPIO_HDR1_TRIS_s,
	            GPIO_HDR2_TRIS_o	=> GPIO_HDR2_TRIS_s,
	            GPIO_3V3_TRIS_o	  	=> GPIO_3V3_TRIS_s,
	            --GPIO_DIFF_TRIS_o	=> open,
				REDS_CONN_REG1_i	=> REDS_CONN_REG1_o_s,
				REDS_CONN_REG2_i  => REDS_CONN_REG2_o_s,
				REDS_CONN_REG3_i  => REDS_CONN_REG3_o_s,
				REDS_CONN_REG4_i  => REDS_CONN_REG4_o_s,
				REDS_CONN_REG5_i  => REDS_CONN_REG5_o_s,
				REDS_CONN_REG1_o  => REDS_CONN_REG1_i_s,
				REDS_CONN_REG2_o  => REDS_CONN_REG2_i_s,
				REDS_CONN_REG3_o  => REDS_CONN_REG3_i_s,
				REDS_CONN_REG4_o  => REDS_CONN_REG4_i_s,
				REDS_CONN_REG5_o  => REDS_CONN_REG5_i_s,
				GPIO_HDR1_REG_i	  => GPIO_HDR1_REG_LBIN_s,
				GPIO_HDR2_REG_i	  =>	GPIO_HDR2_REG_LBIN_s,
				GPIO_3V3_REG_i		=> GPIO_3V3_REG_LBIN_s,	
				--GPIO_DIFF_REG_i	  => (others => '0'),
				GPIO_HDR1_REG_o	  => GPIO_HDR1_REG_LBOUT_s,
				GPIO_HDR2_REG_o	  => GPIO_HDR2_REG_LBOUT_s,
				GPIO_3V3_REG_o		=> GPIO_3V3_REG_LBOUT_s, 
				--GPIO_DIFF_REG_o	  => open,
			  --FMC1
				FMC1_GPIO_LA_REG1_i	=> 	FMC1_GPIO_LA_REG1_FMC2LB_s,	
				FMC1_GPIO_LA_REG2_i	=> 	FMC1_GPIO_LA_REG2_FMC2LB_s,	
				FMC1_GPIO_LA_REG3_i	=> 	FMC1_GPIO_LA_REG3_FMC2LB_s,	
				FMC1_GPIO_LA_REG4_i	=> 	FMC1_GPIO_LA_REG4_FMC2LB_s,	
				FMC1_GPIO_LA_REG5_i	=> 	FMC1_GPIO_LA_REG5_FMC2LB_s,	
				FMC1_GPIO_LA_REG1_o	=> 	FMC1_GPIO_LA_REG1_LB2FMC_s,	
				FMC1_GPIO_LA_REG2_o	=> 	FMC1_GPIO_LA_REG2_LB2FMC_s,	
				FMC1_GPIO_LA_REG3_o	=> 	FMC1_GPIO_LA_REG3_LB2FMC_s,	
				FMC1_GPIO_LA_REG4_o	=> 	FMC1_GPIO_LA_REG4_LB2FMC_s,	
				FMC1_GPIO_LA_REG5_o	=> 	FMC1_GPIO_LA_REG5_LB2FMC_s,	
				FMC1_TRIS1_REG_o		=>  FMC1_TRIS1_REG_s,		
				FMC1_TRIS2_REG_o		=>  FMC1_TRIS2_REG_s,		
				FMC1_TRIS3_REG_o		=>  FMC1_TRIS3_REG_s,		
				FMC1_TRIS4_REG_o		=>  FMC1_TRIS4_REG_s,		
				FMC1_PRSNT_i			=>  FMC1_PRSNT_M2C_L_i,
				--FMC2
				FMC2_GPIO_LA_REG1_i	=> 	FMC2_GPIO_LA_REG1_FMC2LB_s,	
				FMC2_GPIO_LA_REG2_i	=> 	FMC2_GPIO_LA_REG2_FMC2LB_s,	
				FMC2_GPIO_LA_REG3_i	=> 	FMC2_GPIO_LA_REG3_FMC2LB_s,	
				FMC2_GPIO_LA_REG4_i	=> 	FMC2_GPIO_LA_REG4_FMC2LB_s,	
				FMC2_GPIO_LA_REG5_i	=> 	FMC2_GPIO_LA_REG5_FMC2LB_s,	
				FMC2_GPIO_LA_REG1_o	=> 	FMC2_GPIO_LA_REG1_LB2FMC_s,	
				FMC2_GPIO_LA_REG2_o	=> 	FMC2_GPIO_LA_REG2_LB2FMC_s,	
				FMC2_GPIO_LA_REG3_o	=> 	FMC2_GPIO_LA_REG3_LB2FMC_s,	
				FMC2_GPIO_LA_REG4_o	=> 	FMC2_GPIO_LA_REG4_LB2FMC_s,	
				FMC2_GPIO_LA_REG5_o	=> 	FMC2_GPIO_LA_REG5_LB2FMC_s,	
				FMC2_TRIS1_REG_o		=>  FMC2_TRIS1_REG_s,		
				FMC2_TRIS2_REG_o		=>  FMC2_TRIS2_REG_s,		
				FMC2_TRIS3_REG_o		=>  FMC2_TRIS3_REG_s,		
				FMC2_TRIS4_REG_o		=>  FMC2_TRIS4_REG_s,		
				FMC2_PRSNT_i			=>  FMC2_PRSNT_M2C_L_i,
				SPI_nCS1_o			=> SPI_nCS1_s,
				SPI_nCS2_o			=> SPI_nCS2_s,
				SPI_nCS_AD_o      	=> SPI_nCS_AD_s,
				SPI_nCS_DA_o      	=> SPI_nCS_DA_s,
				buzzer_en_o			=> buzzer_en_s,
				fast_mode_o			=> fast_mode_s,
				slow_mode_o			=> slow_mode_s,
				left_rotation_i	  	=> left_rotation_s,
				right_rotation_i	=> right_rotation_s,
				pulse_counter_i	  	=> pulse_counter_s,
				LCD_cmd_o			=> LCD_cmd_s,
				LCD_RS_o			=> LCD_RS_s,
				LCD_RW_o			=> LCD_RW_s,
				LCD_start_cmd_o	  	=> LCD_start_cmd_s,
				LCD_ready_i			=>	LCD_ready_s,
				LCD_Return_data_i	=> LCD_Return_data_s,
				LCD_start_reset_i 	=> LCD_start_reset_s,
				AD_GPIO_io			=> AD_GPIO_o,
				DAC_nLDAC_o			=> DAC_nLDAC_s,	
				DAC_nRS_o			=> DAC_nRS_s,
				Debug_vector_LB	  	=> open
	);
	
	-- Registres in/out du connecteur reds
	u1: reds_conn
	port map(	clk_i				=>	CLK_200MHz_s,					
	            nReset_i			=>  nReset_s,
	            reds_conn_io		=>  SP6_DKK_io,
	            REDS_CONN_REG1_i	=>  REDS_CONN_REG1_i_s,
	            REDS_CONN_REG2_i	=>  REDS_CONN_REG2_i_s,
	            REDS_CONN_REG3_i	=>  REDS_CONN_REG3_i_s,
	            REDS_CONN_REG4_i	=>  REDS_CONN_REG4_i_s,
	            REDS_CONN_REG5_i	=>  REDS_CONN_REG5_i_s,
	            REDS_CONN_REG1_o	=>  REDS_CONN_REG1_o_s,
	            REDS_CONN_REG2_o	=>  REDS_CONN_REG2_o_s,
	            REDS_CONN_REG3_o	=>  REDS_CONN_REG3_o_s,
	            REDS_CONN_REG4_o	=>  REDS_CONN_REG4_o_s,
	            REDS_CONN_REG5_o	=>  REDS_CONN_REG5_o_s,
	            REDS_CONN_TRIS1_i 	=>  REDS_CONN_TRIS1_s, 
	            REDS_CONN_TRIS2_i 	=>  REDS_CONN_TRIS2_s,
	            REDS_CONN_TRIS3_i 	=>  REDS_CONN_TRIS3_s,
	            REDS_CONN_TRIS4_i	=>  REDS_CONN_TRIS4_s,
	            REDS_CONN_TRIS5_i 	=>  REDS_CONN_TRIS5_s
	);  

	--FMC1
	fmc1: FMC_tristate
	port map(	clk_i					=> 	CLK_200MHz_s,
                nReset_i				=> 	nReset_s,
                FMC_LA_P_io			=> 	FMC1_LA_P_io,		
                FMC_LA_N_io			=> 	FMC1_LA_N_io,		
                FMC_GPIO_LA_REG1_i		=> 	FMC1_GPIO_LA_REG1_LB2FMC_s,	
                FMC_GPIO_LA_REG2_i		=> 	FMC1_GPIO_LA_REG2_LB2FMC_s,	
                FMC_GPIO_LA_REG3_i		=> 	FMC1_GPIO_LA_REG3_LB2FMC_s,	
                FMC_GPIO_LA_REG4_i		=> 	FMC1_GPIO_LA_4_s,
                FMC_GPIO_LA_REG5_i		=> 	FMC1_GPIO_LA_REG5_LB2FMC_s,		
                FMC_GPIO_LA_REG1_o		=> 	FMC1_GPIO_LA_REG1_FMC2LB_s,	
                FMC_GPIO_LA_REG2_o		=> 	FMC1_GPIO_LA_REG2_FMC2LB_s,	
                FMC_GPIO_LA_REG3_o		=> 	FMC1_GPIO_LA_REG3_FMC2LB_s,	
                FMC_GPIO_LA_REG4_o		=> 	FMC1_GPIO_LA_REG4_FMC2LB_s,	
                FMC_GPIO_LA_REG5_o		=> 	FMC1_GPIO_LA_REG5_FMC2LB_s,	
                FMC_TRIS1_REG_i			=> 	FMC1_TRIS1_REG_s,	
                FMC_TRIS2_REG_i			=> 	FMC1_TRIS2_REG_s,	
                FMC_TRIS3_REG_i			=> 	FMC1_TRIS3_REG_s,	
                FMC_TRIS4_REG_i			=> 	FMC1_TRIS4_s,	
                FMC_TRIS5_REG_i			=> 	(others => '1')		-- outputs for LEDs DS4..DS1 of the FMC debug board
	);
	
	FMC1_GPIO_LA_4_s 	<= FMC1_CLK0_LOOP_s & FMC1_CLK1_LOOP_s & FMC1_GPIO_LA_REG4_LB2FMC_s(13 downto 0);
	FMC1_TRIS4_s		<= "11" & FMC1_TRIS4_REG_s(13 downto 0);
	
		
	-- -- OBUFDS: Differential Output Buffer
	-- -- Xilinx HDL Libraries Guide, version 11.2
	-- OBUFDS_inst_FMC1 : OBUFDS
	-- generic map (
		-- IOSTANDARD => "LVDS_33")
	-- port map (
		-- O 	=> FMC1_CLK1_M2C_P_i, -- Diff_p output (connect directly to top-level port)
		-- OB 	=> FMC1_CLK1_M2C_N_i, -- Diff_n output (connect directly to top-level port)
		-- I 	=> FMC1_CLK0_LOOP_s -- Buffer input
	-- );
	-- -- End of OBUFDS_inst instantiation
	
	-- IBUFDS: Differential Input Buffer
	-- Xilinx HDL Libraries Guide, version 11.2
	IBUFDS_FMC1_CLK0 : IBUFDS
	generic map (
		CAPACITANCE => "DONT_CARE", -- "LOW", "NORMAL", "DONT_CARE" (Virtex-4 only)
		DIFF_TERM => FALSE, -- Differential Termination (Virtex-4/5, Spartan-3E/3A)
		IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer,
		-- "0"-"12" (Spartan-3E)
		-- "0"-"16" (Spartan-3A)
		IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register,
		-- "AUTO", "0"-"6" (Spartan-3E)
		-- "AUTO", "0"-"8" (Spartan-3A)
		IOSTANDARD => "LVDS_33")
	port map (
		O 	=> FMC1_CLK0_LOOP_s, -- Clock buffer output
		I 	=> FMC1_CLK0_M2C_P_i, -- Diff_p clock buffer input (connect directly to top-level port)
		IB 	=> FMC1_CLK0_M2C_N_i -- Diff_n clock buffer input (connect directly to top-level port)
	);
	-- End of IBUFDS_FMC1_CLK0 instantiation
	
	-- IBUFDS: Differential Input Buffer
	-- Xilinx HDL Libraries Guide, version 11.2
	IBUFDS_FMC1_CLK1 : IBUFDS
	generic map (
		CAPACITANCE => "DONT_CARE", -- "LOW", "NORMAL", "DONT_CARE" (Virtex-4 only)
		DIFF_TERM => FALSE, -- Differential Termination (Virtex-4/5, Spartan-3E/3A)
		IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer,
		-- "0"-"12" (Spartan-3E)
		-- "0"-"16" (Spartan-3A)
		IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register,
		-- "AUTO", "0"-"6" (Spartan-3E)
		-- "AUTO", "0"-"8" (Spartan-3A)
		IOSTANDARD => "LVDS_33")
	port map (
		O 	=> FMC1_CLK1_LOOP_s, -- Clock buffer output
		I 	=> FMC1_CLK1_M2C_P_i, -- Diff_p clock buffer input (connect directly to top-level port)
		IB 	=> FMC1_CLK1_M2C_N_i -- Diff_n clock buffer input (connect directly to top-level port)
	);
	-- End of IBUFDS_FMC1_CLK1 instantiation
	
	--FMC2
		fmc2: FMC_tristate
	port map(	clk_i					=> 	CLK_200MHz_s,
                nReset_i				=> 	nReset_s,
                FMC_LA_P_io				=> 	FMC2_LA_P_io,		
                FMC_LA_N_io				=> 	FMC2_LA_N_io,		
                FMC_GPIO_LA_REG1_i		=> 	FMC2_GPIO_LA_REG1_LB2FMC_s,	
                FMC_GPIO_LA_REG2_i		=> 	FMC2_GPIO_LA_REG2_LB2FMC_s,	
                FMC_GPIO_LA_REG3_i		=> 	FMC2_GPIO_LA_REG3_LB2FMC_s,	
                FMC_GPIO_LA_REG4_i		=> 	FMC2_GPIO_LA_4_s,	
                FMC_GPIO_LA_REG5_i		=> 	FMC2_GPIO_LA_REG5_LB2FMC_s,	
                FMC_GPIO_LA_REG1_o		=> 	FMC2_GPIO_LA_REG1_FMC2LB_s,	
                FMC_GPIO_LA_REG2_o		=> 	FMC2_GPIO_LA_REG2_FMC2LB_s,	
                FMC_GPIO_LA_REG3_o		=> 	FMC2_GPIO_LA_REG3_FMC2LB_s,	
                FMC_GPIO_LA_REG4_o		=> 	FMC2_GPIO_LA_REG4_FMC2LB_s,	
                FMC_GPIO_LA_REG5_o		=> 	FMC2_GPIO_LA_REG5_FMC2LB_s,	
                FMC_TRIS1_REG_i			=> 	FMC2_TRIS1_REG_s,	
                FMC_TRIS2_REG_i			=> 	FMC2_TRIS2_REG_s,	
                FMC_TRIS3_REG_i			=> 	FMC2_TRIS3_REG_s,	
                FMC_TRIS4_REG_i			=> 	FMC2_TRIS4_s,		
                FMC_TRIS5_REG_i			=> 	(others => '1')		-- outputs for LEDs DS4..DS1 of the FMC debug board
	);
	
	FMC2_GPIO_LA_4_s 	<= FMC2_CLK0_LOOP_s & FMC2_CLK1_LOOP_s & FMC2_GPIO_LA_REG4_LB2FMC_s(13 downto 0);
	FMC2_TRIS4_s		<= "11" & FMC2_TRIS4_REG_s(13 downto 0);
	
	-- -- OBUFDS: Differential Output Buffer
	-- -- Xilinx HDL Libraries Guide, version 11.2
	-- OBUFDS_inst_FMC2 : OBUFDS
	-- generic map (
		-- IOSTANDARD => "LVDS_33")
	-- port map (
		-- O 	=> FMC2_CLK0_C2M_P_o, -- Diff_p output (connect directly to top-level port)
		-- OB 	=> FMC2_CLK1_M2C_N_i, -- Diff_n output (connect directly to top-level port)
		-- I 	=> FMC2_CLK0_LOOP_s -- Buffer input
	-- );
	-- -- End of OBUFDS_inst instantiation
	
	-- IBUFDS: Differential Input Buffer
	-- Xilinx HDL Libraries Guide, version 11.2
	IBUFDS_FMC2_CLK0 : IBUFDS
	generic map (
		CAPACITANCE => "DONT_CARE", -- "LOW", "NORMAL", "DONT_CARE" (Virtex-4 only)
		DIFF_TERM => FALSE, -- Differential Termination (Virtex-4/5, Spartan-3E/3A)
		IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer,
		-- "0"-"12" (Spartan-3E)
		-- "0"-"16" (Spartan-3A)
		IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register,
		-- "AUTO", "0"-"6" (Spartan-3E)
		-- "AUTO", "0"-"8" (Spartan-3A)
		IOSTANDARD => "LVDS_33")
	port map (
		O 	=> FMC2_CLK0_LOOP_s, -- Clock buffer output
		I 	=> FMC2_CLK0_M2C_P_i, -- Diff_p clock buffer input (connect directly to top-level port)
		IB 	=> FMC2_CLK0_M2C_N_i -- Diff_n clock buffer input (connect directly to top-level port)
	);
	-- End of IBUFDS_FMC2_CLK0 instantiation
	
	-- IBUFDS: Differential Input Buffer
	-- Xilinx HDL Libraries Guide, version 11.2
	IBUFDS_FMC2_CLK1 : IBUFDS
	generic map (
		CAPACITANCE => "DONT_CARE", -- "LOW", "NORMAL", "DONT_CARE" (Virtex-4 only)
		DIFF_TERM => FALSE, -- Differential Termination (Virtex-4/5, Spartan-3E/3A)
		IBUF_DELAY_VALUE => "0", -- Specify the amount of added input delay for buffer,
		-- "0"-"12" (Spartan-3E)
		-- "0"-"16" (Spartan-3A)
		IFD_DELAY_VALUE => "AUTO", -- Specify the amount of added delay for input register,
		-- "AUTO", "0"-"6" (Spartan-3E)
		-- "AUTO", "0"-"8" (Spartan-3A)
		IOSTANDARD => "LVDS_33")
	port map (
		O 	=> FMC2_CLK1_LOOP_s, -- Clock buffer output
		I 	=> FMC2_CLK1_M2C_P_i, -- Diff_p clock buffer input (connect directly to top-level port)
		IB 	=> FMC2_CLK1_M2C_N_i -- Diff_n clock buffer input (connect directly to top-level port)
	);
	-- End of IBUFDS_FMC2_CLK1 instantiation

	
	-- Registres in/out des gpios
	u2: external_gpio
	port map(	clk_i				=>	CLK_200MHz_s,						
	            nReset_i			=> nReset_s,
	            sp6_header1_conn_io	=> SP6_GPIO_io,
	            sp6_header2_conn_io	=> SP6_GPIO_H_io,
	            sp6_3V3_conn_io		=> SP6_GPIO33_io,
	            --sp6_diff_conn_io	=> open,
	            GPIO_HDR1_REG_i		=> GPIO_HDR1_REG_LBOUT_s,
	            GPIO_HDR2_REG_i		=> GPIO_HDR2_REG_LBOUT_s,
	            GPIO_3V3_REG_i		=> GPIO_3V3_REG_LBOUT_s,	
	            --GPIO_DIFF_REG_i		=> (others => '0'),
	            GPIO_HDR1_REG_o		=> GPIO_HDR1_REG_LBIN_s,
	            GPIO_HDR2_REG_o		=> GPIO_HDR2_REG_LBIN_s,
	            GPIO_3V3_REG_o		=> GPIO_3V3_REG_LBIN_s, 
	            --GPIO_DIFF_REG_o		=> open,
	            GPIO_HDR1_TRIS_i	=> GPIO_HDR1_TRIS_s,
	            GPIO_HDR2_TRIS_i	=> GPIO_HDR2_TRIS_s,
	            GPIO_3V3_TRIS_i		=> GPIO_3V3_TRIS_s
	            --GPIO_DIFF_TRIS_i	=> '0'
	);
	
	-- PLL 
  PLL: clk_PLL_200
  port map( PLL_IN_i           => SP6_Clk_100MHz_i,
            PLL_200MHz_o       => CLK_200MHz_s, 
            PLL_100MHz_o       => CLK_100MHz_s,
            Reset_i            => Reset_s,
            locked_o           => PLL_locked_s
   );
	
	u4: encoder_sens_detector_v2
	port map(	clk_i				=> CLK_200MHz_s,
				nReset_i			=>	nReset_s,	
	            Inc_Enc_A_i		   	=> Inc_Enc_A_i,
	            Inc_Enc_B_i		   	=> Inc_Enc_B_i,
	            left_rotate_o	   	=> left_rotation_s,
	            right_rotate_o	   	=> right_rotation_s,
				pulse_counter_o		=> pulse_counter_s
	);
	
	u5: buzzer
	port map(	clk_i				=> CLK_200MHz_s,			
	            nReset_i			=> nReset_s,
	            buzzer_en_i			=> buzzer_en_s,
	            fast_mode_i			=> fast_mode_s,
	            slow_mode_i			=> slow_mode_s,
	            Buz_osc_o			=> buzzer_s
	);
	
  Buz_osc_o <= buzzer_s;
  
    
  
	u6: LCD_Controller
	port map(	clk_i			=> CLK_200MHz_s,			
	            nReset_i		=> nReset_s,
	            RS_up_i			=> LCD_RS_s,
	            RW_up_i		    => LCD_RW_s,
	            Start_i		    => LCD_start_cmd_s,
	            RS_o			=> LCD_RS_o,		
	            RW_o			=> LCD_R_nW_o,			
	            E_o				=> LCD_E_o,			
	            Ready_o			=> LCD_ready_s,
				Start_rst_o		=> LCD_start_reset_s,
	            Data_up_o		=> LCD_Return_data_s,	
	            Data_up_i		=> LCD_cmd_s,
				-- to tri-state buffer
	            Data_LCD_i	    => Data_LCD_in_s,
				Data_LCD_o	    => Data_LCD_out_s,
				Data_LCD_oe_o   => Data_LCD_oe_s
				
	);
	
	LCD_tris_s <= not Data_LCD_oe_s;

	-- iobuf for LCD data
	-- IOBUF: Single-ended Bi-directional Buffer
	-- Xilinx HDL Libraries Guide, version 12.4
	 IOBUF_LCD_Bus : for i in 0 to LCD_DB_io'length-1 generate
    IOBUF_LCD_bit : IOBUF
    generic map (
      DRIVE => 12,
	  IOSTANDARD => "LVCMOS33",
      SLEW => "FAST"
    )
    port map (
      O => Data_LCD_in_s(i), -- Buffer output
      IO => LCD_DB_io(i), -- Buffer inout port (connect directly to top-level port)
      I => Data_LCD_out_s(i), -- Buffer input
      T => LCD_tris_s -- 3-state enable input, high=input, low=output
    );
  end generate;
	
	
	


  u7 : touch_pad_controller_top
	generic map(N_top_g => Size_of_Timer_c)
    port map(
      Clock_i           => CLK_25MHz_SP6_i,
      Reset_i           => Reset_s,
	  En_i				=> LB_PCB_TB_en_s,
	  Cap_i             => Cap_s,
      TPB_Det_Finger_o  => TPB_Det_finger_s,
      Cmd_Cap_o			=> Cmd_Cap_s
    );

 	
  --| touch pad button bidirectionnal port |--------------------------------------------------
  U1_Open_Collector: Open_Collector
  port map(
    nOE_i       => Cmd_Cap_s,
    In_o        => Cap_s,
    InOut_io    => PCB_TB_io
  );

	-- tests touch pad:
	-- LB_PCB_TB_en_s	<= DIP_i(10);
	-- FPGA_LED_o(7) <= not TPB_Det_finger_s;
	-- FPGA_LED_o(6) <= '0';
  
	  
   -- DDR2 controller
   
   interface_gpmc_ipddr_inst : interface_gpmc_ipddr
  generic map (
    GPMC_BURST_LEN  => 4,
    GPMC_DATA_SIZE  => 16,
	 MCB_PORT_SIZE   => 32
  )
  port map ( 
    interface_state_o => interface_state_s,
    
    rst_i             => Reset_s,
    mcb_calib_done_i  => DDR2_calib_done_s,
    error_o           => open,
    
    gpmc_ckl_i        => SP6_LB_CLK_s,
    gpmc_a_i          => Addr_LB_i,
    gpmc_d_i          => Addr_Data_LB_in_s,
    gpmc_d_o          => ddr2_data_s,
    gpmc_d_tris_o     => cs4_data_tris_s,
    gpmc_nCS_i        => SP6_LB_nCS4_i,
    gpmc_nADV_i       => SP6_LB_nADV_ALE_i,
    gpmc_nWE_i        => SP6_LB_nWE_i,
    gpmc_nOE_i        => SP6_LB_RE_nOE_i,
    gpmc_nWait_o      => SP6_LB_WAIT0_s,
    
    mcb_cmd_addr_o    => ddr2_cmd_byte_addr_s,
    mcb_cmd_bl_o      => ddr2_cmd_bl_s,
    mcb_cmd_en_o      => ddr2_cmd_en_s,
    mcb_cmd_full_i    => ddr2_cmd_full_s,
    mcb_cmd_instr_o   => ddr2_cmd_instr_s,
	    
    mcb_wr_data_o     => ddr2_wr_data_s,
    mcb_wr_en_o       => ddr2_wr_en_s,
    mcb_wr_full_i     => ddr2_wr_full_s,
    mcb_wr_mask_o     => ddr2_wr_mask_s, 
    
    mcb_rd_en_o       => ddr2_rd_en_s,
    mcb_rd_data_i     => ddr2_rd_data_s,
	mcb_rd_empty_i	  => ddr2_rd_empty_s,
    mcb_rd_count_i    => ddr2_rd_count_s
  );
  
  memc5_infrastructure_inst : memc5_infrastructure
  generic map (
    C_RST_ACT_LOW                     => DDR2_RST_ACT_LOW,
    C_INPUT_CLK_TYPE                  => DDR2_INPUT_CLK_TYPE,
    C_CLKOUT0_DIVIDE                  => DDR2_CLKOUT0_DIVIDE,
    C_CLKOUT1_DIVIDE                  => DDR2_CLKOUT1_DIVIDE,
    C_CLKOUT2_DIVIDE                  => DDR2_CLKOUT2_DIVIDE,
    C_CLKOUT3_DIVIDE                  => DDR2_CLKOUT3_DIVIDE,
    C_CLKFBOUT_MULT                   => DDR2_CLKFBOUT_MULT,
    C_DIVCLK_DIVIDE                   => DDR2_DIVCLK_DIVIDE,
    C_INCLK_PERIOD                    => DDR2_INCLK_PERIOD
  )
  port map (
    sys_clk_p                       => '0',
    sys_clk_n                       => '0',
    sys_clk                         => CLK_25MHz_SP6_i,
    sys_rst_i                       => Reset_s,
    clk0                            => open,
    rst0                            => open,
    async_rst                       => DDR2_async_rst_s,
    sysclk_2x                       => DDR2_sysclk_2x_s,
    sysclk_2x_180                   => DDR2_sysclk_2x_180_s,
    pll_ce_0                        => DDR2_pll_ce_0_s,
    pll_ce_90                       => DDR2_pll_ce_90_s,
    pll_lock                        => DDR2_pll_lock_s,
    mcb_drp_clk                     => DDR2_mcb_drp_clk_s
  );
  
   -- wrapper instantiation
  memc5_wrapper_inst : memc5_wrapper
  generic map (
    C_MEMCLK_PERIOD                   => DDR2_MEMCLK_PERIOD,
    C_CALIB_SOFT_IP                   => DDR2_CALIB_SOFT_IP,
    C_SIMULATION                      => DDR2_SIMULATION,
    C_P0_MASK_SIZE                    => DDR2_P0_MASK_SIZE,
    C_P0_DATA_PORT_SIZE               => DDR2_P0_DATA_PORT_SIZE,
    C_P1_MASK_SIZE                    => DDR2_P1_MASK_SIZE,
    C_P1_DATA_PORT_SIZE               => DDR2_P1_DATA_PORT_SIZE,
    C_ARB_NUM_TIME_SLOTS              => DDR2_ARB_NUM_TIME_SLOTS,
    C_ARB_TIME_SLOT_0                 => DDR2_ARB_TIME_SLOT_0,
    C_ARB_TIME_SLOT_1                 => DDR2_ARB_TIME_SLOT_1,
    C_ARB_TIME_SLOT_2                 => DDR2_ARB_TIME_SLOT_2,
    C_ARB_TIME_SLOT_3                 => DDR2_ARB_TIME_SLOT_3,
    C_ARB_TIME_SLOT_4                 => DDR2_ARB_TIME_SLOT_4,
    C_ARB_TIME_SLOT_5                 => DDR2_ARB_TIME_SLOT_5,
    C_ARB_TIME_SLOT_6                 => DDR2_ARB_TIME_SLOT_6,
    C_ARB_TIME_SLOT_7                 => DDR2_ARB_TIME_SLOT_7,
    C_ARB_TIME_SLOT_8                 => DDR2_ARB_TIME_SLOT_8,
    C_ARB_TIME_SLOT_9                 => DDR2_ARB_TIME_SLOT_9,
    C_ARB_TIME_SLOT_10                => DDR2_ARB_TIME_SLOT_10,
    C_ARB_TIME_SLOT_11                => DDR2_ARB_TIME_SLOT_11,
    C_MEM_TRAS                        => DDR2_MEM_TRAS,
    C_MEM_TRCD                        => DDR2_MEM_TRCD,
    C_MEM_TREFI                       => DDR2_MEM_TREFI,
    C_MEM_TRFC                        => DDR2_MEM_TRFC,
    C_MEM_TRP                         => DDR2_MEM_TRP,
    C_MEM_TWR                         => DDR2_MEM_TWR,
    C_MEM_TRTP                        => DDR2_MEM_TRTP,
    C_MEM_TWTR                        => DDR2_MEM_TWTR,
    C_MEM_ADDR_ORDER                  => DDR2_MEM_ADDR_ORDER,
    C_NUM_DQ_PINS                     => DDR2_NUM_DQ_PINS,
    C_MEM_TYPE                        => DDR2_MEM_TYPE,
    C_MEM_DENSITY                     => DDR2_MEM_DENSITY,
    C_MEM_BURST_LEN                   => DDR2_MEM_BURST_LEN,
    C_MEM_CAS_LATENCY                 => DDR2_MEM_CAS_LATENCY,
    C_MEM_ADDR_WIDTH                  => DDR2_MEM_ADDR_WIDTH,
    C_MEM_BANKADDR_WIDTH              => DDR2_MEM_BANKADDR_WIDTH,
    C_MEM_NUM_COL_BITS                => DDR2_MEM_NUM_COL_BITS,
    C_MEM_DDR1_2_ODS                  => DDR2_MEM_DDR1_2_ODS,
    C_MEM_DDR2_RTT                    => DDR2_MEM_DDR2_RTT,
    C_MEM_DDR2_DIFF_DQS_EN            => DDR2_MEM_DDR2_DIFF_DQS_EN,
    C_MEM_DDR2_3_PA_SR                => DDR2_MEM_DDR2_3_PA_SR,
    C_MEM_DDR2_3_HIGH_TEMP_SR         => DDR2_MEM_DDR2_3_HIGH_TEMP_SR,
    C_MEM_DDR3_CAS_LATENCY            => DDR2_MEM_DDR3_CAS_LATENCY,
    C_MEM_DDR3_ODS                    => DDR2_MEM_DDR3_ODS,
    C_MEM_DDR3_RTT                    => DDR2_MEM_DDR3_RTT,
    C_MEM_DDR3_CAS_WR_LATENCY         => DDR2_MEM_DDR3_CAS_WR_LATENCY,
    C_MEM_DDR3_AUTO_SR                => DDR2_MEM_DDR3_AUTO_SR,
    C_MEM_DDR3_DYN_WRT_ODT            => DDR2_MEM_DDR3_DYN_WRT_ODT,
    C_MEM_MOBILE_PA_SR                => DDR2_MEM_MOBILE_PA_SR,
    C_MEM_MDDR_ODS                    => DDR2_MEM_MDDR_ODS,
    C_MC_CALIB_BYPASS                 => DDR2_MC_CALIB_BYPASS,
    C_MC_CALIBRATION_MODE             => DDR2_MC_CALIBRATION_MODE,
    C_MC_CALIBRATION_DELAY            => DDR2_MC_CALIBRATION_DELAY,
    C_SKIP_IN_TERM_CAL                => DDR2_SKIP_IN_TERM_CAL,
    C_SKIP_DYNAMIC_CAL                => DDR2_SKIP_DYNAMIC_CAL,
    C_LDQSP_TAP_DELAY_VAL             => DDR2_LDQSP_TAP_DELAY_VAL,
    C_LDQSN_TAP_DELAY_VAL             => DDR2_LDQSN_TAP_DELAY_VAL,
    C_UDQSP_TAP_DELAY_VAL             => DDR2_UDQSP_TAP_DELAY_VAL,
    C_UDQSN_TAP_DELAY_VAL             => DDR2_UDQSN_TAP_DELAY_VAL,
    C_DQ0_TAP_DELAY_VAL               => DDR2_DQ0_TAP_DELAY_VAL,
    C_DQ1_TAP_DELAY_VAL               => DDR2_DQ1_TAP_DELAY_VAL,
    C_DQ2_TAP_DELAY_VAL               => DDR2_DQ2_TAP_DELAY_VAL,
    C_DQ3_TAP_DELAY_VAL               => DDR2_DQ3_TAP_DELAY_VAL,
    C_DQ4_TAP_DELAY_VAL               => DDR2_DQ4_TAP_DELAY_VAL,
    C_DQ5_TAP_DELAY_VAL               => DDR2_DQ5_TAP_DELAY_VAL,
    C_DQ6_TAP_DELAY_VAL               => DDR2_DQ6_TAP_DELAY_VAL,
    C_DQ7_TAP_DELAY_VAL               => DDR2_DQ7_TAP_DELAY_VAL,
    C_DQ8_TAP_DELAY_VAL               => DDR2_DQ8_TAP_DELAY_VAL,
    C_DQ9_TAP_DELAY_VAL               => DDR2_DQ9_TAP_DELAY_VAL,
    C_DQ10_TAP_DELAY_VAL              => DDR2_DQ10_TAP_DELAY_VAL,
    C_DQ11_TAP_DELAY_VAL              => DDR2_DQ11_TAP_DELAY_VAL,
    C_DQ12_TAP_DELAY_VAL              => DDR2_DQ12_TAP_DELAY_VAL,
    C_DQ13_TAP_DELAY_VAL              => DDR2_DQ13_TAP_DELAY_VAL,
    C_DQ14_TAP_DELAY_VAL              => DDR2_DQ14_TAP_DELAY_VAL,
    C_DQ15_TAP_DELAY_VAL              => DDR2_DQ15_TAP_DELAY_VAL
  )
  port map (
    mcb5_dram_dq                         => DDR2_DQ_io,
    mcb5_dram_a                          => DDR2_A_o,
    mcb5_dram_ba                         => DDR2_BA_o,
    mcb5_dram_ras_n                      => DDR2_nRAS_o,
    mcb5_dram_cas_n                      => DDR2_nCAS_o,
    mcb5_dram_we_n                       => DDR2_WE_o,
    mcb5_dram_odt                        => DDR2_ODT_o,
    mcb5_dram_cke                        => DDR2_CKE_o,
    mcb5_dram_dm                         => DDR2_LDM_o,
    mcb5_dram_udqs                       => DDR2_UDQS_P_o,
    mcb5_dram_udqs_n                     => DDR2_UDQS_N_o,
    mcb5_rzq                             => mcb5_rzq,
    mcb5_zio                             => mcb5_zio,
    mcb5_dram_udm                        => DDR2_UDM_o,
    calib_done                           => DDR2_calib_done_s,
    async_rst                            => DDR2_async_rst_s,
    sysclk_2x                            => DDR2_sysclk_2x_s,
    sysclk_2x_180                        => DDR2_sysclk_2x_180_s,
    pll_ce_0                             => DDR2_pll_ce_0_s,
    pll_ce_90                            => DDR2_pll_ce_90_s,
    pll_lock                             => DDR2_pll_lock_s,
    mcb_drp_clk                          => DDR2_mcb_drp_clk_s,
    mcb5_dram_dqs                        => DDR2_LDQS_P_o,
    mcb5_dram_dqs_n                      => DDR2_LDQS_N_o,
    mcb5_dram_ck                         => DDR2_CK_P_o,
    mcb5_dram_ck_n                       => DDR2_CK_N_o,

    p0_cmd_clk                           =>  SP6_LB_CLK_s,
    p0_cmd_en                            =>  ddr2_cmd_en_s,
    p0_cmd_instr                         =>  ddr2_cmd_instr_s,
    p0_cmd_bl                            =>  ddr2_cmd_bl_s,
    p0_cmd_byte_addr                     =>  ddr2_cmd_byte_addr_s,
    p0_cmd_empty                         =>  open,
    p0_cmd_full                          =>  ddr2_cmd_full_s,
    p0_wr_clk                            =>  SP6_LB_CLK_s,
    p0_wr_en                             =>  ddr2_wr_en_s,
    p0_wr_mask                           =>  ddr2_wr_mask_s,
    p0_wr_data                           =>  ddr2_wr_data_s,
    p0_wr_full                           =>  ddr2_wr_full_s,
    p0_wr_empty                          =>  open,
    p0_wr_count                          =>  ddr2_wr_count_s,
    p0_wr_underrun                       =>  open,
    p0_wr_error                          =>  open,
    p0_rd_clk                            =>  SP6_LB_CLK_s,
    p0_rd_en                             =>  ddr2_rd_en_s,
    p0_rd_data                           =>  ddr2_rd_data_s,
    p0_rd_full                           =>  open,
    p0_rd_empty                          =>  ddr2_rd_empty_s,
    p0_rd_count                          =>  ddr2_rd_count_s,
    p0_rd_overflow                       =>  open,
    p0_rd_error                          =>  open,

    p1_cmd_clk                           =>  '0',
    p1_cmd_en                            =>  '0',
    p1_cmd_instr                         =>  (others => '0'),
    p1_cmd_bl                            =>  (others => '0'),
    p1_cmd_byte_addr                     =>  (others => '0'),
    p1_cmd_empty                         =>  open,
    p1_cmd_full                          =>  open,
    p1_wr_clk                            =>  '0',
    p1_wr_en                             =>  '0',
    p1_wr_mask                           =>  (others => '0'),
    p1_wr_data                           =>  (others => '0'),
    p1_wr_full                           =>  open,
    p1_wr_empty                          =>  open,
    p1_wr_count                          =>  open,
    p1_wr_underrun                       =>  open,
    p1_wr_error                          =>  open,
    p1_rd_clk                            =>  '0',
    p1_rd_en                             =>  '0',
    p1_rd_data                           =>  open,
    p1_rd_full                           =>  open,
    p1_rd_empty                          =>  open,
    p1_rd_count                          =>  open,
    p1_rd_overflow                       =>  open,
    p1_rd_error                          =>  open,

    p2_cmd_clk                           =>  '0',
    p2_cmd_en                            =>  '0',
    p2_cmd_instr                         =>  (others => '0'),
    p2_cmd_bl                            =>  (others => '0'),
    p2_cmd_byte_addr                     =>  (others => '0'),
    p2_cmd_empty                         =>  open,
    p2_cmd_full                          =>  open,
    p2_wr_clk                            =>  '0',
    p2_wr_en                             =>  '0',
    p2_wr_mask                           =>  (others => '0'),
    p2_wr_data                           =>  (others => '0'),
    p2_wr_full                           =>  open,
    p2_wr_empty                          =>  open,
    p2_wr_count                          =>  open,
    p2_wr_underrun                       =>  open,
    p2_wr_error                          =>  open,
    p2_rd_clk                            =>  '0',
    p2_rd_en                             =>  '0',
    p2_rd_data                           =>  open,
    p2_rd_full                           =>  open,
    p2_rd_empty                          =>  open,
    p2_rd_count                          =>  open,
    p2_rd_overflow                       =>  open,
    p2_rd_error                          =>  open,

    p3_cmd_clk                           =>  '0',
    p3_cmd_en                            =>  '0',
    p3_cmd_instr                         =>  (others => '0'),
    p3_cmd_bl                            =>  (others => '0'),
    p3_cmd_byte_addr                     =>  (others => '0'),
    p3_cmd_empty                         =>  open,
    p3_cmd_full                          =>  open,
    p3_wr_clk                            =>  '0',
    p3_wr_en                             =>  '0',
    p3_wr_mask                           =>  (others => '0'),
    p3_wr_data                           =>  (others => '0'),
    p3_wr_full                           =>  open,
    p3_wr_empty                          =>  open,
    p3_wr_count                          =>  open,
    p3_wr_underrun                       =>  open,
    p3_wr_error                          =>  open,
    p3_rd_clk                            =>  '0',
    p3_rd_en                             =>  '0',
    p3_rd_data                           =>  open,
    p3_rd_full                           =>  open,
    p3_rd_empty                          =>  open,
    p3_rd_count                          =>  open,
    p3_rd_overflow                       =>  open,
    p3_rd_error                          =>  open,

    selfrefresh_enter                    =>  '0',
    selfrefresh_mode                     =>  open
  );
end Behavioral;               