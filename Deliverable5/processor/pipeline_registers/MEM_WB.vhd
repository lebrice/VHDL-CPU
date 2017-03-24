LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.instruction_tools.all;

ENTITY MEM_WB_REGISTER IS
	PORT (
        clock: IN STD_LOGIC;
        instruction_in: IN INSTRUCTION;
        instruction_out: OUT INSTRUCTION;
        alu_result_in: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        alu_result_out: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
        data_mem_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        data_mem_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END MEM_WB_REGISTER;

ARCHITECTURE mem_wb_architecture OF MEM_WB_REGISTER IS
    SIGNAL instruction_intermediate: INSTRUCTION;
    SIGNAL alu_result_intermediate: STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL data_mem_intermediate: STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
    instruction_out <= instruction_intermediate;
    data_mem_out <= data_mem_intermediate;
    alu_result_out <= alu_result_intermediate;

    mem_wb_process: PROCESS (clock, instruction_in, data_mem_in, alu_result_in)
    BEGIN
        IF(rising_edge(clock)) THEN
            -- report "MEM_WB register";
            instruction_intermediate <= instruction_in;
            data_mem_intermediate <= data_mem_in;
            alu_result_intermediate <= alu_result_in;
        END IF;
    END PROCESS;

END mem_wb_architecture;
