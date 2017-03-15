LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.instruction_tools.all;

ENTITY if_id_entity IS
	PORT (
        clock: IN STD_LOGIC;
        pc_in: IN INTEGER;
        pc_out: OUT INTEGER;
        instruction_in: IN INSTRUCTION;
        instruction_out: OUT INSTRUCTION;
        stall: IN STD_LOGIC
	);
END if_id_entity;

ARCHITECTURE if_id_architecture OF if_id_entity IS
    SIGNAL pc_intermediate: INTEGER;
    SIGNAL instruction_intermediate: INSTRUCTION;
BEGIN
    if_id_process: PROCESS (clock)
    BEGIN
        IF(clock'EVENT AND clock = '1') THEN
            IF(stall = '0') THEN -- Only update intermediate and output values if we are not stalled.
                pc_intermediate <= pc_in; 
                pc_out <= pc_intermediate;

                instruction_intermediate <= instruction_in;
                instruction_out <= instruction_intermediate;
            END IF;
        END IF;
    END PROCESS;

END if_id_architecture;
