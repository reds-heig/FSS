------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : lba_sp6_registers.vhd
-- Author               : Evangelina Lolivier-Exler
-- Date                 : 24.10.2013
-- Target Devices       : Spartan6 xc6slx150t-3fgg900
--
-- Context              : Reptar - FPGA design
--
---------------------------------------------------------------------------------------------
-- Description :		Address decoder and registers for CPU access to the REPTAR peripherals
--						The registers contained in this block are described in the document 
--						Spartan6_registers.xlsx, tab "Summary_Layout_v2_prop"
---------------------------------------------------------------------------------------------
-- Information :
---------------------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Engineer     Comments
-- 0.0   See header  ELR          Initial version, based on Reptar_local_bus_v2.vhd of VTT
-- 0.1   10.01.14	 ELR		  The bit IRQ_CTL_REG_s(0) is driven by a State Machine instead 
--								  of the write process in order to implement the hardware reset 
--								  feature for this bit
-- 0.2   23.01.14    ELR		  GPIO_H_OE_REG added in the read process. Read process splitted in two
-- 0.3   28.01.14    CVZ          added IRQ_enable signal
---------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.lba_sp6_registers_pkg.all;

    entity lba_sp6_registers is
        port(
        clk_i				    : in std_logic;
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
        -- to SPI mux
        lba_spi_acc_cs_o        : out std_logic;
        lba_spi_adc_cs_o        : out std_logic;
        lba_spi_dac_cs_o        : out std_logic;
        lba_spi_conn_cs_o       : out std_logic;
		------------------------------------------------------------------------------------
		-- to ADC
		adc_gpio_o				: out std_logic_vector(3 downto 0);
		------------------------------------------------------------------------------------
		-- to DAC
		dac_nldac_o				: out std_logic;			
		dac_nrs_o           	: out std_logic;
        ------------------------------------------------------------------------------------
        -- to/from IRQ generator
        irq_clear_o             : out std_logic;
        irq_status_i            : in std_logic;
        irq_source_i            : in std_logic_vector(1 downto 0);
        irq_button_i            : in std_logic_vector(2 downto 0);
        irq_enable_o            : out std_logic;
		push_but_reg_o			: out std_logic_vector(7 downto 0);
        
        ------------------------------------------------------------------------------------
        -- to 7-segments displays
        disp_7seg1_o			: out std_logic_vector(6 downto 0);
        disp_7seg2_o			: out std_logic_vector(6 downto 0);
        disp_7seg3_o			: out std_logic_vector(6 downto 0);
        disp_7seg1_DP_o			: out std_logic;
        disp_7seg2_DP_o			: out std_logic;
        disp_7seg3_DP_o			: out std_logic;	
        --------------------------------------------------------------------------------------        
        -- to/from LCD controller
		rs_up_o		            : out std_logic;
		rw_up_o		            : out std_logic;
		start_o		            : out std_logic;
        ready_i		            : in std_logic;
		start_rst_i	            : in std_logic;
        data_up_i	            : in std_logic_vector(7 downto 0);
        data_up_o	            : out std_logic_vector(7 downto 0);
        --------------------------------------------------------------------------------------
        -- to/from switches and LEDs
        -- push-buttons
        push_but_i				: in std_logic_vector(8 downto 1);	
        --DIPs                         
        dip_i					: in std_logic_vector(9 downto 0);
        --LEDs                         
        led_o				    : out std_logic_vector(7 downto 0);
        led_6_7_en_o            : out std_logic;
    ---------------------------------------------------------------------------------------- 
        -- from encoder sens detector
        left_rotate_i		    : in std_logic;
		right_rotate_i		    : in std_logic;
		pulse_counter_i		    : in std_logic_vector(15 downto 0);
    ------------------------------------------------------------------------------------------
        -- to buzzer controller
        buzzer_en_o			    : out std_logic;
		fast_mode_o			    : out std_logic;
		slow_mode_o			    : out std_logic;
    -------------------------------------------------------------------------------------------
        -- to/from touch pad controller
        tp_en_o					: out  std_logic;
        tp_det_finger_i         : in   std_logic;
    ---------------------------------------------------------------------------------------------   
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
    end lba_sp6_registers;
	
	architecture behavioral of lba_sp6_registers is
	
-- local bus
    signal   data_out_s       	: std_logic_vector(15 downto 0);
    signal   selected_reg_s		: std_logic_vector(15 downto 0);
    signal   data_in_s       	: std_logic_vector(15 downto 0);	
	signal 	 read_en_s			: std_logic;
	signal 	 write_en_s			: std_logic;

-- version																		
	signal	VERSION1_REG_s		  		: std_logic_vector(15 downto 0); 
	signal	VERSION2_REG_s		  		: std_logic_vector(15 downto 0); 
-- test
	signal  CONSTANT_REG_s				: std_logic_vector(15 downto 0); 
-- peripherals descriptor address                              
	signal	PERIPHERAL_DESCRIPTOR_H_REG_s	: std_logic_vector(15 downto 0); 
	signal	PERIPHERAL_DESCRIPTOR_L_REG_s	: std_logic_vector(15 downto 0); 
	signal	SCRATCH1_REG_s			  		: std_logic_vector(15 downto 0); 
	signal	SCRATCH2_REG_s				  	: std_logic_vector(15 downto 0); 
-- input                                    		                   
	signal	DIP_SW_REG_s		  			: std_logic_vector(9 downto 0); 
	signal	PUSH_BUT_REG_s		  			: std_logic_vector(15 downto 0); 
	signal	ENCODER_DIRECTION_REG_s			: std_logic_vector(15 downto 14); 
	signal	ENCODER_COUNT_REG_s				: std_logic_vector(15 downto 0); 
	signal	IRQ_CTL_REG_s		  			: std_logic_vector(7 downto 0); 
	signal  present_st_s, futur_st_s     	: std_logic;
-- output	                                
	signal	DISP_7SEG1_REG_s	  			: std_logic_vector(7 downto 0); 
	signal	DISP_7SEG2_REG_s	  			: std_logic_vector(7 downto 0); 
	signal	DISP_7SEG3_REG_s  				: std_logic_vector(7 downto 0); 
	signal	LCD_CONTROL_REG_s	    		: std_logic_vector(10 downto 0); 
	signal	LCD_STATUS_REG_s  				: std_logic_vector(8 downto 0); 
	signal  p_state_s, f_state_s     		: std_logic;
	signal	LED_REG_s		  				: std_logic_vector(8 downto 0); 
	signal	BUZZER_REG_s		    		: std_logic_vector(2 downto 0); 
-- GPIOs				                    
	signal	GPIO_X_STAT_REG_s	  			: std_logic_vector(10 downto 0); 
	signal	GPIO_X_CTRL_REG_s	  			: std_logic_vector(10 downto 0); 
	signal	GPIO_X_OE_REG_s	  				: std_logic_vector(10 downto 0); 
	signal	GPIO_H_STAT_REG_s		  		: std_logic_vector(7 downto 0);        
	signal	GPIO_H_CTRL_REG_s		  		: std_logic_vector(7 downto 0);       	
	signal	GPIO_H_OE_REG_s				   	: std_logic_vector(7 downto 0); 
	signal	GPIO_3V3_STAT_REG_s			    : std_logic_vector(3 downto 0); 
	signal	GPIO_3V3_CTRL_REG_s			    : std_logic_vector(3 downto 0);
	signal	GPIO_3V3_OE_REG_s 				: std_logic_vector(3 downto 0); 
-- peripheral devices				        
	signal	UART_CONTROL_REG_s 				: std_logic_vector(3 downto 0); 
	signal	AD_GPIO_REG_s 					: std_logic_vector(3 downto 0); 
	signal	DA_CONTROL_REG_s 				: std_logic_vector(1 downto 0); 
	signal	SPI_CS_REG_s					: std_logic_vector(3 downto 0); 
-- DKK 80-p connector (REDS connector)      		                           
	signal	REDS_CONN1_STAT_REG_s			: std_logic_vector(15 downto 0); 
	signal	REDS_CONN2_STAT_REG_s			: std_logic_vector(15 downto 0); 
	signal	REDS_CONN3_STAT_REG_s			: std_logic_vector(15 downto 0); 
	signal	REDS_CONN4_STAT_REG_s			: std_logic_vector(15 downto 0); 
	signal	REDS_CONN5_STAT_REG_s			: std_logic_vector(15 downto 0); 
	signal	REDS_CONN1_CTRL_REG_s			: std_logic_vector(15 downto 0); 
	signal	REDS_CONN2_CTRL_REG_s			: std_logic_vector(15 downto 0); 
	signal	REDS_CONN3_CTRL_REG_s			: std_logic_vector(15 downto 0); 
	signal	REDS_CONN4_CTRL_REG_s			: std_logic_vector(15 downto 0); 
	signal	REDS_CONN5_CTRL_REG_s			: std_logic_vector(15 downto 0); 
	signal	REDS_CONN1_OE_REG_s				: std_logic_vector(15 downto 0); 
	signal	REDS_CONN2_OE_REG_s				: std_logic_vector(15 downto 0); 
	signal	REDS_CONN3_OE_REG_s				: std_logic_vector(15 downto 0); 
	signal	REDS_CONN4_OE_REG_s				: std_logic_vector(15 downto 0); 
	signal	REDS_CONN5_OE_REG_s				: std_logic_vector(15 downto 0); 
-- FMC1 connector	
	signal	FMC1_GPIO1_STAT_REG_s			: std_logic_vector(15 downto 0); 
	signal	FMC1_GPIO2_STAT_REG_s			: std_logic_vector(15 downto 0); 
	signal	FMC1_GPIO3_STAT_REG_s			: std_logic_vector(15 downto 0); 
	signal	FMC1_GPIO4_STAT_REG_s			: std_logic_vector(15 downto 0); 
	signal	FMC1_GPIO5_STAT_REG_s			: std_logic_vector(4 downto 0); 
	signal	FMC1_GPIO1_CTRL_REG_s			: std_logic_vector(15 downto 0); 
	signal	FMC1_GPIO2_CTRL_REG_s			: std_logic_vector(15 downto 0); 
	signal	FMC1_GPIO3_CTRL_REG_s			: std_logic_vector(15 downto 0); 
	signal	FMC1_GPIO4_CTRL_REG_s			: std_logic_vector(15 downto 0); 
	signal	FMC1_GPIO5_CTRL_REG_s			: std_logic_vector(3 downto 0); 
	signal	FMC1_GPIO1_OE_REG_s				: std_logic_vector(15 downto 0); 
	signal	FMC1_GPIO2_OE_REG_s				: std_logic_vector(15 downto 0); 
	signal	FMC1_GPIO3_OE_REG_s				: std_logic_vector(15 downto 0); 
	signal	FMC1_GPIO4_OE_REG_s				: std_logic_vector(15 downto 0); 
	signal	FMC1_GPIO5_OE_REG_s				: std_logic_vector(3 downto 0); 
-- FMC2 connector		
	signal	FMC2_GPIO1_STAT_REG_s			: std_logic_vector(15 downto 0); 
	signal	FMC2_GPIO2_STAT_REG_s			: std_logic_vector(15 downto 0); 
	signal	FMC2_GPIO3_STAT_REG_s			: std_logic_vector(15 downto 0); 
	signal	FMC2_GPIO4_STAT_REG_s			: std_logic_vector(15 downto 0); 
	signal	FMC2_GPIO5_STAT_REG_s			: std_logic_vector(4 downto 0); 
	signal	FMC2_GPIO1_CTRL_REG_s			: std_logic_vector(15 downto 0); 
	signal	FMC2_GPIO2_CTRL_REG_s			: std_logic_vector(15 downto 0); 
	signal	FMC2_GPIO3_CTRL_REG_s			: std_logic_vector(15 downto 0); 
	signal	FMC2_GPIO4_CTRL_REG_s			: std_logic_vector(15 downto 0); 
	signal	FMC2_GPIO5_CTRL_REG_s			: std_logic_vector(3 downto 0); 
	signal	FMC2_GPIO1_OE_REG_s				: std_logic_vector(15 downto 0); 
	signal	FMC2_GPIO2_OE_REG_s				: std_logic_vector(15 downto 0); 
	signal	FMC2_GPIO3_OE_REG_s				: std_logic_vector(15 downto 0); 
	signal	FMC2_GPIO4_OE_REG_s				: std_logic_vector(15 downto 0); 
	signal	FMC2_GPIO5_OE_REG_s				: std_logic_vector(3 downto 0); 
	
	
	begin

	-- read access detection
	read_en_s <= lba_rd_en_i and lba_cs_std_i;
	
	-- write access detection
	write_en_s <= lba_wr_en_i and lba_cs_std_i;
	
	-- local bus asynchronous access data read
	lba_data_rd_std_o 		<= data_out_s;
	
	-- local bus asynchronous access data write
	data_in_s 				<= lba_data_wr_i;

	-- version
    -- see register_pkg to change the version value
	VERSION1_REG_s		<= HW_version_c & ID_FPGA_c & ID_design_FPGA_c; 
	VERSION2_REG_s		<= ID_SUB_DESIGN_c & VERSION_NUMBER_c; 
	-- test
	CONSTANT_REG_s		<= x"12_34";
	-- peripherals descriptor address         
	PERIPHERAL_DESCRIPTOR_H_REG_s	<= (others => '0');
	PERIPHERAL_DESCRIPTOR_L_REG_s	<= (others => '0');
	
	-- input pins sampling
	process(clk_i, reset_i)
	begin
		if (reset_i = '1') then
			DIP_SW_REG_s			  	<= (others => '0');
			PUSH_BUT_REG_s(15) 			<= '0';
			PUSH_BUT_REG_s(7 downto 0) 	<= (others => '0');
			UART_CONTROL_REG_s(0) 		<= '0';
			UART_CONTROL_REG_s(2) 		<= '0';
			
		elsif rising_edge(clk_i) then
			DIP_SW_REG_s			  	<= dip_i;
			-- touch pad
			PUSH_BUT_REG_s(15)			<= tp_det_finger_i;
			PUSH_BUT_REG_s(7 downto 0) 	<= push_but_i;
			UART_CONTROL_REG_s(0) 		<= uart_header_rx_i;
			UART_CONTROL_REG_s(2) 		<= uart_header_rts_i;
			
		end if;
	end process;
	
-- registers bits not used
	PUSH_BUT_REG_s(13 downto 8)		<= (others => '0');
	
-- inputs from other internal blocks running @ 200MHz
    ---------------------------------------------------------------------------------------- 
    -- from encoder sens detector
    ENCODER_DIRECTION_REG_s(14)	<= left_rotate_i;	 
	ENCODER_DIRECTION_REG_s(15)	<= right_rotate_i;	 
	ENCODER_COUNT_REG_s			<= pulse_counter_i;	 
    ------------------------------------------------------------------------------------
    -- from IRQ generator
    IRQ_CTL_REG_s(6 downto 5) <= irq_source_i; 
	IRQ_CTL_REG_s(4) 		  <= irq_status_i;  
    IRQ_CTL_REG_s(3 downto 1) <= irq_button_i;  
    -- 	IRQ_CTL_REG_s(0) is driven by FSM_irqclear_bit state machine (see below)
	---------------------------------------------------------------------------------------- 
	-- to/from LCD controller
	LCD_STATUS_REG_s(8)	<= ready_i;	           
	LCD_STATUS_REG_s(7 downto 0)	<= data_up_i;           
	-------------------------------------------------------------------------------------- 
    -- GPIOs: to/from tri-state buffers on top
        -- GPIO_x
        -- GPIO_x(11..9) are in 16-pin header connector J8 , GPIO_x(8..1) are in 8-pin header connector W1 
    GPIO_X_STAT_REG_s 	<= gpio_x_i;                
        -- GPIO33_x : 16-pin header connector J38 
        -- GPIO33_x(5) is reserved for reset from CPU
    GPIO_3V3_STAT_REG_s <= gpio33_x_i;               
       -- GPIO_Hx : 16-pin header connector J39
    GPIO_H_STAT_REG_s <= gpio_Hx_i;                
    -------------------------------------------------------------------------------------------
	-- DKK 80-p connector (REDS connector)                 
	REDS_CONN1_STAT_REG_s				<= reds_80p_gpio1_i;
	REDS_CONN2_STAT_REG_s				<= reds_80p_gpio2_i;
	REDS_CONN3_STAT_REG_s				<= reds_80p_gpio3_i;
	REDS_CONN4_STAT_REG_s				<= reds_80p_gpio4_i;
	REDS_CONN5_STAT_REG_s				<= reds_80p_gpio5_i;
	-------------------------------------------------------------------------------------------
	-- FMC1 connector
	FMC1_GPIO1_STAT_REG_s				<= fmc1_gpio1_i;
	FMC1_GPIO2_STAT_REG_s				<= fmc1_gpio2_i;
	FMC1_GPIO3_STAT_REG_s				<= fmc1_gpio3_i;
	FMC1_GPIO4_STAT_REG_s				<= fmc1_gpio4_i;
	FMC1_GPIO5_STAT_REG_s(3 downto 0)	<= fmc1_gpio5_i;
	FMC1_GPIO5_STAT_REG_s(4)			<= fmc1_prsnt_i;
	-------------------------------------------------------------------------------------------
	-- FMC2 connector
	FMC2_GPIO1_STAT_REG_s				<= fmc2_gpio1_i;
	FMC2_GPIO2_STAT_REG_s				<= fmc2_gpio2_i;
	FMC2_GPIO3_STAT_REG_s				<= fmc2_gpio3_i;
	FMC2_GPIO4_STAT_REG_s				<= fmc2_gpio4_i;
	FMC2_GPIO5_STAT_REG_s(3 downto 0)	<= fmc2_gpio5_i;
	FMC2_GPIO5_STAT_REG_s(4)			<= fmc2_prsnt_i;
	-------------------------------------------------------------------------------------------
 	
-- Read process
	process(clk_i, reset_i)
	begin
		if (reset_i = '1') then
			data_out_s	<= (others => '0');
		elsif rising_edge(clk_i) then
			if read_en_s = '1' and lba_add_i(22 downto 16) = "0000000"  then
				data_out_s	<= selected_reg_s;	
			end if;
							
		end if;
	end process;
	
	-- address decoder
	process(lba_add_i,VERSION1_REG_s,VERSION2_REG_s,CONSTANT_REG_s,PERIPHERAL_DESCRIPTOR_H_REG_s,PERIPHERAL_DESCRIPTOR_L_REG_s,
			SCRATCH1_REG_s,SCRATCH2_REG_s,REDS_CONN1_STAT_REG_s,REDS_CONN2_STAT_REG_s,REDS_CONN3_STAT_REG_s,REDS_CONN4_STAT_REG_s,
			REDS_CONN5_STAT_REG_s,DIP_SW_REG_s,PUSH_BUT_REG_s,LED_REG_s,UART_CONTROL_REG_s,AD_GPIO_REG_s,GPIO_X_STAT_REG_s,
			GPIO_3V3_STAT_REG_s,SPI_CS_REG_s,GPIO_H_STAT_REG_s,GPIO_X_OE_REG_s,GPIO_3V3_OE_REG_s,GPIO_H_OE_REG_s,DISP_7SEG1_REG_s,DISP_7SEG2_REG_s,
			DISP_7SEG3_REG_s,ENCODER_DIRECTION_REG_s,ENCODER_COUNT_REG_s,BUZZER_REG_s,LCD_STATUS_REG_s,REDS_CONN1_OE_REG_s,
			REDS_CONN2_OE_REG_s,REDS_CONN3_OE_REG_s,REDS_CONN4_OE_REG_s,REDS_CONN5_OE_REG_s,FMC1_GPIO1_STAT_REG_s,
			FMC1_GPIO2_STAT_REG_s,FMC1_GPIO3_STAT_REG_s,FMC1_GPIO4_STAT_REG_s,FMC1_GPIO5_STAT_REG_s,FMC1_GPIO1_OE_REG_s,
			FMC1_GPIO2_OE_REG_s,FMC1_GPIO3_OE_REG_s,FMC1_GPIO4_OE_REG_s,FMC1_GPIO5_OE_REG_s,FMC2_GPIO1_STAT_REG_s,
			FMC2_GPIO2_STAT_REG_s,FMC2_GPIO3_STAT_REG_s,FMC2_GPIO4_STAT_REG_s,FMC2_GPIO5_STAT_REG_s,FMC2_GPIO1_OE_REG_s,
			FMC2_GPIO2_OE_REG_s,FMC2_GPIO3_OE_REG_s,FMC2_GPIO4_OE_REG_s,FMC2_GPIO5_OE_REG_s,IRQ_CTL_REG_s)
	begin
	-- default value
	selected_reg_s	<= (others => '0');	
	-- adressed value
	case lba_add_i(15 downto 0) is   
		when VERSION1_REG_ADD_c		=>                                                                                
			selected_reg_s 	<= VERSION1_REG_s;
		when VERSION2_REG_ADD_c		=>                                                                                
			selected_reg_s <= VERSION2_REG_s;
		when CONSTANT_REG_ADD_c	=>
			selected_reg_s <= CONSTANT_REG_s;
		when PERIPHERAL_DESCRIPTOR_H_ADD_c		=>                                                                                
			selected_reg_s <= PERIPHERAL_DESCRIPTOR_H_REG_s;
		when PERIPHERAL_DESCRIPTOR_L_ADD_c		=>                                                                                
			selected_reg_s <= PERIPHERAL_DESCRIPTOR_L_REG_s;
		when SCRATCH1_REG_ADD_c		=>                                                                                
			selected_reg_s <= SCRATCH1_REG_s;
		when SCRATCH2_REG_ADD_c		=>                                                                                
			selected_reg_s <= SCRATCH2_REG_s;
		when REDS_CONN1_REG_ADD_c		=>                                                                                
			selected_reg_s <= REDS_CONN1_STAT_REG_s; 
		when REDS_CONN2_REG_ADD_c		=>                                                                  	
			selected_reg_s <= REDS_CONN2_STAT_REG_s;
									
		when REDS_CONN3_REG_ADD_c		=>                                                                  				
			selected_reg_s <= REDS_CONN3_STAT_REG_s; 
			
		when REDS_CONN4_REG_ADD_c		=>                                                                  		  		
			selected_reg_s <= REDS_CONN4_STAT_REG_s; 
									
		when REDS_CONN5_REG_ADD_c		=>                                                                  		
			selected_reg_s <= REDS_CONN5_STAT_REG_s; 
									
		when DIP_SW_REG_ADD_c				=>                                                              		  		
			selected_reg_s <= "000000" & DIP_SW_REG_s;  
									
		when PUSH_BUT_REG_ADD_c			=>                                                                  	  		
			selected_reg_s <= PUSH_BUT_REG_s;   
									
		when LED_REG_ADD_c				=>                                                              			
			selected_reg_s <= "0000000" & LED_REG_s; 
									
		when UART_CONTROL_REG_ADD_c		=>                                                                    			
			selected_reg_s <= "000000000000" & UART_CONTROL_REG_s;	
									
		when AD_GPIO_REG_ADD_c	=>                                                                  		    	
			selected_reg_s <= "000000000000" & AD_GPIO_REG_s;  
			
		when GPIO_X_REG_ADD_c		=>                                                                  	  			
			selected_reg_s <= "00000" & GPIO_X_STAT_REG_s; 
									
		when GPIO_3V3_REG_ADD_c			=>                                                                  		  		
			selected_reg_s <= "000000000000" & GPIO_3V3_STAT_REG_s;     
									
		when SPI_CS_REG_ADD_c			=>                                                                  		  		
			selected_reg_s <= "000000000000" & SPI_CS_REG_s; 
			
		when GPIO_H_REG_ADD_c		=>                                                                  	
			selected_reg_s <= "00000000" & GPIO_H_STAT_REG_s;  
									
		when GPIO_X_OE_REG_ADD_c				=>                                                                   			
			selected_reg_s <= "00000" & GPIO_X_OE_REG_s; 
									
		when GPIO_3V3_OE_REG_ADD_c	=>                                                                  				
			selected_reg_s <= "000000000000" & GPIO_3V3_OE_REG_s; 
		
		when GPIO_H_OE_REG_ADD_c	=>
			selected_reg_s <= "00000000" & GPIO_H_OE_REG_s;
											
		when DISP_7SEG1_REG_ADD_c	=>                                                                  			
			selected_reg_s <= "00000000" & DISP_7SEG1_REG_s;  
									
		when DISP_7SEG2_REG_ADD_c	=>                                                                  			
			selected_reg_s <= "00000000" & DISP_7SEG2_REG_s;  
									
		when DISP_7SEG3_REG_ADD_c	=>                                                                  			
			selected_reg_s <= "00000000" & DISP_7SEG3_REG_s; 
									
		when ENCODER_DIRECTION_REG_ADD_c 	=>                                                                  			
			selected_reg_s <= ENCODER_DIRECTION_REG_s & "00000000000000" ;   
									
		when ENCODER_COUNT_REG_ADD_c 	=>                                                                  			
			selected_reg_s <= ENCODER_COUNT_REG_s; 
			
		when BUZZER_REG_ADD_c 	=>        
                 	selected_reg_s <= "0000000000000" & BUZZER_REG_s;
			
		when LCD_STATUS_REG_ADD_c 		=>                                                                  			
			selected_reg_s <= "0000000" & LCD_STATUS_REG_s; 
									
		when REDS_CONN1_OE_REG_ADD_c      =>                                                              			
			selected_reg_s <= REDS_CONN1_OE_REG_s;  
									
		when REDS_CONN2_OE_REG_ADD_c      =>                                                              			
			selected_reg_s <= REDS_CONN2_OE_REG_s;  
									
		when REDS_CONN3_OE_REG_ADD_c      =>                                                              			
			selected_reg_s <= REDS_CONN3_OE_REG_s;
									
		when REDS_CONN4_OE_REG_ADD_c      =>                                                              			
			selected_reg_s <= REDS_CONN4_OE_REG_s;   
									
		when REDS_CONN5_OE_REG_ADD_c      =>                                                              			
			selected_reg_s <= REDS_CONN5_OE_REG_s; 
									
		when FMC1_GPIO1_REG_ADD_c	=>                                                                  			
			selected_reg_s <= FMC1_GPIO1_STAT_REG_s;	
									
		when FMC1_GPIO2_REG_ADD_c	=>                                                                  		
			selected_reg_s <= FMC1_GPIO2_STAT_REG_s;
									
		when FMC1_GPIO3_REG_ADD_c	=>                                                                  			
			selected_reg_s <= FMC1_GPIO3_STAT_REG_s;
									
		when FMC1_GPIO4_REG_ADD_c	=>                                                                  			
			selected_reg_s <= FMC1_GPIO4_STAT_REG_s;	
									
		when FMC1_GPIO5_REG_ADD_c	=>              
			selected_reg_s <= "00000000000" & FMC1_GPIO5_STAT_REG_s;	
									
		when FMC1_GPIO1_OE_REG_ADD_c		=>                                                                  			
			selected_reg_s <= FMC1_GPIO1_OE_REG_s;	
									
		when FMC1_GPIO2_OE_REG_ADD_c		=>                                                                  			
			selected_reg_s <= FMC1_GPIO2_OE_REG_s;	
									
		when FMC1_GPIO3_OE_REG_ADD_c		=>                                                                  			
			selected_reg_s <= FMC1_GPIO3_OE_REG_s;	
									
		when FMC1_GPIO4_OE_REG_ADD_c		=>  
			selected_reg_s <= FMC1_GPIO4_OE_REG_s;
									
		when FMC1_GPIO5_OE_REG_ADD_c		=>  
			selected_reg_s <= "000000000000" & FMC1_GPIO5_OE_REG_s;	
			
		when FMC2_GPIO1_REG_ADD_c	=>
			selected_reg_s <= FMC2_GPIO1_STAT_REG_s;
									
		when FMC2_GPIO2_REG_ADD_c	=>    
			selected_reg_s <= FMC2_GPIO2_STAT_REG_s;	
									
		when FMC2_GPIO3_REG_ADD_c	=>    
			selected_reg_s <= FMC2_GPIO3_STAT_REG_s;	
									
		when FMC2_GPIO4_REG_ADD_c	=>   
			selected_reg_s <= FMC2_GPIO4_STAT_REG_s;
									
		when FMC2_GPIO5_REG_ADD_c	=>   	
			selected_reg_s <= "00000000000" & FMC2_GPIO5_STAT_REG_s;	
			
		when FMC2_GPIO1_OE_REG_ADD_c		=>
			selected_reg_s <= FMC2_GPIO1_OE_REG_ADD_c;
									
		when FMC2_GPIO2_OE_REG_ADD_c		=>
			selected_reg_s <= FMC2_GPIO1_OE_REG_ADD_c;	
									
		when FMC2_GPIO3_OE_REG_ADD_c		=>  
			selected_reg_s <= FMC2_GPIO1_OE_REG_ADD_c;	
									
		when FMC2_GPIO4_OE_REG_ADD_c		=>  
			selected_reg_s <= FMC2_GPIO1_OE_REG_ADD_c;	
			
		when FMC2_GPIO5_OE_REG_ADD_c		=>	
			selected_reg_s <= "000000000000" & FMC2_GPIO5_OE_REG_s;	
									
		when IRQ_CTL_REG_ADD_c			=>  
			selected_reg_s <= "00000000" & IRQ_CTL_REG_s(7 downto 0) ;	
									
		when others						=>
			selected_reg_s <= (others => '0');
	end case;					
	end process;
	
-- address decoder (write operation) and registers
process(clk_i, reset_i)
begin
	if (reset_i = '1') then
		SCRATCH1_REG_s				<= (others => '0');
		SCRATCH2_REG_s				<= (others => '0');
		PUSH_BUT_REG_s(14)			<=	'0';
		LED_REG_s					<=	(others => '0');
		DISP_7SEG1_REG_s			<=	(others => '0');
		DISP_7SEG2_REG_s			<=	(others => '0');
		DISP_7SEG3_REG_s			<=	(others => '0');
		LCD_CONTROL_REG_s(9 downto 0)	<=	(others => '0');
		UART_CONTROL_REG_s(1)		<= '0';
		UART_CONTROL_REG_s(3)       <= '0';		
		AD_GPIO_REG_s				<=	(others => '0');
		DA_CONTROL_REG_s			<=	(others => '0');
		GPIO_X_CTRL_REG_s			<=  (others => '0');
		GPIO_3V3_CTRL_REG_s			<=  (others => '0');
		GPIO_H_CTRL_REG_s			<=  (others => '0');
		GPIO_3V3_OE_REG_s			<=	(others => '0');
		GPIO_X_OE_REG_s				<=	(others => '0');
		GPIO_H_OE_REG_s				<=	(others => '0');
		SPI_CS_REG_s				<=	(others => '0');
		BUZZER_REG_s 				<=	(others => '0');
		REDS_CONN1_CTRL_REG_s		<= (others => '0');
		REDS_CONN2_CTRL_REG_s		<= (others => '0');
		REDS_CONN3_CTRL_REG_s		<= (others => '0');
		REDS_CONN4_CTRL_REG_s		<= (others => '0');
		REDS_CONN5_CTRL_REG_s		<= (others => '0');
		REDS_CONN1_OE_REG_s			<=	(others => '0');
		REDS_CONN2_OE_REG_s			<=	(others => '0');
		REDS_CONN3_OE_REG_s			<=	(others => '0');
		REDS_CONN4_OE_REG_s			<=	(others => '0');
		REDS_CONN5_OE_REG_s			<=	(others => '0');
		FMC1_GPIO1_CTRL_REG_s		<=	(others => '0');
		FMC1_GPIO2_CTRL_REG_s		<=	(others => '0');
		FMC1_GPIO3_CTRL_REG_s		<=	(others => '0');
		FMC1_GPIO4_CTRL_REG_s		<=	(others => '0');
		FMC1_GPIO5_CTRL_REG_s		<=	(others => '0');
		FMC2_GPIO1_CTRL_REG_s		<=	(others => '0');
		FMC2_GPIO2_CTRL_REG_s		<=	(others => '0');
		FMC2_GPIO3_CTRL_REG_s		<=	(others => '0');
		FMC2_GPIO4_CTRL_REG_s		<=	(others => '0');
		FMC2_GPIO5_CTRL_REG_s		<=	(others => '0');
		FMC1_GPIO1_OE_REG_s			<= (others =>'0');
		FMC1_GPIO2_OE_REG_s			<= (others =>'0');
		FMC1_GPIO3_OE_REG_s			<= (others =>'0');
		FMC1_GPIO4_OE_REG_s			<= (others =>'0');
		FMC1_GPIO5_OE_REG_s			<= (others =>'0');
		FMC2_GPIO1_OE_REG_s			<= (others =>'0');
		FMC2_GPIO2_OE_REG_s			<= (others =>'0');
		FMC2_GPIO3_OE_REG_s			<= (others =>'0');
		FMC2_GPIO4_OE_REG_s			<= (others =>'0');
		FMC2_GPIO5_OE_REG_s			<= (others =>'0');
--		IRQ_CTL_REG_s(0)			<= '0'; -- now set by an FSM, see below
        IRQ_CTL_REG_s(7)			<= '0'; -- IRQ_enable		
	elsif rising_edge(clk_i) then
	  if (write_en_s = '1') then
	
		case lba_add_i(15 downto 0) is
				when SCRATCH1_REG_ADD_c		=>  
					SCRATCH1_REG_s			<= data_in_s;
				when SCRATCH2_REG_ADD_c		=>  
					SCRATCH2_REG_s			<= data_in_s;
				when PUSH_BUT_REG_ADD_c			=>
					PUSH_BUT_REG_s(14) 		<= data_in_s(14);
				when LED_REG_ADD_c					=>
					LED_REG_s 				<= data_in_s(8 downto 0);
				when DISP_7SEG1_REG_ADD_c	=>
					DISP_7SEG1_REG_s 		<= data_in_s(7 downto 0);
				when DISP_7SEG2_REG_ADD_c	=>
					DISP_7SEG2_REG_s 		<= data_in_s(7 downto 0);
				when DISP_7SEG3_REG_ADD_c	=>
					DISP_7SEG3_REG_s 		<= data_in_s(7 downto 0);
				when LCD_CONTROL_REG_ADD_c		=>
					LCD_CONTROL_REG_s(9 downto 0) <= data_in_s(9 downto 0);	-- bit 10 is drived from a FSM_start_LCD					
				when UART_CONTROL_REG_ADD_c		=>
					UART_CONTROL_REG_s(1)<= data_in_s(1);
					UART_CONTROL_REG_s(3)<= data_in_s(3);
				when AD_GPIO_REG_ADD_c	=>
					AD_GPIO_REG_s 	<= data_in_s(3 downto 0);
				when DA_CONTROL_REG_ADD_c	=>
					DA_CONTROL_REG_s 		<= data_in_s(1 downto 0);
				when GPIO_X_REG_ADD_c		=>
					GPIO_X_CTRL_REG_s		<= data_in_s(10 downto 0);
				when GPIO_3V3_REG_ADD_c			=>
					GPIO_3V3_CTRL_REG_s			<= data_in_s(3 downto 0);
				when GPIO_H_REG_ADD_c		=>
					GPIO_H_CTRL_REG_s 		<= data_in_s(7 downto 0);
				when GPIO_3V3_OE_REG_ADD_c		=>
					GPIO_3V3_OE_REG_s 		<= data_in_s(3 downto 0);
				when GPIO_X_OE_REG_ADD_c	=>
					GPIO_X_OE_REG_s 		<= data_in_s(10 downto 0);
				when GPIO_H_OE_REG_ADD_c	=>
					GPIO_H_OE_REG_s 		<= data_in_s(7 downto 0);
				when SPI_CS_REG_ADD_c		=>
					SPI_CS_REG_s 			<= data_in_s(3 downto 0);			
				when BUZZER_REG_ADD_c 		=>
					BUZZER_REG_s			<= data_in_s(2 downto 0);
				when REDS_CONN1_REG_ADD_c		=>
					REDS_CONN1_CTRL_REG_s 	<= data_in_s;
				when REDS_CONN2_REG_ADD_c		=>
					REDS_CONN2_CTRL_REG_s 	<= data_in_s;
				when REDS_CONN3_REG_ADD_c		=>
					REDS_CONN3_CTRL_REG_s 	<= data_in_s;
				when REDS_CONN4_REG_ADD_c		=>
					REDS_CONN4_CTRL_REG_s 	<= data_in_s;
				when REDS_CONN5_REG_ADD_c		=>
					REDS_CONN5_CTRL_REG_s 	<= data_in_s;
				when REDS_CONN1_OE_REG_ADD_c =>
					REDS_CONN1_OE_REG_s		<= data_in_s;
				when REDS_CONN2_OE_REG_ADD_c =>
					REDS_CONN2_OE_REG_s		<= data_in_s;
				when REDS_CONN3_OE_REG_ADD_c =>
					REDS_CONN3_OE_REG_s		<= data_in_s;
				when REDS_CONN4_OE_REG_ADD_c =>
					REDS_CONN4_OE_REG_s		<= data_in_s;
				when REDS_CONN5_OE_REG_ADD_c =>
					REDS_CONN5_OE_REG_s		<= data_in_s;
				when FMC1_GPIO1_REG_ADD_c	=>
					FMC1_GPIO1_CTRL_REG_s	<= data_in_s;
				when FMC1_GPIO2_REG_ADD_c	=>
					FMC1_GPIO2_CTRL_REG_s	<= data_in_s;
				when FMC1_GPIO3_REG_ADD_c	=>
					FMC1_GPIO3_CTRL_REG_s	<= data_in_s;
				when FMC1_GPIO4_REG_ADD_c	=>
					FMC1_GPIO4_CTRL_REG_s	<= data_in_s;
				when FMC1_GPIO5_REG_ADD_c	=>
					FMC1_GPIO5_CTRL_REG_s	<= data_in_s(3 downto 0);
				when FMC1_GPIO1_OE_REG_ADD_c =>
					FMC1_GPIO1_OE_REG_s		<= data_in_s;
				when FMC1_GPIO2_OE_REG_ADD_c =>
					FMC1_GPIO2_OE_REG_s		<= data_in_s;
				when FMC1_GPIO3_OE_REG_ADD_c =>
					FMC1_GPIO3_OE_REG_s		<= data_in_s;
				when FMC1_GPIO4_OE_REG_ADD_c =>
					FMC1_GPIO4_OE_REG_s		<= data_in_s;
				when FMC1_GPIO5_OE_REG_ADD_c =>
					FMC1_GPIO5_OE_REG_s		<= data_in_s(3 downto 0);
				when FMC2_GPIO1_REG_ADD_c	=>
					FMC2_GPIO1_CTRL_REG_s	<= data_in_s;
				when FMC2_GPIO2_REG_ADD_c	=>
					FMC2_GPIO2_CTRL_REG_s	<= data_in_s;
				when FMC2_GPIO3_REG_ADD_c	=>
					FMC2_GPIO3_CTRL_REG_s	<= data_in_s;
				when FMC2_GPIO4_REG_ADD_c	=>
					FMC2_GPIO4_CTRL_REG_s	<= data_in_s;
				when FMC2_GPIO5_REG_ADD_c	=>
					FMC2_GPIO5_CTRL_REG_s	<= data_in_s(3 downto 0);
				when FMC2_GPIO1_OE_REG_ADD_c =>
					FMC2_GPIO1_OE_REG_s		<= data_in_s;
				when FMC2_GPIO2_OE_REG_ADD_c =>
					FMC2_GPIO2_OE_REG_s		<= data_in_s;
				when FMC2_GPIO3_OE_REG_ADD_c		=>
					FMC2_GPIO3_OE_REG_s		<= data_in_s;
				when FMC2_GPIO4_OE_REG_ADD_c =>
					FMC2_GPIO4_OE_REG_s		<= data_in_s;
				when FMC2_GPIO5_OE_REG_ADD_c =>
					FMC2_GPIO5_OE_REG_s		<= data_in_s(3 downto 0);
				when IRQ_CTL_REG_ADD_c		=>
					-- IRQ_Enable
					IRQ_CTL_REG_s(7)		<= data_in_s(7);
				when others			=>	null;			
			end case;
	end if;
  end if;	
end process;


 
-- IRQ clear bit reset --------------------------------------------------------------------------------------------------------
FSM_irqclear_bit: process(present_st_s, write_en_s, lba_add_i(15 downto 0), irq_status_i,data_in_s(0))
begin
  -- state 0: init, reset the clear bit
  if (present_st_s = '0') then
    -- output decoder
    IRQ_CTL_REG_s(0) <= '0';
	-- futur state decoder
	if (irq_status_i = '1' and write_en_s = '1' and lba_add_i(15 downto 0) = IRQ_CTL_REG_ADD_c and data_in_s(0) = '1') then
	  -- go to next state
      futur_st_s <= '1';
	else
	  -- stay in the same state
	  futur_st_s <= '0';
	end if;
  -- state 1: set the start bit
  elsif (present_st_s = '1') then
    -- output decoder
    IRQ_CTL_REG_s(0) <= '1';
	-- futur state decoder
	if (irq_status_i = '0') then
	  -- go to init state
      futur_st_s <= '0';
	else
	  -- stay in the same state
	  futur_st_s <= '1';
	end if;
  else
  -- default
    IRQ_CTL_REG_s(0) <= '0';
	futur_st_s <= '0';
  end if;
end process FSM_irqclear_bit;

FSM_irqclear_mem: process(clk_i, reset_i)
begin
	if (reset_i = '1') then
		present_st_s <= '0';
	elsif rising_edge(clk_i) then
		present_st_s <= futur_st_s;
	end if;
end process FSM_irqclear_mem;
-------------------------------------------------------------------------------------------------------------------------

-- LCD start bit reset --------------------------------------------------------------------------------------------------------
FSM_start_LCD: process(p_state_s, write_en_s, lba_add_i(15 downto 0), start_rst_i,data_in_s(10))
begin
  -- state 0: init, reset the start bit
  if (p_state_s = '0') then
    -- output decoder
    LCD_CONTROL_REG_s(10) <= '0';
	-- futur state decoder
	if (write_en_s = '1' and lba_add_i(15 downto 0) = LCD_CONTROL_REG_ADD_c and data_in_s(10) = '1') then
	  -- go to next state
      f_state_s <= '1';
	else
	  -- stay in the same state
	  f_state_s <= '0';
	end if;
  -- state 1: set the start bit
  elsif (p_state_s = '1') then
    -- output decoder
    LCD_CONTROL_REG_s(10) <= '1';
	-- futur state decoder
	if (start_rst_i = '1') then
	  -- go to init state
      f_state_s <= '0';
	else
	  -- stay in the same state
	  f_state_s <= '1';
	end if;
  else
  -- default
    LCD_CONTROL_REG_s(10) <= '0';
	f_state_s <= '0';
  end if;
end process;

FSM_LCD_mem: process(clk_i, reset_i)
begin
	if (reset_i = '1') then
		p_state_s <= '0';
	elsif rising_edge(clk_i) then
		p_state_s <= f_state_s;
	end if;
end process FSM_LCD_mem;
-------------------------------------------------------------------------------------------------------------------------

 -- outputs

		-- to SPI mux
	    lba_spi_acc_cs_o        <= SPI_CS_REG_s(0);
	    lba_spi_adc_cs_o        <= SPI_CS_REG_s(2);
	    lba_spi_dac_cs_o        <= SPI_CS_REG_s(3);
	    lba_spi_conn_cs_o       <= SPI_CS_REG_s(1);
	    --------------------------------------------------------------------------------------------------------------------------------------
		-- to ADC
		adc_gpio_o				<= AD_GPIO_REG_s;
		--------------------------------------------------------------------------------------------------------------------------------------		
		-- to DAC
		dac_nldac_o				<= DA_CONTROL_REG_s(1);		
		dac_nrs_o           	<= DA_CONTROL_REG_s(0);
	    -- to IRQ generator
	    irq_clear_o             <= IRQ_CTL_REG_s(0);
		push_but_reg_o			<= PUSH_BUT_REG_s(7 downto 0);
        irq_enable_o            <= IRQ_CTL_REG_s(7);
	    --------------------------------------------------
	    -- to 7-segments displays
	    disp_7seg1_o			<= not DISP_7SEG1_REG_s(6 downto 0);
	    disp_7seg2_o			<= not DISP_7SEG2_REG_s(6 downto 0);
	    disp_7seg3_o			<= not DISP_7SEG3_REG_s(6 downto 0);
	    disp_7seg1_DP_o			<= not DISP_7SEG1_REG_s(7);	
	    disp_7seg2_DP_o			<= not DISP_7SEG2_REG_s(7);	
	    disp_7seg3_DP_o			<= not DISP_7SEG3_REG_s(7);	
	    --------------------------------------------------
	    -- to LCD controller
	    rs_up_o		            <= LCD_CONTROL_REG_s(9);
	    rw_up_o		            <= LCD_CONTROL_REG_s(8);
	    start_o		            <= LCD_CONTROL_REG_s(10);
	    data_up_o	            <= LCD_CONTROL_REG_s(7 downto 0);
	    --------------------------------------------------
	    -- to switches and LEDs
	    --LEDs                         
	    led_o				    <= LED_REG_s(7 downto 0);
	    led_6_7_en_o            <= LED_REG_s(8);
	    --------------------------------------------------
	    -- to buzzer controller
	    buzzer_en_o			    <= BUZZER_REG_s(0);
	    fast_mode_o			    <= BUZZER_REG_s(1);
	    slow_mode_o			    <= BUZZER_REG_s(2);
	    --------------------------------------------------
        -- to touch pad controller
        tp_en_o					<= PUSH_BUT_REG_s(14);
       --------------------------------------------------
        -- to UART header
        uart_header_cts_o		<= UART_CONTROL_REG_s(3);
        uart_header_tx_o		<= UART_CONTROL_REG_s(1);
        --------------------------------------------------
        -- GPIOs: to tri-state buffers on top
            -- GPIO_x
        gpio_x_o                <= GPIO_X_CTRL_REG_s;
        gpio_x_oe_o             <= GPIO_X_OE_REG_s;
            -- GPIO33_x : 16-pin header connector J38 
            -- GPIO33_x(5) is reserved for reset from CPU
        gpio33_x_o              <= GPIO_3V3_CTRL_REG_s;
        gpio33_x_oe_o           <= GPIO_3V3_OE_REG_s;
            -- GPIO_Hx : 16-pin header connector J39
        gpio_Hx_o                <= GPIO_H_CTRL_REG_s; 
        gpio_Hx_oe_o             <= GPIO_H_OE_REG_s; 
        --------------------------------------------------
        --FMC1
            -- LA00_P/N TO LA07_P/N
        fmc1_gpio1_o			 <= FMC1_GPIO1_CTRL_REG_s;
        fmc1_gpio1_oe_o			 <= FMC1_GPIO1_OE_REG_s;
            -- LA08_P/N TO LA15_P/N
       fmc1_gpio2_o				 <= FMC1_GPIO2_CTRL_REG_s;
        fmc1_gpio2_oe_o			 <= FMC1_GPIO2_OE_REG_s;
            -- LA16_P/N TO LA23_P/N
        fmc1_gpio3_o			 <= FMC1_GPIO3_CTRL_REG_s;
        fmc1_gpio3_oe_o			 <= FMC1_GPIO3_OE_REG_s;
            -- LA24_P/N TO LA31_P/N
        fmc1_gpio4_o			 <= FMC1_GPIO4_CTRL_REG_s;
        fmc1_gpio4_oe_o			 <= FMC1_GPIO4_OE_REG_s;
            -- LA32_P/N TO LA33_P/N
            -- for FMC DEBUG XM105 board:    fmc1_gpio5_io(3..0): LEDS DS4..DS1 
        fmc1_gpio5_o			 <= FMC1_GPIO5_CTRL_REG_s;
        fmc1_gpio5_oe_o			 <= FMC1_GPIO5_OE_REG_s; -- when FMC DEBUG XM105 board is connected, these bits are not used
															-- (direction is forced to output on the top)
        --------------------------------------------------
        --FMC2
            -- LA00_P/N TO LA07_P/N
        fmc2_gpio1_o			 <= FMC2_GPIO1_CTRL_REG_s;
        fmc2_gpio1_oe_o			 <= FMC2_GPIO1_OE_REG_s;
        -- LA08_P/N TO LA15_P/N        
        fmc2_gpio2_o		 	 <= FMC2_GPIO2_CTRL_REG_s;
        fmc2_gpio2_oe_o		 	 <= FMC2_GPIO2_OE_REG_s;
        -- LA16_P/N TO LA23_P/N        
        fmc2_gpio3_o		 	 <= FMC2_GPIO3_CTRL_REG_s;
        fmc2_gpio3_oe_o		 	 <= FMC2_GPIO3_OE_REG_s;
        -- LA24_P/N TO LA31_P/N        
        fmc2_gpio4_o		 	 <= FMC2_GPIO4_CTRL_REG_s;
        fmc2_gpio4_oe_o		 	 <= FMC2_GPIO4_OE_REG_s;
        -- LA32_P/N TO LA33_P/N        
        -- for FMC DEBUG XM105 board:  fmc2_gpio5_io(3..0): LEDS DS4..DS1 
        fmc2_gpio5_o			 <= FMC2_GPIO5_CTRL_REG_s;
        fmc2_gpio5_oe_o			 <= FMC2_GPIO5_OE_REG_s; -- when FMC DEBUG XM105 board is connected, these bits are not used
         -------------------								-- (direction is forced to output on the top)-------------------------------
        -- 80-pin DKK (REDS connector)
            -- pins 1 to 16
        reds_80p_gpio1_o		 <= REDS_CONN1_CTRL_REG_s;
        reds_80p_gpio1_oe_o		 <= REDS_CONN1_OE_REG_s;
            -- pins 17 to 32
        reds_80p_gpio2_o		 <= REDS_CONN2_CTRL_REG_s;
        reds_80p_gpio2_oe_o		 <= REDS_CONN2_OE_REG_s;
            --  pins 33 to 48
       reds_80p_gpio3_o			 <= REDS_CONN3_CTRL_REG_s;
        reds_80p_gpio3_oe_o		 <= REDS_CONN3_OE_REG_s;
            --  pins 49 to 64
        reds_80p_gpio4_o		 <= REDS_CONN4_CTRL_REG_s;
        reds_80p_gpio4_oe_o		 <= REDS_CONN4_OE_REG_s;
            -- pins 65 to 80
        reds_80p_gpio5_o		 <= REDS_CONN5_CTRL_REG_s;
        reds_80p_gpio5_oe_o		 <= REDS_CONN5_OE_REG_s;

	end architecture behavioral;