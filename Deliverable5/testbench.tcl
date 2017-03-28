vlib work

;# Compile the needed components
vcom decodeStage/reg_file/reg_file.vhd -quiet
vcom decodeStage/reg_file/reg_file_tb.vhd -quiet
vcom instruction/instruction.vhd -quiet
vcom instruction/instruction_tb.vhd -quiet
vcom branch_management.vhd -quiet
vcom fetchStage/fetchStage.vhd -quiet
vcom fetchStage/fetchStage_tb.vhd -quiet
vcom decodeStage/decodeStage.vhd -quiet
vcom decodeStage/decodeStage_tb.vhd -quiet
vcom executeStage/alu.vhd -quiet
vcom executeStage/executeStage.vhd -quiet
vcom executeStage/executeStage_tb.vhd -quiet
vcom pipeline_registers/EX_MEM.vhd -quiet
vcom pipeline_registers/ID_EX.vhd -quiet
vcom pipeline_registers/IF_ID.vhd -quiet
vcom pipeline_registers/MEM_WB.vhd -quiet
vcom memory/memory.vhd -quiet
vcom memory/memory_tb.vhd -quiet
vcom memoryStage/memoryStage.vhd -quiet
vcom memoryStage/memoryStage_tb.vhd -quiet
vcom writebackStage/writebackStage.vhd -quiet
vcom writebackStage/writebackStage_tb.vhd -quiet
vcom cpu.vhd -quiet
vcom cpu_tb.vhd -quiet

vsim cpu_tb -quiet
run 10000ns