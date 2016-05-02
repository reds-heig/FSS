-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- Institut REDS
--
-- Fichier :  touch_pad_ctrl.vhd
-- Auteur  :  Hien Truong
-- Date    :  11.12.2012
--
-- Utilise dans   : projet REPTAR
-----------------------------------------------------------------------
-- Fonctionnement vu de l'exterieur : donne l'ordre de charger ou decharger 
--                                    la capacite du touch pad et fourni l'information si on
--                                    a detecte le doigt ou non.
--   Generic:
--     N_g                      taille du timer
--   Entree:
--     reset_i                  Reset asynchrone, actif haut
--     clock_i                  Horloge
--     cap_i                    Quand la FPGA voit la capacite chargée alors cap_i = '1'
--     tpb_det_finger_o         Detection du doigt
--                               
--   Sorties:
--     tpb_det_finger_o         Detection de la presence du doigt     
-----------------------------------------------------------------------
-- Ver    Date          Qui  Commentaires
-- 0.0    see header    HTG  Version initiale
-- 0.1    08.02.2013    HTG  Ajout de Pin_Filter
-- 0.2    04.03.2013	ELR  Ajout entrée enable

-----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity touch_pad_ctrl is
  generic(
     N_Top_g : positive range 1 to 32 := 3);  -- valeur par default
  port( 
        clock_i                 : in    std_logic;
        reset_i                 : in    std_logic;
        -- to/from LBA SP6 registers
        en_i					: in    std_logic;
        tpb_det_finger_o        : out   std_logic;
        -- to/from open collector on top level
        cap_i					: in 	std_logic;
        cmd_cap_o				: out	std_logic
  );
end touch_pad_ctrl;

architecture Struct of touch_pad_ctrl is

  component Cap_UC
    port(
      clock_i               : in  std_logic;
      reset_i               : in  std_logic;
	  en_i					: in  std_logic;
      Cap_Det_Finger_i      : in  std_logic;
      Mem_Full_i            : in  std_logic;
      Timer_Cap_Off_Done_i  : in  std_logic;
      Time_Out_i            : in  std_logic;
      cap_i                 : in  std_logic;
      tpb_det_finger_o      : out std_logic;
      cmd_cap_o             : out std_logic;
      Timer_Start_nStop_o   : out std_logic;
      Mode_CapOn_nCapOff_o  : out std_logic;
      Timer_Init_o          : out std_logic;
      Pin_Filter_Init_o     : out std_logic; --
	  Filter_Init_o			: out std_logic;
	  Capt_Finger_Init_o    : out std_logic;
      Reg_Cap_Thr_Wr_o      : out std_logic;
      Reg_Filter_Wr_o       : out std_logic
    );
  end component; -- Cap_UC
  
  component Pin_Filter is
  port (
        clock_i    : in std_logic;
        reset_i    : in std_logic;
		Init_i	   : in std_logic;
        Data_i     : in  std_logic;
        Data_o     : out std_logic
		); 
  end component; -- Pin_Filter
  
  component Cap_Timer
    generic(
      N_g: positive range 1 to 32);
    port (
      clock_i               : in std_logic;
      reset_i               : in std_logic;
      Start_nStop_i         : in std_logic;
      Init_i                : in std_logic;
      Mode_CapOn_nCapOff_i  : in std_logic;
      Cpt_Timer_o           : out std_logic_vector(N_g-1 downto 0);
      Time_Out_o            : out std_logic;
	  Cap_Off_Done_o		: out std_logic
    );
  end component; -- Cap_Timer

  component Filter
    generic(
      N_g: positive range 1 to 32);
    port(
      clock_i       : in std_logic;
      reset_i       : in std_logic;
	  Init_i	    : in std_logic;
      En_Wr_i       : in std_logic;
      Data_i        : in std_logic_vector(N_g-1 downto 0);
      Data_o        : out std_logic_vector(N_g+1 downto 0);
      Mem_Full_o    : out std_logic
    );
  end component; -- Filter
  
  for all : Filter use entity work.Filter;
  ---------
  
  component Capt_Finger
    generic(
      N_g: positive range 1 to 32);
    port(
      clock_i       : in std_logic;
      reset_i       : in std_logic;
	  Init_i		: in std_logic;
      Cap_Thr_Wr_i  : in std_logic;
      Data_i        : in std_logic_vector(N_g-1 downto 0);
      Det_Finger_o  : out std_logic
    );
  end component; -- Capt_Finger

  --signal Reset_s                : std_logic;
  signal Cap_Det_Finger_s       : std_logic;
  signal Mem_Full_s             : std_logic;
  signal Timer_Cap_Off_Done_s   : std_logic;
  signal Time_Out_s             : std_logic;
  signal Cap_s                  : std_logic;
  signal Timer_Start_nStop_s    : std_logic;
  signal Mode_CapOn_nCapOff_s   : std_logic;
  signal Timer_Init_s           : std_logic;
  signal Filter_Init_s			: std_logic;
  signal Reg_Cap_Thr_Wr_s       : std_logic;
  signal Reg_Filter_Wr_s        : std_logic;
  signal Cpt_Timer_s            : std_logic_vector(N_Top_g-1 downto 0);
  signal Data_s                 : std_logic_vector(N_Top_g+1 downto 0);
  signal Capt_Finger_Init_s		: std_logic;
  signal Pin_Filter_Init_s		: std_logic;

