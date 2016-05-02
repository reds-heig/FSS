-------------------------------------------------------------------
-- FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) --
--  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  --
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity fli_socket is
  port (
    clk_i           : in  std_logic;
    rst_i           : in  std_logic;
    irq_received_i  : in  std_logic;
    data_read_i     : in  std_logic_vector(15 downto 0);
    datavalid_read_i: in  std_logic;
    wr_o            : out std_logic;
    rd_o            : out std_logic;
    write_addr_o    : out std_logic_vector(24 downto 0);
    read_addr_o     : out std_logic_vector(24 downto 0);
    write_data_o    : out std_logic_vector(15 downto 0)
  );
end fli_socket;

architecture fli of fli_socket is

  attribute foreign : string;
  attribute foreign of fli : architecture is "fss_init ./fss.so;";

begin
  assert FALSE report "*** FSS FLI failure ***" severity failure;

end fli;
