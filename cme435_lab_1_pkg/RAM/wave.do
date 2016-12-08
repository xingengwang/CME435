onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/env/input_intf/wren
add wave -noupdate /top/env/input_intf/data
add wave -noupdate -radix hexadecimal /top/env/GOLD/address
add wave -noupdate -radix binary /top/env/GOLD/clock
add wave -noupdate -radix hexadecimal /top/env/GOLD/q
add wave -noupdate -radix hexadecimal {/top/env/GOLD/RAM_Data[0]}
add wave -noupdate -radix hexadecimal {/top/env/GOLD/RAM_Data[1]}
add wave -noupdate -radix hexadecimal {/top/env/GOLD/RAM_Data[2]}
add wave -noupdate -radix hexadecimal {/top/env/GOLD/RAM_Data[3]}
add wave -noupdate -radix hexadecimal {/top/env/GOLD/RAM_Data[4]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 214
configure wave -valuecolwidth 40
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
WaveRestoreZoom {0 ns} {1458 ns}
