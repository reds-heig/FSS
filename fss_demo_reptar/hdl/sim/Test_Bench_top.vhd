-------------------------------------------------------------------
-- FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) --
--  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  --
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

--use ieee.std_logic_unsigned.all;
use work.objection_pkg.all;
--use ieee.std_logic_arith.all;

entity Test_Bench_top is
  generic(
    constant GPMC_to_FPGA_Latency	: time:=7 ns;	-- Latency
    constant FPGA_to_GPMC_Latency	: time:=7 ns	-- Latency
    );
end  Test_Bench_top;

architecture behave of Test_Bench_top is

  signal External_100Mhz_Clk_sti      : std_logic;
  signal GPMC_Clk_25MHz_sti	      : std_logic;
  signal GPMC_nReset_sti	      : std_logic;

  signal GPMC_LB_RE_nOE_sti	      : std_logic;
  signal GPMC_LB_RE_nOE_sti_delayed   : std_logic;

  signal GPMC_LB_nWE_sti	      : std_logic;
  signal GPMC_LB_nWE_sti_delayed      : std_logic;

  signal GPMC_LB_nCS3_sti	      : std_logic;
  signal GPMC_LB_nCS3_sti_delayed     : std_logic;

  signal GPMC_LB_nCS4_sti	      : std_logic;
  signal GPMC_LB_nCS4_sti_delayed     : std_logic;

  signal GPMC_LB_nADV_ALE_sti	      : std_logic;
  signal GPMC_LB_nADV_ALE_sti_delayed : std_logic;

  signal GPMC_LB_nBE0_CLE_sti	      : std_logic;
  signal GPMC_LB_nBE0_CLE_sti_delayed : std_logic;

  signal GPMC_LB_CLK_sti	      : std_logic;
  signal GPMC_LB_CLK_sti_delayed      : std_logic;

  signal GPMC_DIP_sti		      : std_logic_vector (9 downto 0);
  signal GPMC_DIP_sti_delayed	      : std_logic_vector (9 downto 0);

  signal GPMC_Addr_Data_LB_io_sti     : std_logic_vector(15 downto 0);
  signal GPMC_Addr_LB_sti	      : std_logic_vector(24 downto 16);

-- Spartan 6 signals
  signal SP6_LB_WAIT3_sti	  : std_logic;
  signal SP6_LB_WAIT3_sti_delayed : std_logic;

  signal SP6_LB_WAIT0_sti	  : std_logic;
  signal SP6_LB_WAIT0_sti_delayed : std_logic;

  signal End_of_sim		  : std_logic;
  signal TestBenchDelay_s	  : integer;

-- Cmd Async signals -- used by FLI
  signal Cmd_clk_s            : std_logic;
  signal Cmd_nReset_s         : std_logic;
  signal Cmd_single_write_s   : std_logic:='0';
  signal Cmd_addr_write_s     : std_logic_vector (24 downto 0):= (others => '0');
  signal Cmd_data_write_s     : std_logic_vector (15 downto 0):= (others => '0');
  signal Cmd_single_read_s    : std_logic:='0';
  signal Cmd_addr_read_s      : std_logic_vector (24 downto 0):= (others => '0');
  signal Cmd_data_read_s      : std_logic_vector (15 downto 0);
  signal Cmd_datavalid_read_s : std_logic;
  signal Cmd_irq_received_s   : std_logic;

-- FLI GUI
  signal SW_PB_sti : std_logic_vector(8 downto 1);
  signal FPGA_LED_sti : std_logic_vector(7 downto 0);
  signal SP6_7seg1_sti : std_logic_vector(6 downto 0);
  signal SP6_7seg2_sti : std_logic_vector(6 downto 0);
  signal SP6_7seg3_sti : std_logic_vector(6 downto 0);
  signal SP6_7seg1_DP_sti : std_logic;
  signal SP6_7seg2_DP_sti : std_logic;
  signal SP6_7seg3_DP_sti : std_logic;
  signal LCD_DB_sti : std_logic_vector(7 downto 0);
  signal LCD_R_nW_sti : std_logic;
  signal LCD_RS_sti : std_logic;
  signal LCD_E_sti : std_logic;

