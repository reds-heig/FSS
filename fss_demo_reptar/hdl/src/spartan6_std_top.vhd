------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : spartan6_std_top.vhd
-- Author               : Evangelina Lolivier-Exler
-- Date                 : 16.10.2013
-- Target Devices       : Spartan6 XC6SLX150T-3FGG900
--
-- Context              : Reptar - FPGA design
--
-------------------------------------------------------------------------------------------------
-- Description :        REPTAR standard design for Spartan6
--                      access to the peripherals by the ARM CPU (DM3730) through the local bus
-------------------------------------------------------------------------------------------------
-- Information :
--------------------------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Engineer     Comments
-- 0.0   See header   ELR           Initial version, based on Spartan6_top of VTT 
--------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;
use work.mcb_ddr2_pkg.all;
use work.lba_sp6_registers_pkg.all;

entity spartan6_std_top is
    port(
    		-- CLOCK
			SP6_Clk_100MHz_i		:		in std_logic;
			CLK_25MHz_SP6_i			:		in std_logic;			
			-- LOCAL BUS
			SP6_LB_RE_nOE_i			:		in std_logic;
			SP6_LB_nWE_i			:		in std_logic;
			SP6_LB_WAIT3_o			:		out std_logic;
			SP6_LB_nCS3_i			:		in std_logic;
			SP6_LB_nCS4_i			:		in std_logic;
			SP6_LB_nADV_ALE_i		:		in std_logic;
			SP6_LB_nBE0_CLE_i		:		in std_logic;
			SP6_LB_WAIT0_o			:		out std_logic;
			SP6_LB_CLK_i			:		in std_logic;
			-- these are 16-bit word adresses, bit0 from CPU is not wired!! (on CPU side the addresses are always byte adresses) 
			Addr_Data_LB_io			:		inout std_logic_vector(15 downto 0);
			Addr_LB_i				:		in std_logic_vector(24 downto 16);	
			--7SEG
			SP6_7seg1_o				:		out std_logic_vector(6 downto 0);
			SP6_7seg2_o				:		out std_logic_vector(6 downto 0);
			SP6_7seg3_o				:		out std_logic_vector(6 downto 0);
			SP6_7seg1_DP_o			:		out std_logic;
			SP6_7seg2_DP_o			:		out std_logic;
			SP6_7seg3_DP_o			:		out std_logic;			
			-- SWITCH PB
			SW_PB_i					:		in std_logic_vector(8 downto 1);			
			-- MICTOR
			MICTOR_SP6_A0_o		    :		out std_logic_vector(7 downto 0);
			MICTOR_SP6_A1_o		    :		out std_logic_vector(7 downto 0);
			MICTOR_SP6_A2_o		    :		out std_logic_vector(7 downto 0);
			MICTOR_SP6_A3_o		    :		out std_logic_vector(7 downto 0);
			MICTOR_SP6_CLK_0_o	    :		out std_logic;
			MICTOR_SP6_CLK_1_o	    :		out std_logic;			
			--GPIOs (diffs, called gpio_1_n/p .. gpio_5_n/p on schematics):
				-- gpio_1_n, 1_p, 2_n, 2_p and 3_p , used for sp6 configuration from sp3, 
				-- gpio_3_n et 4_p connected to leds on CPU board, 
				-- gpio_4_n, 5_p and 5_n connected to switches on CPU board
			SP6_GPIO_DIFFS_i        :       in std_logic_vector(9 downto 0);		
			                    
			--Conn REDS 80p
			SP6_DKK_io				:		inout std_logic_vector(80 downto 1);		
			--I2C: to FMC boards
--			note: I2C_SDA_1V8_o is temporarily declared as output for test of i2c lines wired to FMC boards			
			I2C_SCL_1V8_o			:		out std_logic;
			I2C_SDA_1V8_o			:		out std_logic;  -- must be declared as inout and connected to a master i2c instance to be able to communicate with i2c devices of FMC mezzanine boards
			--I2C: from CPU
--			note: SP6_I2C_SDA_i is temporarily declared as input for test of i2c lines wired to FMC boards
			SP6_I2C_SCL_i		    :		in std_logic;
			SP6_I2C_SDA_i		    :		in std_logic; -- must be declared as inout and connected to a slave i2c instance to be able to communicate with CPU
			--SPI
				-- cs1: to accelerometer
			SP6_SPI_nCS1_o 	   		:	    out std_logic;
			SP6_ACC_SPI_SDI_o    		:	    out std_logic;
			SP6_ACC_SPI_SCL_o    		:	    out std_logic;
			SP6_ACC_SPI_SDO_i		: 	    in std_logic;
			-- accelerometer interrupts
			SP6_ACC_INT1_i			:		in std_logic;
			SP6_ACC_INT2_i			:		in std_logic;

				-- cs2: to w3 connector
			SP6_SPI_nCS2_o			:		out std_logic;
				-- cs3: from cpu
			SP6_SPI_nCS3_i			:		in std_logic;
				-- cs4: to BTB connector 
                --      not connected to CPU in REPTAR_CPU v1.1!, reserved for futur version of cpu boards with more spi cs outputs
			SP6_SPI_nCS4_i			:		in std_logic;
				-- from cpu
			SP6_SPI_SDO_i			:		in std_logic;
			SP6_SPI_SDI_o			:		out std_logic;
			SP6_SPI_SCLK_i			:		in std_logic;

			--FTDI
			FTDI_TX_i				:		in std_logic;
			FTDI_RX_o				:		out std_logic;
			FTDI_nRESET_o			:		out std_logic;
			FTDI_nRTS_i             :       in  std_logic; -- FTDI_nRTS_i input, not tested!!
			FTDI_nCTS_o             :	    out std_logic;
			--FMC1	
			FMC1_PRSNT_M2C_L_i		:       in  std_logic;
			FMC1_LA_P_io			:       inout std_logic_vector(33 downto 0);
			FMC1_LA_N_io			:       inout std_logic_vector(33 downto 0);
			FMC1_CLK1_M2C_P_i		:       in std_logic;		-- FMC1_CLK0_C2M_P dans schéma
			FMC1_CLK1_M2C_N_i		:       in std_logic;
			FMC1_CLK0_M2C_P_i		:       in std_logic;
			FMC1_CLK0_M2C_N_i		:       in std_logic;
			--FMC2      
			FMC2_PRSNT_M2C_L_i		:       in  std_logic;
			FMC2_LA_P_io			:       inout std_logic_vector(33 downto 0);
			FMC2_LA_N_io			:       inout std_logic_vector(33 downto 0);
			FMC2_CLK1_M2C_P_i		:       in std_logic;		-- FMC2_CLK0_C2M_P dans schéma
			FMC2_CLK1_M2C_N_i		:       in std_logic;
			FMC2_CLK0_M2C_P_i		:       in std_logic;
			FMC2_CLK0_M2C_N_i		:       in std_logic;			
			--GPIO connected to the BTB but not connected to the CPU, not used (3.3V)
			SP6_GPIO_22_i			:		in std_logic;
			--AD
			AD_GPIO_o				:		out std_logic_vector(3 downto 0);
			AD_SDI_o				:		out std_logic;
			AD_nCS_o				:		out std_logic;
			AD_CLK_o				:		out std_logic;
			AD_SDO_i				:		in std_logic;
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
			--PCI PERST, connected to BTB in FPGA board, but not connected on CPU board: reserved for futur CPU board versions
			PCI_PERST_o			    :		out std_logic;
			--CAN, not tested!!
			CAN_RXD_i				:		in std_logic;
			CAN_TXD_o				:		out std_logic;
			--GPIOs 1V8 -> connected between FPGA and CPU 
                -- SP6_GPIO18_1_o: SYS_CLKOUT1 from CPU (can be used as GPIO), not tested as clock!!
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
end spartan6_std_top;

architecture Behavioral of spartan6_std_top is

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
  
	component reds_conn_tristate
		port(	clk_i					:		in std_logic;
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
	end component reds_conn_tristate;
	
	component fmc_conn_tristate is
	port(	clk_i					: in std_logic;
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
	end component fmc_conn_tristate; 

	component gpio_conn_tristate
		port(	
				-- global
				clk_i					:		in std_logic;
				reset_i					:		in std_logic;
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
				GPIO_3V3_TRIS_i			:		in std_logic_vector(4 downto 1)
				
		);
	end component gpio_conn_tristate;
	
	component Open_Collector
    port(
      nOE_i         : in    std_logic;
      InOut_io      : inout std_logic;
      In_o          : out   std_logic
    );
  end component; -- Open_Collector

component lba_ctrl is
	port(
    clk_i				    : in std_logic;
	reset_i				    : in std_logic;
	-- from DM3730 GPMC trough Local Bus
	nCS3_LB_i				: in std_logic;
	nADV_LB_i				: in std_logic;
	nOE_LB_i				: in std_logic;
	nWE_LB_i				: in std_logic;
	Addr_LB_i				: in std_logic_vector(24 downto 16);
    lba_nwait_o              : out std_logic;
	-- from/to tri-state buffer on the top
	lb_add_data_wr_i		: in std_logic_vector(15 downto 0);
	lba_oe_o				: out std_logic;	-- lba_data_rd is connected directly to the LB data mux
	-- from/to lba_std_interface and lba_usr_interface
	lba_wr_en_o             : out std_logic;
	lba_rd_en_o             : out std_logic;
	lba_add_o               : out std_logic_vector(22 downto 0);
	lba_cs_std_o       		: out std_logic; 
	lba_cs_usr_rd_o       	: out std_logic; 
    lba_cs_usr_wr_o       	: out std_logic; 
	lba_wait_usr_i    		: in std_logic
	);
end component lba_ctrl;

constant LBS_FIFO_PORT_SIZE_c : integer := 32;

component lbs_ctrl is
  generic (
    GPMC_BURST_LEN  : integer;
    GPMC_DATA_SIZE  : integer;
    FIFO_PORT_SIZE   : integer
  );
  port (  
    rst_i                   : in     STD_LOGIC;  
    -- to/from DM3730 GPMC through Local Bus
    gpmc_ckl_i              : in	STD_LOGIC;
    gpmc_a_i                : in    STD_LOGIC_VECTOR (8 downto 0);
    gpmc_d_i                : in    STD_LOGIC_VECTOR (GPMC_DATA_SIZE-1 downto 0);
    gpmc_d_o                : out   STD_LOGIC_VECTOR (GPMC_DATA_SIZE-1 downto 0);
    gpmc_d_tris_o           : out   STD_LOGIC;		-- '1' input, '0' output
    gpmc_nCS_i              : in    STD_LOGIC;
    gpmc_nADV_i             : in    STD_LOGIC;
    gpmc_nWE_i              : in    STD_LOGIC;
    gpmc_nOE_i              : in    STD_LOGIC;
    gpmc_nWait_o            : out   STD_LOGIC;
    -- to/from command FIFO 
    lbs_fifo_cmd_addr_o    : out   STD_LOGIC_VECTOR (29 downto 0);
    lbs_fifo_cmd_bl_o      : out   STD_LOGIC_VECTOR (5 downto 0);   -- burst length
    lbs_fifo_cmd_en_o      : out   STD_LOGIC;
    lbs_fifo_cmd_full_i    : in    STD_LOGIC;
    lbs_fifo_cmd_instr_o   : out   STD_LOGIC_VECTOR (2 downto 0);   --
    -- to/from data read FIFO 
    lbs_fifo_wr_data_o     : out   STD_LOGIC_VECTOR (FIFO_PORT_SIZE-1 downto 0);
    lbs_fifo_wr_en_o       : out   STD_LOGIC;
    lbs_fifo_wr_full_i     : in    STD_LOGIC;
    lbs_fifo_wr_mask_o     : out   STD_LOGIC_VECTOR (FIFO_PORT_SIZE/8-1 downto 0);
    -- to/from data write FIFO 
    lbs_fifo_rd_en_o       : out   STD_LOGIC;
    lbs_fifo_rd_data_i     : in    STD_LOGIC_VECTOR (FIFO_PORT_SIZE-1 downto 0);
    lbs_fifo_rd_empty_i    : in    STD_LOGIC;
    lbs_fifo_rd_count_i    : in    STD_LOGIC_VECTOR (6 downto 0);
    -- from Memory Controller Block (IP Xilinx)
	mcb_calib_done_i        : in   STD_LOGIC;
    -- debug    
    interface_state_o       : out  STD_LOGIC_VECTOR (3 downto 0);
	error_o                 : out  STD_LOGIC
  );
end component lbs_ctrl;





component lba_std_interface is
    port(
    clk_i				    : in std_logic;
	-- clock for touch pad controller (25 MHz)
	clk_tp_i				: in std_logic;
    reset_i				    : in std_logic;
    -- to/from lba_ctrl            
    lba_cs_std_i            : in std_logic;
    lba_wr_en_i             : in std_logic;
    lba_rd_en_i             : in std_logic;
    lba_add_i               : in std_logic_vector(22 downto 0);
    -- to mux data std/user on top level
    lba_data_rd_std_o       : out std_logic_vector(15 downto 0);
    -- from tri-state buffer on top level
    lba_data_wr_i           : in std_logic_vector(15 downto 0);
    ------------------------------ ----------------------------------------------
    -- IRQ generation              
        -- from usr_interface      
    lba_irq_user_i          : in std_logic;
    lbs_irq_user_i          : in std_logic;
        -- to BTB connector        
    irq_o                   : out std_logic;
    ------------------------------------------------------------------------------
    -- SPI, DM3730 is master, SP6 is slave 
    -- (only 1 CS come from DM3730, multiplexed by SP6 between Acc, AD, DA and header)
        -- to/from BTB connector
    spi_ncs_i              : in std_logic; 
    spi_clk_i              : in std_logic;
    spi_simo_i             : in std_logic;
    spi_somi_o             : out std_logic;
        -- to/from accelerometer
    spi_acc_ncs_o            : out std_logic;
    spi_acc_clk_o           : out std_logic;
    spi_acc_sdi_o           : out std_logic;
    spi_acc_sdo_i           : in  std_logic;
        -- to/from ADC         
    spi_adc_ncs_o            : out std_logic;
    spi_adc_clk_o           : out std_logic;
    spi_adc_sdi_o           : out std_logic;
    spi_adc_sdo_i           : in std_logic;
	adc_gpio_o				: out std_logic_vector(3 downto 0);
        -- to/from DAC         
    spi_dac_ncs_o            : out std_logic;
    spi_dac_clk_o           : out std_logic;
    spi_dac_sdi_o           : out std_logic;
        -- to/from SPI header connector (W3)
        -- data and clk signals are directly wired from BTB
    spi_conn_ncs_o           : out std_logic;
	-----------------------------------------------------------------------------------
	-- to DAC
	dac_nldac_o				  	:		out std_logic;			
	dac_nrs_o           		:		out std_logic;
    -----------------------------------------------------------------------------------
    -- to 7-segments displays
    disp_7seg1_o			: out std_logic_vector(6 downto 0);
	disp_7seg2_o			: out std_logic_vector(6 downto 0);
	disp_7seg3_o			: out std_logic_vector(6 downto 0);
	disp_7seg1_DP_o			: out std_logic;
	disp_7seg2_DP_o			: out std_logic;
	disp_7seg3_DP_o			: out std_logic;	
    --------------------------------------------------------------------------------------
    -- to/from switches and LEDs
    -- push-buttons
	push_but_i				: in std_logic_vector(8 downto 1);	
	--DIPs                         
	dip_i					: in std_logic_vector(9 downto 0);
	--LEDs                         
	led_o				    : out std_logic_vector(7 downto 0);
    ------------------------------------------------------------------------------------------
    -- LCD
	lcd_rs_o				: out std_logic;
	lcd_rw_o				: out std_logic;
	lcd_e_o		  	        : out std_logic;
	    -- to/from tri-state buffer on top: LCD data bus
	lcd_data_i	            : in std_logic_vector(7 downto 0);
	lcd_data_o	            : out std_logic_vector(7 downto 0);
	lcd_data_oe_o           : out std_logic;
    -------------------------------------------------------------------------------------------------------------
    -- to/from touch pad open collector
    touch_pad_oe            : out std_logic;
    touch_pad_i             : in std_logic;
    ---------------------------------------------------------------------------------------------
    -- from encoder
    enc_a_inc_i             : in std_logic;
    enc_b_inc_i             : in std_logic;
    ---------------------------------------------------------------------------------------------
    -- to buzzer
    buzzer_osc_o            : out std_logic;
    -------------------------------------------------------------------------------------------
    --UART header
	uart_header_cts_o		: out std_logic;
	uart_header_rts_i		: in std_logic;
	uart_header_rx_i		: in std_logic;
	uart_header_tx_o		: out std_logic;
    -------------------------------------------------------------------------------------------
    -- GPIOs: to/from tri-state buffers on top
        -- GPIO_x
        -- GPIO_x(11..9) are in 16-pin header connector J8 , GPIO_x(8..1) are in 8-pin header connector W1 
    gpio_x_i                : in std_logic_vector(11 downto 1);
    gpio_x_o                : out std_logic_vector(11 downto 1);
    gpio_x_oe_o             : out std_logic_vector(11 downto 1);
        -- GPIO33_x : 16-pin header connector J38 
        -- GPIO33_x(5) is reserved for reset from CPU
    gpio33_x_i                : in std_logic_vector(4 downto 1);
    gpio33_x_o                : out std_logic_vector(4 downto 1);
    gpio33_x_oe_o             : out std_logic_vector(4 downto 1);
        -- GPIO_Hx : 16-pin header connector J39
    gpio_Hx_i                : in std_logic_vector(8 downto 1);
    gpio_Hx_o                : out std_logic_vector(8 downto 1);
    gpio_Hx_oe_o             : out std_logic_vector(8 downto 1);
    ------------------------------------------------------------------------------------------------------
    --FMC1
        -- LA00_P/N TO LA07_P/N
	fmc1_gpio1_i		: 		in std_logic_vector(15 downto 0);
	fmc1_gpio1_o		: 		out std_logic_vector(15 downto 0);
    fmc1_gpio1_oe_o		: 		out std_logic_vector(15 downto 0);
        -- LA08_P/N TO LA15_P/N
    fmc1_gpio2_i		: 		in std_logic_vector(15 downto 0);
    fmc1_gpio2_o		: 		out std_logic_vector(15 downto 0);
    fmc1_gpio2_oe_o		: 		out std_logic_vector(15 downto 0);
        -- LA16_P/N TO LA23_P/N
	fmc1_gpio3_i		: 		in std_logic_vector(15 downto 0);
    fmc1_gpio3_o		: 		out std_logic_vector(15 downto 0);
    fmc1_gpio3_oe_o		: 		out std_logic_vector(15 downto 0);
        -- LA24_P/N TO LA31_P/N
	fmc1_gpio4_i		: 		in std_logic_vector(15 downto 0);
    fmc1_gpio4_o		: 		out std_logic_vector(15 downto 0);
    fmc1_gpio4_oe_o		: 		out std_logic_vector(15 downto 0);
        -- LA32_P/N TO LA33_P/N
        -- for FMC DEBUG XM105 board:    fmc1_gpio5_io(3..0): LEDS DS4..DS1 
    fmc1_gpio5_i		: 		in std_logic_vector(3 downto 0);
	fmc1_gpio5_o		: 		out std_logic_vector(3 downto 0);
	fmc1_gpio5_oe_o		: 		out std_logic_vector(3 downto 0);
        -- presence detection (pin H2 du FMC)
    fmc1_prsnt_i        :       in std_logic;
    ------------------------------------------------------------------------------------------------------------
	--FMC2
        -- LA00_P/N TO LA07_P/N
	fmc2_gpio1_i		: 		in std_logic_vector(15 downto 0);
	fmc2_gpio1_o		: 		out std_logic_vector(15 downto 0);
    fmc2_gpio1_oe_o		: 		out std_logic_vector(15 downto 0);
       -- LA08_P/N TO LA15_P/N
    fmc2_gpio2_i		: 		in std_logic_vector(15 downto 0);
    fmc2_gpio2_o		: 		out std_logic_vector(15 downto 0);
    fmc2_gpio2_oe_o		: 		out std_logic_vector(15 downto 0);
       -- LA16_P/N TO LA23_P/N
	fmc2_gpio3_i		: 		in std_logic_vector(15 downto 0);
    fmc2_gpio3_o		: 		out std_logic_vector(15 downto 0);
    fmc2_gpio3_oe_o		: 		out std_logic_vector(15 downto 0);
       -- LA24_P/N TO LA31_P/N
	fmc2_gpio4_i		: 		in std_logic_vector(15 downto 0);
    fmc2_gpio4_o		: 		out std_logic_vector(15 downto 0);
    fmc2_gpio4_oe_o		: 		out std_logic_vector(15 downto 0);
       -- LA32_P/N TO LA33_P/N
       -- for FMC DEBUG XM105 board:    fmc2_gpio5_io(3..0): LEDS DS4..DS1 
       --                               fmc2_gpio5_io(4):     presence detection (pin H2 du FMC)	
    fmc2_gpio5_i		: 	    in std_logic_vector(3 downto 0);
	fmc2_gpio5_o		: 		out std_logic_vector(3 downto 0);
	fmc2_gpio5_oe_o		: 		out std_logic_vector(3 downto 0);
        -- presence detection (pin H2 du FMC)
    fmc2_prsnt_i        :       in std_logic;
    ---------------------------------------------------------------------------------------------------------
    -- 80-pin DKK (REDS connector)
        -- pins 1 to 16
    reds_80p_gpio1_i		: 		in std_logic_vector(16 downto 1);
	reds_80p_gpio1_o		: 		out std_logic_vector(16 downto 1);
    reds_80p_gpio1_oe_o		: 		out std_logic_vector(16 downto 1);
        -- pins 17 to 32
    reds_80p_gpio2_i		: 		in std_logic_vector(32 downto 17);
	reds_80p_gpio2_o		: 		out std_logic_vector(32 downto 17);
    reds_80p_gpio2_oe_o		: 		out std_logic_vector(32 downto 17);
        --  pins 33 to 48
	reds_80p_gpio3_i		: 		in std_logic_vector(48 downto 33);
	reds_80p_gpio3_o		: 		out std_logic_vector(48 downto 33);
    reds_80p_gpio3_oe_o		: 		out std_logic_vector(48 downto 33);
        --  pins 49 to 64
	reds_80p_gpio4_i		: 		in std_logic_vector(64 downto 49);
	reds_80p_gpio4_o		: 		out std_logic_vector(64 downto 49);
    reds_80p_gpio4_oe_o		: 		out std_logic_vector(64 downto 49);
        -- pins 65 to 80
    reds_80p_gpio5_i		: 		in std_logic_vector(80 downto 65);
	reds_80p_gpio5_o		: 		out std_logic_vector(80 downto 65);
    reds_80p_gpio5_oe_o		: 		out std_logic_vector(80 downto 65)
    ---------------------------------------------------------------------------------------------------------------
    );

end component lba_std_interface;  
-----------------------------------------------------------------------------------------------------------------------------------------------
-- MCB Memory Controller Block (Xilinx IP for DDR2 control)
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
	
	component lba_user_interface is
	port (
		
		clk_i	               : in std_logic; -- must be a 200 Mhz clock       
		reset_i                : in std_logic;        
		
		lba_cs_usr_rd_i        : in std_logic;
        lba_cs_usr_wr_i        : in std_logic;
		lba_wr_en_i            : in std_logic;
		lba_rd_en_i            : in std_logic;
		
		lba_add_i              : in std_logic_vector(22 downto 0);
		lba_data_wr_i          : in std_logic_vector(15 downto 0);        
		
		lba_data_rd_user_o     : out std_logic_vector(15 downto 0);           
		lba_wait_user_o        : out std_logic;
		lba_irq_user_o		   : out std_logic
		
		);
	end  component lba_user_interface;
    
    
   component debounce IS
    GENERIC(
        counter_size  :  INTEGER := 3); --counter size (19 bits gives 10.5ms with 50MHz clock)
    PORT(
        clk_i       : in  std_logic;  --input clock
        reset_i     : in  std_logic;  --input clock
        button_i    : in  std_logic;  --input signal to be debounced
        enable_i    : in  std_logic;    
        result_o    : out std_logic); --debounced signal
    END component;
    
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- signals for PLL outputs 	
	signal	CLK_200MHz_s			: 		std_logic;
		
-- global reset
	signal  reset_s					:		std_logic;
	
-- LCD
	signal	lcd_cmd_s				:		std_logic_vector(7 downto 0);
	signal	lcd_rs_s				:		std_logic;
	signal	lcd_rw_s				:		std_logic;
	signal	lcd_start_cmd_s			:		std_logic;	
	signal	lcd_ready_s				:		std_logic;
	signal	lcd_return_data_s		:		std_logic_vector(7 downto 0);
	signal	lcd_start_reset_s		:		std_logic;
	signal  lcd_db_in_s           	:		std_logic_vector(7 downto 0);
	signal  lcd_db_out_s          	:		std_logic_vector(7 downto 0);
	signal  lcd_db_oe_s           	:		std_logic;
	signal  lcd_db_tris_s           :		std_logic;

-- GPIO header connectors	
	signal	gpio_x_reg_lbout_s		:		std_logic_vector(11 downto 1);
	signal	gpio_h_reg_lbout_s    	:		std_logic_vector(8 downto 1);
	signal	gpio_3v3_reg_lbout_s	:		std_logic_vector(4 downto 1);
	signal	gpio_x_reg_lbin_s   	:		std_logic_vector(11 downto 1);
	signal	gpio_h_reg_lbin_s    	:		std_logic_vector(8 downto 1);
	signal	gpio_3v3_reg_lbin_s     :		std_logic_vector(4 downto 1);
	signal  gpio_x_tris_s			:		std_logic_vector(11 downto 1);
	signal  gpio_h_tris_s			:		std_logic_vector(8  downto 1);
	signal  gpio_3v3_tris_s			:		std_logic_vector(4 downto 1);
	signal  gpio_x_oe_s				:		std_logic_vector(11 downto 1);
	signal  gpio_h_oe_s				:		std_logic_vector(8  downto 1);
	signal  gpio_3v3_oe_s			:		std_logic_vector(4 downto 1);

 -- REDS connector (DKK 80-p)	
	signal 	reds_conn1_reg_lbout_s	: std_logic_vector(16 downto 1);
	signal 	reds_conn2_reg_lbout_s	: std_logic_vector(16 downto 1);
	signal 	reds_conn3_reg_lbout_s	: std_logic_vector(16 downto 1);
	signal 	reds_conn4_reg_lbout_s	: std_logic_vector(16 downto 1);
	signal 	reds_conn5_reg_lbout_s	: std_logic_vector(16 downto 1);
	signal 	reds_conn1_reg_lbin_s	: std_logic_vector(16 downto 1);
	signal 	reds_conn2_reg_lbin_s	: std_logic_vector(16 downto 1);
	signal 	reds_conn3_reg_lbin_s	: std_logic_vector(16 downto 1);
	signal 	reds_conn4_reg_lbin_s	: std_logic_vector(16 downto 1);
	signal 	reds_conn5_reg_lbin_s	: std_logic_vector(16 downto 1);
	signal	reds_conn1_tris_s		:  std_logic_vector(16 downto 1);	
	signal  reds_conn2_tris_s		: std_logic_vector(16 downto 1);
	signal  reds_conn3_tris_s		: std_logic_vector(16 downto 1);
	signal  reds_conn4_tris_s		: std_logic_vector(16 downto 1);
	signal  reds_conn5_tris_s		: std_logic_vector(16 downto 1);
	signal	reds_conn1_oe_s			: std_logic_vector(16 downto 1);	
	signal  reds_conn2_oe_s			: std_logic_vector(16 downto 1);
	signal  reds_conn3_oe_s			: std_logic_vector(16 downto 1);
	signal  reds_conn4_oe_s			: std_logic_vector(16 downto 1);
	signal  reds_conn5_oe_s			: std_logic_vector(16 downto 1);

	-- fmc1_tristate
	signal  fmc1_gpio1_reg_lb2fmc_s	: std_logic_vector(15 downto 0);	
	signal  fmc1_gpio2_reg_lb2fmc_s	: std_logic_vector(15 downto 0);	
	signal  fmc1_gpio3_reg_lb2fmc_s	: std_logic_vector(15 downto 0);	
	signal  fmc1_gpio4_reg_lb2fmc_s	: std_logic_vector(15 downto 0);	
	signal  fmc1_gpio5_reg_lb2fmc_s	: std_logic_vector(3 downto 0);	
	signal  fmc1_gpio1_reg_fmc2lb_s	: std_logic_vector(15 downto 0);	
	signal  fmc1_gpio2_reg_fmc2lb_s	: std_logic_vector(15 downto 0);	
	signal  fmc1_gpio3_reg_fmc2lb_s	: std_logic_vector(15 downto 0);	
	signal  fmc1_gpio4_reg_fmc2lb_s	: std_logic_vector(15 downto 0);	
	signal  fmc1_gpio5_reg_fmc2lb_s	: std_logic_vector(3 downto 0);
	signal  fmc1_gpio4_s 			: std_logic_vector(15 downto 0);			
	signal  fmc1_tris1_s			: std_logic_vector(15 downto 0);			
	signal  fmc1_tris2_s			: std_logic_vector(15 downto 0);			
	signal  fmc1_tris3_s			: std_logic_vector(15 downto 0);			
	signal  fmc1_tris4_s			: std_logic_vector(15 downto 0);	
	signal  fmc1_oe1_reg_s			: std_logic_vector(15 downto 0);			
	signal  fmc1_oe2_reg_s			: std_logic_vector(15 downto 0);			
	signal  fmc1_oe3_reg_s			: std_logic_vector(15 downto 0);			
	signal  fmc1_oe4_reg_s			: std_logic_vector(15 downto 0);	
	signal	fmc1_clk0_loop_s		: std_logic;
	signal	fmc1_clk1_loop_s		: std_logic;
	
	-- fmc2_tristate
	signal  fmc2_gpio1_reg_lb2fmc_s	: std_logic_vector(15 downto 0);	
	signal  fmc2_gpio2_reg_lb2fmc_s	: std_logic_vector(15 downto 0);	
	signal  fmc2_gpio3_reg_lb2fmc_s	: std_logic_vector(15 downto 0);	
	signal  fmc2_gpio4_reg_lb2fmc_s	: std_logic_vector(15 downto 0);	
	signal  fmc2_gpio5_reg_lb2fmc_s	: std_logic_vector(3 downto 0);	
	signal  fmc2_gpio1_reg_fmc2lb_s	: std_logic_vector(15 downto 0);	
	signal  fmc2_gpio2_reg_fmc2lb_s	: std_logic_vector(15 downto 0);	
	signal  fmc2_gpio3_reg_fmc2lb_s	: std_logic_vector(15 downto 0);	
	signal  fmc2_gpio4_reg_fmc2lb_s	: std_logic_vector(15 downto 0);	
	signal  fmc2_gpio5_reg_fmc2lb_s	: std_logic_vector(3 downto 0);
	signal  fmc2_gpio4_s 			: std_logic_vector(15 downto 0);			
	signal  fmc2_tris1_s			: std_logic_vector(15 downto 0);			
	signal  fmc2_tris2_s			: std_logic_vector(15 downto 0);			
	signal  fmc2_tris3_s			: std_logic_vector(15 downto 0);			
	signal  fmc2_tris4_s			: std_logic_vector(15 downto 0);	
	signal  fmc2_oe1_reg_s			: std_logic_vector(15 downto 0);			
	signal  fmc2_oe2_reg_s			: std_logic_vector(15 downto 0);			
	signal  fmc2_oe3_reg_s			: std_logic_vector(15 downto 0);			
	signal  fmc2_oe4_reg_s			: std_logic_vector(15 downto 0);	
	signal	fmc2_clk0_loop_s		: std_logic;
	signal	fmc2_clk1_loop_s		: std_logic;
	                                      
	-- Touch Pad Button                   
	signal tpb_oe_s					: std_logic;
    signal tpb_stat_s               : std_logic;

	-- Local Bus Asynchronous Controller
	signal lba_cs_std_s       		: std_logic; 
	signal lba_cs_usr_wr_s       	: std_logic; 
    signal lba_cs_usr_rd_s     		: std_logic;
	signal lba_wr_en_s              : std_logic;
	signal lba_rd_en_s              : std_logic;
	signal lba_wait_std_s     		: std_logic;
	signal lba_wait_usr_s     		: std_logic;
	signal lba_add_s                : std_logic_vector(22 downto 0);
	signal lba_oe_s					: std_logic;
	signal lba_data_rd_std_s		: std_logic_vector(15 downto 0);
	signal lba_data_rd_usr_s		: std_logic_vector(15 downto 0);
	signal lba_data_rd_s			: std_logic_vector(15 downto 0);

    
	
	-- Local Bus Synchronous Controller
	signal lbs_cs_std_s       		: std_logic; 
	signal lbs_wr_en_s              : std_logic;
	signal lbs_rd_en_s              : std_logic;
	signal lbs_wait_std_s     		: std_logic;
	signal lbs_add_s                : std_logic_vector(22 downto 0);
	signal lbs_tris_s				: std_logic;
	signal lbs_data_rd_s			: std_logic_vector(15 downto 0);
	signal lbs_fifo_cmd_addr_s      : std_logic_vector(29 downto 0);
	signal lbs_fifo_cmd_bl_s        : std_logic_vector(5 downto 0);
	signal lbs_fifo_cmd_en_s        : std_logic;
	signal lbs_fifo_cmd_full_s      : std_logic;
	signal lbs_fifo_cmd_instr_s     : std_logic_vector(2 downto 0);
	signal lbs_fifo_wr_data_s       : std_logic_vector(LBS_FIFO_PORT_SIZE_c - 1 downto 0);
	signal lbs_fifo_wr_en_s         : std_logic;
	signal lbs_fifo_wr_full_s       : std_logic;
	signal lbs_fifo_wr_mask_s       : std_logic_vector(LBS_FIFO_PORT_SIZE_c/8 - 1 downto 0);
	signal lbs_fifo_rd_en_s         : std_logic;
	signal lbs_fifo_rd_data_s       : std_logic_vector(LBS_FIFO_PORT_SIZE_c - 1 downto 0);
	signal lbs_fifo_rd_empty_s      : std_logic;
	signal lbs_fifo_rd_count_s      : std_logic_vector(6 downto 0);
	signal mcb_calib_done_s			: std_logic;
	
		
	-- Local Bus tri-state and mux for data source selection
	signal lb_data_rd_s				: std_logic_vector(15 downto 0);
    signal lb_add_data_wr_s			: std_logic_vector(15 downto 0);
	signal lb_oe_s					:      std_logic;
	signal lb_tris_s				: std_logic;
	signal lb_oe_dip_s				: std_logic;
	signal nCS4_nCS3_s          	: std_logic_vector(1 downto 0);
	signal lba_cs_usr_std_s			: std_logic_vector(1 downto 0);
	
	-- Local Bus Asynchronous User Interface
	signal lba_irq_user_s			:		std_logic;
	
	
	
	-- Local Bus Asynchronous User Interface
	signal lbs_irq_user_s			:		std_logic;
	
	-- Memory Controller for DDR2
	signal ddr2_async_rst_s         : std_logic;
	signal ddr2_sysclk_2x_s         : std_logic;
	signal ddr2_sysclk_2x_180_s     : std_logic;
	signal ddr2_pll_ce_0_s          : std_logic;
	signal ddr2_pll_ce_90_s         : std_logic;
	signal ddr2_pll_lock_s          : std_logic;
	signal ddr2_mcb_drp_clk_s       : std_logic;  

    -- Switch debouncing and milisecond prescaler    
    signal sw_PB_debounce_s         : std_logic_vector (8 downto 1);
    signal milisecond_counter       : unsigned(19 downto 0);
    signal milisecond_enable_s      :std_logic;
	
	begin
    
    


 -- global reset 
 reset_s <= not SP6_nReset_i or not uP_nRESET_OUT_i;
 
 -- PLL 
  PLL_inst: clk_PLL_200
  port map( PLL_IN_i           => SP6_Clk_100MHz_i,
            PLL_200MHz_o       => CLK_200MHz_s, 
            PLL_100MHz_o       => open,
            Reset_i            => reset_s,
            locked_o           => open
   );


 -- tri-state buffers for data buses -----------------------------------------------------------------------------------------------------------
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
      O => lcd_db_in_s(i), -- to local bus
      IO => LCD_DB_io(i), -- Buffer inout port (connect directly to top-level port)
      I => lcd_db_out_s(i), -- from local bus
      T => lcd_db_tris_s -- 3-state enable input, high=input, low=output
    );
  end generate;
  
  lcd_db_tris_s <=  not lcd_db_oe_s;
  ------------------------------------------------------------------------------
  	-- iobuf for LB data
	-- IOBUF: Single-ended Bi-directional Buffer
	-- Xilinx HDL Libraries Guide, version 12.4
	 IOBUF_Addresses_Datas : for i in 0 to Addr_Data_LB_io'length-1 generate
    IOBUF_Address_Data : IOBUF
    generic map (
      DRIVE => 12,
	  IOSTANDARD => "LVCMOS18",
      SLEW => "FAST"
    )
    port map (
      O => lb_add_data_wr_s(i), -- Buffer output
      IO => Addr_Data_LB_io(i), -- Buffer inout port (connect directly to top-level port)
      I => lb_data_rd_s(i), -- Buffer input
      T => lb_tris_s -- 3-state enable input, high=input, low=output
    );
  end generate;
 
   nCS4_nCS3_s <= SP6_LB_nCS4_i & SP6_LB_nCS3_i;
   lb_oe_dip_s <= DIP_i(9);

	mux_lb_data:	process (lbs_tris_s, lb_oe_dip_s,lbs_data_rd_s,lba_oe_s,lba_data_rd_s,nCS4_nCS3_s) 
	begin
			case (nCS4_nCS3_s) is
			
				when "01"  =>  -- nCS4 is active: data output from synchronous local bus controller 
							lb_tris_s 	 <= lbs_tris_s or not lb_oe_dip_s;
							lb_data_rd_s <= lbs_data_rd_s;
				when "10"  =>  -- nCS3 is active: data output from asynchronous local bus controller
							lb_tris_s 	 <= not (lba_oe_s and lb_oe_dip_s);
							lb_data_rd_s <= lba_data_rd_s;
				when others => -- input
							lb_tris_s 	 <= '1';
							lb_data_rd_s <= (others => '0');
			end case;
	end process;
	
	
	lba_cs_usr_std_s <= (lba_cs_usr_rd_s or lba_cs_usr_wr_s) & lba_cs_std_s;
	
	mux_lba_data:	process (lba_cs_usr_std_s, lba_data_rd_std_s,lba_data_rd_usr_s) 
	begin
			case (lba_cs_usr_std_s) is
			
				when "01"  =>   
							lba_data_rd_s <= lba_data_rd_std_s;
				when "10"  =>  
							lba_data_rd_s <= lba_data_rd_usr_s;
				when others => 
							lba_data_rd_s <= (others => '1');
			end case;
	end process;


  
  
 ----------------------------------------------------------------------------------------------------------------------------------------------------- 
  -- tri-state buffers for GPIOs -------------------------------------------------------------------------------------------------------------------- 
  	gpio_conn_tristate_inst: gpio_conn_tristate
	port map(	
				clk_i				=>	CLK_200MHz_s,						
	            reset_i				=> reset_s,
				-- to/from pins
	            sp6_header1_conn_io	=> SP6_GPIO_io,
	            sp6_header2_conn_io	=> SP6_GPIO_H_io,
	            sp6_3V3_conn_io		=> SP6_GPIO33_io,
				-- to/from Local bus (lba_std_interface)
	            GPIO_HDR1_REG_i		=> gpio_x_reg_lbout_s,
	            GPIO_HDR2_REG_i		=> gpio_h_reg_lbout_s,
	            GPIO_3V3_REG_i		=> gpio_3v3_reg_lbout_s,	
	            GPIO_HDR1_REG_o		=> gpio_x_reg_lbin_s,
	            GPIO_HDR2_REG_o		=> gpio_h_reg_lbin_s,
	            GPIO_3V3_REG_o		=> gpio_3v3_reg_lbin_s, 
	            GPIO_HDR1_TRIS_i	=> gpio_x_tris_s,
	            GPIO_HDR2_TRIS_i	=> gpio_h_tris_s,
	            GPIO_3V3_TRIS_i		=> gpio_3v3_tris_s
	            
	);

	gpio_x_tris_s	<= not gpio_x_oe_s;
	gpio_h_tris_s   <= not gpio_h_oe_s;
    gpio_3v3_tris_s <= not gpio_3v3_oe_s;
	
	-- tri-state buffers for REDS CONNECTOR -------------------------------------------------------------------------------------------------------------------- 
	reds_conn_tristate_inst: reds_conn_tristate
	port map(	clk_i				=>	CLK_200MHz_s,					
	            reset_i				=>  reset_s,
	            reds_conn_io		=>  SP6_DKK_io,
	            REDS_CONN_REG1_i	=>  reds_conn1_reg_lbout_s,
	            REDS_CONN_REG2_i	=>  reds_conn2_reg_lbout_s,
	            REDS_CONN_REG3_i	=>  reds_conn3_reg_lbout_s,
	            REDS_CONN_REG4_i	=>  reds_conn4_reg_lbout_s,
	            REDS_CONN_REG5_i	=>  reds_conn5_reg_lbout_s,
	            REDS_CONN_REG1_o	=>  reds_conn1_reg_lbin_s,
	            REDS_CONN_REG2_o	=>  reds_conn2_reg_lbin_s,
	            REDS_CONN_REG3_o	=>  reds_conn3_reg_lbin_s,
	            REDS_CONN_REG4_o	=>  reds_conn4_reg_lbin_s,
	            REDS_CONN_REG5_o	=>  reds_conn5_reg_lbin_s,
	            REDS_CONN_TRIS1_i 	=>  reds_conn1_tris_s, 
	            REDS_CONN_TRIS2_i 	=>  reds_conn2_tris_s,
	            REDS_CONN_TRIS3_i 	=>  reds_conn3_tris_s,
	            REDS_CONN_TRIS4_i	=>  reds_conn4_tris_s,
	            REDS_CONN_TRIS5_i 	=>  reds_conn5_tris_s
	);  
	
	reds_conn1_tris_s	<= not reds_conn1_oe_s;
	reds_conn2_tris_s	<= not reds_conn2_oe_s;
	reds_conn3_tris_s	<= not reds_conn3_oe_s;
	reds_conn4_tris_s	<= not reds_conn4_oe_s;
	reds_conn5_tris_s	<= not reds_conn5_oe_s;

	-- buffers for FMC1 -------------------------------------------------------------------------------------------------------------------------------------------
	fmc_conn_tristate_inst1: fmc_conn_tristate
	port map(	clk_i					=> 	CLK_200MHz_s,
                reset_i					=> 	reset_s,
                FMC_LA_P_io				=> 	FMC1_LA_P_io,		
                FMC_LA_N_io				=> 	FMC1_LA_N_io,		
                FMC_GPIO_LA_REG1_i		=> 	fmc1_gpio1_reg_lb2fmc_s,	
                FMC_GPIO_LA_REG2_i		=> 	fmc1_gpio2_reg_lb2fmc_s,	
                FMC_GPIO_LA_REG3_i		=> 	fmc1_gpio3_reg_lb2fmc_s,	
                FMC_GPIO_LA_REG4_i		=> 	fmc1_gpio4_s,
                FMC_GPIO_LA_REG5_i		=> 	fmc1_gpio5_reg_lb2fmc_s,		
                FMC_GPIO_LA_REG1_o		=> 	fmc1_gpio1_reg_fmc2lb_s,	
                FMC_GPIO_LA_REG2_o		=> 	fmc1_gpio2_reg_fmc2lb_s,	
                FMC_GPIO_LA_REG3_o		=> 	fmc1_gpio3_reg_fmc2lb_s,	
                FMC_GPIO_LA_REG4_o		=> 	fmc1_gpio4_reg_fmc2lb_s,	
                FMC_GPIO_LA_REG5_o		=> 	fmc1_gpio5_reg_fmc2lb_s,	
                FMC_TRIS1_REG_i			=> 	fmc1_tris1_s,	
                FMC_TRIS2_REG_i			=> 	fmc1_tris2_s,	
                FMC_TRIS3_REG_i			=> 	fmc1_tris3_s,	
                FMC_TRIS4_REG_i			=> 	fmc1_tris4_s,	
                FMC_TRIS5_REG_i			=> 	(others => '0')		-- outputs for LEDs DS4..DS1 of the FMC debug board
	);
	
	fmc1_tris1_s	<= not fmc1_oe1_reg_s;
	fmc1_tris2_s	<= not fmc1_oe2_reg_s;
	fmc1_tris3_s	<= not fmc1_oe3_reg_s;
	
	-- two pins (PORT4,  bits 15..14) of FMC are used for test of differential clock inputs, each differential clock is converted in a single clock output
	fmc1_gpio4_s 	<= fmc1_clk0_loop_s & fmc1_clk1_loop_s & fmc1_gpio4_reg_lb2fmc_s(13 downto 0);
	fmc1_tris4_s	<= "00" & not fmc1_oe4_reg_s(13 downto 0);
	
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
		O 	=> fmc1_clk0_loop_s, -- Clock buffer output
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
		O 	=> fmc1_clk1_loop_s, -- Clock buffer output
		I 	=> FMC1_CLK1_M2C_P_i, -- Diff_p clock buffer input (connect directly to top-level port)
		IB 	=> FMC1_CLK1_M2C_N_i -- Diff_n clock buffer input (connect directly to top-level port)
	);
	-- End of IBUFDS_FMC1_CLK1 instantiation

	-- buffers for FMC2 -----------------------------------------------------------------------------------------------------------------------------------------------------
	fmc_conn_tristate_inst2: fmc_conn_tristate
	port map(	clk_i					=> 	CLK_200MHz_s,
                reset_i					=> 	reset_s,
                FMC_LA_P_io				=> 	FMC2_LA_P_io,		
                FMC_LA_N_io				=> 	FMC2_LA_N_io,		
                FMC_GPIO_LA_REG1_i		=> 	fmc2_gpio1_reg_lb2fmc_s,	
                FMC_GPIO_LA_REG2_i		=> 	fmc2_gpio2_reg_lb2fmc_s,	
                FMC_GPIO_LA_REG3_i		=> 	fmc2_gpio3_reg_lb2fmc_s,	
                FMC_GPIO_LA_REG4_i		=> 	fmc2_gpio4_s,
                FMC_GPIO_LA_REG5_i		=> 	fmc2_gpio5_reg_lb2fmc_s,		
                FMC_GPIO_LA_REG1_o		=> 	fmc2_gpio1_reg_fmc2lb_s,	
                FMC_GPIO_LA_REG2_o		=> 	fmc2_gpio2_reg_fmc2lb_s,	
                FMC_GPIO_LA_REG3_o		=> 	fmc2_gpio3_reg_fmc2lb_s,	
                FMC_GPIO_LA_REG4_o		=> 	fmc2_gpio4_reg_fmc2lb_s,	
                FMC_GPIO_LA_REG5_o		=> 	fmc2_gpio5_reg_fmc2lb_s,	
                FMC_TRIS1_REG_i			=> 	fmc2_tris1_s,	
                FMC_TRIS2_REG_i			=> 	fmc2_tris2_s,	
                FMC_TRIS3_REG_i			=> 	fmc2_tris3_s,	
                FMC_TRIS4_REG_i			=> 	fmc2_tris4_s,	
                FMC_TRIS5_REG_i			=> 	(others => '0')		-- outputs for LEDs DS4..DS1 of the FMC debug board
	);
	
	fmc2_tris1_s	<= not fmc2_oe1_reg_s;
	fmc2_tris2_s	<= not fmc2_oe2_reg_s;
	fmc2_tris3_s	<= not fmc2_oe3_reg_s;
	
	-- two pins of FMC are used for test of differential clock inputs, each differential clock is converted in a single clock output
	fmc2_gpio4_s 	<= fmc2_clk0_loop_s & fmc2_clk1_loop_s & fmc2_gpio4_reg_lb2fmc_s(13 downto 0);
	fmc2_tris4_s	<= "00" & not fmc2_oe4_reg_s(13 downto 0);
	
	-- -- OBUFDS: Differential Output Buffer
	-- -- Xilinx HDL Libraries Guide, version 11.2
	-- OBUFDS_inst_FMC2 : OBUFDS
	-- generic map (
		-- IOSTANDARD => "LVDS_33")
	-- port map (
		-- O 	=> FMC2_CLK1_M2C_P_i, -- Diff_p output (connect directly to top-level port)
		-- OB 	=> FMC2_CLK1_M2C_N_i, -- Diff_n output (connect directly to top-level port)
		-- I 	=> FMC2_CLK0_LOOP_s -- Buffer input
	-- );
	-- -- End of OBUFDS_inst instantiation
	
	-- IBUFDS_FMC1_CLK0: Differential Input Buffer for CLK0 from mezzanine -------------------------------------------------
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
		O 	=> fmc2_clk0_loop_s, -- Clock buffer output
		I 	=> FMC2_CLK0_M2C_P_i, -- Diff_p clock buffer input (connect directly to top-level port)
		IB 	=> FMC2_CLK0_M2C_N_i -- Diff_n clock buffer input (connect directly to top-level port)
	);
	-- End of IBUFDS_FMC1_CLK0 instantiation -------------------------------------------------------------------------------
	
	-- IBUFDS_FMC1_CLK1: Differential Input Buffer for CLK1 from mezzanine -------------------------------------------------
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
		O 	=> fmc2_clk1_loop_s, -- Clock buffer output
		I 	=> FMC2_CLK1_M2C_P_i, -- Diff_p clock buffer input (connect directly to top-level port)
		IB 	=> FMC2_CLK1_M2C_N_i -- Diff_n clock buffer input (connect directly to top-level port)
	);
	-- End of IBUFDS_FMC1_CLK1 instantiation -----------------------------------------------------------------------------------
	
 --| touch pad button bidirectionnal port |--------------------------------------------------
  tpb_open_collector_inst: Open_Collector
  port map(
    nOE_i       => tpb_oe_s,
    In_o        => tpb_stat_s,
    InOut_io    => PCB_TB_io
  );
  
