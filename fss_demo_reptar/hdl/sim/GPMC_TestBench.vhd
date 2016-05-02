------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : GPMC_TestBench.vhd
-- Author               : Cedric Vulliez
-- Date                 : 29.10.2013
-- Target Devices       : Spartan6 xc6slx150t-3fgg900
--
-- Context              : Reptar - FPGA design
--
------------------------------------------------------------------------------------------
-- Description : GPMC Test Bench For both Aynchronous Wtites/Reads and Synchronous Writes/Reads
--                  This entiy is siumlates The CPU side of the GPMC data transfers    
------------------------------------------------------------------------------------------
-- Information : The user can :
--                  - replace the constant addresses used for the transfers  
--                  - Use the different functions already in place to make Bus transfers 
--                  - Optionnally modify the GPMC bus Timing
------------------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Engineer     Comments


-------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;  
use std.textio.all;     
use work.RNG.all;
--use ieee.std_logic_unsigned.all;
use work.objection_pkg.all;
--use ieee.std_logic_arith.all;

entity GPMC_TestBench is
generic (
        constant GPMC_to_FPGA_Latency      : time:=5 ns; -- Simulates the FPGA total routing Delay. express in ns
        constant FPGA_to_GPMC_Latency      : time:=6 ns -- Simulates the FPGA total routing Delay. express in ns
        );
port (
        -- Clocks
        External_100Mhz_Clk_o	        : out std_logic;
        GPMC_Clk_25MHz_o                : out std_logic;
        GPMC_nReset_o                   : out std_logic;
        -- locas bus
        GPMC_LB_RE_nOE_o                : out std_logic;
        GPMC_LB_nWE_o                   : out std_logic;
        GPMC_LB_WAIT3_i                 : in std_logic;
        GPMC_LB_nCS3_o                  : out std_logic;
        GPMC_LB_nCS4_o                  : out std_logic;
        GPMC_LB_nADV_ALE_o              : out std_logic;
        GPMC_LB_nBE0_CLE_o              : out std_logic;
        GPMC_LB_WAIT0_i                 : in std_logic;
        GPMC_LB_CLK_o                   : out std_logic;
        GPMC_Addr_Data_LB_io            : inout std_logic_vector(15 downto 0);
        GPMC_Addr_LB_o                  : out std_logic_vector(24 downto 16); 
        GPMC_DIP_o                      : out std_logic_vector(10 downto 1);
        -- Cmd Async write and read
		Cmd_clk_o                       : out std_logic;
		Cmd_nReset_o                    : out std_logic;
		Cmd_single_write_i              : in std_logic;
		Cmd_addr_write_i                : in std_logic_vector(24 downto 0);
		Cmd_data_write_i                : in std_logic_vector(15 downto 0);
		Cmd_single_read_i               : in std_logic;
		Cmd_addr_read_i                 : in std_logic_vector(24 downto 0);
		Cmd_data_read_o                 : out std_logic_vector(15 downto 0);
		Cmd_datavalid_read_o            : out std_logic;
		--
        End_of_sim_o                    : out std_logic;
        TestBenchDelay_o                : out integer
    );
end  GPMC_TestBench;

architecture behave of GPMC_TestBench is

