-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : Pin_Filter.vhd
-- Description  : 
--
-- Auteur       : H. Truong
-- Date         : 08.02.13
-- Version      : 0.0
--
-- Utilise      : 
--
--| Modifications |-----------------------------------------------------------
-- Version   Auteur Date               Description
-- 
--
------------------------------------------------------------------------------

library IEEE;
  use IEEE.Std_Logic_1164.all;
  use IEEE.Numeric_Std.all;
  
  --use work.Touch_Control_Pad_pkg.all;

entity Pin_Filter is
  port (
        Clock_i    : in std_logic;
        Reset_i    : in std_logic;
		Init_i	   : in std_logic;
        Data_i     : in  std_logic;
        Data_o     : out std_logic
		); 
end Pin_Filter;

architecture Struct of Pin_Filter is
  
  signal Data_i_s : std_logic_vector(0 downto 0);
  signal Data_o_s : std_logic_vector(2 downto 0);
  
  component Filter4Data 
  generic(
        N_g 		: positive range 1 to 32);
     --  N_g : positive := 8); -- pour simulation
  port (
        Clock_i    : in std_logic;
        Reset_i    : in std_logic;
		Init_i	   : in std_logic;
        Data_i     : in  std_logic_vector(N_g-1 downto 0);
        Data_o     : out std_logic_vector(N_g+1 downto 0)); 
  end component;
  
begin

  Data_i_s(0) <= Data_i;
  
  add_filter:  Filter4Data generic map(N_g => 1)  
                           port map(Clock_i => Clock_i,
                                    Reset_i => Reset_i,
                                    Init_i =>  Init_i,
                                    --Data_i => Data_i_s(0 downto 0),
									Data_i => Data_i_s,
                                    Data_o => Data_o_s);
								
  Data_o <= '1' when  Unsigned(Data_o_s) > To_Unsigned(1,Data_o_s'length) else 
			'0';

end Struct;


