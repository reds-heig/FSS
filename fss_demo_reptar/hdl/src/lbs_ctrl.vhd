----------------------------------------------------------------------------------
-- Company:         REDS
-- Engineer:        CMR
-- 
-- Create Date:     17:01:51 11/27/2012 
-- Design Name:   
-- Module Name:     lbs_ctrl.vhd 
-- Project Name:    REPTAR
-- Target Devices: 
-- Tool versions:   ISE 13.3
-- Description:     Interfaces the GPMC with the Xilinx DDR2 IP to access
--                  the DDR2 connected to the Spartan 6 from the CPU
--                  board through the Local Bus
--
-- Dependencies:    
--
-- Revision: 
--    Revision 0.01 - File Created
--    1.0  Modified by ELR 23.03.2013
--	  1.1  Modified by ELR 01.11.2013 (renamed from gpmc_interface_ipddr)
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lbs_ctrl is
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
end lbs_ctrl;

architecture behave of lbs_ctrl is
  
  -- States
  type T_State is (
    eInit,                        --  0
    eIdle_wait_cs,                --  1
    eGet_address_from_gpmc,       --  2
    eW_get_data_from_gpmc,   	    --  3
    eW_data_to_mcb,  			        --  4
    eW_send_write_cmd_to_mcb,     --  5
    eR_send_read_cmd_to_mcb,      --  6 
    eR_wait_lbs_fifo_data,             --  7 
    --eR_en_read_mcb,   			  --  don't need this state because MCB presents first data transparently before first read enable
	eR_send_data_lsb_to_gpmc,  	  --  8 
	eR_send_data_msb_to_gpmc,	  --  9  
    eError                        -- 10
  );
  
  function CONV_STATE_TO_STDLV (state : T_State) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(T_State'pos(state),4));
  end function CONV_STATE_TO_STDLV;
  
  -- Internal signals
  signal ePresent_s, eFutur_s : T_State;
  
  signal address_buffer_s     : std_logic_vector(29 downto 0);
  
  signal gpmc_data_buffer_s        : std_logic_vector(GPMC_DATA_SIZE-1 downto 0);
  
  signal rd_nwr_s,address_buffer_en_s,
          sel_msb_s,gpmc_data_buffer_en_s,
          lbs_fifo_data_buffer_en_s          : std_logic;
  
  signal  lbs_fifo_data_msb_buffer_s       : std_logic_vector(GPMC_DATA_SIZE-1 downto 0);
  
  signal data_count_futur_s, 
          data_count_present_s         : integer := 0;
  
  constant INSTR_READ                 : std_logic_vector (2 downto 0) := "001";
  constant INSTR_WRITE                : std_logic_vector (2 downto 0) := "000";
  
  
  constant lbs_fifo_BURST_LEN              : integer := GPMC_BURST_LEN/2; -- Paquet size is 32 bit
  
begin

  -- Input decoder
  state_decoder : process (
    gpmc_a_i, gpmc_d_i, gpmc_nCS_i, gpmc_nADV_i, gpmc_nWE_i, gpmc_nOE_i, 
    mcb_calib_done_i, lbs_fifo_cmd_full_i, lbs_fifo_wr_full_i, 
    lbs_fifo_rd_data_i,lbs_fifo_rd_count_i,lbs_fifo_rd_empty_i, 
    ePresent_s,data_count_present_s
  ) is

  begin
  
    -- Default values
    gpmc_d_tris_o   	  <= '1';    
    error_o         	  <= '0';    
    lbs_fifo_cmd_en_o    	  <= '0';
    rd_nwr_s 			      <= '1';      
    lbs_fifo_wr_en_o     	  <= '0';       
    lbs_fifo_rd_en_o     	  <= '0'; 	
    gpmc_nWait_o    	  <= '1';	
    address_buffer_en_s <= '0';
    lbs_fifo_data_buffer_en_s <= '0';
    gpmc_data_buffer_en_s <= '0';
    sel_msb_s			      <= '0';
    data_count_futur_s 	<= 0; -- reset gpmc sent data counter
    
    
    -- State machine
    case ePresent_s is
      when eInit =>
              
        -- If calib is done and CS inactive, go idle
        if mcb_calib_done_i = '1' AND gpmc_nCS_i = '1' then
          eFutur_s <= eIdle_wait_cs;
        else
          eFutur_s <= eInit;
        end if;
      
      
      when eIdle_wait_cs =>
        -- Idle waits on CS activation and address set valid
        if gpmc_nCS_i = '0' AND gpmc_nADV_i = '0' then
          eFutur_s <= eGet_address_from_gpmc;
        else
          eFutur_s <= eIdle_wait_cs;
        end if;
      
      
      when eGet_address_from_gpmc =>
        -- Get address on bus
        address_buffer_en_s <= '1';
    
        -- Switch between write/read cases
        if gpmc_nWE_i = '0' AND gpmc_nOE_i = '1' AND gpmc_nADV_i = '1' then -- Write
          eFutur_s <= eW_get_data_from_gpmc;
        elsif gpmc_nWE_i = '1' AND gpmc_nOE_i = '0' then -- Read
          eFutur_s <= eR_send_read_cmd_to_mcb;
        else 
          eFutur_s <= eGet_address_from_gpmc;
        end if;
      
      ------------------------------------------------------------------
      -- WRITE
      ------------------------------------------------------------------
      when eW_get_data_from_gpmc =>
        gpmc_data_buffer_en_s <= '1';
        
        data_count_futur_s <= data_count_present_s + 1;
        
        eFutur_s <= eW_data_to_mcb;
      
      
      when eW_data_to_mcb =>

        data_count_futur_s <= data_count_present_s + 1;
        
        lbs_fifo_wr_en_o <= '1';
        
        
        if lbs_fifo_wr_full_i = '1' then
          -- No more space in write fifo, go to wait state
          eFutur_s <= eError;
        elsif data_count_present_s >= GPMC_BURST_LEN-1 then
          -- All data was sent by the gpmc
          eFutur_s <= eW_send_write_cmd_to_mcb;
        else
          eFutur_s <= eW_get_data_from_gpmc;
        end if;
    
      -- end write 
      when eW_send_write_cmd_to_mcb =>
        rd_nwr_s        <= '0';        
        lbs_fifo_cmd_en_o    <= '1';
            
        eFutur_s <= eInit;    
        
      
      ------------------------------------------------------------------
      -- READ
      ------------------------------------------------------------------
      when eR_send_read_cmd_to_mcb => 
        gpmc_nWait_o <= '0'; -- Activate wait
        lbs_fifo_cmd_en_o <= '1'; -- send read command to mcb
            
        if lbs_fifo_cmd_full_i = '1' then
          eFutur_s <= eError;
        else
          eFutur_s <= eR_wait_lbs_fifo_data;
        end if;
        
      
      when eR_wait_lbs_fifo_data =>
        gpmc_nWait_o <= '0'; -- Activate wait
                
        -- Wait until all data are loaded in IP
        if lbs_fifo_rd_count_i >= std_logic_vector(to_unsigned(lbs_fifo_BURST_LEN, lbs_fifo_rd_count_i'length)) then
          eFutur_s <= eR_send_data_lsb_to_gpmc; -- first data is present transparently at the mcb output before the first read enable 
        else 
          eFutur_s <= eR_wait_lbs_fifo_data;
        end if;
      
      when eR_send_data_lsb_to_gpmc =>
        -- Write lsb to gpmc data bus 
        gpmc_d_tris_o     <= '0';
        data_count_futur_s  <= data_count_present_s + 1;
        -- read and register msb data from mcb
        lbs_fifo_data_buffer_en_s <= '1';
            
        eFutur_s <= eR_send_data_msb_to_gpmc;
      
        
      when eR_send_data_msb_to_gpmc =>
        -- Write msb to gpmc data bus 
        sel_msb_s           <= '1';
        gpmc_d_tris_o       <= '0';
        data_count_futur_s  <= data_count_present_s + 1;
    
        -- Activate rd enable to get the next data
        if (lbs_fifo_rd_empty_i = '0') then
          lbs_fifo_rd_en_o <= '1';
        end if;  

        -- end read
        if data_count_present_s >= GPMC_BURST_LEN-1 then
          eFutur_s <= eInit;
        else
          -- get next data
          eFutur_s <= eR_send_data_lsb_to_gpmc;
        end if;
        
        
      when eError =>
        error_o <= '1';
    
        eFutur_s <= eInit;
    
      when others =>
        eFutur_s <= eInit;

    end case;
  
  end process state_decoder;
  
  
  -- Synchronous
  sequential : process (gpmc_ckl_i, rst_i)
  
  begin
    if( rst_i = '1' ) then
      ePresent_s            <= eInit;   
      data_count_present_s  <= 0;
    elsif( Rising_Edge(gpmc_ckl_i) ) then      
      -- Save state
      ePresent_s            <= eFutur_s;
      data_count_present_s  <= data_count_futur_s;
    end if;
  end process sequential;
  
  -- outputs 
  
  lbs_fifo_wr_data_o     <= gpmc_d_i & gpmc_data_buffer_s;
  lbs_fifo_wr_mask_o     <= (others => '0');   
  
  lbs_fifo_cmd_addr_o    <= address_buffer_s;
  lbs_fifo_cmd_bl_o      <= std_logic_vector(to_unsigned(lbs_fifo_BURST_LEN-1, lbs_fifo_cmd_bl_o'length));  
  lbs_fifo_cmd_instr_o   <= INSTR_WRITE when rd_nwr_s='0' else INSTR_READ;
  
  gpmc_d_o          <= lbs_fifo_data_msb_buffer_s when sel_msb_s='1' else lbs_fifo_rd_data_i(15 downto 0);
    
  interface_state_o <= CONV_STATE_TO_STDLV(ePresent_s);
  
  
  
  
  -- Buffers
  -----------------------------------------------------------------------------------
  address_buf : process (gpmc_ckl_i, rst_i)
  
  begin
    if( rst_i = '1' ) then      
      address_buffer_s <= (others => '0');
    elsif( Rising_Edge(gpmc_ckl_i)) then
	  if (address_buffer_en_s = '1') then
      -- register the byte address
		address_buffer_s <= "0000" & gpmc_a_i & gpmc_d_i & '0';  
	  end if;
    end if;
  end process address_buf;
 ------------------------------------------------------------------------- 
  gpmc_data_buf : process (gpmc_ckl_i, rst_i)
  
  begin
    if( rst_i = '1' ) then      
      gpmc_data_buffer_s <= (others => '0');
    elsif( Rising_Edge(gpmc_ckl_i)) then
	  if gpmc_data_buffer_en_s = '1' then
      -- Save state
		gpmc_data_buffer_s <= gpmc_d_i;  
	  end if;
    end if;
  end process gpmc_data_buf;
  
  -------------------------------------------------------------------------------------  
  lbs_fifo_data_buf : process (gpmc_ckl_i, rst_i)
  
  begin
    if( rst_i = '1' ) then      
      lbs_fifo_data_msb_buffer_s <= (others => '0');
    elsif( Rising_Edge(gpmc_ckl_i)) then
      -- Save state
	  if lbs_fifo_data_buffer_en_s = '1' then
		lbs_fifo_data_msb_buffer_s <= lbs_fifo_rd_data_i(31 downto 16);     
	  end if;
    end if;
  end process lbs_fifo_data_buf;
  -------------------------------------------------------------------------------------------
  
  
  
end behave;
