onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/env/DUT/address
add wave -noupdate /top/env/DUT/q
add wave -noupdate /top/env/DUT/ROM_Data
add wave -noupdate /top/env/DUT/i
add wave -noupdate /top/env/DUT/initial_data
add wave -noupdate -divider {Environment Signals}
add wave -noupdate /top/env/DUT/clock
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {182 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 215
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ns} {874 ns}
