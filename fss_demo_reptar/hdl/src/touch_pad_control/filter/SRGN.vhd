-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : SRGN.vhd
-- Description  : 
--          
--          
--         
--          
--          Entrees :
--	         
--          
--          Sorties :
--	         
--          
--          Priorite des commandes: Reset,...
--
-- Auteur       : H. Truong
-- Date         : 08.01.13
-- Version      : 0.0
--
-- Utilise      : Projet REPTAR, touch control pad
--
--| Modifications |-----------------------------------------------------------
-- Version   Auteur Date               Description
-- 0.0       HTG    08.01.2013         Mise à jour
--       
------------------------------------------------------------------------------

library IEEE;
  use IEEE.Std_Logic_1164.all;
  --use IEEE.Numeric_Std.all;

entity SRGN is
    generic(
     N_g : positive range 1 to 32);
    port( Clock_i, Reset_i : in std_logic;
          En_i   : in std_logic;
          Data_i : in  std_logic_vector(N_g-1 downto 0);
          Data_o : out std_logic_vector(N_g-1 downto 0)
        );
end SRGN;

architecture Comport of SRGN is

-- variables internes pour le registre
  --signal Reset_s : Std_Logic;
 
  signal Reg_Fut_s, Reg_Pres_s: Std_Logic_Vector(N_g-1 downto 0);
  
begin
--Adaptation de la polarite
-- 
--Concatenation de la valeur d'entree

 
  -- decodeur d'etat futur
  Reg_Fut_s <=  Data_i when (En_i='1') else --chargement
                Reg_Pres_s;  -- maintien

  -- description du registre flip-flop D              
  Mem: process(Clock_i, Reset_i)
  begin
    if (Reset_i ='1') then
      Reg_Pres_s <= (others=>'0');
    elsif Rising_Edge(Clock_i) then
      Reg_Pres_s <= Reg_Fut_s;
    end if;
  end process;

--Mise a jours de l'etat du registre
  Data_o <= Reg_Pres_s;
  

end Comport; 
