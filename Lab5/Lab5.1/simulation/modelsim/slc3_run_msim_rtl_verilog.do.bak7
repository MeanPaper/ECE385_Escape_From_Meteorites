transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided {C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided/HexDriver.sv}
vlog -sv -work work +incdir+C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided {C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided/reg_16.sv}
vlog -sv -work work +incdir+C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided {C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided/test_memory.sv}
vlog -sv -work work +incdir+C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided {C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided/synchronizers.sv}
vlog -sv -work work +incdir+C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided {C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided/SLC3_2.sv}
vlog -sv -work work +incdir+C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided {C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided/Mem2IO.sv}
vlog -sv -work work +incdir+C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided {C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided/ISDU.sv}
vlog -sv -work work +incdir+C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided {C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided/mux.sv}
vlog -sv -work work +incdir+C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided {C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided/memory_contents.sv}
vlog -sv -work work +incdir+C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided {C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided/datapath.sv}
vlog -sv -work work +incdir+C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided {C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided/slc3.sv}
vlog -sv -work work +incdir+C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided {C:/Users/ldm18/Desktop/385_FPGA_project/Lab5provided/slc3_testtop.sv}

vlog -sv -work work +incdir+C:/Users/ldm18/Desktop/385_FPGA_project/lab_5/../Lab5provided {C:/Users/ldm18/Desktop/385_FPGA_project/lab_5/../Lab5provided/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run 1000 ns
