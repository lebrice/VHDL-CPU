LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.instruction_tools.all;

ENTITY IF_ID_REGISTER IS
	PORT (
        clock: IN STD_LOGIC;
        pc_in: IN INTEGER;
        pc_out: OUT INTEGER;
        instruction_in: IN INSTRUCTION;
        instruction_out: OUT INSTRUCTION;
        stall: IN STD_LOGIC
	);
END IF_ID_REGISTER;

ARCHITECTURE if_id_architecture OF IF_ID_REGISTER IS
    SIGNAL pc_intermediate: INTEGER;
    SIGNAL instruction_intermediate: INSTRUCTION;
BEGIN
    pc_out <= pc_intermediate;
    instruction_out <= instruction_intermediate;

    if_id_process: PROCESS (clock, stall, pc_in, instruction_in)
    BEGIN
        IF(rising_edge(clock)) THEN
            -- report "IF_ID Register";
            IF(stall = '1') THEN -- Only update intermediate and output values if we are not stalled.
                -- report "IF_ID is stalled";
            ELSE
                pc_intermediate <= pc_in; 
                instruction_intermediate <= instruction_in;
            END IF;
        END IF;
    END PROCESS;


END if_id_architecture;
