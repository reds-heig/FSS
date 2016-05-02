-----------------------------------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
-----------------------------------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
-----------------------------------------------------------------------------------------------------------------------
--
-- File                 : lba_ctrl_fsm.vhd
-- Author               : Evangelina Lolivier-Exler
-- Date                 : 08.11.2013
-- Target Devices       : Spartan6 xc6slx150t-3fgg900
--
-- Context              : Reptar - FPGA design
--
--------------------------------------------------------------------------------------------------------------------------
-- Description :		local bus asynchronous (lba) controller  
--						Controls the data transfers between the DM3730 and the standard or user REPTAR interfaces
--						(lba_std_interface.vhd and lba_usr_interface.vhd)
--						From the DM3730 side, the Local Bus is controller by the GPMC (General Purpose Memory Controller)
--						The clock provided by the GPMC is not used in this block, that's why it is called "asynchrounous"
--						The state machine of this block runs at 200 MHz (internal FPGA clock)
--------------------------------------------------------------------------------------------------------------------------
-- Information :
--------------------------------------------------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Engineer     Comments
-- 0.0   See header  ELR          Initial version
-- 1.0   19.11.13    CVZ          introducing cs_user_Wr and Rd


--------------------------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lba_ctrl_fsm is
	port(
    clk_i				    : in std_logic;
	reset_i				    : in std_logic;
	-- from DM3730 GPMC trough Local Bus
	nCS3_LB_i				: in std_logic;
	nADV_LB_i				: in std_logic;
	nOE_LB_i				: in std_logic;
	nWE_LB_i				: in std_logic;
	Addr_LB_i				: in std_logic_vector(24 downto 23); -- Addr_LB_i(24) : to split up between SP6-SP3
																 -- Addr_LB_i(23) : to split up between std-usr
	lba_wait_o              : out std_logic;                     
	-- from/to tri-state buffer on the top
	lba_oe_o				: out std_logic;	-- lba_data_rd is connected directly to the LB data mux
	-- from/to lba_std_interface and lba_usr_interface
	lba_wr_en_o             : out std_logic;
	lba_rd_en_o             : out std_logic;
	lba_add_en_o       		: out std_logic; 
	lba_cs_std_o       		: out std_logic; 
	lba_cs_usr_rd_o      	: out std_logic; 
    lba_cs_usr_wr_o      	: out std_logic; 
	lba_wait_usr_i    		: in std_logic
	);

end lba_ctrl_fsm;

architecture behavioral of lba_ctrl_fsm is

-- main FSM
 type state_fsm1_t is (
    init,                       --  0
    wait_cs_assertion,          --  1
    Start_Read_Cycle,       --  2
    check_wait_usr,  			--  3
    send_data_usr_to_cpu,     	--  4
    send_wait_usr_to_cpu,      	--  5 
    enable_write_to_usr,      	--  6 
    wait_end_of_acces_usr,   	--  7 		 
	enable_write_to_std,  		--  8        
	wait_end_of_acces_std,	    --  9
    enable_read_from_std,       -- 10                 
	send_data_std_to_cpu		-- 11
  );
  
-- address FSM
   type state_fsm2_t is (
    init,                 --  0
    get_address,          --  1
    wait_cs_deassertion   --  2
  );
  
  signal present_st_s, futur_st_s : state_fsm1_t;
  signal psnt_st_s, fut_st_s : state_fsm2_t;
  signal lba_cs_std_s       : std_logic;
  signal lba_cs_usr_rd_s    : std_logic;
  signal lba_cs_usr_wr_s    : std_logic;
  signal lba_wr_en_s        : std_logic;
  signal lba_rd_en_s        : std_logic;
  signal lba_oe_s           : std_logic;
  signal lba_wait_s	        : std_logic;
  signal lba_add_en_s       : std_logic; 
  

begin
---- main FSM -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- Futur state and outputs decoder
  state_decoder : process (nCS3_LB_i, nOE_LB_i, nWE_LB_i, 
						Addr_LB_i(24 downto 23), lba_wait_usr_i,present_st_s) is

  begin
  
    -- Default values
    lba_cs_std_s 	<= '0';    
    lba_cs_usr_wr_s <= '0';    
    lba_cs_usr_rd_s <= '0'; 
    lba_wr_en_s  	<= '0';
    lba_rd_en_s     <= '0';      
    lba_oe_s       	<= '0';  
    lba_wait_s		<= '0';
    
    -- State machine
    case present_st_s is
      when init =>
              
        -- ensure that nCS is inactive (the last access has finished)
        if nCS3_LB_i = '1' then
          futur_st_s <= wait_cs_assertion;
        else
          futur_st_s <= init;
        end if;
      
      -- start of access
      when wait_cs_assertion =>
        -- read access to STD interface
        if nCS3_LB_i = '0' AND Addr_LB_i(24 downto 23) = "00" AND nWE_LB_i = '1' AND nOE_LB_i = '0'  then
          futur_st_s <= enable_read_from_std;
		-- read access to USR interface  
		elsif  nCS3_LB_i = '0' AND Addr_LB_i(24 downto 23) = "01" AND nWE_LB_i = '1' AND nOE_LB_i = '0'  then
          futur_st_s <= Start_Read_Cycle; 
		-- write access to STD interface   
		elsif  nCS3_LB_i = '0' AND Addr_LB_i(24 downto 23) = "00" AND nWE_LB_i = '0' AND nOE_LB_i = '1'  then
          futur_st_s <= enable_write_to_std; 
		-- write access to USR interface   
		elsif  nCS3_LB_i = '0' AND Addr_LB_i(24 downto 23) = "01" AND nWE_LB_i = '0' AND nOE_LB_i = '1'  then
          futur_st_s <= enable_write_to_usr; 
        else
          futur_st_s <= wait_cs_assertion;
        end if;
		
 ------------------------------------------------------------------
