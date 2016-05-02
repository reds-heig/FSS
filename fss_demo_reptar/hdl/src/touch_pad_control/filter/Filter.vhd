-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : Filter.vhd
-- Description  : 
--
-- Auteur       : H. Truong
-- Date         : 29.01.13
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

entity Filter is
  generic(
     N_g 		: positive range 1 to 32 :=3); -- valeur par defaut est 3
    -- N_g : positive := 4); -- pour simulation
  port (
        Clock_i    : in std_logic;
        Reset_i    : in std_logic;
		Init_i	   : in std_logic;
        En_Wr_i    : in std_logic;
        Data_i     : in  std_logic_vector(N_g-1 downto 0);
        Data_o     : out std_logic_vector(N_g+1 downto 0);
        Mem_Full_o : out std_logic ); 
end Filter;

architecture Struct of Filter is

  Type Type_Data_Mem_ar is array (0 to 16) of std_logic_vector(N_g-1 downto 0);
  Type Type_Data_ar1 is array (0 to 1) of std_logic_vector(N_g+2 downto 0);
  Type Type_Data_ar2 is array (0 to 3) of std_logic_vector(N_g+1 downto 0);
  Type Type_Data_ar3 is array (0 to 7) of std_logic_vector(N_g downto 0);
  
  signal Data_Mem_s : Type_Data_Mem_ar;
  signal Data_ar1_s : Type_Data_ar1;
  signal Data_ar2_s : Type_Data_ar2;
  signal Data_ar3_s : Type_Data_ar3;
  signal Data_Somme_s : std_logic_vector(N_g+3 downto 0);
  signal Cpt_Fut_s, Cpt_Pres_s: unsigned(4 downto 0);
  signal Mem_Full_s : std_logic;
 
  component SRGN
  generic(
    N_g : positive range 1 to 32);
  port (Clock_i, Reset_i : in std_logic;
        En_i    : in std_logic;
        Data_i  : in std_logic_vector(N_g-1 downto 0);
        Data_o  : out std_logic_vector(N_g-1 downto 0)
        );
  end component;
  
  component ADDN 
  generic(
     N_g : positive range 1 to 32);
  port (Nbr_A_i    : in  std_logic_vector(N_g-1 downto 0);
        Nbr_B_i    : in  std_logic_vector(N_g-1 downto 0);
        Cin_i      : in  std_logic;
        Somme_o    : out std_logic_vector(N_g-1 downto 0);
        Cout_o     : out std_logic);
  end component;
  
begin

------------------------------------------------------------------------------
-- Compteur pour etablir si la memoire du filtre est plein
------------------------------------------------------------------------------
  -- decodeur d'etats futur
  Cpt_Fut_s <= (others =>'0') when Init_i = '1' else
               Cpt_Pres_s + 1 when En_Wr_i = '1' and Mem_Full_s = '0' else
			   Cpt_Pres_s;
  
  Mem_Cpt: process(Clock_i, Reset_i)
  begin
    if (Reset_i ='1') then
      Cpt_Pres_s <= (others=>'0');
    elsif Rising_Edge(Clock_i) then
      Cpt_Pres_s <= Cpt_Fut_s;
    end if;
  end process;
  
  -- decodeur de sorties
  -- important est que 2**(Cpt_Pres_s'length-1)+2 est un valeur plus grand que le nombre de donne memorise 
  Mem_Full_s <= '1' when Cpt_Pres_s = (2**(Cpt_Pres_s'length-1)+2) else 
				'0';

------------------------------------------------------------------------------
-- mem16data
   
  Data_Mem_s(0)<= Data_i;
  
  srgn_use: for I in 0 to 15 generate
	
  SRGN_N_DATA_TIME:   SRGN generic map(N_g => N_g)
							  port map(Clock_i => Clock_i,
	                                   Reset_i => Reset_i,
	                                   En_i    => En_Wr_i,
                                       Data_i  => Data_Mem_s(I),
	                                   Data_o  => Data_Mem_s(I+1));
                                         
  end generate;
  
 ------------------------------------------------------------------------------ 
  -- bloc1
  add_bloc1_use:  ADDN generic map(N_g => N_g+3)  
                       port map(
                                Nbr_A_i => Data_ar1_s(0),
                                Nbr_B_i => Data_ar1_s(1),
                                Cin_i => '0',
                                Somme_o => Data_Somme_s(N_g+2 downto 0),
                                Cout_o => Data_Somme_s(N_g+3));                   
 
  -- bloc2	
  addn_bloc2_use: for I in 0 to 1 generate
 
    ADDN_2TIME:  ADDN generic map(N_g => N_g+2)
                      port map(
                               Nbr_A_i => Data_ar2_s(2*I),
                               Nbr_B_i => Data_ar2_s(2*I+1),
                               Cin_i => '0',
                               Somme_o => Data_ar1_s(I)(N_g +1 downto 0),
                               Cout_o => Data_ar1_s(I)(N_g+2));
  end generate;
  
  -- bloc 3
  addn_bloc3_use: for I in 0 to 3 generate
 
    ADDN_4TIME:  ADDN generic map(N_g => N_g+1)
                      port map(
                               Nbr_A_i => Data_ar3_s(2*I),
                               Nbr_B_i => Data_ar3_s(2*I+1),
                               Cin_i => '0',
                               Somme_o => Data_ar2_s(I)(N_g downto 0),
                               Cout_o => Data_ar2_s(I)(N_g+1));
  end generate;
  
  -- bloc 4
  addn_bloc4_use: for I in 0 to 7 generate
 
    ADDN_8TIME:  ADDN generic map(N_g => N_g)
                      port map(
                               Nbr_A_i => Data_Mem_s(2*I+1),
                               Nbr_B_i => Data_Mem_s(2*I+2),
                               Cin_i => '0',
                               Somme_o => Data_ar3_s(I)(N_g -1 downto 0),
                               Cout_o => Data_ar3_s(I)(N_g));
  end generate;
  ---------------------------------------------------------------------------
 
  ----------------------------------------------------------------------------
 -----------------------------------------------------------------------------   
  Data_o <= Data_Somme_s(N_g+3 downto 2); -- average  
  Mem_Full_o <= Mem_Full_s;
end Struct;


