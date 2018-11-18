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

use work.INSTRUCTION_TOOLS.all;

ARCHITECTURE behaviour OF instruction_tb IS
BEGIN
    test_process : process
    variable test_instruction : std_logic_vector(31 downto 0);
    variable test : INSTRUCTION;
    BEGIN
        test_instruction := (others => '0');
        test_instruction(5 downto 0) := "100000"; -- ADD function code
        test := getInstruction(test_instruction);
        assert test.format = R_TYPE report "Did not report the right instruction format for ADD" severity error;
        assert test.instruction_type = ADD report "Did not report the right instruction type for ADD" severity error;

        test := makeInstruction("000000", 1,2,3,0, "100000"); -- ADD R1 R2 R3
        assert test.instruction_type = ADD report "Did not report the right instruction type for ADD" severity error;
        assert test.format = R_TYPE report "Did not report the right instruction format for ADD" severity error;
        
        
        test := makeInstruction("000010", 1,2,3,0, "000000"); -- jump
        assert test.instruction_type = JUMP report "Did not report the right instruction type for JUMP" severity error;
        assert test.format = J_TYPE report "Incorrect format for Jump instruction" severity error;

        test := makeInstruction("000010", 1231);
        assert test.format = J_TYPE report "Incorrect format for Jump with integer address" severity error;
        assert test.instruction_type = JUMP report "Did not create a Jump instruction correctly" severity error;
        assert test.address = 1231 report "Did not correctly return the jump address supplied." severity error;


        
        
        wait;

    END PROCESS;

 
END;