-------------------------------------------------------------------------------------------------------------------------------------------------------  
  	-- MICTOR
	MICTOR_SP6_A0_o <= (others => '1');
	MICTOR_SP6_A1_o	<= (others => '1');
	MICTOR_SP6_A2_o	<= (others => '1');
 	MICTOR_SP6_A3_o <= (others => '1');
	
	MICTOR_SP6_CLK_0_o	<= '1';
	MICTOR_SP6_CLK_1_o	<= '1';

--------------------------------------------------------------------------------------------------------------------------------------------------

-- creating 1 pre-scaler to generate a pulse every milisecond on each switch debounce inst
process (CLK_200MHz_s, reset_s)
begin
    if reset_s='1' then
        milisecond_counter      <= (others=> '0');
        milisecond_enable_s     <='0';
    elsif rising_edge(CLK_200MHz_s) then
    
        if milisecond_counter = unsigned(TIMER_1MILISECOND_C) then -- see sp6_register.pkg
            milisecond_counter      <= (others=> '0');
            milisecond_enable_s     <='1';
        else 
            milisecond_counter      <= milisecond_counter+1;
            milisecond_enable_s     <='0';
        end if;
    end if;
end process;

---------------- Switch debounce  -----


switch_debounce_bus : for i in 1 to SW_PB_i'length generate
--=================================
switch_debounce_bit : debounce 
--=================================

  generic map(
    counter_size  => 3) --counter size (3 bits gives 10.5ms with 50MHz clock)
  port map(
    clk_i       => CLK_200MHz_s,--input clock
    reset_i     => reset_s, --input clock
    button_i    => SW_PB_i(i), --input signal to be debounced
    enable_i    => milisecond_enable_s,    
    result_o    => sw_PB_debounce_s(i) --debounced signal
    );
  end generate;

    
       
    
    
    
    
    
    
    
    
    
