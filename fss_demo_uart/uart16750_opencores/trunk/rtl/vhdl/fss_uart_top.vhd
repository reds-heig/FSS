-------------------------------------------------------------------
-- FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) --
-- Alberto Dassatti, Roberto Rigamonti, Xavier Ruppen - 08.2015	 --
-------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fss_uart_top is

end fss_uart_top;

architecture behaviour of fss_uart_top is

  component uart_16750 is
    port (
      CLK        : in std_logic;                       -- Clock
      RST        : in std_logic;                       -- Reset
      BAUDCE     : in std_logic;                       -- Baudrate generator
                                                       -- clock enable
      CS         : in std_logic;                       -- Chip select
      WR         : in std_logic;                       -- Write to UART
      RD         : in std_logic;                       -- Read from UART
      A          : in std_logic_vector(2 downto 0);    -- Register select
      DIN        : in std_logic_vector(7 downto 0);    -- Data bus input
      DOUT       : out std_logic_vector(7 downto 0);   -- Data bus output
      DDIS       : out std_logic;                      -- Driver disable
      INT        : out std_logic;                      -- Interrupt output
      OUT1N      : out std_logic;                      -- Output 1
      OUT2N      : out std_logic;                      -- Output 2
      RCLK       : in std_logic;                       -- Receiver clock (16x
                                                       -- baudrate)
      BAUDOUTN   : out std_logic;                      -- Baudrate generator
                                                       -- output (16x baudrate)
      RTSN       : out std_logic;                      -- RTS output
      DTRN       : out std_logic;                      -- DTR output
      CTSN       : in std_logic;                       -- CTS input
      DSRN       : in std_logic;                       -- DSR input
      DCDN       : in std_logic;                       -- DCD input
      RIN        : in std_logic;                       -- RI input
      SIN        : in std_logic;                       -- Receiver input
      SOUT       : out std_logic                       -- Transmitter output
      );
  end component;

  component fli_socket is
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
  end component;

  component clock is
    port (
      clk_o : out std_logic
      );
  end component;

  component slib_clock_div is
    generic (
      RATIO       : integer := 18     -- Clock divider ratio
      );
    port (
      CLK         : in std_logic;     -- Clock
      RST         : in std_logic;     -- Reset
      CE          : in std_logic;     -- Clock enable input
      Q           : out std_logic     -- New clock enable output
      );
  end component;

  component or_rst is
    port (
      inA_i     : in  std_logic;
      inB_i     : in  std_logic;
      sys_rst_o : out std_logic
      );
  end component;

  --| Signals declarations   |--------------------------------------------------------------
  signal sys_clk_s   : std_logic;
  signal sys_rst_s   : std_logic;
  signal A_rst_s     : std_logic;
  signal B_rst_s     : std_logic;
  signal A_addr_s    : std_logic_vector(2 downto 0);
  signal B_addr_s    : std_logic_vector(2 downto 0);
  signal A_in_s      : std_logic_vector(7 downto 0);
  signal B_in_s      : std_logic_vector(7 downto 0);
  signal A_wr_s      : std_logic;
  signal B_wr_s      : std_logic;
  signal A_rd_s      : std_logic;
  signal B_rd_s      : std_logic;

  signal A_out_s     : std_logic_vector(7 downto 0);
  signal B_out_s     : std_logic_vector(7 downto 0);
  signal A_irq_s     : std_logic;
  signal B_irq_s     : std_logic;

  signal A_cs_s      : std_logic;
  signal B_cs_s      : std_logic;
  signal A_baudce_s  : std_logic;
  signal B_baudce_s  : std_logic;

  signal A_ddis_s    : std_logic;
  signal B_ddis_s    : std_logic;
  signal A_out1N_s   : std_logic;
  signal B_out1N_s   : std_logic;
  signal A_out2N_s   : std_logic;
  signal B_out2N_s   : std_logic;
  signal A_dtrN_s    : std_logic;
  signal B_dtrN_s    : std_logic;
  signal A_riN_s     : std_logic;
  signal B_riN_s     : std_logic;

  -- Links between UARTs
  signal A_ctsN_s    : std_logic;
  signal B_ctsN_s    : std_logic;
  signal A_tx_s      : std_logic;
  signal B_tx_s      : std_logic;
  signal A_rclk_s    : std_logic;
  signal B_rclk_s    : std_logic;

  signal baudce_s    : std_logic;

  for fli_A : fli_socket use entity
    work.fli_socket(endpoint_A);
  for fli_B : fli_socket use entity
    work.fli_socket(endpoint_B);

