------------------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- Institut REDS
--
-- Fichier :  touch_pad_ctrl_pkg.vhd
-- Auteur  :  H. Truong
-- Date    :  11.12.2012
--
-- Utilise dans   : Projet touch control pad
------------------------------------------------------------------------------------------
-- Fonctionnement vu de l'exterieur : 
--   Paquetage des projets: Cap_Timer,Capt_Finger,Touch_Control_Pad_Top
--
------------------------------------------------------------------------------------------
-- Ver  Date        Qui  Commentaires
-- 0.0  See header  HTG  Version initiale pour le projet touch control pad
-- 
-- 
------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.LOG_pkg.all;

package touch_pad_ctrl_pkg is

  --| Definir les constantes necessaires au projet |-------------------

------------------------------------------------------------------------------------
-- From EPM-25-25 et valeur de la capacite C0,Cf,la R_pull_up et Rs
------------------------------------------------------------------------------------
  -- public:
  -- Periode de l'horloge du systeme => 
  --   - 5 MHz => 200 ns -- pour carte Altera
  --    25 MHz => 40 ns
  -- constant Periode_Clock_Sys_c : Time := 40 ns; -- pour carte altera
  constant Periode_Clock_Sys_c : Time := 40 ns; -- pour carte Reptar

  -- Temps du signal Cmd_Cap_o pour etre sur que la capacité sans ou avec le doigt est charge
  constant Time_Cmd_Cap_Load_c : Time := 1000 ns;

  -- Temps pour decharger la capacite (2 Cycle d'horloge sont deja compris par default = nbr d'etats avant de demaree le contage pour decharger)
  constant Time_Cap_unLoad_c : Time := 0 ns;  
  
  -- constant Epsilon 				: Time := 1 ns; -- delay minimal necessaire pour detecter le doigt (valeur > 0)
  constant Epsilon_c 				: Time := 0 ns; -- avec 0 ns est la limite de detection du doigt (pour le Test Bench)
  constant Time_Step_With_Finger_c	: Time := 100 ns;
  
 ------------------------------------------------------------------------------------
  -- private:
  -- Temps pour l'emulation de la presence ou absence du doigt
  -- constant Time_With_Finger_c 	: Time := Time_Cmd_Cap_Load_c *50;  -- pas utilise
  -- constant Time_Without_Finger_c : Time := Time_Cmd_Cap_Load_c *100; -- pas utilise

  -- Temps de charge de la capacite jusqu'à la detection de la FPGA ( emulation pour le test-bench!) sans le doigt
  constant Time_Cap_Load_Em_Without_Finger_c : Time := (Time_Cmd_Cap_Load_c * 2)/4;
  --constant Time_Cap_Load_Em_Without_Finger_c : Time := (Time_Cmd_Cap_Load_c * 2);

  -- Temps de charge de la capacite jusqu'à la detection de la FPGA ( emulation pour le test-bench!) avec le doigt
  
 
  constant Time_Cap_Load_Em_With_Finger_c : Time :=  Time_Cap_Load_Em_Without_Finger_c + Time_Step_With_Finger_c + Epsilon_c;  

  -- Temps de decharge de la capacite emule (pour le test-bench!) sans ou avec le doigt
  constant Time_Cap_unLoad_Em_c : Time := Time_Cap_unLoad_c;  
  
  
  
  -- Constant utilise dans le bloc Cap_Timer
  ------------------------------------------------------------------------------------------
  --Calcul attente pour charger la capacite sans ou avec le doigt
    
  constant Nbr_Att_Cap_Load_c : Positive := Time_Cmd_Cap_Load_c/Periode_Clock_Sys_c ;
  
  --Calcul attente pour decharger la capacite avec ou sens le doigt  si Time_Cap_unLoad_c > 0                       
  constant Nbr_Att_Cap_unLoad_c : Integer := Time_Cap_unLoad_c/Periode_Clock_Sys_c;
  
  -- Constant utilise dans le bloc Touch_Control_Pad_Top
  --------------------------------------------------------------------------------------------  
  --Calcul du nombre de la taille du Cap_timer
  constant Size_of_Timer_c : Positive := ilogup(Nbr_Att_Cap_Load_c);
  
  -- Constant utilise dans le bloc Capt_Finger
  ------------------------------------------------------------------------------------------
  --Step pour la decision s'il y a le doigt
  constant Step_With_Finger_c : Positive := (Time_Step_With_Finger_c * 4)/Periode_Clock_Sys_c;  -- a etablir
  
  -- Constant utilise pour le Test-Bench
  ------------------------------------------------------------------------------------------

  -- Calcul attente du signal Cmd_Cap pour decharge la capacite
  constant Nbr_Att_Cmd_Cap_unLoad_c : Integer := Time_Cap_unLoad_Em_c/Periode_Clock_Sys_c;
  
  -- Calcul attente pour charger la capacite jusqu'à la detection de la FPGA sans le doigt (pour le test-bench)  
  constant Nbr_Att_Cap_Load_Em_Without_Finger_c : Positive := Time_Cap_Load_Em_Without_Finger_c/Periode_Clock_Sys_c;
  -- Calcul attente pour charger la capacite jusqu'à la detection de la FPGA avec le doigt (pour le test-bench)  
  constant Nbr_Att_Cap_Load_Em_With_Finger_c : Positive := Time_Cap_Load_Em_With_Finger_c/Periode_Clock_Sys_c;
  
  -- taille du timer utilise pour le test bench
  constant N_tb_c : Positive := Size_of_Timer_c;

  
  -- Constant utilise pour le bloc Filter
  -------------------------------------------------------------------------------------------
  --calcul nombre de iteration pour faire un additioneur generique 
  --constant Size_Filter_c : Positive := 16;
  --constant N_it_c : Positive := ilogup(Size_Filter_c); -- 
---------------------------------------------------------------------------------------------

end touch_pad_ctrl_pkg;

package body touch_pad_ctrl_pkg is
end touch_pad_ctrl_pkg;





