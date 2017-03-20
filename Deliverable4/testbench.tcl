vlib work

;# Compile the needed components
vcom instruction.vhd
vcom memory.vhd
vcom writebackStage.vhd
vcom alu.vhd
vcom executeStage.vhd
vcom reg_file/reg_file.vhd
vcom decodeStage.vhd
vcom fetchStage.vhd
vcom EX_MEM.vhd
vcom ID_EX.vhd
vcom IF_ID.vhd
vcom MEM_WB.vhd
vcom memoryStage.vhd
vcom cpu.vhd
vcom cpu_tb.vhd

;# Start simulation
vsim cpu_tb

;# Run for 10000 ns
run 10000ns