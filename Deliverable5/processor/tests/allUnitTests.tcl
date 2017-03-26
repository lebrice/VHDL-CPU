vlib work

;# Compile the needed components
vcom ../decodeStage/reg_file/reg_file.vhd
vcom ../decodeStage/reg_file/reg_file_tb.vhd
vcom ../instruction/instruction.vhd
vcom ../instruction/instruction_tb.vhd
vcom ../fetchStage/fetchStage.vhd
vcom ../fetchStage/fetchStage_tb.vhd
vcom ../decodeStage/decodeStage.vhd
vcom ../decodeStage/decodeStage_tb.vhd
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

vcom addi_tb.vhd
vcom add_tb.vhd
vcom beq_tb.vhd
vcom bne_tb.vhd
vcom j_tb.vhd
vcom jal_tb.vhd
vcom jr_tb.vhd
vcom lw_tb.vhd
vcom sll_tb.vhd
vcom sra_tb.vhd
vcom srl_tb.vhd


;# Start simulation
vsim addi_tb.vhd
vsim add_tb.vhd
vsim beq_tb.vhd
vsim bne_tb.vhd
vsim j_tb.vhd
vsim jal_tb.vhd
vsim jr_tb.vhd
vsim lw_tb.vhd
vsim sll_tb.vhd
vsim sra_tb.vhd
vsim srl_tb.vhd

;# Run for 10000 ns
run 10000ns