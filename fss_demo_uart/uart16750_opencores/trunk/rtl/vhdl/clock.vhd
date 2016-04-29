-------------------------------------------------------------------
-- FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) --
-- Alberto Dassatti, Roberto Rigamonti, Xavier Ruppen - 10.2015	 --
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity clock is
  generic (
    PERIOD : time := 1000 ns
    );
  port (
    clk_o : out std_logic
    );
end clock;

architecture behaviour of clock is

  signal clk_s : std_logic := '0';

begin

  clk_s <= not clk_s after PERIOD;
  clk_o <= clk_s;

end behaviour;
