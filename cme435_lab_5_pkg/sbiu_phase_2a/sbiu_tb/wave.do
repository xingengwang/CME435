onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /env/us_intf/clk
add wave -noupdate -format Logic /env/us_intf/rst_b
add wave -noupdate -format Logic /env/us_intf/rdy
add wave -noupdate -format Logic /env/us_intf/frame
add wave -noupdate -format Literal -radix hexadecimal /env/us_intf/adr_data
add wave -noupdate -format Logic /env/ds_intf/clk
add wave -noupdate -format Logic /env/ds_intf/rst_b
add wave -noupdate -format Logic /env/ds_intf/bus_req
add wave -noupdate -format Logic /env/ds_intf/bus_gnt
add wave -noupdate -format Logic /env/ds_intf/wait_sig
add wave -noupdate -format Logic /env/ds_intf/valid
add wave -noupdate -format Literal -radix hexadecimal /env/ds_intf/src_adr_out
add wave -noupdate -format Literal -radix hexadecimal /env/ds_intf/dst_adr_out
add wave -noupdate -format Literal -radix hexadecimal /env/ds_intf/data_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
configure wave -namecolwidth 235
configure wave -valuecolwidth 39
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
WaveRestoreZoom {0 ns} {939 ns}