------------------- USER PARAMETERS START ---------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------
    constant Spartan6BoardSelector              : std_logic :='0'; -- 0 for Spartan6 
    constant Spartan3BoardSelector              : std_logic :='1'; -- 1 for Spartan3   
    constant InterfaceUserSelector              : std_logic:= '1'; -- 1 for User Interface
    constant InterfaceStdSelector               : std_logic:= '0'; -- 0 for Std interface   
    -- Addresses used. 25bits vectors
	constant USER_ADDRESS_0                     : std_logic_vector(24 downto 0) := Spartan6BoardSelector & InterfaceUserSelector & "000" & x"01000"; --0x0000000 RW
    constant USER_ADDRESS_1                     : std_logic_vector(24 downto 0) := Spartan6BoardSelector & InterfaceUserSelector & "000" & x"04001"; --0x0000001 RW
    constant USER_ADDRESS_2                     : std_logic_vector(24 downto 0) := Spartan6BoardSelector & InterfaceUserSelector & "000" & x"06002"; --0x0000002 RW
    constant USER_ADDRESS_3                     : std_logic_vector(24 downto 0) := Spartan6BoardSelector & InterfaceUserSelector & "000" & x"000A3"; --0x0000003 RW
    constant USER_ADDRESS_4                     : std_logic_vector(24 downto 0) := Spartan6BoardSelector & InterfaceUserSelector & "000" & x"B0004"; --0x0000004 RW
    constant USER_ADDRESS_5                     : std_logic_vector(24 downto 0) := Spartan6BoardSelector & InterfaceUserSelector & "000" & x"F0005"; --0x0000005 RW
    constant USER_ADDRESS_6                     : std_logic_vector(24 downto 0) := Spartan6BoardSelector & InterfaceUserSelector & "000" & x"C0006"; --0x0000006 RW
    constant USER_ADDRESS_7                     : std_logic_vector(24 downto 0) := Spartan6BoardSelector & InterfaceUserSelector & "000" & x"00F07"; --0x0000007 RW
    constant USER_ADDRESS_8                     : std_logic_vector(24 downto 0) := Spartan6BoardSelector & InterfaceUserSelector & "000" & x"000F8"; --0x0000008 RW
    -- ....
    constant USER_ADDRESS_16                    : std_logic_vector(24 downto 0) := Spartan6BoardSelector & InterfaceUserSelector & "000" & x"00010"; --0x0000010 RW
    
   constant REDS_CONN1_REG_ADD_c                : std_logic_vector(24 downto 0) := Spartan6BoardSelector & InterfaceStdSelector & "000" &  x"00080"; 
   constant	LED_REG_ADD_c		  				: std_logic_vector(24 downto 0) := Spartan6BoardSelector & InterfaceStdSelector & "000" &  x"0001D"; --0x003A W 
    --=================================================
    -- CPU TIMING CONSTANTS FOR SYNCHRONOUS TRANSFERTS
    --=================================================
    
    constant FPGA_latency                       : integer:=2;  -- n* 5ns for latency simulation    -- Simulates the latency between the Bus to the DFF, and back from DFF to the bus. 2*5ns typical  
   
    

    constant GPMCFCLKDIVIDER                    : integer := 3; -- GPMC_FCLK frequency/ 0, 2, 3 or 4 . Only 0, 1, 2, 3 values are valid
    constant CLKACTIVATIONTIME                  : integer := 2; -- should be set acording to the signal's latencies from pins to inside the FPGA so not all change at the same time
    
    
    constant ADVONTIME                          : integer := 0;
    constant CSONTIME                           : integer := 0;   
          
    constant PAGEBURSTACCESSTIME                : integer := (GPMCFCLKDIVIDER+1)*1;-- * the number of GPMC_CLK wanted       
 
    
    -- ADDRESS VALID TIME
    constant ADVRDOFFTIME                       : integer := ADVONTIME + (GPMCFCLKDIVIDER+1)*1; -- stay active *n Cycle time   
   
    
    -- OUTPUT ENABLE TIME         
    constant OEONTIME                           : integer := ADVRDOFFTIME + (GPMCFCLKDIVIDER+1)*1; -- set how many clk cycles you want this signal to start at
     --=========================================================================================================================================
    constant RDACCESSTIME                       : integer := OEONTIME  +FPGA_latency +(GPMCFCLKDIVIDER+1)*1;  -- OEONTIME + latency ||| (GPMCFCLKDIVIDER+1)*1  is optional
    --=========================================================================================================================================
   
    constant OEOFFTIME0                         : integer := RDACCESSTIME; 
    constant OEOFFTIME1                         : integer := PAGEBURSTACCESSTIME/2 ;
    constant OEOFFTIME                          : integer := OEOFFTIME0+ OEOFFTIME1;   
   
      -- Chip Select TIME
    constant CSRDOFFTIME0                       : integer := RDACCESSTIME;
    constant CSRDOFFTIME1                       : integer := PAGEBURSTACCESSTIME/2 ;
    constant CSRDOFFTIME                        : integer := CSRDOFFTIME0+ CSRDOFFTIME1;
   
     -- READ CYCLE TIME
    constant RDCYCLETIME0                       : integer := RDACCESSTIME;
    constant RDCYCLETIME1                       : integer := PAGEBURSTACCESSTIME/2 ; -- PAGEBURSTACCESSTIME/2 wont work with GPMC_CLK= GPMC_FCLK    
    constant RDCYCLETIME                        : integer := RDCYCLETIME0 + RDCYCLETIME1;     
   
   -- write registers same as read
   constant CSWROFFTIME                         : integer:= CSRDOFFTIME;
   constant ADVWROFFTIME                        : integer:= ADVRDOFFTIME;
   constant WEOFFTIME                           : integer:= OEOFFTIME;
   constant WEONTIME                            : integer:= OEONTIME;
   constant WRCYCLETIME                         : integer:= RDCYCLETIME;
   
   -- make the registers for the CPU
   constant GPMC_CONFIG2_4                     : std_logic_vector (31 downto 0):= "00000000000" & std_logic_vector(to_unsigned(CSWROFFTIME,5))  & "000" & std_logic_vector(to_unsigned(CSRDOFFTIME,5)) & '0' & "000" & std_logic_vector(to_unsigned(CSONTIME,4));
   constant GPMC_CONFIG3_4                     : std_logic_vector (31 downto 0):= "00000000000" & std_logic_vector(to_unsigned(ADVWROFFTIME,5)) & "000" & std_logic_vector(to_unsigned(ADVRDOFFTIME,5)) & '0' & "000" & std_logic_vector(to_unsigned(ADVONTIME,4));
   constant GPMC_CONFIG4_4                     : std_logic_vector (31 downto 0):= "000"         & std_logic_vector(to_unsigned(WEOFFTIME,5))    &   '0' & "000" & std_logic_vector(to_unsigned(OEONTIME,4)) & "000" & std_logic_vector(to_unsigned(OEOFFTIME,5)) & '0' & "000" & std_logic_vector(to_unsigned(OEONTIME,4));
   constant GPMC_CONFIG5_4                     : std_logic_vector (31 downto 0):= "0000"        & std_logic_vector(to_unsigned(PAGEBURSTACCESSTIME,4))   & "000" & std_logic_vector(to_unsigned(RDACCESSTIME,5)) & "000" & std_logic_vector(to_unsigned(WRCYCLETIME,5)) & "000" & std_logic_vector(to_unsigned(RDCYCLETIME,5));
   
   
   
   --=============================
   -- TIMING FOR ASYN TRANSFERS
   --=============================
 -- all based on GPMC_FCLK (200Mhz) cycles

    constant ASYN_CSONTIME           : integer := 0;
    constant ASYN_ADVONTIME          : integer := 0;

    -- read specific
    constant ASYN_CSRDOFFTIME        : integer := 16;
    constant ASYN_ADVRDOFFTIME       : integer := 2;
    constant ASYN_OEONTIME           : integer := 4;
    constant ASYN_OEOFFTIME          : integer := 16;    
    constant ASYN_RDACCESSTIME       : integer := 14;
    constant ASYN_RDCYCLETIME        : integer := 20;

    -- write specific
    constant ASYN_CSWROFFTIME       : integer := 10;
    constant ASYN_ADVWROFFTIME      : integer := 2;

    constant ASYN_WEONTIME          : integer := 4;
    constant ASYN_WEOFFTIME         : integer := 10;

    constant ASYN_WRDATAONADMUXBUS  : integer := 4;
    constant ASYN_WRCYCLETIME       : integer := 10;
    
    constant CYCLE2CYCLEDELAY       : integer := 4;
  
   ------------------- USER PARAMETERS END -----------------------------
   ---------------------------------------------------------------------
   ---------------------------------------------------------------------
   
   
   
    -- Clk periods      
	constant CLK_PERIOD                 : time := 10 ns;	-- Clk 100Mhz
	constant CLK_PERIOD_62Mhz           : time := 16 ns;	-- Clk 62.5Mhz	
	constant CLK_PERIOD_200             : time := 5 ns;     -- Clk 200Mhz
            
    -----------------
    
    signal clk_100Mhz_sti               : std_logic;
	signal nRst_sti                     : std_logic;
    signal clk_62Mhz_sti                : std_logic;
    signal GPMC_FCLK_sti                : std_logic;
    signal LB_CLK                       : std_logic;  -- locas bus clk 
    signal SP6_LB_CLK_sti               : std_logic;
    signal LB_CLK_EN                    : std_logic;    
            
    signal DIP_sti                      : std_logic_vector (10 downto 1);
    signal SP6_LB_nCS3_sti              : std_logic;
    signal SP6_LB_nCS4_sti              : std_logic;
    signal SP6_LB_RE_nOE_sti            : std_logic;
    signal SP6_LB_nWE_sti               : std_logic;      
    signal SP6_LB_nADV_ALE_sti          : std_logic;
    signal SP6_LB_nBE0_CLE_sti          : std_logic;
    signal SP6_LB_RE_nOE_delay          : std_logic;    
    
    signal Addr_Data_LB_sti             : std_logic_vector(15 downto 0);
    signal Addr_Data_LB_Zstate_delayed  : std_logic_vector(15 downto 0);
    signal Addr_LB_sti                  : std_logic_vector(24 downto 16);  
    signal Addr_Data_LB_Zstate          : std_logic_vector(15 downto 0);
    signal data_direction_out           : std_logic; 
    

    signal GPMC_LB_Wait3_pipe          : std_logic_vector(1 downto 0); 
 
    
    signal GPMC_Data_obs                : std_logic_vector(15 downto 0);
    signal GPMC_Data_valid_obs          : std_logic;
    
    
    signal Burst_nb                     : std_logic_vector(15 downto 0);
    signal Read_burst_loop              : integer;
    signal pagetimerCounter             : integer;
    
    signal end_of_sim                   : std_logic:='0';  
    signal DUMMY_READ                   : std_logic_vector (15 downto 0):=x"0003"; 
    
    signal TestBenchDelay               : integer:= 0; -- use for delaying all the output signals
    
    constant array_depth                : integer :=9;
    type Data_array is array (array_depth-1 downto 0) of std_logic_vector (15 downto 0);
    signal GPMC_DataWrite               : Data_array;
    signal GPMC_DataRead                : Data_array;
	
	signal cmd_single_write_s             : std_logic:='0'; 
	signal cmd_single_write_reg           : std_logic:='0'; 
	signal cmd_single_read_s              : std_logic:='0'; 
	signal cmd_single_read_reg            : std_logic:='0'; 
    
    
    
	 -- Copyright (c) 1996, Ben Cohen.   All rights reserved.
    function Image(In_Image : Std_Logic_Vector) return String is
        variable L : Line;  -- access type
        variable W : String(1 to In_Image'length) := (others => ' ');  
    begin
        IEEE.Std_Logic_TextIO.WRITE(L, In_Image);
        W(L.all'range) := L.all;
        Deallocate(L);
        return W;
    end Image;
    
    
begin





-- tristate with delay process
-- process      
-- begin
    -- data_direction_out <='1'; 
    -- wait on SP6_LB_RE_nOE_sti until SP6_LB_RE_nOE_sti='0';
    -- data_direction_out<= '0';
    -- wait on SP6_LB_RE_nOE_delay until SP6_LB_RE_nOE_delay ='1';
    -- data_direction_out <='1'; 
-- end process;

SP6_LB_RE_nOE_delay <= SP6_LB_RE_nOE_sti'delayed (CLK_PERIOD_200*2);
Addr_Data_LB_Zstate <= Addr_Data_LB_sti when data_direction_out ='1' else (others=>'Z'); 
SP6_LB_CLK_sti <= LB_CLK when LB_CLK_EN ='1' else '0';
Addr_Data_LB_Zstate_delayed <=  GPMC_Addr_Data_LB_io'delayed(FPGA_to_GPMC_Latency); -- simulate the delay from FPGA. signal used to read the data



wait_pipe_proc: process (nRst_sti,GPMC_FCLK_sti)
begin
    if nRst_sti='0' then
        GPMC_LB_Wait3_pipe <="00";
        
    elsif rising_edge(GPMC_FCLK_sti) then
        GPMC_LB_Wait3_pipe <= GPMC_LB_Wait3_pipe(0) & GPMC_LB_WAIT3_i;
        
    end if;
end process;



 sti1_proc: process 
	begin
		raise_objection;
		wait until  end_of_sim = '1';
		drop_objection;
		wait;
	end process;
    
    
 -- clocks processes      
    clock_100: process
	begin
		clk_100Mhz_sti<='0';
		wait for CLK_PERIOD/2;
		clk_100Mhz_sti<='1';
		wait for CLK_PERIOD/2;
		if no_objection then
			wait;
		end if;
	end process;
    
    clock_200: process
	begin
		GPMC_FCLK_sti<='1';
		wait for CLK_PERIOD_200/2;
		GPMC_FCLK_sti<='0';
		wait for CLK_PERIOD_200/2;
		if no_objection then
			wait;
		end if;
	end process;
    
    clock_25: process
	begin
		clk_62Mhz_sti<='0';
		wait for CLK_PERIOD_62Mhz/2;
		clk_62Mhz_sti<='1';
		wait for CLK_PERIOD_62Mhz/2;
		if no_objection then
			wait;
		end if;
	end process;
	
    clock_CPU: process
	begin
        if GPMCFCLKDIVIDER = 0 then
            LB_CLK<='0';		
            wait for CLK_PERIOD_200/2;
            LB_CLK<='1';
            wait for CLK_PERIOD_200/2;
        elsif GPMCFCLKDIVIDER = 1 then --GPMC_FCLK frequency / 2    
            LB_CLK<='0';		
            wait for CLK_PERIOD_200;
            LB_CLK<='1';
            wait for CLK_PERIOD_200;
        elsif GPMCFCLKDIVIDER = 2 then --GPMC_FCLK frequency / 3    
            LB_CLK<='0';		
            wait for CLK_PERIOD_200*1.5;
            LB_CLK<='1';
            wait for CLK_PERIOD_200*1.5;
        elsif GPMCFCLKDIVIDER = 3 then --GPMC_FCLK frequency / 4    
            LB_CLK<='0';		
            wait for CLK_PERIOD_200*2;
            LB_CLK<='1';
            wait for CLK_PERIOD_200*2;        
        else
            report LF &
            "GPMCFCLKDIVIDER must be 0x0, 0x1, 0x2 or 0x3 only"   & LF             
            severity FAILURE; 
		end if;
        if no_objection then
			wait;
		end if;
	end process;    

	nReset: process
	begin
		nRst_sti<='0';
		wait for CLK_PERIOD*3;
		nRst_sti<='1';
		wait;
	end process;
	
    

    

process
    ----------------------------------------------------
    -- different procedures for Ayn/Sync Writes/Reads  
    ----------------------------------------------------
    
    --===============================
    -- Asynchronous WRTIE procedure
    --===============================    
    procedure Asyn_single_write(    signal ADDRESS  :  std_logic_vector (24 downto 0);
                                    signal Data     :  std_logic_vector (15 downto 0)) is                                
    begin
        -- Asynchronous Single Write
        wait on GPMC_FCLK_sti until GPMC_FCLK_sti='1';
        
        -- signals Initialisation 
        SP6_LB_nBE0_CLE_sti     <= '0'; 
        SP6_LB_nADV_ALE_sti     <= '1';        
       -- report "Writes " & image(Data) &  " in Add ===> " & integer'image(to_integer(unsigned(ADDRESS))) severity NOTE; 
        
        -- Puts Address on the Bus
        Addr_Data_LB_sti        <= ADDRESS (15 downto 0);
        Addr_LB_sti             <= ADDRESS (24 downto 16);
        
        for i in 0 to ASYN_WRCYCLETIME  loop      
       
            if i=ASYN_CSONTIME then
                 SP6_LB_nCS3_sti         <= '0';
            end if;
            
            if i=ASYN_ADVONTIME then
                SP6_LB_nADV_ALE_sti     <= '0';
            end if;

            if i= ASYN_ADVWROFFTIME then
                SP6_LB_nADV_ALE_sti     <= '1';
            end if;
        
            if i=  ASYN_WEONTIME then
                SP6_LB_nWE_sti          <= '0';
            end if;
           
            if i=ASYN_WRDATAONADMUXBUS then
                Addr_Data_LB_sti        <= Data (15 downto 0);                
            end if;    
                          
           
            if i=ASYN_CSWROFFTIME then    
                -- if GPMC_LB_WAIT3_i = '0' or (GPMC_LB_Wait3_pipe/="11" ) then -- freeze the counter until Wait is deaserted. 
                    -- wait on GPMC_LB_Wait3_pipe until GPMC_LB_Wait3_pipe="11";                
                    -- wait on GPMC_FCLK_sti until GPMC_FCLK_sti='1'; 
                -- end if; 
               SP6_LB_nCS3_sti         <= '1';
            end if;
            
            if i=ASYN_WEOFFTIME then
                 -- if GPMC_LB_WAIT3_i = '0' or (GPMC_LB_Wait3_pipe/="11" ) then -- freeze the counter until Wait is deaserted. 
                    -- wait on GPMC_LB_Wait3_pipe until GPMC_LB_Wait3_pipe="11";  
                    -- wait on GPMC_FCLK_sti until GPMC_FCLK_sti='1'; 
                -- end if;                 
                SP6_LB_nWE_sti          <= '1';      
            end if;   
        
            if i=ASYN_WRCYCLETIME then
                SP6_LB_nBE0_CLE_sti     <= '1';
                SP6_LB_nADV_ALE_sti     <= '0';
            end if;
            
            wait for CLK_PERIOD_200;   
             
        end loop;                 
        
        -- wait more cycle before ending the procedure
        wait for CLK_PERIOD_200*CYCLE2CYCLEDELAY;     
    end procedure Asyn_single_write;
    
    
    --===============================
    -- Asynchronous READ procedure
    --===============================
    procedure Asyn_single_read(     signal ADDRESS  :  std_logic_vector (24 downto 0);
                                    signal Data_Read_LB_obs     : out std_logic_vector (15 downto 0);
                                    signal Data_valid            : out std_logic) is                                
    
    begin
        -- Asynchronous Single Read    
        wait on GPMC_FCLK_sti until GPMC_FCLK_sti='1'; 
        
        --report "Read at addresse " & integer'image(to_integer(unsigned(ADDRESS))) severity NOTE; 
        SP6_LB_nBE0_CLE_sti     <= '0';
        SP6_LB_nADV_ALE_sti     <= '1';
        Addr_Data_LB_sti        <= ADDRESS (15 downto 0);
        Addr_LB_sti             <= ADDRESS (24 downto 16);
        Data_valid  <='0';
        
        for i in 0 to ASYN_RDCYCLETIME loop            
       
            if i=ASYN_CSONTIME then
                SP6_LB_nCS3_sti         <= '0';
            end if;
            
            if i=ASYN_ADVONTIME then
                SP6_LB_nADV_ALE_sti     <= '0';   
            end if; 
        
            if i=ASYN_ADVRDOFFTIME then
                SP6_LB_nADV_ALE_sti     <= '1';
            end if;            
            
            if i= ASYN_OEONTIME then
                SP6_LB_RE_nOE_sti       <= '0'; 
                data_direction_out      <= '0';                
            end if;  
            
            if i= ASYN_RDACCESSTIME then
               if GPMC_LB_WAIT3_i = '0' or (GPMC_LB_Wait3_pipe/="11" ) then -- freeze the counter until Wait is deaserted. 
                    wait on GPMC_LB_Wait3_pipe until GPMC_LB_Wait3_pipe="11";                   
                    wait on GPMC_FCLK_sti until GPMC_FCLK_sti='1'; 
                end if;                 
                Data_Read_LB_obs        <= Addr_Data_LB_Zstate_delayed;    -- takes the data from the delayed bus (LB_Clk  --> FPGA Flip-Flop -->  Local Bus Tristate time)   
                Data_valid  <='1';
                report "Read the data at " & integer'image(i)  severity NOTE; 
            else
                Data_valid  <='0';
            end if;            
            
            if i= ASYN_CSRDOFFTIME then
                SP6_LB_nCS3_sti         <= '1';
            end if;
            
            if i=ASYN_OEOFFTIME then
                SP6_LB_RE_nOE_sti       <= '1';
            end if;            
            
            if i=ASYN_RDCYCLETIME then
                SP6_LB_nADV_ALE_sti     <= '0'; 
                SP6_LB_nBE0_CLE_sti     <= '1'; 
                data_direction_out      <= '1';                
            end if;            
            wait for CLK_PERIOD_200; 
        end loop;
        
        Data_valid  <='0';
       -- wait more cycle before ending the procedure
        wait for CLK_PERIOD_200*CYCLE2CYCLEDELAY;     
    end procedure Asyn_single_read;
    
       
    --=====================================
    -- Synchronous Multiple READ procedure
    --=====================================    
    procedure syn_burst_read(   constant ADDRESS            : in std_logic_vector (24 downto 0);
                                signal Burst_nb             : in std_logic_vector(15 downto 0);
                                signal Data_Read            : out std_logic_vector(15 downto 0);
                                signal Data_Read_valid      : out std_logic) is  
                                
    variable  activation_time   : integer := GPMCFCLKDIVIDER - CLKACTIVATIONTIME +1;
    variable  transaction_time  : integer := RDCYCLETIME + PAGEBURSTACCESSTIME*(to_integer(unsigned(Burst_nb))-1); -- total time for 1 burst read
    begin
     -- Synchronous Multiple Read
        Data_Read_valid     <= '0';
        report LF & "Burst read at address " & integer'image(to_integer(unsigned(ADDRESS))) & " for " & integer'image(to_integer(unsigned(Burst_nb))) & " x 16bits" severity Note; 
        -- wait for a LB_clk rising Edge
        wait on LB_CLK until LB_CLK='1';
                 
        -- deal with clk delay at start
        if CLKACTIVATIONTIME /=0 then
            for i in 1 to  activation_time  loop        
                wait on GPMC_FCLK_sti until GPMC_FCLK_sti='1';
            end loop;
        end if;
        LB_CLK_EN               <= '1';
        Addr_Data_LB_sti        <= ADDRESS (15 downto 0);
        Addr_LB_sti             <= ADDRESS (24 downto 16);
        SP6_LB_nBE0_CLE_sti     <= '0';
        SP6_LB_nADV_ALE_sti     <= '1';          
        
        -- loop cycles and assert signals based on their timing set in constants
        -- set the address up to RDACCESSTIME
        for i in 0 to RDACCESSTIME -1  loop
                 
            
            -- nCS
            if CSONTIME= i then
                SP6_LB_nCS4_sti         <= '0';           
            end if;
            
            
            -- nADV 
            if ADVONTIME = i then
                SP6_LB_nADV_ALE_sti     <= '0';
            end if;
            if ADVRDOFFTIME = i then
                SP6_LB_nADV_ALE_sti     <= '1';
            end if;
            
            -- nOE
            if OEONTIME= i then        
                SP6_LB_RE_nOE_sti       <= '0';
                data_direction_out      <= '0';     
            elsif OEOFFTIME= i then  
                SP6_LB_RE_nOE_sti       <= '1';
            end if;
            
            Read_burst_loop <=i;
            wait for CLK_PERIOD_200;           
        end loop;
        
        -- loop for all the Data burst
        for i in RDACCESSTIME to transaction_time loop
        
            if pagetimerCounter =   0 then
                Data_Read           <= Addr_Data_LB_Zstate_delayed;
                Data_Read_valid     <= '1';
                
            else
               
                Data_Read_valid     <= '0';
                Data_Read           <= (others=>'0');
            end if;
                
            if pagetimerCounter = PAGEBURSTACCESSTIME-1 then
                pagetimerCounter <= 0;
            else                
                pagetimerCounter <= pagetimerCounter+1;
            end if;
                
            -- nCS
            if CSONTIME= i then
                SP6_LB_nCS4_sti         <= '0';
            elsif i= RDACCESSTIME + CSRDOFFTIME1 + PAGEBURSTACCESSTIME*(to_integer(unsigned(Burst_nb))-1) then
                SP6_LB_nCS4_sti         <= '1';
            end if;
        
            -- nOE
            if OEONTIME= i then        
                SP6_LB_RE_nOE_sti       <= '0';
            elsif  i= RDACCESSTIME + OEOFFTIME1 + PAGEBURSTACCESSTIME*(to_integer(unsigned(Burst_nb))-1) then  
                SP6_LB_RE_nOE_sti       <= '1';
            end if;
        
             if transaction_time =i then
                SP6_LB_nBE0_CLE_sti<='1';
                data_direction_out      <= '1'; 
            end if;
            
            Read_burst_loop <=i;
            wait for CLK_PERIOD_200;      
        end loop;      
                
        
       
        Data_Read_valid     <= '0';
        --Read_burst_loop <= 0;
        pagetimerCounter <=0;
        LB_CLK_EN       <= '0';          
        
        -- wait more cycle before ending the procedure
        wait for CLK_PERIOD_200*CYCLE2CYCLEDELAY;     
       
    end procedure syn_burst_read;  

	begin
	if nRst_sti ='0' then
	    -- Local Bus signals
        DIP_sti                 <= (others=>'1');      
        SP6_LB_nCS3_sti         <= '1';
        SP6_LB_nCS4_sti         <= '1';
        SP6_LB_RE_nOE_sti       <= '1';
        SP6_LB_nWE_sti          <= '1';
        SP6_LB_nADV_ALE_sti     <= '0';
        SP6_LB_nBE0_CLE_sti     <= '1';
        Addr_Data_LB_sti        <= (others=>'0');
        Addr_LB_sti             <= (others=>'0');
        data_direction_out      <= '1'; 
        -- GPMC signals
        Burst_nb                <= (others=>'0');        
        GPMC_Data_obs           <= (others=>'0');
        GPMC_Data_valid_obs     <='0';  
        
       
        TestBenchDelay          <= 0;
        DUMMY_READ              <= x"0003";
        LB_CLK_EN               <='0';
        pagetimerCounter        <= 0;  
        Read_burst_loop         <= 0;
        GPMC_DataWrite          <= (others=>(others=>'0'));
        GPMC_DataRead           <= (others=>(others=>'0'));
		
		cmd_single_write_reg    <='0';
		cmd_single_read_reg     <='0';
		--Cmd_data_read_o         <= (others=>'0');
		wait for CLK_PERIOD_200;
	else
	
		wait on GPMC_FCLK_sti until GPMC_FCLK_sti='1';
		cmd_single_write_reg <= cmd_single_write_s;
		cmd_single_read_reg <= cmd_single_read_s;
	
		if (cmd_single_write_s='1') and (cmd_single_write_reg='0') then 
            -- Call procedure write
			Asyn_single_write (Cmd_addr_write_i, Cmd_data_write_i);
		end if;
		
		if (cmd_single_read_s='1') and (cmd_single_read_reg='0') then
            -- Call procedure read
			Asyn_single_Read (Cmd_addr_read_i, GPMC_Data_obs, GPMC_Data_valid_obs);
        end if;
	
	end if;
end process;
 
    
stimuli: process   
    
    begin    
    
    ---=======================
    --       MAIN 
    ---=======================

		
        wait until nRst_sti='1';
        wait for CLK_PERIOD*50;
        report LF & LF &
        "-------------------------------"  & LF &
        "    Début de la Simulation"        & LF &
        "-------------------------------"  severity Warning; 
     
        
		-- cmd_single_write_s <= '1';
		-- wait for CLK_PERIOD_200;
		-- cmd_single_write_s <= '0';
		-- wait for CLK_PERIOD_200*20;
		
		-- cmd_single_read_s <= '1';
		-- wait for CLK_PERIOD_200;
		-- cmd_single_read_s <= '0';
		-- wait for CLK_PERIOD_200*20;
		wait for CLK_PERIOD_200*20;

        wait;        
    end process; 
    
    
--====================    
    -- OUTPUTS
--====================
    
    -- input clock for Reptar @100Mhz   
    External_100Mhz_Clk_o	        <= clk_100Mhz_sti'delayed(100 ps); -- best case senario, the FPGA sees the signals 100 ps after they change    
    GPMC_Clk_25MHz_o                <= '0';
    GPMC_nReset_o                   <= nRst_sti;
    
    GPMC_DIP_o                      <= DIP_sti;
    End_of_sim_o                    <= end_of_sim; 
    TestBenchDelay_o                <= TestBenchDelay;
    
    -- normal outputs
    GPMC_LB_RE_nOE_o                <= SP6_LB_RE_nOE_sti; 
    GPMC_LB_nWE_o                   <= SP6_LB_nWE_sti;
    GPMC_LB_nCS3_o                  <= SP6_LB_nCS3_sti;
    GPMC_LB_nCS4_o                  <= SP6_LB_nCS4_sti;
    GPMC_LB_nADV_ALE_o              <= SP6_LB_nADV_ALE_sti;
    GPMC_LB_nBE0_CLE_o              <= SP6_LB_nBE0_CLE_sti;

    GPMC_LB_CLK_o                   <= SP6_LB_CLK_sti;
    GPMC_Addr_Data_LB_io            <= Addr_Data_LB_Zstate'delayed(GPMC_to_FPGA_Latency);
    GPMC_Addr_LB_o                  <= Addr_LB_sti'delayed(GPMC_to_FPGA_Latency);

    -- Cmd Async signals 
    Cmd_clk_o                       <= GPMC_FCLK_sti;
	Cmd_nReset_o                    <= nRst_sti;
    cmd_single_read_s               <= Cmd_single_read_i;
	cmd_single_write_s              <= Cmd_single_write_i;
	Cmd_data_read_o                 <= GPMC_Data_obs;
	Cmd_datavalid_read_o            <= GPMC_Data_valid_obs;
    
end behave;
