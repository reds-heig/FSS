------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : spi_mux.vhd
-- Author               : Evangelina Lolivier-Exler
-- Date                 : 24.10.2013
-- Target Devices       : Spartan6 xc6slx150t-3fgg900
--
-- Context              : Reptar - FPGA design
--
---------------------------------------------------------------------------------------------
-- Description : Switch for SPI signals from DM3730 (module SPI4, 1 channel supported) 
--				 to accelerometer, ADC, DAC or connector W3 (for W3 only CS is switched, 
--				 other signals are directly wired)
--				 Switch for SPI data from accelerometer or ADC to DM3730
--				 Selection is done based on register SPI_CS_REG
---------------------------------------------------------------------------------------------
-- Information :
---------------------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Engineer     Comments
-- 0.0   See header  ELR          Initial version


---------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

    entity spi_mux is
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
    end spi_mux;
	
	architecture dataflow of spi_mux is
	

	begin
	
			-- generate mux selection from SPI register settings
			

            -- data to BTB connector (SPI bus of DM3730) 
            spi_somi_o  <= 	spi_adc_sdo_i when lba_spi_adc_cs_i = '1' else
							spi_acc_sdo_i when lba_spi_acc_cs_i = '1' else
							'1';
			
            -- data and ctrl signals to accelerometer (CS active low)
            spi_acc_ncs_o   <=   spi_ncs_i when lba_spi_acc_cs_i = '1' else '1';   
            spi_acc_clk_o  <=   spi_clk_i  when lba_spi_acc_cs_i = '1' else '1';       
            spi_acc_sdi_o  <= 	spi_simo_i when lba_spi_acc_cs_i = '1' else '1';        
                     
            -- data and ctrl signals to ADC (CS active low)         
            spi_adc_ncs_o   <=   spi_ncs_i when lba_spi_adc_cs_i = '1'  else '1';           
            spi_adc_clk_o  <=   spi_clk_i  when lba_spi_adc_cs_i = '1'  else '1';           
            spi_adc_sdi_o  <= 	spi_simo_i when lba_spi_adc_cs_i = '1'  else '1';           
                     
            -- data and ctrl signals to DAC (CS active low)        
            spi_dac_ncs_o     <=   spi_ncs_i when lba_spi_dac_cs_i = '1'  else '1';         
            spi_dac_clk_o    <=   spi_clk_i  when lba_spi_dac_cs_i = '1'  else '1';         
            spi_dac_sdi_o    <=   spi_simo_i when lba_spi_dac_cs_i = '1'  else '1';   
			
            -- CS to SPI header connector (W3): send to connector the input CS from DM3730 if the connector's CS is enabled on register (for debug purposes)
                -- data and clk signals are directly wired from BTB
            spi_conn_ncs_o  <=  spi_ncs_i   when  lba_spi_conn_cs_i = '1' else '1';       
	
	
	
	
	
	end architecture dataflow;	
