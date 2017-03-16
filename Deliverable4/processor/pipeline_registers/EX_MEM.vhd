LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.instruction_tools.all;

ENTITY EX_MEM_REGISTER IS
	PORT (
        clock: IN STD_LOGIC;

        pc_in: IN INTEGER;
        pc_out: OUT INTEGER;

        instruction_in: IN INSTRUCTION;
        instruction_out: OUT INSTRUCTION;

        does_branch_in: IN STD_LOGIC;
        does_branch_out: OUT STD_LOGIC;

        alu_result_in: IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        alu_result_out: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);

        branch_target_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_target_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);

        b_value_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        b_value_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END EX_MEM_REGISTER;

ARCHITECTURE ex_mem_architecture OF EX_MEM_REGISTER IS
    SIGNAL pc_intermediate: INTEGER;
    SIGNAL instruction_intermediate: INSTRUCTION;
    SIGNAL does_branch_intermediate: STD_LOGIC;
    SIGNAL alu_result_intermediate: STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL branch_target_intermediate: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL b_value_intermediate: STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
    pc_out <= pc_intermediate;
    instruction_out <= instruction_intermediate;
    does_branch_out <= does_branch_intermediate;
    alu_result_out <= alu_result_intermediate;
    b_value_out <= b_value_intermediate;
    branch_target_out <= branch_target_intermediate;


    ex_mem_process: PROCESS (clock)
    BEGIN
        IF(rising_edge(clock)) THEN
            --set internal signals to incoming signals
            pc_intermediate <= pc_in;
            instruction_intermediate <= instruction_in;
            does_branch_intermediate <= does_branch_in;
            alu_result_intermediate <= alu_result_in;
            b_value_intermediate <= b_value_in;
            branch_target_intermediate <= branch_target_in;
        END IF;
    END PROCESS;

END ex_mem_architecture;
