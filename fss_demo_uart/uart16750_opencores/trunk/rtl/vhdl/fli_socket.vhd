-------------------------------------------------------------------
-- FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) --
-- Alberto Dassatti, Roberto Rigamonti, Xavier Ruppen - 10.2015	 --
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity fli_socket is
  port (
    -- FLI -> VHDL model
    rst_o       : out std_logic;
    addr_o      : out std_logic_vector(2 downto 0);
    data_in_o   : out std_logic_vector(7 downto 0);
    wr_o        : out std_logic;
    rd_o        : out std_logic;
    -- VHDL model -> FLI
    clk_i       : in  std_logic;
    data_out_i  : in  std_logic_vector(7 downto 0);
    irq_i       : in  std_logic;
    -- Constant
    cs_o        : out std_logic;
    baudce_o    : out std_logic;
    -- Ignored
    ddis_i      : in  std_logic;
    out1N_i     : in  std_logic;
    out2N_i     : in  std_logic;
    riN_o       : out std_logic
    );
end fli_socket;

architecture endpoint_A of fli_socket is

  attribute foreign : string;
  attribute foreign of endpoint_A : architecture is "fss_init ./A_fss.so; A";

begin
  assert FALSE report "*** FSS FLI failure ***" severity failure;

end endpoint_A;

architecture endpoint_B of fli_socket is

  attribute foreign : string;
  attribute foreign of endpoint_B : architecture is "fss_init ./B_fss.so; B";

begin
  assert FALSE report "*** FSS FLI failure ***" severity failure;

end endpoint_B;
