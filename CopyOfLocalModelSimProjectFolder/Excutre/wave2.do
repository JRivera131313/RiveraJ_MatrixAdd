onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 25 -radix hexadecimal -childformat {{{/top/U1/instructMem[9]} -radix hexadecimal} {{/top/U1/instructMem[8]} -radix hexadecimal} {{/top/U1/instructMem[7]} -radix hexadecimal} {{/top/U1/instructMem[6]} -radix hexadecimal} {{/top/U1/instructMem[5]} -radix hexadecimal} {{/top/U1/instructMem[4]} -radix hexadecimal} {{/top/U1/instructMem[3]} -radix hexadecimal} {{/top/U1/instructMem[2]} -radix hexadecimal} {{/top/U1/instructMem[1]} -radix hexadecimal} {{/top/U1/instructMem[0]} -radix hexadecimal}} -expand -subitemconfig {{/top/U1/instructMem[9]} {-height 25 -radix hexadecimal} {/top/U1/instructMem[8]} {-height 25 -radix hexadecimal} {/top/U1/instructMem[7]} {-height 25 -radix hexadecimal} {/top/U1/instructMem[6]} {-height 25 -radix hexadecimal} {/top/U1/instructMem[5]} {-height 25 -radix hexadecimal} {/top/U1/instructMem[4]} {-height 25 -radix hexadecimal} {/top/U1/instructMem[3]} {-height 25 -radix hexadecimal} {/top/U1/instructMem[2]} {-height 25 -radix hexadecimal} {/top/U1/instructMem[1]} {-height 25 -radix hexadecimal} {/top/U1/instructMem[0]} {-height 25 -radix hexadecimal}} /top/U1/instructMem
add wave -noupdate /top/U3/nRead
add wave -noupdate /top/U3/nWrite
add wave -noupdate /top/U3/address
add wave -noupdate /top/U3/ExeDataOut
add wave -noupdate /top/U3/nReset
add wave -noupdate /top/U3/Clk
add wave -noupdate /top/U3/InstructDataOut
add wave -noupdate /top/U3/MemDataOut
add wave -noupdate /top/U3/clkCounter
add wave -noupdate /top/U3/complete
add wave -noupdate /top/U3/currentOperation
add wave -noupdate /top/U3/PC
add wave -noupdate /top/U3/opCode
add wave -noupdate /top/U3/operation
add wave -noupdate /top/U3/destAddress
add wave -noupdate /top/U3/src1Address
add wave -noupdate /top/U3/src2Address
add wave -noupdate /top/U3/Result
add wave -noupdate /top/U3/src1Data
add wave -noupdate /top/U3/src2Data
add wave -noupdate -expand /top/U2/mainMemArray
add wave -noupdate {/top/U2/mainMemArray[2]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {142 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 11
configure wave -gridperiod 12
configure wave -griddelta 20
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {27 ps} {223 ps}
