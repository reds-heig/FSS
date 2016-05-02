-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- Institut REDS
--
-- Fichier :  Cap_Timer.vhd
-- Auteur  :  H. Truong
-- Date    :  28.01.2013
--
-- Utilise dans   : Projet touch control pad
--                  
------------------------------------------------------------------------------------------------------------
-- Fonctionnement vu de l'exterieur : le timer compte le temps pour charger la capacite 
--                                    et pour decharger la capacite
--   Generic:
--     N_g                      taille du compteur
--   Entree:
--     Reset_i                  Reset asynchrone, actif haut
--     Clock_i                  Horloge
--     Init_i                   Initialise le Timer
--     Start_nStop_i            Si Start Demarre le comptage si non maintien de la valeur compte 
--     Mode_CapOn_nCapOff_i     Si capon il est en mode de charge de la capacite si non en mode de decharge  
--   Sorties:
--     Cpt_Timer_o              Compte le temps pour charger la capacite ou pour decharger la capacite 
--     Time_out_o               Quand timer a comte jusqu'à ca valeur maximum le time_out est actif
--     Cap_Off_Done_o           Le signal Cap_Off_Done_o est pris en consideration en mode decharge et
--                              est actif quand on a compte jusqu'à la valeur que on a suppose necessaire  
--                              pour decharger la capacite
--------------------------------------------------------------------------------------------------------------
-- Ver    Date          Qui  Commentaires
-- 1.0    See header    HTG  Version initiale
-- 
-- 
-----------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.touch_pad_ctrl_pkg.all;

entity Cap_timer is
   generic(
    N_g : positive range 1 to 32 := 3);  -- valeur par defaut
   port( 
     Clock_i                : in  std_logic;
     Reset_i                : in  std_logic;
     Init_i                 : in  std_logic;
     Start_nStop_i          : in  std_logic;
     Mode_CapOn_nCapOff_i   : in  std_logic;
     Cpt_Timer_o            : out std_logic_vector(N_g-1 downto 0);
     Time_Out_o             : out std_logic;
     Cap_Off_Done_o         : out std_logic
 );
end Cap_Timer ;

architecture Comport of Cap_timer is

 -- signaux internes

  signal Cpt_Timer_Pres_s, Cpt_Timer_Fut_s : Unsigned(Cpt_Timer_o'range);
  signal Det_Cap_Off_Done_Cpt_s, Time_Out_s : Std_Logic;
  
  
  
begin -- Comport

  Det_Cap_Off_Done_Cpt_s <= '1' when Cpt_Timer_Pres_s = To_Unsigned(Nbr_Att_Cap_Unload_c,N_g) and Mode_CapOn_nCapOff_i= '0' and Init_i = '0' else
							'0';
                            
  Time_Out_s  <= '1' when Cpt_Timer_Pres_s = (2**Cpt_Timer_Pres_s'length-1) and Init_i = '0' else
                 '0';
  
  -- Decodeur d'etat futur
  Cpt_Timer_Fut_s <= (others=>'0') when Init_i='1' else  --initialise CPT lorsque Init_i actif
                 --gestion des cas Start actif (else)
                 Cpt_Timer_Pres_s + 1 when Start_nStop_i = '1' and Det_Cap_Off_Done_Cpt_s = '0' and Time_Out_s = '0' else -- compte tant que le delai pas ecoule
                 Cpt_Timer_Pres_s;   --Start actif avec delai ecoule
  
  --description element mémoire
  Mem: process (Clock_i, Reset_i)
  begin
    if Reset_i='1' then
      Cpt_Timer_Pres_s <= (others => '0');   -- reset asynchrone
    elsif Rising_Edge(Clock_i) then       
      Cpt_Timer_Pres_s <= Cpt_Timer_Fut_s;
    --else maintien 
    end if;
  end process;

  --Decodeur de Sortie
  Cpt_Timer_o <= std_logic_vector(Cpt_Timer_Pres_s);
  Cap_Off_Done_o <= Det_Cap_Off_Done_Cpt_s;
  Time_Out_o <= Time_Out_s;
end Comport;

------------
------------


