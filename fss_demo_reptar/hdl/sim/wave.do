onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider GPMC
add wave -noupdate /test_bench_top/GPMC_Emulation/TestBenchDelay_o
add wave -noupdate -radix hexadecimal -childformat {{/test_bench_top/GPMC_Emulation/GPMC_DataRead(8) -radix hexadecimal} {/test_bench_top/GPMC_Emulation/GPMC_DataRead(7) -radix hexadecimal} {/test_bench_top/GPMC_Emulation/GPMC_DataRead(6) -radix hexadecimal} {/test_bench_top/GPMC_Emulation/GPMC_DataRead(5) -radix hexadecimal} {/test_bench_top/GPMC_Emulation/GPMC_DataRead(4) -radix hexadecimal} {/test_bench_top/GPMC_Emulation/GPMC_DataRead(3) -radix hexadecimal} {/test_bench_top/GPMC_Emulation/GPMC_DataRead(2) -radix hexadecimal} {/test_bench_top/GPMC_Emulation/GPMC_DataRead(1) -radix hexadecimal} {/test_bench_top/GPMC_Emulation/GPMC_DataRead(0) -radix hexadecimal}} -subitemconfig {/test_bench_top/GPMC_Emulation/GPMC_DataRead(8) {-height 15 -radix hexadecimal} /test_bench_top/GPMC_Emulation/GPMC_DataRead(7) {-height 15 -radix hexadecimal} /test_bench_top/GPMC_Emulation/GPMC_DataRead(6) {-height 15 -radix hexadecimal} /test_bench_top/GPMC_Emulation/GPMC_DataRead(5) {-height 15 -radix hexadecimal} /test_bench_top/GPMC_Emulation/GPMC_DataRead(4) {-height 15 -radix hexadecimal} /test_bench_top/GPMC_Emulation/GPMC_DataRead(3) {-height 15 -radix hexadecimal} /test_bench_top/GPMC_Emulation/GPMC_DataRead(2) {-height 15 -radix hexadecimal} /test_bench_top/GPMC_Emulation/GPMC_DataRead(1) {-height 15 -radix hexadecimal} /test_bench_top/GPMC_Emulation/GPMC_DataRead(0) {-height 15 -radix hexadecimal}} /test_bench_top/GPMC_Emulation/GPMC_DataRead
add wave -noupdate -radix hexadecimal -childformat {{/test_bench_top/GPMC_Emulation/GPMC_DataWrite(8) -radix hexadecimal} {/test_bench_top/GPMC_Emulation/GPMC_DataWrite(7) -radix hexadecimal} {/test_bench_top/GPMC_Emulation/GPMC_DataWrite(6) -radix hexadecimal} {/test_bench_top/GPMC_Emulation/GPMC_DataWrite(5) -radix hexadecimal} {/test_bench_top/GPMC_Emulation/GPMC_DataWrite(4) -radix hexadecimal} {/test_bench_top/GPMC_Emulation/GPMC_DataWrite(3) -radix hexadecimal} {/test_bench_top/GPMC_Emulation/GPMC_DataWrite(2) -radix hexadecimal} {/test_bench_top/GPMC_Emulation/GPMC_DataWrite(1) -radix hexadecimal} {/test_bench_top/GPMC_Emulation/GPMC_DataWrite(0) -radix hexadecimal}} -subitemconfig {/test_bench_top/GPMC_Emulation/GPMC_DataWrite(8) {-height 15 -radix hexadecimal} /test_bench_top/GPMC_Emulation/GPMC_DataWrite(7) {-height 15 -radix hexadecimal} /test_bench_top/GPMC_Emulation/GPMC_DataWrite(6) {-height 15 -radix hexadecimal} /test_bench_top/GPMC_Emulation/GPMC_DataWrite(5) {-height 15 -radix hexadecimal} /test_bench_top/GPMC_Emulation/GPMC_DataWrite(4) {-height 15 -radix hexadecimal} /test_bench_top/GPMC_Emulation/GPMC_DataWrite(3) {-height 15 -radix hexadecimal} /test_bench_top/GPMC_Emulation/GPMC_DataWrite(2) {-height 15 -radix hexadecimal} /test_bench_top/GPMC_Emulation/GPMC_DataWrite(1) {-height 15 -radix hexadecimal} /test_bench_top/GPMC_Emulation/GPMC_DataWrite(0) {-height 15 -radix hexadecimal}} /test_bench_top/GPMC_Emulation/GPMC_DataWrite
add wave -noupdate -expand -group {Asyn. Read} /test_bench_top/GPMC_Emulation/GPMC_FCLK_sti
add wave -noupdate -expand -group {Asyn. Read} /test_bench_top/GPMC_LB_CLK_sti
add wave -noupdate -expand -group {Asyn. Read} /test_bench_top/GPMC_Emulation/GPMC_Addr_LB_o
add wave -noupdate -expand -group {Asyn. Read} -radix hexadecimal /test_bench_top/GPMC_Emulation/Addr_Data_LB_Zstate_delayed
add wave -noupdate -expand -group {Asyn. Read} /test_bench_top/GPMC_Emulation/GPMC_LB_nBE0_CLE_o
add wave -noupdate -expand -group {Asyn. Read} /test_bench_top/GPMC_Emulation/GPMC_LB_nCS3_o
add wave -noupdate -expand -group {Asyn. Read} /test_bench_top/GPMC_Emulation/GPMC_LB_nADV_ALE_o
add wave -noupdate -expand -group {Asyn. Read} /test_bench_top/GPMC_Emulation/GPMC_LB_RE_nOE_o
add wave -noupdate -expand -group {Asyn. Read} /test_bench_top/GPMC_Emulation/GPMC_LB_WAIT3_i
add wave -noupdate -expand -group {Asyn. Write} /test_bench_top/GPMC_Emulation/GPMC_FCLK_sti
add wave -noupdate -expand -group {Asyn. Write} /test_bench_top/GPMC_LB_CLK_sti
add wave -noupdate -expand -group {Asyn. Write} /test_bench_top/GPMC_Emulation/GPMC_Addr_LB_o
add wave -noupdate -expand -group {Asyn. Write} -radix hexadecimal /test_bench_top/GPMC_Emulation/Addr_Data_LB_sti
add wave -noupdate -expand -group {Asyn. Write} /test_bench_top/GPMC_Emulation/GPMC_LB_nBE0_CLE_o
add wave -noupdate -expand -group {Asyn. Write} /test_bench_top/GPMC_Emulation/GPMC_LB_nCS3_o
add wave -noupdate -expand -group {Asyn. Write} /test_bench_top/GPMC_Emulation/GPMC_LB_nADV_ALE_o
add wave -noupdate -expand -group {Asyn. Write} /test_bench_top/GPMC_Emulation/GPMC_LB_nWE_o
add wave -noupdate -expand -group {Asyn. Write} /test_bench_top/GPMC_Emulation/GPMC_LB_WAIT3_i
add wave -noupdate -divider FPGA
add wave -noupdate /test_bench_top/FPGA_top/Addr_Data_LB_io
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/clk_i
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/reset_i
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/nCS3_LB_i
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/nADV_LB_i
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/nOE_LB_i
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/nWE_LB_i
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/Addr_LB_i
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/lba_wait_usr_i
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/lba_wait_s
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/lba_nwait_o
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/lb_add_data_wr_i
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/lba_oe_o
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/lba_wr_en_o
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/lba_rd_en_o
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/lba_add_o
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/lba_cs_std_o
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/lba_cs_usr_rd_o
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/lba_cs_usr_wr_o
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/nCS3_LB_s
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/nADV_LB_s
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/nOE_LB_s
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/nWE_LB_s
add wave -noupdate -group lba_ctrl_inst /test_bench_top/FPGA_top/lba_ctrl_inst/lba_add_en_s
add wave -noupdate -group {IOBUF Addresss_Data(0)} /test_bench_top/FPGA_top/IOBUF_Addresses_Datas(0)/IOBUF_Address_Data/CAPACITANCE
add wave -noupdate -group {IOBUF Addresss_Data(0)} /test_bench_top/FPGA_top/IOBUF_Addresses_Datas(0)/IOBUF_Address_Data/DRIVE
add wave -noupdate -group {IOBUF Addresss_Data(0)} /test_bench_top/FPGA_top/IOBUF_Addresses_Datas(0)/IOBUF_Address_Data/I
add wave -noupdate -group {IOBUF Addresss_Data(0)} /test_bench_top/FPGA_top/IOBUF_Addresses_Datas(0)/IOBUF_Address_Data/IBUF_DELAY_VALUE
add wave -noupdate -group {IOBUF Addresss_Data(0)} /test_bench_top/FPGA_top/IOBUF_Addresses_Datas(0)/IOBUF_Address_Data/IBUF_LOW_PWR
add wave -noupdate -group {IOBUF Addresss_Data(0)} /test_bench_top/FPGA_top/IOBUF_Addresses_Datas(0)/IOBUF_Address_Data/IFD_DELAY_VALUE
add wave -noupdate -group {IOBUF Addresss_Data(0)} /test_bench_top/FPGA_top/IOBUF_Addresses_Datas(0)/IOBUF_Address_Data/IO
add wave -noupdate -group {IOBUF Addresss_Data(0)} /test_bench_top/FPGA_top/IOBUF_Addresses_Datas(0)/IOBUF_Address_Data/IOSTANDARD
add wave -noupdate -group {IOBUF Addresss_Data(0)} /test_bench_top/FPGA_top/IOBUF_Addresses_Datas(0)/IOBUF_Address_Data/O
add wave -noupdate -group {IOBUF Addresss_Data(0)} /test_bench_top/FPGA_top/IOBUF_Addresses_Datas(0)/IOBUF_Address_Data/SLEW
add wave -noupdate -group {IOBUF Addresss_Data(0)} /test_bench_top/FPGA_top/IOBUF_Addresses_Datas(0)/IOBUF_Address_Data/T
add wave -noupdate -radix hexadecimal /test_bench_top/GPMC_Emulation/cmd_single_write_s
add wave -noupdate -radix hexadecimal /test_bench_top/GPMC_Emulation/cmd_single_write_reg
add wave -noupdate -radix hexadecimal /test_bench_top/GPMC_Emulation/Cmd_addr_write_i
add wave -noupdate -radix hexadecimal /test_bench_top/GPMC_Emulation/Cmd_data_write_i
add wave -noupdate -radix hexadecimal /test_bench_top/GPMC_Emulation/cmd_single_read_s
add wave -noupdate -radix hexadecimal /test_bench_top/GPMC_Emulation/cmd_single_read_reg
add wave -noupdate -radix hexadecimal /test_bench_top/GPMC_Emulation/Cmd_addr_read_i
add wave -noupdate -radix hexadecimal /test_bench_top/GPMC_Emulation/Cmd_data_read_o
add wave -noupdate -radix hexadecimal /test_bench_top/GPMC_Emulation/GPMC_Data_obs
add wave -noupdate -radix hexadecimal /test_bench_top/GPMC_Emulation/GPMC_Data_valid_obs
add wave -noupdate -radix hexadecimal -childformat {{/test_bench_top/FPGA_top/FPGA_LED_o(7) -radix hexadecimal} {/test_bench_top/FPGA_top/FPGA_LED_o(6) -radix hexadecimal} {/test_bench_top/FPGA_top/FPGA_LED_o(5) -radix hexadecimal} {/test_bench_top/FPGA_top/FPGA_LED_o(4) -radix hexadecimal} {/test_bench_top/FPGA_top/FPGA_LED_o(3) -radix hexadecimal} {/test_bench_top/FPGA_top/FPGA_LED_o(2) -radix hexadecimal} {/test_bench_top/FPGA_top/FPGA_LED_o(1) -radix hexadecimal} {/test_bench_top/FPGA_top/FPGA_LED_o(0) -radix hexadecimal}} -subitemconfig {/test_bench_top/FPGA_top/FPGA_LED_o(7) {-radix hexadecimal} /test_bench_top/FPGA_top/FPGA_LED_o(6) {-radix hexadecimal} /test_bench_top/FPGA_top/FPGA_LED_o(5) {-radix hexadecimal} /test_bench_top/FPGA_top/FPGA_LED_o(4) {-radix hexadecimal} /test_bench_top/FPGA_top/FPGA_LED_o(3) {-radix hexadecimal} /test_bench_top/FPGA_top/FPGA_LED_o(2) {-radix hexadecimal} /test_bench_top/FPGA_top/FPGA_LED_o(1) {-radix hexadecimal} /test_bench_top/FPGA_top/FPGA_LED_o(0) {-radix hexadecimal}} /test_bench_top/FPGA_top/FPGA_LED_o
add wave -noupdate /test_bench_top/FPGA_top/SP6_GPIO18_1_o
add wave -noupdate /test_bench_top/FPGA_top/SW_PB_i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1685641 ps} 0} {{Cursor 2} {24954669 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 498
configure wave -valuecolwidth 247
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {2014312 ps} {2841352 ps}