begin
-- simulates the FPGA design delay link to the routing.
-- The TestBenchDelay_s signal is there to gradually increase the latency,
-- to simulate worst cases cenarios, where the rising_edge is happening just before data change

  GPMC_LB_RE_nOE_sti_delayed	  <=  GPMC_LB_RE_nOE_sti'delayed(GPMC_to_FPGA_Latency)		when TestBenchDelay_s=0 else
				      GPMC_LB_RE_nOE_sti'delayed(GPMC_to_FPGA_Latency +0.5 ns)	when TestBenchDelay_s=1 else
				      GPMC_LB_RE_nOE_sti'delayed(GPMC_to_FPGA_Latency +1 ns)	when TestBenchDelay_s=2 else
				      GPMC_LB_RE_nOE_sti'delayed(GPMC_to_FPGA_Latency +1.5 ns)	when TestBenchDelay_s=3 else
				      GPMC_LB_RE_nOE_sti'delayed(GPMC_to_FPGA_Latency +2 ns)	when TestBenchDelay_s=4 else
				      GPMC_LB_RE_nOE_sti'delayed(GPMC_to_FPGA_Latency +2.5 ns)	when TestBenchDelay_s=5 else
				      GPMC_LB_RE_nOE_sti'delayed(GPMC_to_FPGA_Latency +3 ns)	when TestBenchDelay_s=6 else
				      GPMC_LB_RE_nOE_sti'delayed(GPMC_to_FPGA_Latency +3.5 ns)	when TestBenchDelay_s=7 else
				      GPMC_LB_RE_nOE_sti'delayed(GPMC_to_FPGA_Latency +4 ns)	when TestBenchDelay_s=8 else
				      GPMC_LB_RE_nOE_sti'delayed(GPMC_to_FPGA_Latency +4.5 ns)	when TestBenchDelay_s=9 else
				      GPMC_LB_RE_nOE_sti'delayed(GPMC_to_FPGA_Latency +5 ns)	when TestBenchDelay_s=10 else
				      GPMC_LB_RE_nOE_sti'delayed(GPMC_to_FPGA_Latency );

  GPMC_LB_nWE_sti_delayed	  <=  GPMC_LB_nWE_sti'delayed(GPMC_to_FPGA_Latency )	     when TestBenchDelay_s=0 else
				      GPMC_LB_nWE_sti'delayed(GPMC_to_FPGA_Latency +0.5 ns)  when TestBenchDelay_s=1 else
				      GPMC_LB_nWE_sti'delayed(GPMC_to_FPGA_Latency +1 ns)    when TestBenchDelay_s=2 else
				      GPMC_LB_nWE_sti'delayed(GPMC_to_FPGA_Latency +1.5 ns)  when TestBenchDelay_s=3 else
				      GPMC_LB_nWE_sti'delayed(GPMC_to_FPGA_Latency +2 ns)    when TestBenchDelay_s=4 else
				      GPMC_LB_nWE_sti'delayed(GPMC_to_FPGA_Latency +2.5 ns)  when TestBenchDelay_s=5 else
				      GPMC_LB_nWE_sti'delayed(GPMC_to_FPGA_Latency +3 ns)    when TestBenchDelay_s=6 else
				      GPMC_LB_nWE_sti'delayed(GPMC_to_FPGA_Latency +3.5 ns)  when TestBenchDelay_s=7 else
				      GPMC_LB_nWE_sti'delayed(GPMC_to_FPGA_Latency +4 ns)    when TestBenchDelay_s=8 else
				      GPMC_LB_nWE_sti'delayed(GPMC_to_FPGA_Latency +4.5 ns)  when TestBenchDelay_s=9 else
				      GPMC_LB_nWE_sti'delayed(GPMC_to_FPGA_Latency +5 ns)    when TestBenchDelay_s=10 else
				      GPMC_LB_nWE_sti'delayed(GPMC_to_FPGA_Latency );

  GPMC_LB_nCS3_sti_delayed	  <=  GPMC_LB_nCS3_sti'delayed(GPMC_to_FPGA_Latency )	      when TestBenchDelay_s=0 else
				      GPMC_LB_nCS3_sti'delayed(GPMC_to_FPGA_Latency +0.5 ns)  when TestBenchDelay_s=1 else
				      GPMC_LB_nCS3_sti'delayed(GPMC_to_FPGA_Latency +1 ns)    when TestBenchDelay_s=2 else
				      GPMC_LB_nCS3_sti'delayed(GPMC_to_FPGA_Latency +1.5 ns)  when TestBenchDelay_s=3 else
				      GPMC_LB_nCS3_sti'delayed(GPMC_to_FPGA_Latency +2 ns)    when TestBenchDelay_s=4 else
				      GPMC_LB_nCS3_sti'delayed(GPMC_to_FPGA_Latency +2.5 ns)  when TestBenchDelay_s=5 else
				      GPMC_LB_nCS3_sti'delayed(GPMC_to_FPGA_Latency +3 ns)    when TestBenchDelay_s=6 else
				      GPMC_LB_nCS3_sti'delayed(GPMC_to_FPGA_Latency +3.5 ns)  when TestBenchDelay_s=7 else
				      GPMC_LB_nCS3_sti'delayed(GPMC_to_FPGA_Latency +4 ns)    when TestBenchDelay_s=8 else
				      GPMC_LB_nCS3_sti'delayed(GPMC_to_FPGA_Latency +4.5 ns)  when TestBenchDelay_s=9 else
				      GPMC_LB_nCS3_sti'delayed(GPMC_to_FPGA_Latency +5 ns)    when TestBenchDelay_s=10 else
				      GPMC_LB_nCS3_sti'delayed(GPMC_to_FPGA_Latency );

  GPMC_LB_nCS4_sti_delayed	  <=  GPMC_LB_nCS4_sti'delayed(GPMC_to_FPGA_Latency )	      when TestBenchDelay_s=0 else
				      GPMC_LB_nCS4_sti'delayed(GPMC_to_FPGA_Latency +0.5 ns)  when TestBenchDelay_s=1 else
				      GPMC_LB_nCS4_sti'delayed(GPMC_to_FPGA_Latency +1 ns)    when TestBenchDelay_s=2 else
				      GPMC_LB_nCS4_sti'delayed(GPMC_to_FPGA_Latency +1.5 ns)  when TestBenchDelay_s=3 else
				      GPMC_LB_nCS4_sti'delayed(GPMC_to_FPGA_Latency +2 ns)    when TestBenchDelay_s=4 else
				      GPMC_LB_nCS4_sti'delayed(GPMC_to_FPGA_Latency +2.5 ns)  when TestBenchDelay_s=5 else
				      GPMC_LB_nCS4_sti'delayed(GPMC_to_FPGA_Latency +3 ns)    when TestBenchDelay_s=6 else
				      GPMC_LB_nCS4_sti'delayed(GPMC_to_FPGA_Latency +3.5 ns)  when TestBenchDelay_s=7 else
				      GPMC_LB_nCS4_sti'delayed(GPMC_to_FPGA_Latency +4 ns)    when TestBenchDelay_s=8 else
				      GPMC_LB_nCS4_sti'delayed(GPMC_to_FPGA_Latency +4.5 ns)  when TestBenchDelay_s=9 else
				      GPMC_LB_nCS4_sti'delayed(GPMC_to_FPGA_Latency +5 ns)    when TestBenchDelay_s=10 else
				      GPMC_LB_nCS4_sti'delayed(GPMC_to_FPGA_Latency );

  GPMC_LB_nADV_ALE_sti_delayed	  <=  GPMC_LB_nADV_ALE_sti'delayed(GPMC_to_FPGA_Latency )	  when TestBenchDelay_s=0 else
				      GPMC_LB_nADV_ALE_sti'delayed(GPMC_to_FPGA_Latency +0.5 ns)  when TestBenchDelay_s=1 else
				      GPMC_LB_nADV_ALE_sti'delayed(GPMC_to_FPGA_Latency +1 ns)	  when TestBenchDelay_s=2 else
				      GPMC_LB_nADV_ALE_sti'delayed(GPMC_to_FPGA_Latency +1.5 ns)  when TestBenchDelay_s=3 else
				      GPMC_LB_nADV_ALE_sti'delayed(GPMC_to_FPGA_Latency +2 ns)	  when TestBenchDelay_s=4 else
				      GPMC_LB_nADV_ALE_sti'delayed(GPMC_to_FPGA_Latency +2.5 ns)  when TestBenchDelay_s=5 else
				      GPMC_LB_nADV_ALE_sti'delayed(GPMC_to_FPGA_Latency +3 ns)	  when TestBenchDelay_s=6 else
				      GPMC_LB_nADV_ALE_sti'delayed(GPMC_to_FPGA_Latency +3.5 ns)  when TestBenchDelay_s=7 else
				      GPMC_LB_nADV_ALE_sti'delayed(GPMC_to_FPGA_Latency +4 ns)	  when TestBenchDelay_s=8 else
				      GPMC_LB_nADV_ALE_sti'delayed(GPMC_to_FPGA_Latency +4.5 ns)  when TestBenchDelay_s=9 else
				      GPMC_LB_nADV_ALE_sti'delayed(GPMC_to_FPGA_Latency +5 ns)	  when TestBenchDelay_s=10 else
				      GPMC_LB_nADV_ALE_sti'delayed(GPMC_to_FPGA_Latency );

  GPMC_LB_nBE0_CLE_sti_delayed	  <=  GPMC_LB_nBE0_CLE_sti'delayed(GPMC_to_FPGA_Latency )	  when TestBenchDelay_s=0 else
				      GPMC_LB_nBE0_CLE_sti'delayed(GPMC_to_FPGA_Latency +0.5 ns)  when TestBenchDelay_s=1 else
				      GPMC_LB_nBE0_CLE_sti'delayed(GPMC_to_FPGA_Latency +1 ns)	  when TestBenchDelay_s=2 else
				      GPMC_LB_nBE0_CLE_sti'delayed(GPMC_to_FPGA_Latency +1.5 ns)  when TestBenchDelay_s=3 else
				      GPMC_LB_nBE0_CLE_sti'delayed(GPMC_to_FPGA_Latency +2 ns)	  when TestBenchDelay_s=4 else
				      GPMC_LB_nBE0_CLE_sti'delayed(GPMC_to_FPGA_Latency +2.5 ns)  when TestBenchDelay_s=5 else
				      GPMC_LB_nBE0_CLE_sti'delayed(GPMC_to_FPGA_Latency +3 ns)	  when TestBenchDelay_s=6 else
				      GPMC_LB_nBE0_CLE_sti'delayed(GPMC_to_FPGA_Latency +3.5 ns)  when TestBenchDelay_s=7 else
				      GPMC_LB_nBE0_CLE_sti'delayed(GPMC_to_FPGA_Latency +4 ns)	  when TestBenchDelay_s=8 else
				      GPMC_LB_nBE0_CLE_sti'delayed(GPMC_to_FPGA_Latency +4.5 ns)  when TestBenchDelay_s=9 else
				      GPMC_LB_nBE0_CLE_sti'delayed(GPMC_to_FPGA_Latency +5 ns)	  when TestBenchDelay_s=10 else
				      GPMC_LB_nBE0_CLE_sti'delayed(GPMC_to_FPGA_Latency );

  GPMC_LB_CLK_sti_delayed	  <=  GPMC_LB_CLK_sti'delayed(GPMC_to_FPGA_Latency )	     when TestBenchDelay_s=0 else
				      GPMC_LB_CLK_sti'delayed(GPMC_to_FPGA_Latency +0.5 ns)  when TestBenchDelay_s=1 else
				      GPMC_LB_CLK_sti'delayed(GPMC_to_FPGA_Latency +1 ns)    when TestBenchDelay_s=2 else
				      GPMC_LB_CLK_sti'delayed(GPMC_to_FPGA_Latency +1.5 ns)  when TestBenchDelay_s=3 else
				      GPMC_LB_CLK_sti'delayed(GPMC_to_FPGA_Latency +2 ns)    when TestBenchDelay_s=4 else
				      GPMC_LB_CLK_sti'delayed(GPMC_to_FPGA_Latency +2.5 ns)  when TestBenchDelay_s=5 else
				      GPMC_LB_CLK_sti'delayed(GPMC_to_FPGA_Latency +3 ns)    when TestBenchDelay_s=6 else
				      GPMC_LB_CLK_sti'delayed(GPMC_to_FPGA_Latency +3.5 ns)  when TestBenchDelay_s=7 else
				      GPMC_LB_CLK_sti'delayed(GPMC_to_FPGA_Latency +4 ns)    when TestBenchDelay_s=8 else
				      GPMC_LB_CLK_sti'delayed(GPMC_to_FPGA_Latency +4.5 ns)  when TestBenchDelay_s=9 else
				      GPMC_LB_CLK_sti'delayed(GPMC_to_FPGA_Latency +5 ns)    when TestBenchDelay_s=10 else
				      GPMC_LB_CLK_sti'delayed(GPMC_to_FPGA_Latency );

  GPMC_DIP_sti_delayed		  <=  GPMC_DIP_sti'delayed(GPMC_to_FPGA_Latency )	  when TestBenchDelay_s=0 else
				      GPMC_DIP_sti'delayed(GPMC_to_FPGA_Latency +0.5 ns)  when TestBenchDelay_s=1 else
				      GPMC_DIP_sti'delayed(GPMC_to_FPGA_Latency +1 ns)	  when TestBenchDelay_s=2 else
				      GPMC_DIP_sti'delayed(GPMC_to_FPGA_Latency +1.5 ns)  when TestBenchDelay_s=3 else
				      GPMC_DIP_sti'delayed(GPMC_to_FPGA_Latency +2 ns)	  when TestBenchDelay_s=4 else
				      GPMC_DIP_sti'delayed(GPMC_to_FPGA_Latency +2.5 ns)  when TestBenchDelay_s=5 else
				      GPMC_DIP_sti'delayed(GPMC_to_FPGA_Latency +3 ns)	  when TestBenchDelay_s=6 else
				      GPMC_DIP_sti'delayed(GPMC_to_FPGA_Latency +3.5 ns)  when TestBenchDelay_s=7 else
				      GPMC_DIP_sti'delayed(GPMC_to_FPGA_Latency +4 ns)	  when TestBenchDelay_s=8 else
				      GPMC_DIP_sti'delayed(GPMC_to_FPGA_Latency +4.5 ns)  when TestBenchDelay_s=9 else
				      GPMC_DIP_sti'delayed(GPMC_to_FPGA_Latency +5 ns)	  when TestBenchDelay_s=10 else
				      GPMC_DIP_sti'delayed(GPMC_to_FPGA_Latency );

  SP6_LB_WAIT0_sti_delayed	  <=  SP6_LB_WAIT0_sti'delayed(FPGA_to_GPMC_Latency );

  SP6_LB_WAIT3_sti_delayed	  <=  SP6_LB_WAIT3_sti'delayed(FPGA_to_GPMC_Latency );

