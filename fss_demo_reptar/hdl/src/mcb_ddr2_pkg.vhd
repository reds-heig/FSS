  ------------------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- Institut REDS
--
-- Fichier :  mcb_ddr2_pkg.vhd
-- Auteur  :  Evangelina Lolivier-Exler
-- Date    :  25.03.2013
--
-- Utilise dans   : REPTAR 
------------------------------------------------------------------------------------------
-- Fonctionnement vu de l'exterieur : 
--   Paquetage des constantes utilisées pour l'IP DDR2 de Xilinx
--
------------------------------------------------------------------------------------------
-- Ver  Date        Qui  Commentaires
-- 0.0  See header  ELR  Version initiale 
-- 
-- 
------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

package mcb_ddr2_pkg is
  
  -- DDR2
  constant DDR2_MEMCLK_PERIOD        : integer := 2500; 
  constant DDR2_GPMC_BURST_LEN       : integer := 4;
  constant DDR2_GPMC_DATA_SIZE       : integer := 16;
  constant DDR2_MCB_PORT_SIZE        : integer := 32;
  
  constant  DDR2_P0_MASK_SIZE         : integer := 4;
  constant  DDR2_P0_DATA_PORT_SIZE    : integer := 32;
  constant DDR2_P1_MASK_SIZE         : integer := 4;
  constant DDR2_P1_DATA_PORT_SIZE    : integer := 32;
  
  
  constant DDR2_RST_ACT_LOW          : integer := 0; 
    -- # = 1 for active low reset,
    -- # = 0 for active high reset.
  
  constant DDR2_INPUT_CLK_TYPE       : string := "SINGLE_ENDED"; -- input clock type DIFFERENTIAL or SINGLE_ENDED.
  
  constant DDR2_CALIB_SOFT_IP        : string := "TRUE"; 
    -- # = TRUE, Enables the soft calibration logic,
    -- # = FALSE, Disables the soft calibration logic.
    
  constant DDR2_SIMULATION           : string := "FALSE"; 
    -- # = TRUE, Simulating the design. Useful to reduce the simulation time,
    -- # = FALSE, Implementing the design.
    
    
  constant DDR2_HW_TESTING           : string := "FALSE"; 
    -- Determines the address space accessed by the traffic generator,
    -- # = FALSE, Smaller address space,
    -- # = TRUE, Large address space.
  
  constant DDR2_MEM_ADDR_ORDER       : string := "BANK_ROW_COLUMN"; 
    -- The order in which user address is provided to the memory controller,
    -- ROW_BANK_COLUMN or BANK_ROW_COLUMN.
    
  constant DDR2_NUM_DQ_PINS          : integer := 16; -- External memory data width.
  constant DDR2_MEM_ADDR_WIDTH       : integer := 14; -- External memory address width.
  constant DDR2_MEM_BANKADDR_WIDTH   : integer := 3; -- External memory bank address width.
  
  
  constant DDR2_ARB_NUM_TIME_SLOTS   : integer := 12; 
  constant DDR2_ARB_TIME_SLOT_0      : bit_vector(11 downto 0) := o"0124"; 
  constant DDR2_ARB_TIME_SLOT_1      : bit_vector(11 downto 0) := o"1240"; 
  constant DDR2_ARB_TIME_SLOT_2      : bit_vector(11 downto 0) := o"2401"; 
  constant DDR2_ARB_TIME_SLOT_3      : bit_vector(11 downto 0) := o"4012"; 
  constant DDR2_ARB_TIME_SLOT_4      : bit_vector(11 downto 0) := o"0124"; 
  constant DDR2_ARB_TIME_SLOT_5      : bit_vector(11 downto 0) := o"1240"; 
  constant DDR2_ARB_TIME_SLOT_6      : bit_vector(11 downto 0) := o"2401"; 
  constant DDR2_ARB_TIME_SLOT_7      : bit_vector(11 downto 0) := o"4012"; 
  constant DDR2_ARB_TIME_SLOT_8      : bit_vector(11 downto 0) := o"0124"; 
  constant DDR2_ARB_TIME_SLOT_9      : bit_vector(11 downto 0) := o"1240"; 
  constant DDR2_ARB_TIME_SLOT_10     : bit_vector(11 downto 0) := o"2401"; 
  constant DDR2_ARB_TIME_SLOT_11     : bit_vector(11 downto 0) := o"4012"; 
  
  constant DDR2_MEM_TRAS             : integer := 42500; 
  constant DDR2_MEM_TRCD             : integer := 12500; 
  constant DDR2_MEM_TREFI            : integer := 7800000; 
  constant DDR2_MEM_TRFC             : integer := 197500; 
  constant DDR2_MEM_TRP              : integer := 12500; 
  constant DDR2_MEM_TWR              : integer := 15000; 
  constant DDR2_MEM_TRTP             : integer := 7500; 
  constant DDR2_MEM_TWTR             : integer := 7500; 
  constant DDR2_MEM_TYPE             : string := "DDR2"; 
  constant DDR2_MEM_DENSITY          : string := "2Gb"; 
  constant DDR2_MEM_BURST_LEN        : integer := 4; 
  constant DDR2_MEM_CAS_LATENCY      : integer := 5; 
  constant DDR2_MEM_NUM_COL_BITS     : integer := 10; 
  
  constant DDR2_MEM_DDR1_2_ODS       : string := "FULL"; 
  constant DDR2_MEM_DDR2_RTT         : string := "50OHMS"; 
  constant DDR2_MEM_DDR2_DIFF_DQS_EN  : string := "YES"; 
  constant DDR2_MEM_DDR2_3_PA_SR     : string := "FULL"; 
  constant DDR2_MEM_DDR2_3_HIGH_TEMP_SR  : string := "NORMAL"; 
  constant DDR2_MEM_DDR3_CAS_LATENCY  : integer := 6; 
  constant DDR2_MEM_DDR3_ODS         : string := "DIV6"; 
  constant DDR2_MEM_DDR3_RTT         : string := "DIV2"; 
  constant DDR2_MEM_DDR3_CAS_WR_LATENCY  : integer := 5; 
  constant DDR2_MEM_DDR3_AUTO_SR     : string := "ENABLED"; 
  constant DDR2_MEM_DDR3_DYN_WRT_ODT  : string := "OFF"; 
  constant DDR2_MEM_MOBILE_PA_SR     : string := "FULL"; 
  constant DDR2_MEM_MDDR_ODS         : string := "FULL"; 
  constant DDR2_MC_CALIB_BYPASS      : string := "NO"; 
  constant DDR2_MC_CALIBRATION_MODE  : string := "CALIBRATION"; 
  constant DDR2_MC_CALIBRATION_DELAY  : string := "HALF"; 
  constant DDR2_SKIP_IN_TERM_CAL     : integer := 0; 
  constant DDR2_SKIP_DYNAMIC_CAL     : integer := 0; 
  constant DDR2_LDQSP_TAP_DELAY_VAL  : integer := 0; 
  constant DDR2_LDQSN_TAP_DELAY_VAL  : integer := 0; 
  constant DDR2_UDQSP_TAP_DELAY_VAL  : integer := 0; 
  constant DDR2_UDQSN_TAP_DELAY_VAL  : integer := 0; 
  constant DDR2_DQ0_TAP_DELAY_VAL    : integer := 0; 
  constant DDR2_DQ1_TAP_DELAY_VAL    : integer := 0; 
  constant DDR2_DQ2_TAP_DELAY_VAL    : integer := 0; 
  constant DDR2_DQ3_TAP_DELAY_VAL    : integer := 0; 
  constant DDR2_DQ4_TAP_DELAY_VAL    : integer := 0; 
  constant DDR2_DQ5_TAP_DELAY_VAL    : integer := 0; 
  constant DDR2_DQ6_TAP_DELAY_VAL    : integer := 0; 
  constant DDR2_DQ7_TAP_DELAY_VAL    : integer := 0; 
  constant DDR2_DQ8_TAP_DELAY_VAL    : integer := 0; 
  constant DDR2_DQ9_TAP_DELAY_VAL    : integer := 0; 
  constant DDR2_DQ10_TAP_DELAY_VAL   : integer := 0; 
  constant DDR2_DQ11_TAP_DELAY_VAL   : integer := 0; 
  constant DDR2_DQ12_TAP_DELAY_VAL   : integer := 0; 
  constant DDR2_DQ13_TAP_DELAY_VAL   : integer := 0; 
  constant DDR2_DQ14_TAP_DELAY_VAL   : integer := 0; 
  constant DDR2_DQ15_TAP_DELAY_VAL   : integer := 0; 
  constant DDR2_SMALL_DEVICE         : string := "FALSE"; 
  
  
  
  function ddr2_sim_hw (val1:std_logic_vector( 31 downto 0); val2: std_logic_vector( 31 downto 0) )  return  std_logic_vector;
  
 
  
  
  
  
  -- DDR2 mcb infrastructure
  constant DDR2_CLKOUT0_DIVIDE       : integer := 1; 
  constant DDR2_CLKOUT1_DIVIDE       : integer := 1; 
  constant DDR2_CLKOUT2_DIVIDE       : integer := 8; 
  constant DDR2_CLKOUT3_DIVIDE       : integer := 8; 
  constant DDR2_CLKFBOUT_MULT        : integer := 8; 
  constant DDR2_DIVCLK_DIVIDE        : integer := 1; 
  constant DDR2_INCLK_PERIOD         : integer := ((DDR2_MEMCLK_PERIOD * DDR2_CLKFBOUT_MULT) / (DDR2_DIVCLK_DIVIDE * DDR2_CLKOUT0_DIVIDE * 2));
  