----------------------------------------------------------------------------------------------------------------------------------------------------
lba_ctrl_inst: lba_ctrl
	port map(
    clk_i					=>	CLK_200MHz_s,	    
	reset_i					=>	reset_s,	    
	-- from DM3730 GPMC trough Local Bus
	nCS3_LB_i				=>	SP6_LB_nCS3_i,
	nADV_LB_i				=>	SP6_LB_nADV_ALE_i,
	nOE_LB_i				=>	SP6_LB_RE_nOE_i,
	nWE_LB_i				=>	SP6_LB_nWE_i,
	Addr_LB_i				=>	Addr_LB_i,
    lba_nwait_o              =>  SP6_LB_WAIT3_o,
	-- from/to tri-state buffer on the top
	lb_add_data_wr_i		=> lb_add_data_wr_s,	
	lba_oe_o				=>	lba_oe_s,		
	-- from/to lba_std_interface and lba_usr_interface
	lba_wr_en_o         	=> lba_wr_en_s,  
	lba_rd_en_o         	=> lba_rd_en_s,   
	lba_add_o           	=> lba_add_s,  
	lba_cs_std_o       		=> lba_cs_std_s,	
	lba_cs_usr_wr_o       	=> lba_cs_usr_wr_s,
    lba_cs_usr_rd_o      	=> lba_cs_usr_rd_s,		
	lba_wait_usr_i			=> lba_wait_usr_s  
	);
