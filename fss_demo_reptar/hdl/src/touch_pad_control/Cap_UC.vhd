------------------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- Institut REDS
--
-- Fichier :  Cap_UC.vhd
-- Auteur  :  H. Truong
-- Date    :  08.02.2013
--
-- Utilise dans   : Projet touch control pad
--                  
------------------------------------------------------------------------------------------
-- Fonctionnement vu de l'exterieur : unite de command du touch pad  
--                                   
--   Entree:
--     Reset_i                  Reset asynchrone, actif haut
--     Clock_i                  Horloge
--     Cap_Det_Finger_i         detection du doigt
--     Mem_Full_i               memoire du filtre est plein 
--     Timer_Cap_Off_Done_i     la capacite est decharge
--     Cap_i                    la capacite est charge
--     Time_Out_i               le temps pour charger la capacite est termine
--   Sorties:
--     TPB_Det_Finger_o         Detection du doigt pour allume un Led
--     Cmd_Cap_o                quand Cmd_Cap_o est actif on charge la capacite sinon on 
--                              decharge la capacite
--     Timer_Start_nStop_o      Si actif on demarre le timer sinon on maintien le temps mesure.
--     Mode_CapOn_nCapOff_o     Si actif on mesure le temps de charge de la capacite sinon on 
--                              mesure le temps de decharge
--     Timer_Init_o             initialisation du timer         
--     Pin_Filter_Init_o        initialisation du pin filter 
--     Filter_Init_o            initialisation du filtre
--     Capt_Finger_Init_o       initialisation di bloc de decision si il y a le doigt 
--     Reg_Cap_Thr_Wr_o         ecriture de la valeur de seuil dans un registre
--     Reg_Filter_Wr_o	        ecriture dans le registre du filtre
------------------------------------------------------------------------------------------
-- Ver  Date        Qui  Commentaires
-- 1.0  See header  HTG  Version initiale
-- 1.1  04.03.2013	ELR  Ajout entrée enable
-- 
-- 
--                      
------------------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Cap_UC is
  port( 
    Clock_i                 : in std_logic;
    Reset_i                 : in std_logic;
	En_i                 	: in std_logic;
    Cap_Det_Finger_i        : in std_logic;
    Mem_Full_i              : in std_logic;
    Timer_Cap_Off_Done_i    : in std_logic;
    Cap_i                   : in std_logic;
    Time_Out_i              : in std_logic;
    TPB_Det_Finger_o        : out std_logic;
    Cmd_Cap_o               : out std_logic;
    Timer_Start_nStop_o     : out std_logic;
    Mode_CapOn_nCapOff_o    : out std_logic;
    Timer_Init_o            : out std_logic;
    Pin_Filter_Init_o       : out std_logic; --
	Filter_init_o			: out std_logic;
	Capt_Finger_Init_o		: out std_logic;
    Reg_Cap_Thr_Wr_o        : out std_logic;
    Reg_Filter_Wr_o         : out std_logic
   );
end Cap_UC ;

architecture M_Etat of Cap_UC is

   -- Architecture Declarations
   type Type_Etat is (
	  Init,
      Ph1_Init,
      Ph1_Cap_Unload_To_Load,
      Ph1_Cap_Load,
      Ph1_New_Data_Fifo,
      Ph1_Cap_Load_To_Unload_Init_Timer,
      Ph1_Cap_Load_To_Unload_Wait_Done,
      Save_Cap_Thr,
      Ph2_Init_Timer,
      Ph2_Cap_Unload_To_Load,
      Ph2_Cap_Load,
      Ph2_New_Data_Fifo,
      Ph2_Cap_Load_To_Unload_Init_Timer,
      Ph2_Cap_Load_To_Unload_Wait_Done,
      Ph3_Det_Finger_Init_Timer,
      Ph3_Cap_Unload_To_Load,
      Ph3_Cap_Load,
      Ph3_New_Data,
      Ph3_Cap_Load_To_Unload_Init_Timer,
      Ph3_Cap_Load_To_Unload_Wait_Done,
      Det_Error
   );

  signal Etat_Pres, Etat_Fut : Type_Etat ;
  signal Cmd_Cap_s 	: std_logic;
  
  