begin

  U0_Cap_Uc: Cap_UC 
  port map(
    clock_i                 => clock_i,
    reset_i                 => reset_i,
	en_i					=> en_i,
    Cap_Det_Finger_i        => Cap_Det_Finger_s,
    Mem_Full_i             	=> Mem_Full_s,
    Timer_Cap_Off_Done_i    => Timer_Cap_Off_Done_s,
    Time_Out_i              => Time_Out_s,
    cap_i                   => Cap_s,
    tpb_det_finger_o        => tpb_det_finger_o,
    cmd_cap_o               => cmd_cap_o,
    Timer_Start_nStop_o     => Timer_Start_nStop_s,
    Mode_CapOn_nCapOff_o    => Mode_CapOn_nCapOff_s,
    Timer_Init_o            => Timer_Init_s,
    Pin_Filter_Init_o       => Pin_Filter_Init_s, --
	Filter_Init_o			=> Filter_Init_s,
	Capt_Finger_Init_o		=> Capt_Finger_Init_s,
    Reg_Cap_Thr_Wr_o        => Reg_Cap_Thr_Wr_s,
    Reg_Filter_Wr_o         => Reg_Filter_Wr_s
  );
  
    
  U1_Cap_Timer: Cap_Timer
  generic map(N_g => N_Top_g)
  port map(
    clock_i                 => clock_i,
    reset_i                 => reset_i,
    Start_nStop_i           => Timer_Start_nStop_s,
    Init_i                  => Timer_Init_s,      
    Mode_CapOn_nCapOff_i    => Mode_CapOn_nCapOff_s,
    Cpt_Timer_o             => Cpt_Timer_s,
    Time_Out_o              => Time_Out_s,
	Cap_Off_Done_o			=> Timer_Cap_Off_Done_s
  );
  
  U2_Filter: Filter
  generic map(N_g => N_Top_g)
  port map(
    clock_i     => clock_i,
    reset_i     => reset_i,
	Init_i		=> Filter_Init_s,
    En_Wr_i     => Reg_Filter_Wr_s,
    Data_i      => Cpt_Timer_s,
    Mem_Full_o  => Mem_Full_s,
    Data_o      => Data_s
  );
  
  U3_Capt_Finger: Capt_Finger
  generic map(N_g => N_Top_g + 2)
  port map(
    clock_i         => clock_i,
    reset_i         => reset_i,
	Init_i			=> Capt_Finger_Init_s,
    Cap_Thr_Wr_i    => Reg_Cap_Thr_Wr_s,
    Data_i          => Data_s,
    Det_Finger_o    => Cap_Det_Finger_s
  );
  
  U4_Pin_Filter: Pin_Filter
  port map(
    clock_i  => clock_i,
    reset_i  => reset_i,
    Init_i   => Pin_Filter_Init_s,
    Data_i   => cap_i,
    Data_o   => Cap_s
  ); 
  
end architecture Struct;