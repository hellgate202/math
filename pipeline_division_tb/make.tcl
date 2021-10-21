vlib work
vlog -sv -f files
vopt +acc pipeline_division_tb -o pipeline_division_tb_opt
vsim pipeline_division_tb_opt
do wave.do
run -all
