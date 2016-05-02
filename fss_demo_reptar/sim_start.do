#!/usr/bin/tclsh

if {[file exists work] == 0} {
    vlib work
}

# ++ Compile HDL ++
puts "\nVHDL compilation :"
#---------- /touch_pag_control ----------------
vcom hdl/src/touch_pad_control/filter/Filter.vhd
vcom hdl/src/touch_pad_control/filter/ADDN.vhd
vcom hdl/src/touch_pad_control/filter/Filter4Data.vhd
vcom hdl/src/touch_pad_control/filter/Pin_Filter.vhd
vcom hdl/src/touch_pad_control/filter/SRGN.vhd
vcom hdl/src/touch_pad_control/lib/LOG_pkg.vhd
vcom hdl/src/touch_pad_control/touch_pad_ctrl_pkg.vhd
vcom hdl/src/touch_pad_control/Cap_Timer.vhd
vcom hdl/src/touch_pad_control/Cap_UC.vhd
vcom hdl/src/touch_pad_control/Capt_Finger.vhd
vcom hdl/src/touch_pad_control/touch_pad_ctrl.vhd

#---------- /ip/ddr ----------------
vcom hdl/src/ip/ddr/iodrp_controller.vhd
vcom hdl/src/ip/ddr/iodrp_mcb_controller.vhd
vcom hdl/src/ip/ddr/mcb_raw_wrapper.vhd
vcom hdl/src/ip/ddr/mcb_soft_calibration.vhd
vcom hdl/src/ip/ddr/memc5_infrastructure.vhd
vcom hdl/src/ip/ddr/memc5_wrapper.vhd
vcom hdl/src/ip/ddr/mcb_soft_calibration_top.vhd

#---------- /ip/clk_pll ----------------
vcom hdl/src/ip/clk_pll/clk_PLL_200.vhd
vcom hdl/src/ip/clk_pll/clk_pll.vhd

#---------- /src ----------------
vcom hdl/src/lba_ctrl.vhd
vcom hdl/src/lba_ctrl_fsm.vhd
vcom hdl/src/Timer.vhd
vcom hdl/src/spi_mux.vhd
vcom hdl/src/reds_conn_tristate.vhd
vcom hdl/src/Open_Collector.vhd
vcom hdl/src/mcb_ddr2_pkg.vhd
vcom hdl/src/lcd_ctrl.vhd
vcom hdl/src/lbs_ctrl.vhd
vcom hdl/src/lba_sp6_registers_pkg.vhd
vcom hdl/src/lba_std_interface.vhd
vcom hdl/src/lba_sp6_registers.vhd
vcom hdl/src/irq_generator.vhd
vcom hdl/src/gpio_conn_tristate.vhd
vcom hdl/src/fmc_conn_tristate.vhd
vcom hdl/src/encoder_sens_detector.vhd
vcom hdl/src/buzzer_ctrl.vhd
vcom hdl/src/lba_user_interface.vhd
vcom hdl/src/debounce.vhd
vcom hdl/src/spartan6_std_top.vhd

#---------- testBench Files ----------------
vcom hdl/sim/objection_pkg.vhd
vcom hdl/sim/random_pkg.vhd
vcom hdl/sim/GPMC_TestBench.vhd
vcom hdl/sim/fli_socket.vhd
vcom hdl/sim/fli_gui.vhd
vcom hdl/sim/Test_Bench_top.vhd

# ++ Start simulation ++
vsim -t 1ps -novopt work.Test_Bench_top
# vsim work.write_initIRQ.do
do hdl/sim/wave.do
wave refresh
