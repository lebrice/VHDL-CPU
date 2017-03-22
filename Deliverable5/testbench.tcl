vlib work

;# Compile the needed components

vcom instruction/instruction.vhd
vcom instruction/instruction_tb.vhd
vcom fetchStage/fetchStage.vhd
vcom fetchStage/fetchStage_tb.vhd

vcom decodeStage/decodeStage.vhd
vcom decodeStage/decodeStage_tb.vhd
vcom decodeStage/reg_file/reg_file.vhd
vcom decodeStage/reg_file/reg_file_tb.vhd

vcom executeStage/alu.vhd
vcom executeStage/executeStage.vhd
vcom executeStage/executeStage_tb.vhd

vcom pipeline_registers/EX_MEM.vhd
vcom pipeline_registers/ID_EX.vhd
vcom pipeline_registers/IF_ID.vhd
vcom pipeline_registers/MEM_WB.vhd

vcom memory/memory.vhd
vcom memory/memory_tb.vhd
vcom memoryStage/memoryStage.vhd
vcom memoryStage/memoryStage_tb.vhd

vcom writebackStage/writebackStage.vhd
vcom writebackStage/writebackStage_tb.vhd

vcom cpu.vhd
vcom cpu_tb.vhd

;# Start simulation
vsim cpu_tb

;# Run for 10000 ns
run 10000ns