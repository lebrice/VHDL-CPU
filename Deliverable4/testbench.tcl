vlib work

;# Compile the needed components
vcom processor/instruction/instruction.vhd
vcom processor/memory/memory.vhd
vcom processor/writeback/writebackStage.vhd
vcom processor/alu.vhd
vcom processor/executeStage/executeStage.vhd
vcom processor/decode/reg_file/reg_file.vhd
vcom processor/decode/decodeStage.vhd
vcom processor/fetchStage/fetchStage.vhd
vcom processor/pipeline_registers/EX_MEM.vhd
vcom processor/pipeline_registers/ID_EX.vhd
vcom processor/pipeline_registers/IF_ID.vhd
vcom processor/pipeline_registers/MEM_WB.vhd
vcom processor/memoryStage/memoryStage.vhd
vcom processor/cpu.vhd
vcom processor/cpu_tb.vhd

;# Start simulation
vsim cpu_tb

;# Run for 50 ns
run 50ns