-------------------------------------------------------------------
-- FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) --
--  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  --
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity fli_gui is
  port (
    -- FLI -> VHDL model
    -- SWITCH PB
    SW_PB_o		  : out std_logic_vector(8 downto 1);
    -- VHDL model -> FLI
    --LEDs
    FPGA_LED_i		  : in std_logic_vector(7 downto 0);
    --7SEG
    SP6_7seg1_i		  : in std_logic_vector(6 downto 0);
    SP6_7seg2_i		  : in std_logic_vector(6 downto 0);
    SP6_7seg3_i		  : in std_logic_vector(6 downto 0);
    SP6_7seg1_DP_i	  : in std_logic; -- Decimal Point
    SP6_7seg2_DP_i	  : in std_logic;
    SP6_7seg3_DP_i	  : in std_logic;
    --LCD
    -- TODO: we have to simulate the actual LCD here. Maybe in the future?
    -- See SEEE's reptar_sp6_clcd.h/.c for inspiration.
    LCD_DB_io		  : inout std_logic_vector(7 downto 0); -- bidirectional data port
    LCD_R_nW_i		  : in std_logic; -- read/write
    LCD_RS_i		  : in std_logic; -- reset
    LCD_E_i		  : in std_logic -- enable
    );
end fli_gui;

architecture gui of fli_gui is

  attribute foreign of gui : architecture is "fss_gui_init ./fss_gui.so";

begin
  assert FALSE report "*** FSS GUI FLI failure ***" severity failure;

end gui;
