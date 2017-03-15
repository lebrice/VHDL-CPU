LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.instruction_tools.all;

ENTITY ex_mem_entity IS
	PORT (
        clock: IN STD_LOGIC;
        pc_in: IN INTEGER;
        pc_out: OUT INTEGER;
        instruction_in: IN INSTRUCTION;
        instruction_out: OUT INSTRUCTION;
        does_branch_in: IN STD_LOGIC;
        does_branch_out: OUT STD_LOGIC;
        alu_result_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_result_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        b_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        b_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END ex_mem_entity;

ARCHITECTURE ex_mem_architecture OF ex_mem_entity IS
    SIGNAL pc_intermediate: INTEGER;
    SIGNAL instruction_intermediate: INSTRUCTION;
    SIGNAL does_branch_intermediate: STD_LOGIC;
    SIGNAL alu_result_intermediate: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL b_intermediate: STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
    ex_mem_process: PROCESS (clock)
    BEGIN
        IF(clock'EVENT AND clock = '1') THEN
            pc_intermediate <= pc_in;
            pc_out <= pc_intermediate;

            instruction_intermediate <= instruction_in;
            instruction_out <= instruction_intermediate;

            does_branch_intermediate <= does_branch_in;
            does_branch_out <= does_branch_intermediate;

            alu_result_intermediate <= alu_result_in;
            alu_result_out <= alu_result_intermediate;

            b_intermediate <= b_in;
            b_out <= b_intermediate;
        END IF;
    END PROCESS;

END ex_mem_architecture;
