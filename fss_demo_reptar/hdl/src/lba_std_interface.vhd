------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : lba_std_interface.vhd
-- Author               : Evangelina Lolivier-Exler
-- Date                 : 16.10.2013
-- Target Devices       : Spartan6 xc6slx150t-3fgg900
--
-- Context              : Reptar - FPGA design
--
---------------------------------------------------------------------------------------------
-- Description :		standard interface between the local bus asynchronous (lba) controller  
--						and the peripherals of the REPTAR board
--						The registers contained in this block are described in the document 
--						Spartan6_registers.xlsx
---------------------------------------------------------------------------------------------
-- Information :
---------------------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Engineer     Comments
-- 0.0   See header  ELR          Initial version, based on Reptar_local_bus_v2.vhd of VTT
-- 1.0   19.12.13    ELR		  LEDs for encoder inverted

---------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.touch_pad_ctrl_pkg.all;

entity lba_std_interface is
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
	dac_nldac_o				 :	out std_logic;			
	dac_nrs_o           	 :	out std_logic;
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

end lba_std_interface;

architecture structural of lba_std_interface is

    component lba_sp6_registers is
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
    end component lba_sp6_registers;
    
    component spi_mux is
        port(
            -- to/from LBA SP6 registers
            lba_spi_acc_cs_i        : in std_logic;
            lba_spi_adc_cs_i        : in std_logic;
            lba_spi_dac_cs_i        : in std_logic;
            lba_spi_conn_cs_i       : in std_logic;
            -- to/from BTB connector (SPI bus of DM3730)
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
            -- to/from DAC         
            spi_dac_ncs_o            : out std_logic;
            spi_dac_clk_o           : out std_logic;
            spi_dac_sdi_o           : out std_logic;
            -- to/from SPI header connector (W3)
                -- data and clk signals are directly wired from BTB
            spi_conn_ncs_o           : out std_logic

        );
    end component spi_mux;
    
    component irq_generator is
        port(
			clk_i				: in std_logic;
			reset_i				: in std_logic;
            -- to/from LBA SP6 registers
            irq_clear_i         : in std_logic;
            irq_status_o        : out std_logic;
            irq_source_o        : out std_logic_vector(1 downto 0);
            irq_button_o        : out std_logic_vector(2 downto 0);
			push_but_reg_i		: in std_logic_vector(8 downto 1);
            irq_enable_i        : in std_logic;
            -- from user interface
            lba_irq_user_i      : in std_logic;
            lbs_irq_user_i      : in std_logic;
            -- to BTB connector (DM3730)
            irq_o               : out std_logic
        );
    end component irq_generator;
    
    component encoder_sens_detector
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
	end component encoder_sens_detector;
	
	
	component buzzer_ctrl
		port(	
            clk_i				:		in std_logic;
			reset_i			    :		in std_logic;
            -- from LBA SP6 registers
			buzzer_en_i			:		in std_logic;
			fast_mode_i			:		in std_logic;
			slow_mode_i			:		in std_logic;
            -- to buzzer
			buz_osc_o			:		out std_logic
		);
	end component buzzer_ctrl;
	
	
	component lcd_ctrl
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
	end component lcd_ctrl;
	
	
    component touch_pad_ctrl is
    generic(
        N_Top_g : positive range 1 to 32 := 3);  -- default value
    port( 
        clock_i                 : in    std_logic;
        reset_i                 : in    std_logic;
        -- to/from LBA SP6 registers
        en_i					: in    std_logic;
        tpb_det_finger_o        : out   std_logic;
        -- to/from open collector on top level
        cap_i					: in 	std_logic;
        cmd_cap_o				: out	std_logic
    );
    end component touch_pad_ctrl;

    
    -- SPI
    signal lba_spi_acc_cs_s        : std_logic;
    signal lba_spi_adc_cs_s        : std_logic;
    signal lba_spi_dac_cs_s        : std_logic;
    signal lba_spi_conn_cs_s       : std_logic;
    
    -- IRQ generator
    signal irq_clear_s             : std_logic;
	signal irq_status_s            : std_logic;
    signal irq_source_s            : std_logic_vector(1 downto 0);
    signal irq_button_s            : std_logic_vector(2 downto 0);
	signal push_but_reg_s		   : std_logic_vector(8 downto 1);
    signal irq_enable_s            : std_logic;
    
    -- LCD controller
    signal rs_up_s                  :  std_logic;		  
    signal rw_up_s                  :  std_logic;		  
    signal start_s                  :  std_logic;		  
    signal ready_s                  :  std_logic;		  
    signal start_rst_s	            :  std_logic;
    signal data_up_lcd2reg_s        :  std_logic_vector(7 downto 0);
    signal data_up_reg2lcd_s        :  std_logic_vector(7 downto 0);
	
	-- LEDs
	signal led_reg_s               : std_logic_vector(7 downto 0);
	signal led_6_7_en_s            : std_logic;
    
    -- encoder sens detector
    signal left_rotation_s	      : std_logic;
	signal right_rotation_s	      : std_logic;
	signal pulse_counter_s	      : std_logic_vector(15 downto 0);
    
    -- buzzer controller
    signal buzzer_en_s            : std_logic;
    signal fast_mode_s            : std_logic;
    signal slow_mode_s            : std_logic;
    
    -- touch pad controller
    signal tp_en_s		          : std_logic;
    signal tp_det_finger_s        : std_logic;
    
    
