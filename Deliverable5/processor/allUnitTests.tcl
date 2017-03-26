vlib work

;# Compile the needed components
vcom decodeStage/reg_file/reg_file.vhd
vcom decodeStage/reg_file/reg_file_tb.vhd
vcom instruction/instruction.vhd
vcom instruction/instruction_tb.vhd
vcom fetchStage/fetchStage.vhd
vcom fetchStage/fetchStage_tb.vhd
vcom decodeStage/decodeStage.vhd
vcom decodeStage/decodeStage_tb.vhd
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

vcom tests/addi_tb.vhd
vcom tests/add_tb.vhd
vcom tests/beq_tb.vhd
vcom tests/bne_tb.vhd
vcom tests/j_tb.vhd
vcom tests/jal_tb.vhd
vcom tests/jr_tb.vhd
vcom tests/lw_tb.vhd
vcom tests/sll_tb.vhd
vcom tests/sra_tb.vhd
vcom tests/srl_tb.vhd


;# Start simulation
vsim addi_tb
vsim add_tb
vsim beq_tb
vsim bne_tb
vsim j_tb
vsim jal_tb
vsim jr_tb
vsim lw_tb
vsim sll_tb
vsim sra_tb
vsim srl_tb

;# Run for 10000 ns
run 10000ns