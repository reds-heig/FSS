-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- Institut REDS
--
-- Fichier :  Capt_Finger.vhd
-- Auteur  :  H. Truong
-- Date    :  13.12.2012
--
-- Utilise dans   : Projet touch control pad
--                  
-----------------------------------------------------------------------
-- Fonctionnement vu de l'exterieur : detect la presence du doigt en
--                                    conparant les donnés recue avec la valeur
--                                    du temps necessaire pour charger la capacite
--                                    en memoire.
--   Generic:
--     N_g                      taille des donnees recues
--   Entree:
--     Reset_i                  Reset asynchrone, actif haut
--     Clock_i                  Horloge
--     Data_i                   donnees recues
--     Cap_Thr_Wr_i             Ecriture la valeur du temps necessaire pour charger
--                              la capacite jusqu'à quand la FPGA voit le niveaux '1' 
--   Sorties:
--     Det_Finger_o             detection de la presence du doigt   
--
-----------------------------------------------------------------------
-- Ver    Date          Qui  Commentaires
-- 0.0    See header    HTG  Version initiale, entite
-- 
-- 
-----------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.touch_pad_ctrl_pkg.all;

entity Capt_Finger is
   generic(
    N_g : positive range 1 to 32 := 3); -- valeur par defaut
    --N_g : positive := 8);
   port( 
     Clock_i        : in  std_logic;
     Reset_i        : in  std_logic;
     Init_i         : in  std_logic;
     Data_i         : in  std_logic_vector(N_g-1 downto 0);
     Cap_Thr_Wr_i   : in  std_logic;
     Det_Finger_o   : out std_logic
 );
end Capt_finger ;

architecture Struct_Comport of Capt_Finger is

component SRGN
  generic(
    N_g : positive range 1 to 32);
  port (Clock_i, Reset_i : in std_logic;
        En_i    : in std_logic;
        Data_i  : in std_logic_vector(N_g-1 downto 0);
        Data_o  : out std_logic_vector(N_g-1 downto 0)
        );
  end component;

 -- signaux internes
  signal Data_Thr_s         : std_logic_vector(Data_i'range);
  signal Abs_Comp_s         : std_logic_vector(Data_i'range);
  signal Data_Comp_s        : std_logic_vector(Data_i'range);
  signal En_s				: std_logic; 
  
begin -- Comport

  Data_Comp_s <= (others => '0') when Init_i = '1' else
				 Data_i;
  En_s <=  '1' when Init_i = '1' else
           Cap_Thr_Wr_i;
 
  
  U0:   SRGN generic map(N_g => N_g)
                port map(Clock_i => Clock_i,
                         Reset_i => Reset_i,
                         En_i    => En_s,
                         Data_i  => Data_Comp_s,
                         Data_o  => Data_Thr_s);
                         
                          
-- Comparaison des Data avec la valeur de seuil Data_Thr_s
   
  Abs_Comp_s <= (others => '0') when unsigned(Data_Thr_s) = To_Unsigned(0,N_g) else 
                std_logic_vector(unsigned(Data_Thr_s) - unsigned(Data_Comp_s)) when unsigned(Data_Thr_s) > unsigned(Data_Comp_s) else
                std_logic_vector(unsigned(Data_Comp_s) - unsigned(Data_Thr_s));
  
  Det_Finger_o <= '0' when unsigned(Abs_Comp_s) < To_Unsigned(Step_With_finger_c,N_g) else
                  '1';
                  
end Struct_Comport;

------------
------------


