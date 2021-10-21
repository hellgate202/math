onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pipeline_division_tb/DUT/clk_i
add wave -noupdate /pipeline_division_tb/DUT/rst_i
add wave -noupdate -radix unsigned /pipeline_division_tb/DUT/divinded_i
add wave -noupdate -radix unsigned /pipeline_division_tb/DUT/divisor_i
add wave -noupdate /pipeline_division_tb/DUT/valid_i
add wave -noupdate /pipeline_division_tb/DUT/ready_o
add wave -noupdate -radix unsigned /pipeline_division_tb/DUT/quotient_o
add wave -noupdate -radix unsigned /pipeline_division_tb/DUT/reminder_o
add wave -noupdate /pipeline_division_tb/DUT/valid_o
add wave -noupdate /pipeline_division_tb/DUT/ready_i
add wave -noupdate -expand /pipeline_division_tb/DUT/division_stages
add wave -noupdate -expand /pipeline_division_tb/DUT/rh_comb
add wave -noupdate /pipeline_division_tb/DUT/q
add wave -noupdate -radix unsigned /pipeline_division_tb/DUT/divisor_lock
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {134083 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 591
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {338204 ps}