end mcb_ddr2_pkg;

package body mcb_ddr2_pkg is
   function ddr2_sim_hw (val1:std_logic_vector( 31 downto 0); val2: std_logic_vector( 31 downto 0) )  return  std_logic_vector is
  begin
   if (DDR2_HW_TESTING = "FALSE") then
     return val1;
   else
     return val2;
   end if;
   end function;
   
   
   
   
   
 constant DDR2_p0_BEGIN_ADDRESS                   : std_logic_vector(31 downto 0)  := ddr2_sim_hw (x"00000100", x"01000000");
  constant DDR2_p0_DATA_MODE                       : std_logic_vector(3 downto 0)  := "0010";
  constant DDR2_p0_END_ADDRESS                     : std_logic_vector(31 downto 0)  := ddr2_sim_hw (x"000002ff", x"02ffffff");
  constant DDR2_p0_PRBS_EADDR_MASK_POS             : std_logic_vector(31 downto 0)  := ddr2_sim_hw (x"fffffc00", x"fc000000");
  constant DDR2_p0_PRBS_SADDR_MASK_POS             : std_logic_vector(31 downto 0)  := ddr2_sim_hw (x"00000100", x"01000000");
  constant DDR2_p1_BEGIN_ADDRESS                   : std_logic_vector(31 downto 0)  := ddr2_sim_hw (x"00000300", x"03000000");
  constant DDR2_p1_DATA_MODE                       : std_logic_vector(3 downto 0)  := "0010";
  constant DDR2_p1_END_ADDRESS                     : std_logic_vector(31 downto 0)  := ddr2_sim_hw (x"000004ff", x"04ffffff");
  constant DDR2_p1_PRBS_EADDR_MASK_POS             : std_logic_vector(31 downto 0)  := ddr2_sim_hw (x"fffff800", x"f8000000");
  constant DDR2_p1_PRBS_SADDR_MASK_POS             : std_logic_vector(31 downto 0)  := ddr2_sim_hw (x"00000300", x"03000000");
  constant DDR2_p2_BEGIN_ADDRESS                   : std_logic_vector(31 downto 0)  := ddr2_sim_hw (x"00000500", x"05000000");
  constant DDR2_p2_DATA_MODE                       : std_logic_vector(3 downto 0)  := "0010";
  constant DDR2_p2_END_ADDRESS                     : std_logic_vector(31 downto 0)  := ddr2_sim_hw (x"000006ff", x"06ffffff");
  constant DDR2_p2_PRBS_EADDR_MASK_POS             : std_logic_vector(31 downto 0)  := ddr2_sim_hw (x"fffff800", x"f8000000");
  constant DDR2_p2_PRBS_SADDR_MASK_POS             : std_logic_vector(31 downto 0)  := ddr2_sim_hw (x"00000500", x"05000000");
  constant DDR2_p3_BEGIN_ADDRESS                   : std_logic_vector(31 downto 0)  := ddr2_sim_hw (x"00000700", x"01000000");
  constant DDR2_p3_DATA_MODE                       : std_logic_vector(3 downto 0)  := "0010";
  constant DDR2_p3_END_ADDRESS                     : std_logic_vector(31 downto 0)  := ddr2_sim_hw (x"000008ff", x"02ffffff");
  constant DDR2_p3_PRBS_EADDR_MASK_POS             : std_logic_vector(31 downto 0)  := ddr2_sim_hw (x"fffff000", x"fc000000");
  constant DDR2_p3_PRBS_SADDR_MASK_POS             : std_logic_vector(31 downto 0)  := ddr2_sim_hw (x"00000700", x"01000000");  
end mcb_ddr2_pkg;