----------------------------------------------------------------------------------------------------------------------------------------------------- 
 lba_user_interface_inst: lba_user_interface
	port map(
		
		clk_i	             => CLK_200MHz_s, -- must be a 200 Mhz clock       
		reset_i              => reset_s,       
		-- to/from lba_ctrl                      
		lba_cs_usr_rd_i      => lba_cs_usr_rd_s,
        lba_cs_usr_wr_i      => lba_cs_usr_wr_s,
		lba_wr_en_i          => lba_wr_en_s, 
		lba_rd_en_i          => lba_rd_en_s, 
		lba_add_i            => lba_add_s,   
		lba_wait_user_o      => lba_wait_usr_s,
		-- to mux data std/user on top level
        lba_data_rd_user_o   => lba_data_rd_usr_s, 
		-- from tri-state buffer on top level
		lba_data_wr_i        => lb_add_data_wr_s,
		lba_irq_user_o		 => lba_irq_user_s
		
		);
	
----------------------------------------------------------------------------------------------------------------------------------------------------- 
 lba_std_interface_inst : lba_std_interface
    port map(
    clk_i				    => CLK_200MHz_s,
	-- clock for touch pad controller (25 MHz)
	clk_tp_i				=> CLK_25MHz_SP6_i,
    reset_i				    => reset_s,
    -- to/from lba_ctrl            
    lba_cs_std_i       		=> lba_cs_std_s,        
    lba_wr_en_i             => lba_wr_en_s,    
    lba_rd_en_i             => lba_rd_en_s, 
	lba_add_i               => lba_add_s,      
    -- to mux data std/user on top level
    lba_data_rd_std_o       => lba_data_rd_std_s,
    -- from tri-state buffer on top level
    lba_data_wr_i           => lb_add_data_wr_s,
    ------------------------------ ----------------------------------------------
    -- IRQ generation              
        -- from usr_interface      
    lba_irq_user_i          => lba_irq_user_s,
    lbs_irq_user_i          => lbs_irq_user_s,
        -- to BTB connector        
    irq_o                   => SP6_GPIO18_1_o,
    ------------------------------------------------------------------------------
    -- SPI, DM3730 is master, SP6 is slave 
    -- (only 1 CS come from DM3730, multiplexed by SP6 between Acc, AD, DA and header)
        -- to/from BTB connector
    spi_ncs_i				=> SP6_SPI_nCS3_i,              
    spi_clk_i               => SP6_SPI_SCLK_i,
    spi_simo_i              => SP6_SPI_SDO_i,
    spi_somi_o              => SP6_SPI_SDI_o,
        -- to/from accelerometer
    spi_acc_ncs_o   		=> SP6_SPI_nCS1_o,       
    spi_acc_clk_o           => SP6_ACC_SPI_SCL_o,
    spi_acc_sdi_o           => SP6_ACC_SPI_SDI_o,
    spi_acc_sdo_i           => SP6_ACC_SPI_SDO_i,
        -- to/from ADC      
    spi_adc_ncs_o    		=> AD_nCS_o,      
    spi_adc_clk_o           => AD_CLK_o,
    spi_adc_sdi_o           => AD_SDI_o,
    spi_adc_sdo_i           => AD_SDO_i,
	adc_gpio_o				=> AD_GPIO_o,
        -- to/from DAC      
    spi_dac_ncs_o    		=> DAC_nCS_o,       
    spi_dac_clk_o           => DAC_CLK_o,
    spi_dac_sdi_o           => DAC_SDI_o,
        -- to/from SPI header connector (W3)
        -- data and clk signals are directly wired from BTB
    spi_conn_ncs_o          => SP6_SPI_nCS2_o,  
	------------------------------------------------------------------------------------
	-- to DAC
	dac_nldac_o				=> DAC_nLDAC_o,		
	dac_nrs_o           	=> DAC_nRS_o,
    -----------------------------------------------------------------------------------
    -- to 7-segments displays
    disp_7seg1_o			=> SP6_7seg1_o,		
	disp_7seg2_o			=> SP6_7seg2_o,		
	disp_7seg3_o			=> SP6_7seg3_o,		
	disp_7seg1_DP_o			=> SP6_7seg1_DP_o,	
	disp_7seg2_DP_o			=> SP6_7seg2_DP_o,	
	disp_7seg3_DP_o			=> SP6_7seg3_DP_o,	
    --------------------------------------------------------------------------------------
    -- to/from switches and LEDs
    -- push-buttons
	push_but_i				=> sw_PB_debounce_s,			
	--DIPs                  
	dip_i					=> DIP_i,				
	--LEDs                  
	led_o					=> FPGA_LED_o,			    
	------------------------------------------------------------------------------------------
    -- LCD
	lcd_rs_o				=> LCD_RS_o,				
	lcd_rw_o				=> LCD_R_nW_o,
	lcd_e_o		  	        => LCD_E_o,
	    -- to/from tri-state buffer on top: LCD data bus
	lcd_data_i	            => lcd_db_in_s,
	lcd_data_o	            => lcd_db_out_s,
	lcd_data_oe_o           => lcd_db_oe_s,
    -------------------------------------------------------------------------------------------------------------
    -- to/from touch pad open collector
    touch_pad_oe            => tpb_oe_s,
    touch_pad_i             => tpb_stat_s,
    ---------------------------------------------------------------------------------------------
    -- from encoder
    enc_a_inc_i       		=> Inc_Enc_A_i,     
    enc_b_inc_i             => Inc_Enc_B_i,
    ---------------------------------------------------------------------------------------------
    -- to buzzer
    buzzer_osc_o   			=> Buz_osc_o,         
    -------------------------------------------------------------------------------------------
    --UART header
	uart_header_cts_o		=> SP6_UART1_CTS_o,			
	uart_header_rts_i		=> SP6_UART1_RTS_i,	
	uart_header_rx_i		=> SP6_UART1_RX_i,	
	uart_header_tx_o		=> SP6_UART1_TX_o,	
    -------------------------------------------------------------------------------------------
    -- GPIOs: to/from tri-state buffers on top
        -- GPIO_x
        -- GPIO_x(11..9) are in 16-pin header connector J8 , GPIO_x(8..1) are in 8-pin header connector W1 
    gpio_x_i                => gpio_x_reg_lbin_s,																				
    gpio_x_o 				=> gpio_x_reg_lbout_s,                                                                                               
    gpio_x_oe_o             => gpio_x_oe_s,                                                                                
        -- GPIO33_x : 16-pin header connector J38                                                           
        -- GPIO33_x(5) is reserved for reset from CPU                                                       
    gpio33_x_i				=> gpio_3v3_reg_lbin_s,                                                                                               
    gpio33_x_o              => gpio_3v3_reg_lbout_s,                                                       
    gpio33_x_oe_o           => gpio_3v3_oe_s,                                                              
        -- GPIO_Hx : 16-pin header connector J39                                                           
    gpio_Hx_i               => gpio_h_reg_lbin_s,
    gpio_Hx_o               => gpio_h_reg_lbout_s, 
    gpio_Hx_oe_o            => gpio_h_oe_s,
    ------------------------------------------------------------------------------------------------------
    --FMC1
        -- LA00_P/N TO LA07_P/N
	fmc1_gpio1_i			=> fmc1_gpio1_reg_fmc2lb_s,																			
	fmc1_gpio1_o			=> fmc1_gpio1_reg_lb2fmc_s,				                                                            
    fmc1_gpio1_oe_o			=> fmc1_oe1_reg_s,	                                                            
        -- LA08_P/N TO LA15_P/N                                                             
    fmc1_gpio2_i			=> fmc1_gpio2_reg_fmc2lb_s,	                                                            
    fmc1_gpio2_o			=> fmc1_gpio2_reg_lb2fmc_s,					                                                            	
    fmc1_gpio2_oe_o			=> fmc1_oe2_reg_s,	 	                                                            	
        -- LA16_P/N TO LA23_P/N                                                             
	fmc1_gpio3_i			=> fmc1_gpio3_reg_fmc2lb_s,	                                    
    fmc1_gpio3_o			=> fmc1_gpio3_reg_lb2fmc_s,					                    
    fmc1_gpio3_oe_o			=> fmc1_oe3_reg_s,	 	                                                            
        -- LA24_P/N TO LA31_P/N                                                             
	fmc1_gpio4_i			=> fmc1_gpio4_reg_fmc2lb_s,	                                    
    fmc1_gpio4_o			=> fmc1_gpio4_reg_lb2fmc_s,				                        
    fmc1_gpio4_oe_o			=> fmc1_oe4_reg_s,	 	
        -- LA32_P/N TO LA33_P/N
        -- for FMC DEBUG XM105 board:    fmc1_gpio5_io(3..0): LEDS DS4..DS1 
    fmc1_gpio5_i			=> fmc1_gpio5_reg_fmc2lb_s,
	fmc1_gpio5_o			=> fmc1_gpio5_reg_lb2fmc_s,			
	fmc1_gpio5_oe_o			=> open,
        -- presence detection (pin H2 du FMC)
    fmc1_prsnt_i        	=> FMC1_PRSNT_M2C_L_i,
    ------------------------------------------------------------------------------------------------------------
	--FMC2
        -- LA00_P/N TO LA07_P/N
	fmc2_gpio1_i		    => fmc2_gpio1_reg_fmc2lb_s,		
	fmc2_gpio1_o		    => fmc2_gpio1_reg_lb2fmc_s,		
    fmc2_gpio1_oe_o		    => fmc2_oe1_reg_s,	          
       -- LA08_P/N TO LA15_PP/N                          
    fmc2_gpio2_i		    => fmc2_gpio2_reg_fmc2lb_s,	  
    fmc2_gpio2_o		    => fmc2_gpio2_reg_lb2fmc_s,		
    fmc2_gpio2_oe_o		    => fmc2_oe2_reg_s,	 	      
       -- LA16_P/N TO LA23_PP/N                          
	fmc2_gpio3_i		    => fmc2_gpio3_reg_fmc2lb_s,	  
    fmc2_gpio3_o		    => fmc2_gpio3_reg_lb2fmc_s,		
    fmc2_gpio3_oe_o		    => fmc2_oe3_reg_s,	 	      
       -- LA24_P/N TO LA31_PP/N                          
	fmc2_gpio4_i		    => fmc2_gpio4_reg_fmc2lb_s,	  
    fmc2_gpio4_o		    => fmc2_gpio4_reg_lb2fmc_s,		
    fmc2_gpio4_oe_o		    => fmc2_oe4_reg_s,	 	
       -- LA32_P/N TO LA33_P/N
       -- for FMC DEBUG XM105 board:    fmc2_gpio5_io(3..0): LEDS DS4..DS1 
       --                               fmc2_gpio5_io(4):     presence detection (pin H2 du FMC)	
    fmc2_gpio5_i			=> fmc2_gpio5_reg_fmc2lb_s,
	fmc2_gpio5_o		    => fmc2_gpio5_reg_lb2fmc_s,	
	fmc2_gpio5_oe_o		    => open,
        -- presence detection (pin H2 du FMC)
    fmc2_prsnt_i            => FMC2_PRSNT_M2C_L_i,
    ---------------------------------------------------------------------------------------------------------
    -- 80-pin DKK (REDS connector)
        -- pins 1 to 16
    reds_80p_gpio1_i		=>  reds_conn1_reg_lbin_s,																											
	reds_80p_gpio1_o		=>  reds_conn1_reg_lbout_s,                                                                                                        
    reds_80p_gpio1_oe_o		=>  reds_conn1_oe_s,                                                                                                        
        -- pins 17 to 32                                                                                                            
    reds_80p_gpio2_i		=>  reds_conn2_reg_lbin_s,                                                                                                        
	reds_80p_gpio2_o		=>  reds_conn2_reg_lbout_s,                                                                                                        
    reds_80p_gpio2_oe_o		=>  reds_conn2_oe_s,                                                                                                         
        --  pins 33 to 48                                                                                                           
	reds_80p_gpio3_i		=>  reds_conn3_reg_lbin_s,                                                                                                        
	reds_80p_gpio3_o		=>  reds_conn3_reg_lbout_s,                                                                                                        
    reds_80p_gpio3_oe_o		=>  reds_conn3_oe_s,                                                                                                          
        --  pins 49 to 64                                                                                                          
	reds_80p_gpio4_i		=>  reds_conn4_reg_lbin_s,                                                                                
	reds_80p_gpio4_o		=>  reds_conn4_reg_lbout_s,                                                                                
    reds_80p_gpio4_oe_o		=>  reds_conn4_oe_s,                                                                                   
        -- pins 65 to 80
    reds_80p_gpio5_i		=>  reds_conn5_reg_lbin_s,
	reds_80p_gpio5_o		=>  reds_conn5_reg_lbout_s,
    reds_80p_gpio5_oe_o		=>  reds_conn5_oe_s 
    ---------------------------------------------------------------------------------------------------------------
    );
	