begin

   lba_sp6_reg_inst: lba_sp6_registers
        port map(
        clk_i				    => clk_i,
        reset_i				    => reset_i,
        -- to/from lba_ctrl           
        lba_cs_std_i            => lba_cs_std_i,  
        lba_wr_en_i             => lba_wr_en_i,   
        lba_rd_en_i             => lba_rd_en_i,  
		lba_add_i               => lba_add_i,     
        -- to mux data std/user on top level
        lba_data_rd_std_o       => lba_data_rd_std_o,
        -- from tri-state buffer on top level
        lba_data_wr_i           => lba_data_wr_i,
        ------------------------------ ----------------------------------------------
        -- to SPI mux
        lba_spi_acc_cs_o        => lba_spi_acc_cs_s,   
        lba_spi_adc_cs_o        => lba_spi_adc_cs_s,   
        lba_spi_dac_cs_o        => lba_spi_dac_cs_s,   
        lba_spi_conn_cs_o       => lba_spi_conn_cs_s,
		------------------------------------------------------------------------------------
		-- to ADC
		adc_gpio_o				=> adc_gpio_o, 
		------------------------------------------------------------------------------------
		-- to DAC
		dac_nldac_o				=> dac_nldac_o,		
		dac_nrs_o           	=> dac_nrs_o,		
        -----------------------------------------------------------------------------------
        -- to/from IRQ generator
        irq_clear_o             => irq_clear_s,  
        irq_status_i            => irq_status_s, 
        irq_source_i            => irq_source_s, 
        irq_button_i            => irq_button_s, 
		push_but_reg_o	   		=> push_but_reg_s,
        irq_enable_o            => irq_enable_s,  
        -----------------------------------------------------------------------------------
        -- to 7-segments displays
        disp_7seg1_o			=> disp_7seg1_o,	
        disp_7seg2_o			=> disp_7seg2_o,	
        disp_7seg3_o			=> disp_7seg3_o,	
        disp_7seg1_DP_o			=> disp_7seg1_DP_o,	
        disp_7seg2_DP_o			=> disp_7seg2_DP_o,	
        disp_7seg3_DP_o			=> disp_7seg3_DP_o,	
        -------------------------------------------------------------------------------------        
        -- to/from LCD controller
		rs_up_o		            => rs_up_s,		  
		rw_up_o		            => rw_up_s,		  
		start_o		            => start_s,		  
        ready_i		            => ready_s,		  
		start_rst_i	            => start_rst_s,	  
        data_up_i	            => data_up_lcd2reg_s,	  
        data_up_o	            => data_up_reg2lcd_s,	  
        --------------------------------------------------------------------------------------
        -- to/from switches and LEDs
        -- push-buttons
        push_but_i				=> push_but_i,
        --DIPs                     
        dip_i					=> dip_i,
        --LEDs                     
        led_o				    => led_reg_s, 
        led_6_7_en_o            => led_6_7_en_s,
    ---------------------------------------------------------------------------------------- 
        -- from encoder sens detector
        left_rotate_i		    => left_rotation_s,	
		right_rotate_i		    => right_rotation_s,	
		pulse_counter_i		    => pulse_counter_s,	
    ------------------------------------------------------------------------------------------
        -- to buzzer controller
        buzzer_en_o			    => buzzer_en_s,
		fast_mode_o			    => fast_mode_s,
		slow_mode_o			    => slow_mode_s,
    -------------------------------------------------------------------------------------------
        -- to/from touch pad controller
        tp_en_o					=> tp_en_s,		
        tp_det_finger_i         => tp_det_finger_s, 
    ---------------------------------------------------------------------------------------------   
        --UART header
        uart_header_cts_o		=> uart_header_cts_o,	
        uart_header_rts_i		=> uart_header_rts_i,	
        uart_header_rx_i		=> uart_header_rx_i	,
        uart_header_tx_o		=> uart_header_tx_o	,
    -------------------------------------------------------------------------------------------
        -- GPIOs: to/from tri-state buffers on top
            -- GPIO_x
            -- GPIO_x(11..9) are in 16-pin header connector J8 , GPIO_x(8..1) are in 8-pin header connector W1 
        gpio_x_i                => gpio_x_i,    
        gpio_x_o                => gpio_x_o,    
        gpio_x_oe_o             => gpio_x_oe_o ,
            -- GPIO33_x : 16-pin header connector J38 
            -- GPIO33_x(5) is reserved for reset from CPU
        gpio33_x_i                => gpio33_x_i,      
        gpio33_x_o                => gpio33_x_o,      
        gpio33_x_oe_o             => gpio33_x_oe_o,   
            -- GPIO_Hx : 16-pin header connector J39
        gpio_Hx_i                => gpio_Hx_i,     
        gpio_Hx_o                => gpio_Hx_o,     
        gpio_Hx_oe_o             => gpio_Hx_oe_o,  
    ------------------------------------------------------------------------------------------------------
        --FMC1
            -- LA00_P/N TO LA07_P/N
        fmc1_gpio1_i			=> fmc1_gpio1_i,	
        fmc1_gpio1_o			=> fmc1_gpio1_o,	
        fmc1_gpio1_oe_o			=> fmc1_gpio1_oe_o,	
            -- LA08_P/N TO LA15_P/N
        fmc1_gpio2_i		=>  fmc1_gpio2_i,			
        fmc1_gpio2_o		=>	fmc1_gpio2_o,		
        fmc1_gpio2_oe_o		=>	fmc1_gpio2_oe_o,		
            -- LA16_P/N TO LA23_P/N
        fmc1_gpio3_i		=> 	fmc1_gpio3_i,			
        fmc1_gpio3_o		=> 	fmc1_gpio3_o,			
        fmc1_gpio3_oe_o		=> 	fmc1_gpio3_oe_o,			
            -- LA24_P/N TO LA31_P/N
        fmc1_gpio4_i		=> 	fmc1_gpio4_i,			
        fmc1_gpio4_o		=> 	fmc1_gpio4_o,			
        fmc1_gpio4_oe_o		=> 	fmc1_gpio4_oe_o,			
            -- LA32_P/N TO LA33_P/N
            -- for FMC DEBUG XM105 board:    fmc1_gpio5_io(3..0): LEDS DS4..DS1 
        fmc1_gpio5_i		=> 	fmc1_gpio5_i,		
        fmc1_gpio5_o		=> 	fmc1_gpio5_o,		
        fmc1_gpio5_oe_o		=> 	fmc1_gpio5_oe_o,		
            -- presence detection (pin H2 du FMC)
        fmc1_prsnt_i        =>  fmc1_prsnt_i,     
    ------------------------------------------------------------------------------------------------------------
        --FMC2
            -- LA00_P/N TO LA07_P/N
        fmc2_gpio1_i		=> 	fmc2_gpio1_i,		
        fmc2_gpio1_o		=> 	fmc2_gpio1_o,		
        fmc2_gpio1_oe_o		=> 	fmc2_gpio1_oe_o,		
        -- LA08_P/N TO LA15_P/N
        fmc2_gpio2_i		=> 	fmc2_gpio2_i,	
        fmc2_gpio2_o		=> 	fmc2_gpio2_o,	
        fmc2_gpio2_oe_o		=> 	fmc2_gpio2_oe_o,	
        -- LA16_P/N TO LA23_P/N
        fmc2_gpio3_i		=> 	fmc2_gpio3_i,		
        fmc2_gpio3_o		=> 	fmc2_gpio3_o,		
        fmc2_gpio3_oe_o		=> 	fmc2_gpio3_oe_o,		
        -- LA24_P/N TO LA31_P/N
        fmc2_gpio4_i		=> 	fmc2_gpio4_i,		
        fmc2_gpio4_o		=> 	fmc2_gpio4_o,		
        fmc2_gpio4_oe_o		=> 	fmc2_gpio4_oe_o,		
        -- LA32_P/N TO LA33_P/N
        -- for FMC DEBUG XM105 board:    fmc2_gpio5_io(3..0): LEDS DS4..DS1 
        --                               fmc2_gpio5_io(4):     presence detection (pin H2 du FMC)	
        fmc2_gpio5_i		=> 	 fmc2_gpio5_i,		   
        fmc2_gpio5_o		=> 	 fmc2_gpio5_o,			
        fmc2_gpio5_oe_o		=> 	 fmc2_gpio5_oe_o,		
            -- presence detection (pin H2 du FMC)
        fmc2_prsnt_i        =>   fmc2_prsnt_i,     
    ---------------------------------------------------------------------------------------------------------
        -- 80-pin DKK (REDS connector)
            -- pins 1 to 16
        reds_80p_gpio1_i		=> reds_80p_gpio1_i	,		
        reds_80p_gpio1_o		=> reds_80p_gpio1_o	,		
        reds_80p_gpio1_oe_o		=> reds_80p_gpio1_oe_o,			
            -- pins 17 to 32                           ,
        reds_80p_gpio2_i		=> reds_80p_gpio2_i	,		
        reds_80p_gpio2_o		=> reds_80p_gpio2_o	,		
        reds_80p_gpio2_oe_o		=> reds_80p_gpio2_oe_o,			
            --  pins 33 to 48                          ,
        reds_80p_gpio3_i		=> reds_80p_gpio3_i	,		
        reds_80p_gpio3_o		=> reds_80p_gpio3_o	,		
        reds_80p_gpio3_oe_o		=> reds_80p_gpio3_oe_o,			
            --  pins 49 to 64                          ,
        reds_80p_gpio4_i		=> reds_80p_gpio4_i	,		
        reds_80p_gpio4_o		=> reds_80p_gpio4_o	,		
        reds_80p_gpio4_oe_o		=> reds_80p_gpio4_oe_o,			
            -- pins 65 to 80                           ,
        reds_80p_gpio5_i		=> reds_80p_gpio5_i	,		
        reds_80p_gpio5_o		=> reds_80p_gpio5_o	,		
        reds_80p_gpio5_oe_o		=> reds_80p_gpio5_oe_o		
    ---------------------------------------------------------------------------------------------------------------
          
        );
		
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- LEDs (active-low) -----------------------
	
		
	led_o(5 downto 0) 	<= not led_reg_s(5 downto 0);	
	
	-- LEDs 6 and 7 can be driven from the LB register or from the encoder controller
    led_o(7) 			<= not led_reg_s(7) when led_6_7_en_s = '1' else not left_rotation_s;
	led_o(6) 			<= not led_reg_s(6) when led_6_7_en_s = '1' else not right_rotation_s;
	
	
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------			

        spi_mux_inst: spi_mux
        port map(
            -- to/from LBA SP6 registers
            lba_spi_acc_cs_i   => lba_spi_acc_cs_s,      
            lba_spi_adc_cs_i   => lba_spi_adc_cs_s,      
            lba_spi_dac_cs_i   => lba_spi_dac_cs_s,      
            lba_spi_conn_cs_i  => lba_spi_conn_cs_s,     
            -- to/from BTB connector (SPI bus of DM3730)
            spi_ncs_i          =>  spi_ncs_i,    
            spi_clk_i          =>  spi_clk_i,    
            spi_simo_i         =>  spi_simo_i,   
            spi_somi_o         =>  spi_somi_o,   
            -- to/from accelerometer
            spi_acc_ncs_o       => spi_acc_ncs_o ,      
            spi_acc_clk_o      => spi_acc_clk_o,      
            spi_acc_sdi_o      => spi_acc_sdi_o,      
            spi_acc_sdo_i      => spi_acc_sdo_i,      
            -- to/from ADC                     
            spi_adc_ncs_o       => spi_adc_ncs_o ,      
            spi_adc_clk_o      => spi_adc_clk_o,      
            spi_adc_sdi_o      => spi_adc_sdi_o,      
            spi_adc_sdo_i      => spi_adc_sdo_i,      
            -- to/from DAC                     
            spi_dac_ncs_o       => spi_dac_ncs_o ,      
            spi_dac_clk_o      => spi_dac_clk_o,      
            spi_dac_sdi_o      => spi_dac_sdi_o,      
            -- to/from SPI header connector (W3)
                -- data and clk signals are directly wired from BTB
            spi_conn_ncs_o      =>   spi_conn_ncs_o   

        );
		
	   encoder_sens_detect_inst: encoder_sens_detector
		port map(	
            clk_i		=> clk_i,			
			reset_i		=> reset_i,			
            -- from incremental encoder
			a_inc_i		=> 	enc_a_inc_i,	
			b_inc_i		=> 	enc_b_inc_i,	
            -- to/from LBA SP6 registers
			left_rotate_o	=> left_rotation_s,		
			right_rotate_o	=> right_rotation_s,		
			pulse_counter_o	=> pulse_counter_s	
		);
	
		lcd_ctrl_inst: lcd_ctrl
		port map(	
            clk_i			=>  clk_i,		
			reset_i			=>	reset_i	,
            -- to/from LBA SP6 registers
			rs_up_i		 	=> 	rs_up_s,		  			
			rw_up_i		 	=>  rw_up_s,		    		
			start_i		 	=>  start_s,		    		  	
            ready_o		 	=>  ready_s,		        
			start_rst_o	 	=>  start_rst_s,	    	   
            -- data returned to LB                  	   
			data_up_o		=>	data_up_lcd2reg_s,	                         
			-- data/cmd received from LB
			data_up_i		=>	data_up_reg2lcd_s,	
			-- to/from LCD
			rs_o			=> lcd_rs_o,		
			rw_o			=> lcd_rw_o,		
			e_o				=> lcd_e_o,		    
			-- to/from tri-state buffer on top level
			data_lcd_i	     => lcd_data_i,	 
			data_lcd_o	     => lcd_data_o,	 
			data_lcd_oe_o    => lcd_data_oe_o
	);
	
		touch_pad_ctrl_inst: touch_pad_ctrl 
		generic map(N_top_g => Size_of_Timer_c)  
		port map( 
			clock_i                 => clk_tp_i, 
			reset_i                 => reset_i, 
			-- to/from LBA SP6 registers
			en_i					=> tp_en_s,			
			tpb_det_finger_o        => tp_det_finger_s, 
			-- to/from open collector on top level
			cap_i					=> touch_pad_i, 			
			cmd_cap_o				=> touch_pad_oe  
		);
 
 	buzzer_ctrl_inst: buzzer_ctrl
		port map(	
            clk_i				=> clk_i,	
			reset_i			    => reset_i,	
            -- from LBA SP6 registers
			buzzer_en_i			=> buzzer_en_s,
			fast_mode_i			=> fast_mode_s,
			slow_mode_i			=> slow_mode_s,
            -- to buzzer        
			buz_osc_o			=> buzzer_osc_o
		);
		
	    irq_generator_inst: irq_generator
        port map(
			clk_i			   => clk_i,	
			reset_i			   => reset_i,	
             -- to/from LBA SP6 registers
            irq_clear_i        => irq_clear_s, 
            irq_status_o       => irq_status_s, 
            irq_source_o       => irq_source_s, 
            irq_button_o       => irq_button_s, 
			push_but_reg_i	   => push_but_reg_s,
            irq_enable_i       => irq_enable_s,
            -- from user interface
            lba_irq_user_i     => lba_irq_user_i, 
            lbs_irq_user_i     => lbs_irq_user_i, 
            -- to BTB connector 
            irq_o         		=> irq_o      
        );

 

    
end structural;
    
    
	
    