-- ==========================================
  FLI_Gui : entity work.fli_gui
-- ==========================================
    port map(
      -- FLI -> VHDL model
      -- SWITCH PB
      SW_PB_o	     => SW_PB_sti,
      -- VHDL model -> FLI
      --LEDs
      FPGA_LED_i     => FPGA_LED_sti,
      --7SEG
      SP6_7seg1_i    => SP6_7seg1_sti,
      SP6_7seg2_i    => SP6_7seg2_sti,
      SP6_7seg3_i    => SP6_7seg3_sti,
      SP6_7seg1_DP_i => SP6_7seg1_DP_sti,
      SP6_7seg2_DP_i => SP6_7seg2_DP_sti,
      SP6_7seg3_DP_i => SP6_7seg3_DP_sti,
      -- LCD
      -- TODO: we have to simulate the actual LCD here. Maybe in the future?
      -- See SEEE's reptar_sp6_clcd.h/.c for inspiration.
      LCD_DB_io	     => LCD_DB_sti,
      LCD_R_nW_i     => LCD_R_nW_sti,
      LCD_RS_i	     => LCD_RS_sti,
      LCD_E_i	     => LCD_E_sti
      );

-- ==========================================
  FLI : entity work.fli_socket
-- ==========================================
    port map (
      clk_i	           => Cmd_clk_s,
      rst_i	           => Cmd_nReset_s,
      irq_received_i   => Cmd_irq_received_s,
      data_read_i	   => Cmd_data_read_s,
      datavalid_read_i => Cmd_datavalid_read_s,
      wr_o	           => Cmd_single_write_s,
      rd_o	           => Cmd_single_read_s,
      write_addr_o     => Cmd_addr_write_s,
      read_addr_o	   => Cmd_addr_read_s,
      write_data_o     => Cmd_data_write_s
      );