begin

  -- Baudrate generator clock enable
  BGCE: slib_clock_div generic map (RATIO => 18) port map (sys_clk_s, sys_rst_s, '1', baudce_s);

  u_clk : clock
    port map (
      clk_o => sys_clk_s
      );

  u_reset : or_rst
    port map (
      inA_i     => A_rst_s,
      inB_i     => B_rst_s,
      sys_rst_o => sys_rst_s
      );

  fli_A : fli_socket
    port map (
      -- FLI -> VHDL model
      rst_o       => A_rst_s,
      addr_o      => A_addr_s,
      data_in_o   => A_in_s,
      wr_o        => A_wr_s,
      rd_o        => A_rd_s,
      -- VHDL model -> FLI
      clk_i       => sys_clk_s,
      data_out_i  => A_out_s,
      irq_i       => A_irq_s,
      -- Constant
      cs_o        => A_cs_s,
      baudce_o    => A_baudce_s,
      -- Ignored
      ddis_i      => A_ddis_s,
      out1N_i     => A_out1N_s,
      out2N_i     => A_out2N_s,
      riN_o       => A_riN_s
      );

  fli_B : fli_socket
    port map (
      -- FLI -> VHDL model
      rst_o       => B_rst_s,
      addr_o      => B_addr_s,
      data_in_o   => B_in_s,
      wr_o        => B_wr_s,
      rd_o        => B_rd_s,
      -- VHDL model -> FLI
      clk_i       => sys_clk_s,
      data_out_i  => B_out_s,
      irq_i       => B_irq_s,
      -- Constant
      cs_o        => B_cs_s,
      baudce_o    => B_baudce_s,
      -- Ignored
      ddis_i      => B_ddis_s,
      out1N_i     => B_out1N_s,
      out2N_i     => B_out2N_s,
      riN_o       => B_riN_s
      );

  uart_A : uart_16750
    port map (
      CLK        => sys_clk_s,
      RST        => sys_rst_s,
      BAUDCE     => baudce_s,
      CS         => A_cs_s,
      WR         => A_wr_s,
      RD         => A_rd_s,
      A          => A_addr_s,
      DIN        => A_in_s,
      DOUT       => A_out_s,
      DDIS       => A_ddis_s,
      INT        => A_irq_s,
      OUT1N      => A_out1N_s,
      OUT2N      => A_out2N_s,
      RCLK       => A_rclk_s,
      BAUDOUTN   => A_rclk_s,
      RTSN       => A_ctsN_s,
      DTRN       => A_dtrN_s,
      CTSN       => A_ctsN_s,
      DSRN       => A_dtrN_s,
      DCDN       => A_dtrN_s,
      RIN        => A_riN_s,
      SIN        => B_tx_s,
      SOUT       => A_tx_s
      );

  uart_B : uart_16750
    port map (
      CLK        => sys_clk_s,
      RST        => sys_rst_s,
      BAUDCE     => baudce_s,
      CS         => B_cs_s,
      WR         => B_wr_s,
      RD         => B_rd_s,
      A          => B_addr_s,
      DIN        => B_in_s,
      DOUT       => B_out_s,
      DDIS       => B_ddis_s,
      INT        => B_irq_s,
      OUT1N      => B_out1N_s,
      OUT2N      => B_out2N_s,
      RCLK       => B_rclk_s,
      BAUDOUTN   => B_rclk_s,
      RTSN       => B_ctsN_s,
      DTRN       => B_dtrN_s,
      CTSN       => B_ctsN_s,
      DSRN       => B_dtrN_s,
      DCDN       => B_dtrN_s,
      RIN        => B_riN_s,
      SIN        => A_tx_s,
      SOUT       => B_tx_s
      );

end behaviour;
