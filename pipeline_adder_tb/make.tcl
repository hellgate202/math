vlib work
vlog -sv -f files
vopt +acc pipeline_adder_tb -o pipeline_adder_tb_opt
vsim pipeline_adder_tb_opt
do wave.do
run -all
