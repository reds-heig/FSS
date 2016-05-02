------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : lba_user_interface.vhd
-- Author               : Cedric Vulliez
-- Date                 : 06.11.2013
-- Target Devices       : Spartan6 xc6slx150t-3fgg900
--
-- Context              : Reptar - FPGA design
--
------------------------------------------------------------------------------------------
-- Description : User Interface to test all different asyn access types, with different wait length time
--               made to validate Lba_crtl interface and the GPMC_TestBench                   
------------------------------------------------------------------------------------------
-- Information : 
--              Write operation is done without wait    
--              Read operation increment the wait time based on the register Add.
--              USER_ADDRESS_0  : 0 wait periode(s)  
--              USER_ADDRESS_1  : 1 wait periode(s)  
--              USER_ADDRESS_2  : 2 wait periode(s)  
--              USER_ADDRESS_3  : 3 wait periode(s)  
--              ...
--              USER_ADDRESS_8  : 8 wait periode(s) 
--                  
------------------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Engineer     Comments
-- 1.0   06.11.13       CVZ         Initial version

-------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity lba_user_interface is
port (
       
        clk_i	                        : in std_logic; -- must be a 200 Mhz clock       
        reset_i                         : in std_logic;        
       
        lba_cs_usr_rd_i                 : in std_logic;
        lba_cs_usr_wr_i                 : in std_logic;
        lba_wr_en_i                     : in std_logic;
        lba_rd_en_i                     : in std_logic;
        
        lba_add_i                       : in std_logic_vector(22 downto 0);
        lba_data_wr_i                   : in std_logic_vector(15 downto 0);        
        
        lba_data_rd_user_o              : out std_logic_vector(15 downto 0);           
        lba_wait_user_o                 : out std_logic;
		lba_irq_user_o		   			: out std_logic
      
    );
end  lba_user_interface;

architecture behave of lba_user_interface is

----------------------------------------------  
-- Addresses used. 23bits vectors
----------------------------------------------       

	constant USER_ADDRESS_0                     : std_logic_vector(2 downto 0) := "000"; --0x0000000 RW
    constant USER_ADDRESS_1                     : std_logic_vector(2 downto 0) := "001"; --0x0000001 RW
    constant USER_ADDRESS_2                     : std_logic_vector(2 downto 0) := "010"; --0x0000002 RW
    constant USER_ADDRESS_3                     : std_logic_vector(2 downto 0) := "011"; --0x0000003 RW
    constant USER_ADDRESS_4                     : std_logic_vector(2 downto 0) := "100"; --0x0000004 RW
    constant USER_ADDRESS_5                     : std_logic_vector(2 downto 0) := "101"; --0x0000005 RW
    constant USER_ADDRESS_6                     : std_logic_vector(2 downto 0) := "110"; --0x0000006 RW
    constant USER_ADDRESS_7                     : std_logic_vector(2 downto 0) := "111"; --0x0000007 RW
    -- ....
    constant USER_ADDRESS_16                    : std_logic_vector(22 downto 0) := "00000000000000000010000"; --0x0000010 RW
      
   
-----------------   signals   ----------------------
   signal User_register_0_s                     : std_logic_vector (15 downto 0);
   signal User_register_1_s                     : std_logic_vector (15 downto 0);
   signal User_register_2_s                     : std_logic_vector (15 downto 0);
   signal User_register_3_s                     : std_logic_vector (15 downto 0);
   signal User_register_4_s                     : std_logic_vector (15 downto 0);
   signal User_register_5_s                     : std_logic_vector (15 downto 0);
   signal User_register_6_s                     : std_logic_vector (15 downto 0);
   signal User_register_7_s                     : std_logic_vector (15 downto 0);
   
   signal lba_data_rd_temps_s                   : std_logic_vector (15 downto 0);
   
   
   type state_machine is (Interface_ready, Interface_wait_active,Interface_wait_EndReadCycle);   
   signal interface_state : state_machine;
   
   signal wait_counter_s                        : unsigned (7 downto 0);
   
begin

	lba_irq_user_o <= '0';

    
Write_Operation:process (clk_i, reset_i)
begin

    if reset_i='1' then 
        User_register_0_s       <= (others=>'0');
        User_register_1_s       <= (others=>'0');
        User_register_2_s       <= (others=>'0');
        User_register_3_s       <= (others=>'0');
        User_register_4_s       <= (others=>'0');
        User_register_5_s       <= (others=>'0');
        User_register_6_s       <= (others=>'0');
        User_register_7_s       <= (others=>'0');
     
    elsif rising_edge(clk_i) then
                   
        -- write operation
        if lba_cs_usr_wr_i='1' and lba_wr_en_i='1' then
        
            case lba_add_i(2 downto 0) is
                    
                when USER_ADDRESS_0=>
                    User_register_0_s   <= lba_data_wr_i;
                when USER_ADDRESS_1=>
                    User_register_1_s   <= lba_data_wr_i; 
                when USER_ADDRESS_2=>
                    User_register_2_s   <= lba_data_wr_i;
                when USER_ADDRESS_3=>
                    User_register_3_s   <= lba_data_wr_i; 
                when USER_ADDRESS_4=>
                    User_register_4_s   <= lba_data_wr_i;
                when USER_ADDRESS_5=>
                    User_register_5_s   <= lba_data_wr_i; 
                when USER_ADDRESS_6=>
                    User_register_6_s   <= lba_data_wr_i;
                when USER_ADDRESS_7=>
                    User_register_7_s   <= lba_data_wr_i;   
                when others=>
                    null;                
            end case;
        end if;
    end if;
