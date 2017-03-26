vlib work

;# Compile the needed components

vcom ../instruction/instruction.vhd
vcom ../instruction/instruction_tb.vhd
vcom ../fetchStage/fetchStage.vhd
vcom ../fetchStage/fetchStage_tb.vhd
vcom ../decodeStage/decodeStage.vhd
vcom ../decodeStage/decodeStage_tb.vhd
vcom ../decodeStage/reg_file/reg_file.vhd
vcom ../decodeStage/reg_file/reg_file_tb.vhd
vcom ../executeStage/alu.vhd
vcom ../executeStage/executeStage.vhd
vcom ../executeStage/executeStage_tb.vhd
vcom ../pipeline_registers/EX_MEM.vhd
vcom ../pipeline_registers/ID_EX.vhd
vcom ../pipeline_registers/IF_ID.vhd
vcom ../pipeline_registers/MEM_WB.vhd
vcom ../memory/memory.vhd
vcom ../memory/memory_tb.vhd
vcom ../memoryStage/memoryStage.vhd
vcom ../memoryStage/memoryStage_tb.vhd
vcom ../writebackStage/writebackStage.vhd
vcom ../writebackStage/writebackStage_tb.vhd
vcom ../cpu.vhd
vcom ../cpu_tb.vhd

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
vsim tests/addi_tb.vhd
vsim tests/add_tb.vhd
vsim tests/beq_tb.vhd
vsim tests/bne_tb.vhd
vsim tests/j_tb.vhd
vsim tests/jal_tb.vhd
vsim tests/jr_tb.vhd
vsim tests/lw_tb.vhd
vsim tests/sll_tb.vhd
vsim tests/sra_tb.vhd
vsim tests/srl_tb.vhd

;# Run for 10000 ns
run 10000ns