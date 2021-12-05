onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /pipeline_adder_tb/DUT/clk_i
add wave -noupdate -radix unsigned /pipeline_adder_tb/DUT/rst_i
add wave -noupdate -radix decimal /pipeline_adder_tb/DUT/data_i
add wave -noupdate -radix unsigned /pipeline_adder_tb/DUT/data_valid_i
add wave -noupdate -radix unsigned /pipeline_adder_tb/DUT/ready_o
add wave -noupdate -radix decimal /pipeline_adder_tb/DUT/data_o
add wave -noupdate -radix unsigned /pipeline_adder_tb/DUT/data_valid_o
add wave -noupdate -radix unsigned /pipeline_adder_tb/DUT/ready_i
add wave -noupdate -radix unsigned -childformat {{{/pipeline_adder_tb/DUT/add_stages[3]} -radix unsigned} {{/pipeline_adder_tb/DUT/add_stages[2]} -radix unsigned} {{/pipeline_adder_tb/DUT/add_stages[1]} -radix unsigned} {{/pipeline_adder_tb/DUT/add_stages[0]} -radix unsigned}} -expand -subitemconfig {{/pipeline_adder_tb/DUT/add_stages[3]} {-height 16 -radix unsigned} {/pipeline_adder_tb/DUT/add_stages[2]} {-height 16 -radix unsigned} {/pipeline_adder_tb/DUT/add_stages[1]} {-height 16 -radix unsigned} {/pipeline_adder_tb/DUT/add_stages[0]} {-height 16 -radix unsigned}} /pipeline_adder_tb/DUT/add_stages
add wave -noupdate /pipeline_adder_tb/DUT/PIPELINE_CHART
add wave -noupdate -expand /pipeline_adder_tb/DUT/ex_pipe
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {40383 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 331
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
WaveRestoreZoom {0 ps} {152250 ps}
