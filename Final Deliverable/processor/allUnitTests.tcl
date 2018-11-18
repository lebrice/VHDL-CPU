vlib work

;# Compile the needed components
vcom prediction/branch_predictor.vhd -quiet
vcom prediction/prediction.vhd -quiet
vcom decodeStage/reg_file/reg_file.vhd -quiet
vcom decodeStage/reg_file/reg_file_tb.vhd -quiet
vcom instruction/instruction.vhd -quiet
vcom instruction/instruction_tb.vhd -quiet
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

vcom tests/add_tb.vhd -quiet
vcom tests/sub_tb.vhd -quiet
vcom tests/addi_tb.vhd -quiet
vcom tests/mult_tb.vhd -quiet
vcom tests/div_tb.vhd -quiet
vcom tests/slt_tb.vhd -quiet
vcom tests/slti_tb.vhd -quiet
vcom tests/and_tb.vhd -quiet
vcom tests/or_tb.vhd -quiet
vcom tests/nor_tb.vhd -quiet
vcom tests/xor_tb.vhd -quiet
vcom tests/andi_tb.vhd -quiet
vcom tests/ori_tb.vhd -quiet
vcom tests/xori_tb.vhd -quiet
vcom tests/lui_tb.vhd -quiet
vcom tests/sll_tb.vhd -quiet
vcom tests/srl_tb.vhd -quiet
vcom tests/sra_tb.vhd -quiet
vcom tests/lw_tb.vhd -quiet
vcom tests/beq_tb.vhd -quiet
vcom tests/bne_tb.vhd -quiet
vcom tests/j_tb.vhd -quiet
vcom tests/jr_tb.vhd -quiet
vcom tests/jal_tb.vhd -quiet


;# Start simulation and run each tb
vsim add_tb -quiet
run 1000ns
vsim sub_tb -quiet
run 1000ns
vsim addi_tb -quiet
run 1000ns
vsim mult_tb -quiet
run 1000ns
vsim div_tb -quiet
run 1000ns
vsim slt_tb -quiet
run 1000ns
vsim slti_tb -quiet
run 1000ns
vsim and_tb -quiet
run 1000ns
vsim or_tb -quiet
run 1000ns
vsim nor_tb -quiet
run 1000ns
vsim xor_tb -quiet
run 1000ns
vsim andi_tb -quiet
run 1000ns
vsim ori_tb -quiet
run 1000ns
vsim xori_tb -quiet
run 1000ns
vsim lui_tb -quiet
run 1000ns
vsim sll_tb -quiet
run 1000ns
vsim srl_tb -quiet
run 1000ns
vsim sra_tb -quiet
run 1000ns
vsim lw_tb -quiet
run 1000ns
vsim beq_tb -quiet
run 1000ns
vsim bne_tb -quiet
run 1000ns
vsim j_tb -quiet
run 1000ns
vsim jr_tb -quiet
run 1000ns
vsim jal_tb -quiet
run 1000ns
