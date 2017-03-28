LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.instruction_tools.all;

ENTITY ID_EX_REGISTER IS
	PORT (
        clock: IN STD_LOGIC;
        pc_in: IN INTEGER;
        pc_out: OUT INTEGER;
        instruction_in: IN INSTRUCTION;
        instruction_out: OUT INSTRUCTION;
        sign_extend_imm_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        sign_extend_imm_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        a_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        a_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        b_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        b_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END ID_EX_REGISTER;

ARCHITECTURE id_ex_architecture OF ID_EX_REGISTER IS
    SIGNAL pc_intermediate: INTEGER;
    SIGNAL instruction_intermediate: INSTRUCTION;
    SIGNAL sign_extend_imm_intermediate: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL a_intermediate: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL b_intermediate: STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
    pc_out <= pc_intermediate;
    instruction_out <= instruction_intermediate;
    sign_extend_imm_out <= sign_extend_imm_intermediate;
    a_out <= a_intermediate;
    b_out <= b_intermediate;

    id_ex_process: PROCESS (clock, pc_in, instruction_in, sign_extend_imm_in, a_in, b_in)
    BEGIN
        IF(rising_edge(clock)) THEN
            -- report "ID_EX Register";
            pc_intermediate <= pc_in;
            instruction_intermediate <= instruction_in;
            sign_extend_imm_intermediate <= sign_extend_imm_in;
            a_intermediate <= a_in;
            b_intermediate <= b_in;
        END IF;
    END PROCESS;

END id_ex_architecture;
