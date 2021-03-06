onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/env/clk
add wave -noupdate /top/test/reset
add wave -noupdate /top/test/ns_per_clk
add wave -noupdate /top/test/i
add wave -noupdate /top/test/dm
add wave -noupdate /top/env/GOLD/o_reg
add wave -noupdate /top/env/GOLD/comp_unit/o_reg
add wave -noupdate /top/env/GOLD/comp_unit/i
add wave -noupdate /top/env/GOLD/comp_unit/dm
add wave -noupdate /top/env/GOLD/comp_unit/i_pins
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {14681 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 273
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
WaveRestoreZoom {0 ns} {41020 ns}