-- READ from standard interface
------------------------------------------------------------------
       
      when enable_read_from_std =>
        lba_cs_std_s <= '1';   
        lba_rd_en_s  <= '1';
    
        futur_st_s <= send_data_std_to_cpu;
        
     
      when send_data_std_to_cpu =>

        lba_cs_std_s <= '1'; 
		lba_rd_en_s  <= '1';
        lba_oe_s     <= '1';  
        
        if nOE_LB_i = '1' then
          futur_st_s <= init;
        else
          futur_st_s <= send_data_std_to_cpu;
        end if;
		
  ------------------------------------------------------------------
 -- READ from user interface
 ------------------------------------------------------------------
   
      when Start_Read_Cycle =>
        lba_cs_usr_rd_s <= '1';   
        
    
        futur_st_s <= check_wait_usr;
        
   
      when check_wait_usr =>
        lba_cs_usr_rd_s <= '1';  
		lba_rd_en_s  <= '1';
                
        -- data is not ready
        if lba_wait_usr_i = '1' then
          futur_st_s <= send_wait_usr_to_cpu; 
		-- data is ready  
		else 
		  futur_st_s <= send_data_usr_to_cpu; 
        end if;
      
      when send_wait_usr_to_cpu =>
        lba_cs_usr_rd_s <= '1';  
		lba_rd_en_s  <= '1';
        lba_wait_s	 <= '1';
        
        -- data is ready
        if lba_wait_usr_i = '0' then
          futur_st_s <= send_data_usr_to_cpu; 
		-- data is not ready  
		else 
		  futur_st_s <= send_wait_usr_to_cpu; 
        end if;
       
        
      when send_data_usr_to_cpu =>
        lba_cs_usr_rd_s <= '1';   		
        lba_oe_s	 <= '1';
   
        if nOE_LB_i = '1' then
          futur_st_s <= init;
        else
          futur_st_s <= send_data_usr_to_cpu;
        end if;
 ------------------------------------------------------------------
 -- WRITE to STD interface
 ------------------------------------------------------------------
       
      when enable_write_to_std =>
        lba_cs_std_s <= '1';   
        lba_wr_en_s  <= '1';
    
        futur_st_s <= init;
        
      
      when wait_end_of_acces_std =>

        lba_cs_std_s <= '1'; 
        
        futur_st_s <= init;
 ------------------------------------------------------------------
 -- WRITE to USR interface
 ------------------------------------------------------------------
      when enable_write_to_usr =>
        lba_cs_usr_wr_s     <= '1';   
        lba_wr_en_s         <= '1';
    
        futur_st_s <= init;
        
      
    --  when wait_end_of_acces_usr =>

      --  lba_cs_usr_s <= '1'; 
        
       -- futur_st_s <= init;
		
	  when others =>
	  
	   futur_st_s <= init;
	
	end case;	
  
  end process state_decoder;
  
  
  -- Synchronous
  sequential : process (clk_i, reset_i)
  
  begin
    if( reset_i = '1' ) then
      present_st_s <= init;         
    elsif( Rising_Edge(clk_i) ) then      
      -- Save state
      present_st_s <= futur_st_s;
    end if;
  end process sequential;
  
---- end of main FSM -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
---- address FSM -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  state_decoder2 : process (nCS3_LB_i, nADV_LB_i,psnt_st_s) is

  begin
  
    -- Default values
    lba_add_en_s <= '0';
    
    -- State machine
    case psnt_st_s is
	
      when init =>
              
        if nCS3_LB_i = '0' AND nADV_LB_i = '0' then
          fut_st_s <= get_address;
        else
          fut_st_s <= init;
        end if;
		
	  when get_address =>
	  
	    lba_add_en_s <= '1';
              
        fut_st_s <= wait_cs_deassertion;
		
      when wait_cs_deassertion =>
              
        if nCS3_LB_i = '1' then
          fut_st_s <= init;
        else
          fut_st_s <= wait_cs_deassertion;
        end if;
	  
	  when others => 
	    fut_st_s <= wait_cs_deassertion;
		
	end case;
  end process state_decoder2;
  
  -- Synchronous
  memory : process (clk_i, reset_i)
  
  begin
    if( reset_i = '1' ) then
      psnt_st_s <= init;         
    elsif( Rising_Edge(clk_i) ) then      
      -- Save state
      psnt_st_s <= fut_st_s;
    end if;
  end process memory;
  
  
---- end of address FSM -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  -- outputs 
  lba_cs_std_o      <= lba_cs_std_s;
  lba_cs_usr_rd_o   <= lba_cs_usr_rd_s;
  lba_cs_usr_wr_o   <= lba_cs_usr_wr_s;
  lba_wr_en_o       <= lba_wr_en_s ;
  lba_rd_en_o       <= lba_rd_en_s; 
  lba_oe_o          <= lba_oe_s;    
  lba_wait_o        <= lba_wait_s;	
  lba_add_en_o      <= lba_add_en_s;
  
end behavioral;