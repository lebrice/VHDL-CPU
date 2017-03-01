-- cache_tb.vhd: For testing cache.vhd
-- Fabrice Normandin, ID 260636800
-- Asher Wright, ID 260559393
-- William Stephen Poole, ID 260508650
-- Stephan Greto-McGrath, ID 
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY instruction_tb IS
END instruction_tb;

use work.OPCODE_TOOLS.all;

ARCHITECTURE behaviour OF instruction_tb IS
BEGIN
    test_process : process
    variable inst : INSTRUCTION;
    variable test_instruction : std_logic_vector(31 downto 0);
    BEGIN
        test_instruction := (others => '0');
        test_instruction(5 downto 0) := "100000"; -- ADD function code
        inst := getInstruction(test_instruction);
        assert inst.format = R_TYPE report "Did not report the right instruction format for ADD" severity error;
        assert inst.instruction_type = ADD report "Did not report the right instruction type for ADD" severity error;
        wait;

    END PROCESS;

 
END;