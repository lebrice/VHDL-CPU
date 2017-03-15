LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.instruction_tools.all;

ENTITY id_ex_entity IS
	PORT (
        clock: IN STD_LOGIC;
        pc_in: IN INTEGER;
        pc_out: OUT INTEGER;
        instruction_in: IN INSTRUCTION;
        instruction_out: OUT INSTRUCTION;
        sign_extend_imm_in: IN INTEGER;
        sign_extend_imm_out: OUT INTEGER;
        a_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        a_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        b_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        b_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END id_ex_entity;

ARCHITECTURE id_ex_architecture OF id_ex_entity IS
    SIGNAL pc_intermediate: INTEGER;
    SIGNAL instruction_intermediate: INSTRUCTION;
    SIGNAL sign_extend_imm_intermediate: INTEGER;
    SIGNAL a_intermediate: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL b_intermediate: STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
    id_ex_process: PROCESS (clock)
    BEGIN
        IF(clock'EVENT AND clock = '1') THEN
            pc_intermediate <= pc_in;
            pc_out <= pc_intermediate;

            instruction_intermediate <= instruction_in;
            instruction_out <= instruction_intermediate;

            sign_extend_imm_intermediate <= sign_extend_imm_in;
            sign_extend_imm_out <= sign_extend_imm_intermediate;

            a_intermediate <= a_in;
            a_out <= a_intermediate;

            b_intermediate <= b_in;
            b_out <= b_intermediate;
        END IF;
    END PROCESS;

END id_ex_architecture;