end process;
       
    
    
    
    
    
    
Read_Operation:process (clk_i, reset_i)
begin

    if reset_i='1' then        
            
        interface_state         <= Interface_ready;        
        lba_wait_user_o         <= '0';  
              
        wait_counter_s          <= (others=>'0');
        lba_data_rd_temps_s     <= (others=>'0');
    elsif rising_edge(clk_i) then
    
        
        case interface_state is        
            
            -- when no wait is needed
            when Interface_ready=>
            
                -- resets the counter
                wait_counter_s  <= (others=>'0');
                
                -- read operation
                if lba_cs_usr_rd_i='1' then
                
                    case lba_add_i(2 downto 0) is
                      
                        when USER_ADDRESS_0=>
                            lba_data_rd_temps_s   <= User_register_0_s;
                        
                         -- if others addresses, activate the wait
                        when others=>
                            lba_wait_user_o     <= '1';
                            interface_state     <= Interface_wait_active;
                    end case;
                end if;
            
            -- handles the wait
            when Interface_wait_active=>
                
                case lba_add_i(2 downto 0) is
                      
                    when USER_ADDRESS_1=>
                        if wait_counter_s= x"00" then                            
                            lba_data_rd_temps_s   <= User_register_1_s;
                            lba_wait_user_o     <= '0';
                            interface_state     <= Interface_wait_EndReadCycle;
                        end if;                        
                    when USER_ADDRESS_2=>
                        if wait_counter_s= x"01" then                            
                            lba_data_rd_temps_s   <= User_register_2_s;
                            lba_wait_user_o     <= '0';
                            interface_state     <= Interface_wait_EndReadCycle;
                        end if;                             
                    when USER_ADDRESS_3=>
                        if wait_counter_s= x"02" then                            
                            lba_data_rd_temps_s   <= User_register_3_s;
                            lba_wait_user_o     <= '0';
                            interface_state     <= Interface_wait_EndReadCycle;
                        end if;                                   
                    when USER_ADDRESS_4=>
                        if wait_counter_s= x"03" then                            
                            lba_data_rd_temps_s   <= User_register_4_s;
                            lba_wait_user_o     <= '0';
                            interface_state     <= Interface_wait_EndReadCycle;
                        end if;                           
                    when USER_ADDRESS_5=>
                        if wait_counter_s= x"04" then                            
                            lba_data_rd_temps_s   <= User_register_5_s;
                            lba_wait_user_o     <= '0';
                            interface_state     <= Interface_wait_EndReadCycle;
                        end if;                                   
                    when USER_ADDRESS_6=>
                        if wait_counter_s= x"05" then                            
                            lba_data_rd_temps_s   <= User_register_6_s;
                            lba_wait_user_o     <= '0';
                            interface_state     <= Interface_wait_EndReadCycle;
                        end if;                         
                    when USER_ADDRESS_7=>
                        if wait_counter_s= x"06" then                            
                            lba_data_rd_temps_s   <= User_register_7_s;
                            lba_wait_user_o     <= '0';
                            interface_state     <= Interface_wait_EndReadCycle;
                        end if;  
                         
                    when others=>
                        lba_wait_user_o     <= '0';
                        interface_state     <= Interface_ready;
                end case;
                    
                -- counter
                wait_counter_s <= wait_counter_s+ 1;            
                 
            when Interface_wait_EndReadCycle =>
                lba_wait_user_o         <= '0';
                if lba_cs_usr_rd_i='0' then                    
                    interface_state         <= Interface_ready;
                end if;
             
            
            
            when others=>
                lba_wait_user_o         <= '0';
                interface_state         <= Interface_ready;
        end case;
    end if;
end process;
    
    
    
   -- process to sync the data to the bus only once 
process (clk_i, reset_i) 
begin
    if reset_i='1' then
         lba_data_rd_user_o      <= (others=>'0'); 
    elsif rising_edge(clk_i) then
        if lba_cs_usr_rd_i='1' and lba_rd_en_i='1' then
            lba_data_rd_user_o  <= lba_data_rd_temps_s;
        end if;
    end if;     
end process;



    
  
    
    
end behave;
