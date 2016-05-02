------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : irq_generator.vhd
-- Author               : Evangelina Lolivier-Exler
-- Date                 : 24.10.2013
-- Target Devices       : Spartan6 xc6slx150t-3fgg900
--
-- Context              : Reptar - FPGA design
--
---------------------------------------------------------------------------------------------
-- Description : IRQ generation on a button pressure (SW_PB_i) or from user lba or lbs blocks
--				 update of the register IRQ_CTL when an interrupt is generated
--				 the interrupt line is reset to '0' when the irq_clear bit is set to '1'
---------------------------------------------------------------------------------------------
-- Information : description of IRQ_CTL register on file Spartan6_registers.xlsx
---------------------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Engineer     Comments
-- 0.0   See header  ELR          Initial version
-- 0.1   28.01.14    CVZ          Added the irq_enable signal

---------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

 
 entity irq_generator is
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
  end irq_generator;
	
architecture behavioral of irq_generator is

-- signals for IRQ generation ----------------------------------------------------------

-- number of the button that has generated the IRQ
signal  irq_press_but_s			: std_logic_vector(2 downto 0);
-- button pressure detection
signal  irq_status_s			: std_logic;
signal  irq_event_s				: std_logic;
-- registers for SW_PB_i
signal  PUSH_BUT_REG1_s			: std_logic_vector(7 downto 0);
signal  PUSH_BUT_REG2_s			: std_logic_vector(7 downto 0);
signal  PUSH_BUT_REG3_s			: std_logic_vector(7 downto 0);
----------------------

	
begin

-- IRQ generation on a button pressure (SW_PB_i) 

 --	output sychronization
	process(clk_i, reset_i)
	begin
		if (reset_i = '1') then
			irq_o <= '0';
		elsif rising_edge(clk_i) then
			irq_o <= irq_status_s;
		end if;
	end process;


-- registers
push_but_reg1: process(clk_i, reset_i)
begin
	if (reset_i = '1') then
		PUSH_BUT_REG1_s <= (others => '0');
	elsif rising_edge(clk_i) then
		PUSH_BUT_REG1_s <=  push_but_reg_i;
	end if;
end process push_but_reg1;

push_but_reg2: process(clk_i, reset_i)
begin
	if (reset_i = '1') then
		PUSH_BUT_REG2_s <= (others => '0');
	elsif rising_edge(clk_i) then
		PUSH_BUT_REG2_s <=  PUSH_BUT_REG1_s;
	end if;
end process push_but_reg2;

push_but_reg3: process(clk_i, reset_i)
begin
	if (reset_i = '1') then
		PUSH_BUT_REG3_s <= (others => '0');
	elsif rising_edge(clk_i) then
		PUSH_BUT_REG3_s <=  PUSH_BUT_REG2_s;
	end if;
end process push_but_reg3;

-- button pressure event detection

-- irq_event_s signal is set to '1' while a button is hold pressed and is reset to '0' when the button is released
 irq_event_s	<= '1' when irq_press_but_s > "000" or (PUSH_BUT_REG1_s(0)='1' and PUSH_BUT_REG2_s(0)='1' and PUSH_BUT_REG3_s(0)='0') else '0';
 
 irq_press_but_s <= "000" when PUSH_BUT_REG1_s(0)='1' and PUSH_BUT_REG2_s(0)='1' and PUSH_BUT_REG3_s(0)='0' else
					"001" when PUSH_BUT_REG1_s(1)='1' and PUSH_BUT_REG2_s(1)='1' and PUSH_BUT_REG3_s(1)='0' else
					"010" when PUSH_BUT_REG1_s(2)='1' and PUSH_BUT_REG2_s(2)='1' and PUSH_BUT_REG3_s(2)='0' else
					"011" when PUSH_BUT_REG1_s(3)='1' and PUSH_BUT_REG2_s(3)='1' and PUSH_BUT_REG3_s(3)='0' else
					"100" when PUSH_BUT_REG1_s(4)='1' and PUSH_BUT_REG2_s(4)='1' and PUSH_BUT_REG3_s(4)='0' else
					"101" when PUSH_BUT_REG1_s(5)='1' and PUSH_BUT_REG2_s(5)='1' and PUSH_BUT_REG3_s(5)='0' else
					"110" when PUSH_BUT_REG1_s(6)='1' and PUSH_BUT_REG2_s(6)='1' and PUSH_BUT_REG3_s(6)='0' else
					"111" when PUSH_BUT_REG1_s(7)='1' and PUSH_BUT_REG2_s(7)='1' and PUSH_BUT_REG3_s(7)='0' else
					"000";

	
 -- register event and button number
 
 process(clk_i, reset_i)
	begin
		if (reset_i = '1') then
			irq_status_s <= '0';
			irq_button_o <= (others => '0');
			irq_source_o <= "11";
		elsif rising_edge(clk_i) then
            if irq_enable_i ='1' then
            -- interrupt generated by the std interface (pressure on a button)
                if irq_event_s = '1' and irq_status_s = '0' then
                    irq_status_s <= '1';
                    irq_button_o <= irq_press_but_s;
                    irq_source_o <= "00";
            -- interrupt generated by the lba user interface		
                elsif lba_irq_user_i = '1' and irq_status_s = '0' then
                    irq_status_s <= '1';
                    irq_button_o <= (others => '0');
                    irq_source_o <= "01";
            -- interrupt generated by the lbs user interface			
                elsif lbs_irq_user_i = '1' and irq_status_s = '0' then
                    irq_status_s <= '1';
                    irq_button_o <= (others => '0');
                    irq_source_o <= "10";
            -- clear interrupt
                elsif irq_clear_i = '1' and irq_status_s = '1'  then
                    irq_status_s <= '0';
                    irq_button_o <= (others => '0');
                    irq_source_o <= "11";
                end if;
            else
                irq_status_s <= '0';
                irq_button_o <= (others => '0');
                irq_source_o <= "11";
            end if;
		end if;
		
end process;

irq_status_o <= irq_status_s;

end architecture behavioral;	

