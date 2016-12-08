onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /env/dut/clk
add wave -noupdate -format Logic /env/dut/rst_b
add wave -noupdate -divider {Input Interface}
add wave -noupdate -format Logic /env/dut/bnd_plse
add wave -noupdate -format Logic /env/dut/ack
add wave -noupdate -format Literal -radix hexadecimal /env/dut/data_in
add wave -noupdate -divider {Output Port 1 Interface}
add wave -noupdate -format Literal -radix hexadecimal /env/dut/newdata_len_1
add wave -noupdate -format Logic /env/dut/proceed_1
add wave -noupdate -format Literal -radix hexadecimal /env/dut/data_out_1
add wave -noupdate -divider {Output Port 2 Interface}
add wave -noupdate -format Literal -radix hexadecimal /env/dut/newdata_len_2
add wave -noupdate -format Logic /env/dut/proceed_2
add wave -noupdate -format Literal -radix hexadecimal /env/dut/data_out_2
add wave -noupdate -divider {Output Port 3 Interface}
add wave -noupdate -format Literal -radix hexadecimal /env/dut/newdata_len_3
add wave -noupdate -format Logic /env/dut/proceed_3
add wave -noupdate -format Literal -radix hexadecimal /env/dut/data_out_3
add wave -noupdate -divider {Output Port 4 Interface}
add wave -noupdate -format Literal -radix hexadecimal /env/dut/newdata_len_4
add wave -noupdate -format Logic /env/dut/proceed_4
add wave -noupdate -format Literal -radix hexadecimal /env/dut/data_out_4
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {270 ns} 0}
configure wave -namecolwidth 234
configure wave -valuecolwidth 38
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
WaveRestoreZoom {0 ns} {240 ns}
