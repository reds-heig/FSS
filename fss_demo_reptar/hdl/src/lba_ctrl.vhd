-----------------------------------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
-----------------------------------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
-----------------------------------------------------------------------------------------------------------------------
--
-- File                 : lba_ctrl.vhd
-- Author               : Evangelina Lolivier-Exler
-- Date                 : 01.11.2013
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


--------------------------------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lba_ctrl is
	port(
    clk_i				    : in std_logic;
	reset_i				    : in std_logic;
	-- from DM3730 GPMC trough Local Bus
	nCS3_LB_i				: in std_logic;
	nADV_LB_i				: in std_logic;
	nOE_LB_i				: in std_logic;
	nWE_LB_i				: in std_logic;
	Addr_LB_i				: in std_logic_vector(24 downto 16);
    lba_nwait_o             : out std_logic;
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
end lba_ctrl;

architecture structural of lba_ctrl is

 component lba_ctrl_fsm is
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

end component lba_ctrl_fsm;

signal nCS3_LB_s        : std_logic;
signal nADV_LB_s        : std_logic;
signal nOE_LB_s         : std_logic;
signal nWE_LB_s	        : std_logic;
signal lba_wait_s       : std_logic;
signal lba_add_en_s : std_logic;
signal lb_add_s         : STD_LOGIC_VECTOR(22 downto 0);


begin

	input_synchro: process (clk_i, reset_i)
	begin
		if( reset_i = '1' ) then
			nCS3_LB_s		 <= '1';
            nADV_LB_s		 <= '1';
            nOE_LB_s		 <= '1';
            nWE_LB_s		 <= '1';	
		elsif( Rising_Edge(clk_i) ) then      
			nCS3_LB_s		 <= nCS3_LB_i;
            nADV_LB_s		 <= nADV_LB_i;
            nOE_LB_s		 <= nOE_LB_i;
            nWE_LB_s		 <= nWE_LB_i;	
		end if;
	end process;

	lba_ctrl_fsm_inst: lba_ctrl_fsm
	port map(
		clk_i			 => clk_i,	
		reset_i			 => reset_i,
		
		nCS3_LB_i		 => nCS3_LB_s,
		nADV_LB_i		 => nADV_LB_s,
		nOE_LB_i		 => nOE_LB_s,
		nWE_LB_i		 => nWE_LB_s,
		Addr_LB_i		 => Addr_LB_i(24 downto 23),
		lba_wait_o       => lba_wait_s,
		lba_oe_o		 => lba_oe_o,
		lba_wr_en_o      => lba_wr_en_o,
		lba_rd_en_o      => lba_rd_en_o,
		lba_add_en_o	 => lba_add_en_s,
		lba_cs_std_o     => lba_cs_std_o,
		lba_cs_usr_rd_o  => lba_cs_usr_rd_o,
        lba_cs_usr_wr_o  => lba_cs_usr_wr_o,
		lba_wait_usr_i   => lba_wait_usr_i
		);
	
	lba_nwait_o <= not lba_wait_s;
	
	address_register: process (clk_i, reset_i)
	begin
		if( reset_i = '1' ) then
			lb_add_s <= (others => '0');
		elsif( Rising_Edge(clk_i) ) then  
			if lba_add_en_s = '1' then -- saves the address when it is valid
				lb_add_s <= Addr_LB_i(22 downto 16) & lb_add_data_wr_i;			
			end if;
		end if;
	end process;
	
	-- outputs
	lba_add_o <= lb_add_s;
  
end structural;