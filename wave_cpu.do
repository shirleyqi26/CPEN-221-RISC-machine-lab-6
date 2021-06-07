onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpu_tb/sim_clk
add wave -noupdate /cpu_tb/sim_Z
add wave -noupdate /cpu_tb/sim_N
add wave -noupdate /cpu_tb/sim_V
add wave -noupdate /cpu_tb/sim_in
add wave -noupdate /cpu_tb/sim_load
add wave -noupdate /cpu_tb/sim_out
add wave -noupdate /cpu_tb/sim_reset
add wave -noupdate /cpu_tb/sim_s
add wave -noupdate /cpu_tb/sim_w
add wave -noupdate /cpu_tb/dut/ALU_state
add wave -noupdate /cpu_tb/dut/asel
add wave -noupdate /cpu_tb/dut/bsel
add wave -noupdate /cpu_tb/dut/finished
add wave -noupdate /cpu_tb/dut/instruction
add wave -noupdate /cpu_tb/dut/load
add wave -noupdate /cpu_tb/dut/loada
add wave -noupdate /cpu_tb/dut/loadb
add wave -noupdate /cpu_tb/dut/loadc
add wave -noupdate /cpu_tb/dut/loads
add wave -noupdate /cpu_tb/dut/move_state
add wave -noupdate /cpu_tb/dut/nsel
add wave -noupdate /cpu_tb/dut/Rd
add wave -noupdate /cpu_tb/dut/Rm
add wave -noupdate /cpu_tb/dut/Rn
add wave -noupdate /cpu_tb/dut/readnum
add wave -noupdate /cpu_tb/dut/vsel
add wave -noupdate /cpu_tb/dut/write
add wave -noupdate /cpu_tb/dut/writenum
add wave -noupdate /cpu_tb/dut/DP/REGFILE/R0
add wave -noupdate /cpu_tb/dut/DP/REGFILE/R1
add wave -noupdate /cpu_tb/dut/DP/REGFILE/R2
add wave -noupdate /cpu_tb/dut/DP/REGFILE/R3
add wave -noupdate /cpu_tb/dut/DP/REGFILE/R4
add wave -noupdate /cpu_tb/dut/DP/REGFILE/R5
add wave -noupdate /cpu_tb/dut/DP/REGFILE/R6
add wave -noupdate /cpu_tb/dut/DP/REGFILE/R7
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {376 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {583 ps}