begin -- M_Etat

  --| Registre d'Etat |-----------------------------------------------------
  Mem : process( Clock_i, Reset_i )
  begin
    if Reset_i = '1' then
      Etat_Pres <= Init;
    elsif rising_edge(Clock_i) then
      Etat_Pres <= Etat_Fut;
    end if;
  end process;


  --| decodeur d'etat futur et de sortie |----------------------------------
  --Dec_Fut: process (Etat_Pres,Cap_Det_Finger_i, Cap_i,Timer_Cap_Off_Done_i, Mem_Full_i, Time_Out_i)
  Dec_Fut: process (Etat_Pres,Cap_Det_Finger_i, Cap_i, Timer_Cap_Off_Done_i, Mem_Full_i, Time_Out_i,En_i)
  begin

    -- Valeur par defaut des sorties
    Cmd_Cap_s                  <= '0'; -- sans aleas  --> post synchronisation si necessaire
	Filter_Init_o			   <= '0';
	Capt_Finger_Init_o		   <= '0';
    Timer_Init_o               <= '1';
    Pin_Filter_Init_o          <= '0';
    Mode_CapOn_nCapOff_o       <= '0';
    Timer_Start_nStop_o        <= '0';
    Reg_Filter_Wr_o            <= '0';
    Reg_Cap_Thr_Wr_o           <= '0';
    TPB_Det_Finger_o           <= '0';
	
	
   
	

    -- L'etat futur par defaut est Det_Error.
    -- Toutes les transitions doivent donc etre explicites (en particulier le maintient).
    Etat_Fut <= Det_Error;

    case Etat_Pres is
    -------------------------------------------------------------------------
    --| Initialisation |------------------------------------
	when Init =>
	  Filter_Init_o <= '1';
      Pin_Filter_Init_o <= '1';
	  Capt_Finger_Init_o <= '1';
	-- ELR: ajout enable le 04.03.2013 ------------  
	  if En_i = '1' then
		Etat_Fut <= Ph1_Init;
	  else
	    Etat_Fut <= Init;
	  end if;
	--------------------------------------------------  
    when Ph1_Init =>
     --   Timer_Init_o <= '1';
      Etat_Fut <= Ph1_Cap_Unload_To_Load;
    when Ph1_Cap_Unload_To_Load =>
      Cmd_Cap_s <= '1';
      Timer_Init_o <= '0';
      Mode_CapOn_nCapOff_o <= '1';
      Timer_Start_nStop_o <= '1';
	  
      if Cap_i = '1' or Time_Out_i='1' then
        Etat_Fut <= Ph1_Cap_Load;
      else
        Etat_Fut <= Ph1_Cap_Unload_To_Load;
      end if;
    when Ph1_Cap_Load =>
      -- Cmd_Cap_o <= '0';
      Timer_Init_o <= '0';
      -- Timer_Start_nStop_o <= '0';
      Mode_CapOn_nCapOff_o <= '1';
	
	  Etat_Fut <= Ph1_New_Data_Fifo;
    when Ph1_New_Data_Fifo =>
      -- Cmd_Cap_o <= '0';
      Timer_Init_o <= '0';
      -- Timer_Start_nStop_o <= '0';
      Mode_CapOn_nCapOff_o <= '1';
      Reg_Filter_Wr_o <= '1';
      Etat_Fut <= Ph1_Cap_Load_To_Unload_Init_Timer;
    when Ph1_Cap_Load_To_Unload_Init_Timer =>
      -- Cmd_Cap_o <= '0';
      -- Timer_Init_o <= '1';
      -- Timer_Start_nStop_o <= '0';
      -- Mode_CapOn_nCapOff_o <= '0';
      -- Reg_Filter_Wr_o <= '0';
      Etat_Fut <= Ph1_Cap_Load_To_Unload_Wait_Done;
    when Ph1_Cap_Load_To_Unload_Wait_Done =>
      -- Cmd_Cap_o <= '0';
      Timer_Init_o <= '0';
      Timer_Start_nStop_o <= '1';
      -- Mode_CapOn_nCapOff_o <= '0';
      -- Reg_Filter_Wr_o <= '0';
	  
      if Mem_Full_i='0' and Timer_Cap_Off_Done_i = '1' then
	  --if Mem_Full_i='0' then
        Etat_Fut <= Ph1_Init;
      elsif Mem_Full_i='1' and Timer_Cap_Off_Done_i = '1' then
	  --elsif Mem_Full_i='1' then
        Etat_Fut <= Save_Cap_Thr;
	  else
	    Etat_Fut <= Ph1_Cap_Load_To_Unload_Wait_Done; -- il vas jamais 
      end if;
	when Save_Cap_Thr =>
	  -- Cmd_Cap_o <= '0';
      -- Timer_Init_o <= '1';
      -- Mode_CapOn_nCapOff_o <= '0';
      -- Timer_Start_nStop_o <= '0';
      -- Reg_Filter_Wr_o <= '0';
      Reg_Cap_Thr_Wr_o <= '1';
      -- TPB_Det_Finger_o <= '0';
      Etat_Fut <= Ph2_Init_Timer;
    when Ph2_Init_Timer =>
      -- Cmd_Cap_o <= '0';
      Timer_Init_o <= '1';
      -- Mode_CapOn_nCapOff_o <= '0';
      -- Timer_Start_nStop_o <= '0';
      -- Reg_Filter_Wr_o <= '0';
      -- Reg_Cap_Thr_wr_o <= '0';
      
	 
      Etat_Fut <= Ph2_Cap_Unload_To_Load;
    when Ph2_Cap_Unload_To_Load =>
      Cmd_Cap_s <= '1';
      Timer_Init_o <= '0';
      Timer_Start_nStop_o <= '1';
      Mode_CapOn_nCapOff_o <= '1';
      -- Reg_Filter_Wr_o <= '0';
      -- TPB_Det_Finger_o <= '0';
	 
      if Cap_i = '1' or Time_Out_i = '1' then
        Etat_Fut <= Ph2_Cap_Load;
      else
        Etat_Fut <= Ph2_Cap_Unload_To_Load;
      end if;
    when Ph2_Cap_Load =>
      -- Cmd_Cap_o <= '0';
      Timer_Init_o <= '0';
      -- Timer_Start_nStop_o <= '0';
      Mode_CapOn_nCapOff_o <= '1';
      -- TPB_Det_Finger_o <= '0';
	 
      Etat_Fut <= Ph2_New_Data_Fifo;
    when Ph2_New_Data_Fifo =>
      -- Cmd_Cap_o <= '0';
      Timer_Init_o <= '0';
      -- Timer_Start_nStop_o <= '0';
      Mode_CapOn_nCapOff_o <= '1';
       --TPB_Det_Finger_o <= '0';
      Reg_Filter_wr_o <= '1';
    
      Etat_Fut <= Ph2_Cap_Load_To_Unload_Init_Timer;
    when Ph2_Cap_Load_To_Unload_Init_Timer =>
      -- Cmd_Cap_Cap_o <='0';
      -- Timer_Init_o <= '1';
      -- Mode_CapOn_nCapOff_o <= '0';
      -- Timer_Start_nStop_o <= '0';
      -- Reg_Filter_Wr_o <= '0';
      -- Reg_Cap_Thr_Wr_o <= '0';
     
	 
      Etat_Fut <= Ph2_Cap_Load_To_Unload_Wait_Done;
    when Ph2_Cap_Load_To_Unload_Wait_Done =>
      -- Cmd_Cap_o <= '0';
      Timer_Init_o <= '0';
      -- Mode_CapOn_nCapOff_o <='0';
      Timer_Start_nStop_o <= '1';
      -- Reg_Filter_Wr_o <= '0';
      -- Reg_Cap_Thr_o <= '0';
      -- TPB_Det_Finger_o <= '0';
	 
      if Cap_Det_Finger_i = '1' and Timer_Cap_Off_Done_i = '1' then
        Etat_Fut <= Ph3_Det_Finger_Init_Timer;
      elsif Cap_Det_Finger_i = '0' and Timer_Cap_Off_Done_i = '1' then
        Etat_Fut <= Ph2_Init_Timer;
      else
        Etat_Fut <= Ph2_Cap_Load_To_Unload_Wait_Done; -- il vas jamais
      end if;
    when Ph3_Det_Finger_Init_Timer =>
      -- Cmd_Cap_o <= '0';
      -- Timer_Init_o <= '1';
      -- Mode_CapOn_nCapOff_o <= '0';
      -- Timer_Start_nStop_o <= '0';
      -- Reg_Filter_Wr_o <= '0';
      -- Reg_Cap_OS_Wr_o <= '0';
      TPB_Det_Finger_o <= '1';
      Etat_Fut <= Ph3_Cap_Unload_To_Load;
    when Ph3_Cap_Unload_To_Load =>
      Cmd_Cap_s <= '1';
      Timer_Init_o <= '0';
      Mode_CapOn_nCapOff_o <= '1';
      Timer_Start_nStop_o <= '1';
      -- Reg_Filter_Wr_o <= '0';
      -- Reg_Cap_Thr_Wr_o <= '0';
      TPB_Det_Finger_o <= '1';
      Etat_Fut <= Ph3_Cap_Load;
      if Cap_i = '1' or Time_Out_i = '1' then
        Etat_Fut <= Ph3_Cap_Load;
      else
        Etat_Fut <= Ph3_Cap_Unload_To_Load;
      end if;
      
    when Ph3_Cap_Load =>
      -- Cmd_Cap_o <= '0';
      Timer_Init_o <= '0';
      Mode_CapOn_nCapOff_o <= '1';
      -- Timer_Start_nStop_o <= '0';
      -- Reg_Filter_Wr_o <= '0';
      -- Reg_Cap_Thr_Wr_o <= '0';
      TPB_Det_Finger_o <= '1';
      Etat_Fut <= Ph3_New_Data;
    when Ph3_New_Data =>
      -- Cmd_Cap_o <= '0';
      Timer_Init_o <= '0';
      Mode_CapOn_nCapOff_o <= '1';
      -- Timer_Start_nStop_o <= '0';
      Reg_Filter_Wr_o <= '1';
      -- Reg_Cap_Thr_Wr_o <= '0';
      TPB_Det_Finger_o <= '1';
      Etat_Fut <= Ph3_Cap_Load_To_Unload_Init_Timer;
    when Ph3_Cap_Load_To_Unload_Init_Timer =>
      -- Cmd_Cap_o <= '0';
      -- Timer_Init_o <= '1';
      -- Mode_CapOn_nCapOff_o <= '0';
      -- Timer_Start_nStop_o <= '0';
      -- Reg_Filter_Wr_o <= '0';
      -- Reg_Cap_Thr_Wr_o <= '0';
      TPB_Det_Finger_o <= '1';
      Etat_Fut <= Ph3_Cap_Load_To_Unload_Wait_Done;
     
    when Ph3_Cap_Load_To_Unload_Wait_Done =>
      -- Cmd_Cap_o <= '0';
      Timer_Init_o <= '0';
      Timer_Start_nStop_o <= '1';
      -- Mode_CapOn_nCapOff_o <= '0';
      -- Reg_Filter_Wr_o <= '0';
      TPB_Det_Finger_o <= '1';
      if Cap_Det_Finger_i = '1' and Timer_Cap_Off_Done_i='1' then
	  --if Cap_Det_Finger_i = '1' then
        Etat_Fut <= Ph3_Det_Finger_Init_Timer;
      elsif Cap_Det_Finger_i = '0' and Timer_Cap_Off_Done_i='1' then
	  --elsif Cap_Det_Finger_i = '0' then
        Etat_Fut <= Ph2_Init_Timer;
      else
        Etat_Fut <= Ph3_Cap_Load_To_Unload_Wait_Done; -- il vas jamais
      end if;
    -------------------------------------------------------------------------
    --| Etat d'erreur |------------------------------------------------------
    when Det_Error =>
       TPB_Det_Finger_o <= '1';

    --| Autres cas |---------------------------------------------------------
    when others =>
      
    end case;
    
  end process;
  
  Cmd_Cap_o <= Cmd_Cap_s;
  
end M_Etat;
