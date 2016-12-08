onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/env/DUT/pm_addr
add wave -noupdate /top/env/DUT/from_PS
add wave -noupdate /top/env/DUT/pc
add wave -noupdate /top/env/DUT/clk
add wave -noupdate /top/env/DUT/sync_reset
add wave -noupdate /top/env/DUT/jmp
add wave -noupdate /top/env/DUT/jmp_nz
add wave -noupdate /top/env/DUT/dont_jmp
add wave -noupdate /top/env/DUT/jmp_addr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {52409 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 217
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
WaveRestoreZoom {51398 ns} {59602 ns}
