-------------------------------------------------------------------
-- FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) --
-- Alberto Dassatti, Roberto Rigamonti, Xavier Ruppen - 10.2015	 --
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity or_rst is
  port (
      inA_i     : in  std_logic;
      inB_i     : in  std_logic;
      sys_rst_o : out std_logic
    );
end or_rst;

architecture behaviour of or_rst is

begin

  sys_rst_o <= inA_i or inB_i;

end behaviour;