--==========================================
  GPMC_Emulation : entity work.GPMC_TestBench
--=========================================
    generic map(
      GPMC_to_FPGA_Latency	  => GPMC_to_FPGA_Latency,
      FPGA_to_GPMC_Latency	  => FPGA_to_GPMC_Latency
      )
    port map(
      -- Clocks
      External_100Mhz_Clk_o	  => External_100Mhz_Clk_sti,
      GPMC_Clk_25MHz_o		  => GPMC_Clk_25MHz_sti,
      GPMC_nReset_o		      => GPMC_nReset_sti,
      -- locas bus
      GPMC_LB_RE_nOE_o		  => GPMC_LB_RE_nOE_sti,
      GPMC_LB_nWE_o		      => GPMC_LB_nWE_sti,
      GPMC_LB_WAIT3_i		  => SP6_LB_WAIT3_sti_delayed,
      GPMC_LB_nCS3_o		  => GPMC_LB_nCS3_sti,
      GPMC_LB_nCS4_o		  => GPMC_LB_nCS4_sti,
      GPMC_LB_nADV_ALE_o	  => GPMC_LB_nADV_ALE_sti,
      GPMC_LB_nBE0_CLE_o	  => GPMC_LB_nBE0_CLE_sti,
      GPMC_LB_WAIT0_i		  => SP6_LB_WAIT0_sti_delayed,
      GPMC_LB_CLK_o		      => GPMC_LB_CLK_sti,
      GPMC_Addr_Data_LB_io	  => GPMC_Addr_Data_LB_io_sti, -- latency is done in the Emulation to deal wit tristate
      GPMC_Addr_LB_o		  => GPMC_Addr_LB_sti,	       -- latency is done in the Emulation to deal wit tristate
      GPMC_DIP_o		      => GPMC_DIP_sti,
      -- Cmd Async write and read
      Cmd_clk_o			      => Cmd_clk_s,
      Cmd_nReset_o		      => Cmd_nReset_s,
      Cmd_single_write_i	  => Cmd_single_write_s,
      Cmd_addr_write_i		  => Cmd_addr_write_s,
      Cmd_data_write_i		  => Cmd_data_write_s,
      Cmd_single_read_i		  => Cmd_single_read_s,
      Cmd_addr_read_i		  => Cmd_addr_read_s,
      Cmd_data_read_o		  => Cmd_data_read_s,
      Cmd_datavalid_read_o	  => Cmd_datavalid_read_s,
      --
      End_of_sim_o		      => End_of_sim,
      TestBenchDelay_o		  => TestBenchDelay_s
      );

