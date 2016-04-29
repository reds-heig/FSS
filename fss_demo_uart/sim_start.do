vlib work
vmap work work
vcom -work work hdl/*.vhd
vsim -t 100ns fss_uart_top
set StdArithNoWarnings 1
add wave -noupdate -radix hexadecimal /fss_uart_top/sys_rst_s
add wave -noupdate -radix hexadecimal /fss_uart_top/A_rst_s
add wave -position 2  sim:/fss_uart_top/uart_A/UART_TX/CState
add wave -noupdate -radix hexadecimal /fss_uart_top/A_irq_s
add wave -noupdate -radix hexadecimal /fss_uart_top/A_addr_s
add wave -noupdate -radix hexadecimal /fss_uart_top/A_in_s
add wave -noupdate -radix hexadecimal /fss_uart_top/A_wr_s
add wave -noupdate -radix hexadecimal /fss_uart_top/A_rd_s
add wave -noupdate -radix hexadecimal /fss_uart_top/A_out_s
add wave -noupdate -radix hexadecimal /fss_uart_top/A_tx_s
add wave -noupdate -radix hexadecimal /fss_uart_top/uart_A/iMCR_LOOP
add wave -noupdate -radix hexadecimal /fss_uart_top/uart_A/BAUDOUTN
add wave -noupdate -radix hexadecimal /fss_uart_top/fli_A/baudce_o
add wave -noupdate -radix hexadecimal /fss_uart_top/uart_A/BAUDCE
add wave -noupdate -radix hexadecimal /fss_uart_top/sys_clk_s
add wave -noupdate -radix hexadecimal /fss_uart_top/B_out_s
add wave -noupdate -radix hexadecimal /fss_uart_top/B_addr_s
add wave -noupdate -radix hexadecimal /fss_uart_top/B_rst_s
add wave -noupdate -radix hexadecimal /fss_uart_top/B_wr_s
add wave -noupdate -radix hexadecimal /fss_uart_top/B_rd_s
add wave -noupdate -radix hexadecimal /fss_uart_top/B_in_s
add wave -noupdate -radix hexadecimal /fss_uart_top/B_irq_s
add wave -noupdate -radix hexadecimal /fss_uart_top/A_cs_s
add wave -noupdate -radix hexadecimal /fss_uart_top/B_cs_s
add wave -noupdate -radix hexadecimal /fss_uart_top/A_baudce_s
add wave -noupdate -radix hexadecimal /fss_uart_top/B_baudce_s
add wave -noupdate -radix hexadecimal /fss_uart_top/A_ddis_s
add wave -noupdate -radix hexadecimal /fss_uart_top/B_ddis_s
add wave -noupdate -radix hexadecimal /fss_uart_top/A_out1N_s
add wave -noupdate -radix hexadecimal /fss_uart_top/B_out1N_s
add wave -noupdate -radix hexadecimal /fss_uart_top/A_out2N_s
add wave -noupdate -radix hexadecimal /fss_uart_top/B_out2N_s
add wave -noupdate -radix hexadecimal /fss_uart_top/A_dtrN_s
add wave -noupdate -radix hexadecimal /fss_uart_top/B_dtrN_s
add wave -noupdate -radix hexadecimal /fss_uart_top/A_riN_s
add wave -noupdate -radix hexadecimal /fss_uart_top/B_riN_s
add wave -noupdate -radix hexadecimal /fss_uart_top/A_ctsN_s
add wave -noupdate -radix hexadecimal /fss_uart_top/B_ctsN_s
add wave -noupdate -radix hexadecimal /fss_uart_top/B_tx_s
add wave -noupdate -radix hexadecimal /fss_uart_top/A_rclk_s
add wave -noupdate -radix hexadecimal /fss_uart_top/B_rclk_s
configure wave -signalnamewidth 1
force -freeze sim:/fss_uart_top/A_rst_s 1 0
run 10ms
force -freeze sim:/fss_uart_top/A_rst_s 0 0
run 10ms
run -all