-- end of lba_std_interface instantiation ------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
-- lbs controller
   lbs_ctrl_inst : lbs_ctrl
  generic map (
    GPMC_BURST_LEN  => 4,
    GPMC_DATA_SIZE  => 16,
	FIFO_PORT_SIZE   => LBS_FIFO_PORT_SIZE_c
  )
  port map ( 
    rst_i 					=> reset_s,                 
    -- to/from DM3730 GPMC through Local Bus
    gpmc_ckl_i              => SP6_LB_CLK_i, -- ajouter un BUFG?
    gpmc_a_i                => Addr_LB_i,              
    gpmc_nCS_i              => SP6_LB_nCS4_i,
    gpmc_nADV_i             => SP6_LB_nADV_ALE_i,
    gpmc_nWE_i              => SP6_LB_nWE_i,
    gpmc_nOE_i              => SP6_LB_RE_nOE_i,
    gpmc_nWait_o            => SP6_LB_WAIT0_o,
    -- from/to tristate buffer
    gpmc_d_i                => lb_add_data_wr_s,              
    gpmc_d_o                => lbs_data_rd_s,            
    gpmc_d_tris_o           => lbs_tris_s,          
    -- to/from command FIFO 
    lbs_fifo_cmd_addr_o     => lbs_fifo_cmd_addr_s,     
    lbs_fifo_cmd_bl_o       => lbs_fifo_cmd_bl_s,       
    lbs_fifo_cmd_en_o       => lbs_fifo_cmd_en_s,       
    lbs_fifo_cmd_full_i     => lbs_fifo_cmd_full_s,     
    lbs_fifo_cmd_instr_o    => lbs_fifo_cmd_instr_s,    
    -- to/from data read FIFO  
    lbs_fifo_wr_data_o      => lbs_fifo_wr_data_s,      
    lbs_fifo_wr_en_o        => lbs_fifo_wr_en_s,       
    lbs_fifo_wr_full_i      => lbs_fifo_wr_full_s,      
	lbs_fifo_wr_mask_o      => lbs_fifo_wr_mask_s,      
    -- to/from data write FIFO 
    lbs_fifo_rd_en_o        => lbs_fifo_rd_en_s,       
    lbs_fifo_rd_data_i      => lbs_fifo_rd_data_s,      
    lbs_fifo_rd_empty_i     => lbs_fifo_rd_empty_s,     
    lbs_fifo_rd_count_i     => lbs_fifo_rd_count_s,     
    -- from Memory Controller Block (IP Xilinx)
    mcb_calib_done_i        => mcb_calib_done_s,        
	-- debug    
    interface_state_o       => open,     
    error_o                 => open
  );
  
  -- end of lbs controller instantiation -----------------------------------------------------------------------------------------------------
  
  ------------------------------------------------------------------------------------------------------------------------------------------------
    PLL_ddr2 : memc5_infrastructure
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
    sys_rst_i                       => reset_s,
    clk0                            => open,
    rst0                            => open,
    async_rst                       => ddr2_async_rst_s,
    sysclk_2x                       => ddr2_sysclk_2x_s,
    sysclk_2x_180                   => ddr2_sysclk_2x_180_s,
    pll_ce_0                        => ddr2_pll_ce_0_s,
    pll_ce_90                       => ddr2_pll_ce_90_s,
    pll_lock                        => ddr2_pll_lock_s,
    mcb_drp_clk                     => ddr2_mcb_drp_clk_s   -- 200 MHz
  );
  
   -- wrapper instantiation
  memc5_wrapper_inst : memc5_wrapper
  generic map (
    C_MEMCLK_PERIOD                   => DDR2_MEMCLK_PERIOD,
    C_CALIB_SOFT_IP                   => DDR2_CALIB_SOFT_IP,
    C_SIMULATION                      => DDR2_SIMULATION,
    C_P0_MASK_SIZE                    => LBS_FIFO_PORT_SIZE_c/8,
    C_P0_DATA_PORT_SIZE               => LBS_FIFO_PORT_SIZE_c,
    C_P1_MASK_SIZE                    => LBS_FIFO_PORT_SIZE_c/8,
    C_P1_DATA_PORT_SIZE               => LBS_FIFO_PORT_SIZE_c,
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
    mcb5_dram_dq                         => ddr2_dq_io,
    mcb5_dram_a                          => ddr2_a_o,
    mcb5_dram_ba                         => ddr2_ba_o,
    mcb5_dram_ras_n                      => ddr2_nras_o,
    mcb5_dram_cas_n                      => ddr2_ncas_o,
    mcb5_dram_we_n                       => ddr2_we_o,
    mcb5_dram_odt                        => ddr2_odt_o,
    mcb5_dram_cke                        => ddr2_cke_o,
    mcb5_dram_dm                         => ddr2_ldm_o,
    mcb5_dram_udqs                       => ddr2_udqs_p_o,
    mcb5_dram_udqs_n                     => ddr2_udqs_n_o,
    mcb5_rzq                             => mcb5_rzq,
    mcb5_zio                             => mcb5_zio,
    mcb5_dram_udm                        => ddr2_udm_o,
    calib_done                           => mcb_calib_done_s,
    async_rst                            => ddr2_async_rst_s,
    sysclk_2x                            => ddr2_sysclk_2x_s,
    sysclk_2x_180                        => ddr2_sysclk_2x_180_s,
    pll_ce_0                             => ddr2_pll_ce_0_s,
    pll_ce_90                            => ddr2_pll_ce_90_s,
    pll_lock                             => ddr2_pll_lock_s,
    mcb_drp_clk                          => ddr2_mcb_drp_clk_s,
    mcb5_dram_dqs                        => ddr2_ldqs_p_o,
    mcb5_dram_dqs_n                      => ddr2_ldqs_n_o,
    mcb5_dram_ck                         => ddr2_ck_p_o,
    mcb5_dram_ck_n                       => ddr2_ck_n_o,

    p0_cmd_clk                           =>  SP6_LB_CLK_i,												
    p0_cmd_en                            =>  lbs_fifo_cmd_en_s,                                             
    p0_cmd_instr                         =>  lbs_fifo_cmd_instr_s,                                     
    p0_cmd_bl                            =>  lbs_fifo_cmd_bl_s,                                        
    p0_cmd_byte_addr                     =>  lbs_fifo_cmd_addr_s,                                      
    p0_cmd_empty                         =>  open,                                                     
    p0_cmd_full                          =>  lbs_fifo_cmd_full_s,
	
    p0_wr_clk                            =>  SP6_LB_CLK_i,                                             
    p0_wr_en                             =>  lbs_fifo_wr_en_s,                                         
    p0_wr_mask                           =>  lbs_fifo_wr_mask_s,                                       
    p0_wr_data                           =>  lbs_fifo_wr_data_s,                                       
    p0_wr_full                           =>  lbs_fifo_wr_full_s,                                       
    p0_wr_empty                          =>  open,                                                     
    p0_wr_count                          =>  open,                                          
    p0_wr_underrun                       =>  open,                                                     
    p0_wr_error                          =>  open,  
	
    p0_rd_clk                            =>  SP6_LB_CLK_i,                                             
    p0_rd_en                             =>  lbs_fifo_rd_en_s,
    p0_rd_data                           =>  lbs_fifo_rd_data_s,
    p0_rd_full                           =>  open,
    p0_rd_empty                          =>  lbs_fifo_rd_empty_s,
    p0_rd_count                          =>  lbs_fifo_rd_count_s,
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
 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
  	-- FTDI
	-- loopback
	FTDI_RX_o <= FTDI_TX_i;
	FTDI_nRESET_o <= '1';
	FTDI_nCTS_o <= '1';
 --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
	-- CAN
	-- not used
	CAN_TXD_o <= '0';
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
	-- Digital audio
	-- loopback for test toslink connectors 
	Digital_Audio_TX_o <= Digital_Audio_RX_i;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
	--PCI PERST, connected to BTB in FPGA board, but not connected on CPU board: reserved for futur CPU board versions
	PCI_PERST_o <= '1';
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
	-- i2c to FMC
	-- temporary wired to i2c inputs from CPU for test of the lines
	I2C_SCL_1V8_o <= SP6_I2C_SCL_i;	-- from cpu to fmc
	I2C_SDA_1V8_o <= SP6_I2C_SDA_i;
 


end Behavioral;