--======================================
  FPGA_top: entity work.spartan6_std_top
--======================================
    port map(
      -- Clocks
      SP6_Clk_100MHz_i		  => External_100Mhz_Clk_sti,
      CLK_25MHz_SP6_i		  => GPMC_Clk_25MHz_sti,
      SP6_nReset_i		      => GPMC_nReset_sti,
      -- locas bus
      SP6_LB_RE_nOE_i		  => GPMC_LB_RE_nOE_sti_delayed,
      SP6_LB_nWE_i		      => GPMC_LB_nWE_sti_delayed,
      SP6_LB_WAIT3_o		  => SP6_LB_WAIT3_sti,
      SP6_LB_nCS3_i		      => GPMC_LB_nCS3_sti_delayed,
      SP6_LB_nCS4_i		      => GPMC_LB_nCS4_sti_delayed,
      SP6_LB_nADV_ALE_i		  => GPMC_LB_nADV_ALE_sti_delayed,
      SP6_LB_nBE0_CLE_i		  => GPMC_LB_nBE0_CLE_sti_delayed,
      SP6_LB_WAIT0_o		  => SP6_LB_WAIT0_sti,
      SP6_LB_CLK_i		      => GPMC_LB_CLK_sti_delayed,
      Addr_Data_LB_io		  => GPMC_Addr_Data_LB_io_sti,
      Addr_LB_i			      => GPMC_Addr_LB_sti,
      DIP_i			          => GPMC_DIP_sti_delayed,

      --7SEG
      SP6_7seg1_o		      => SP6_7seg1_sti,
      SP6_7seg2_o		      => SP6_7seg2_sti,
      SP6_7seg3_o		      => SP6_7seg3_sti,
      SP6_7seg1_DP_o		  => SP6_7seg1_DP_sti,
      SP6_7seg2_DP_o		  => SP6_7seg2_DP_sti,
      SP6_7seg3_DP_o		  => SP6_7seg3_DP_sti,
      -- SWITCH PB
      SW_PB_i			      => SW_PB_sti,
      -- MICTOR
      MICTOR_SP6_A0_o		  => open,
      MICTOR_SP6_A1_o		  => open,
      MICTOR_SP6_A2_o		  => open,
      MICTOR_SP6_A3_o		  => open,
      MICTOR_SP6_CLK_0_o	  => open,
      MICTOR_SP6_CLK_1_o	  => open,
      --GPIOs (diffs, called gpio_1_n/p .. gpio_5_n/p on schematics):
      -- gpio_1_n, 1_p, 2_n, 2_p and 3_p , used for sp6 configuration from sp3,
      -- gpio_3_n et 4_p connected to leds on CPU board,
      -- gpio_4_n, 5_p and 5_n connected to switches on CPU board
      SP6_GPIO_DIFFS_i		  => (others => '0'),

      --Conn REDS 80p
      SP6_DKK_io		  => open,
      --I2C: to FMC boards
      I2C_SCL_1V8_o		  => open,
      I2C_SDA_1V8_o		  => open,
      SP6_I2C_SCL_i		  => '0',
      SP6_I2C_SDA_i		  => '0',
      --SPI
      -- cs2: to w3 connector
      SP6_SPI_nCS2_o		  => open,
      -- cs3: from cpu
      SP6_SPI_nCS3_i		  => '0',
      -- cs4: to BTB connector
      --      not connected to CPU in REPTAR_CPU v1.1!, reserved for future
      -- versions of cpu boards with more spi cs outputs
      SP6_SPI_nCS4_i		  => '0',
      -- from cpu
      SP6_SPI_SDO_i		  => '0',
      SP6_SPI_SDI_o		  => open,
      SP6_SPI_SCLK_i		  => '0',
      -- accelerometer interrupts
      SP6_ACC_INT1_i		  => '0',
      SP6_ACC_INT2_i		  => '0',
      -- accelerometer SPI
      SP6_SPI_nCS1_o		  => open,
      SP6_ACC_SPI_SDI_o		  => open,
      SP6_ACC_SPI_SCL_o		  => open,
      SP6_ACC_SPI_SDO_i		  => '0',
      --FTDI
      FTDI_TX_i			  => '0',
      FTDI_RX_o			  => open,
      FTDI_nRESET_o		  => open,
      FTDI_nRTS_i		  => '0', -- FTDI_nRTS_i input, not tested!!
      FTDI_nCTS_o		  => open,
      --FMC1
      FMC1_PRSNT_M2C_L_i	  => '0',
      FMC1_LA_P_io		  => open,
      FMC1_LA_N_io		  => open,
      FMC1_CLK1_M2C_P_i		  => '0', -- FMC1_CLK0_C2M_P dans schéma
      FMC1_CLK1_M2C_N_i		  => '0',
      FMC1_CLK0_M2C_P_i		  => '0',
      FMC1_CLK0_M2C_N_i		  => '0',
      --FMC2
      FMC2_PRSNT_M2C_L_i	  => '0',
      FMC2_LA_P_io		  => open,
      FMC2_LA_N_io		  => open,
      FMC2_CLK1_M2C_P_i		  => '0', -- FMC2_CLK0_C2M_P dans schéma
      FMC2_CLK1_M2C_N_i		  => '0',
      FMC2_CLK0_M2C_P_i		  => '0',
      FMC2_CLK0_M2C_N_i		  => '0',
      --GPIO connected to the BTB but not connected to the CPU, not used (3.3V)
      SP6_GPIO_22_i		  => '0',
      --AD
      AD_GPIO_o			  => open,
      AD_SDI_o			  => open,
      AD_nCS_o			  => open,
      AD_CLK_o			  => open,
      AD_SDO_i			  => '0',
      --GPIOs: connector labeled "GPIO_x" on the board silkscreen
      SP6_GPIO_io		  => open,
      --DIPs
      -- modified 16.10.2013 ELR: 9..0 instead of 10..1

      --LEDs
      FPGA_LED_o		  => FPGA_LED_sti,

      --Encoder
      Inc_Enc_A_i		  => '0',
      Inc_Enc_B_i		  => '0',
      --Digital audio
      Digital_Audio_TX_o	  => open,
      Digital_Audio_RX_i	  => '0',
      -- PCI PERST, connected to BTB in FPGA board, but not connected on CPU
      -- board: reserved for futur CPU board versions
      PCI_PERST_o		  => open,
      --CAN, not tested!!
      CAN_RXD_i			  => '0',
      CAN_TXD_o			  => open,
      --GPIOs 1V8 -> connected between FPGA and CPU
      -- SP6_GPIO18_1_o: SYS_CLKOUT1 from CPU (can be used as GPIO), not tested
      -- as clock!!
      -- In this version: used as GPIO for IRQ generation when a switch is
      -- pressed
      SP6_GPIO18_1_o		  => Cmd_irq_received_s,
      -- uP_nRESET_OUT_i: (SP6_GPIO18_2 on schematics) nRESET_OUT from CPU
      uP_nRESET_OUT_i		  => '1',
      --GPIOs 3V3: CONNECTED TO BTB AND SP3
      SP6_GPIO33_io		  => open,
      -- reset from SP6 Config button, resets only the SP6 flip-flops

      --UART
      SP6_UART1_CTS_o		  => open,
      SP6_UART1_RTS_i		  => '0',
      SP6_UART1_RX_i		  => '0',
      SP6_UART1_TX_o		  => open,
      --DA
      DAC_nRS_o			  => open,
      DAC_nCS_o			  => open,
      DAC_nLDAC_o		  => open,
      DAC_CLK_o			  => open,
      DAC_SDI_o			  => open,
      --Buzzer
      Buz_osc_o			  => open,
      --Touch pad
      PCB_TB_io			  => open,
      --GPIOs header: labeled "GPIO_Hx" on the board silkscreen
      SP6_GPIO_H_io		  => open,
      --LCD
      LCD_DB_io			  => LCD_DB_sti,
      LCD_R_nW_o		  => LCD_R_nW_sti,
      LCD_RS_o			  => LCD_RS_sti,
      LCD_E_o			  => LCD_E_sti,
      --DDR2
      DDR2_A_o			  => open,
      DDR2_BA_o			  => open,
      DDR2_DQ_io		  => open,
      DDR2_CKE_o		  => open,
      DDR2_WE_o			  => open,
      DDR2_ODT_o		  => open,
      DDR2_nRAS_o		  => open,
      DDR2_nCAS_o		  => open,
      DDR2_LDM_o		  => open,
      DDR2_UDM_o		  => open,
      DDR2_LDQS_P_o		  => open,
      DDR2_LDQS_N_o		  => open,
      DDR2_UDQS_P_o		  => open,
      DDR2_UDQS_N_o		  => open,
      DDR2_CK_P_o		  => open,
      DDR2_CK_N_o		  => open,
      mcb5_rzq			  => open,
      mcb5_zio			  => open,
      -- not used (RFU on the chip: reserved for futur use)
      DDR2_A14_i		  =>'0'

     --SMB
     --PCIe
     --SATA
      );

end behave;
