LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.INSTRUCTION_TOOLS.all;

ENTITY fetchStage_tb IS
END fetchStage_tb;

ARCHITECTURE behaviour OF fetchStage_tb IS

    constant bit_width : INTEGER := 32;
    constant ram_size : INTEGER := 8192;
    constant clock_period : time := 1 ns;
    
    -- component under test.
    COMPONENT fetchStage IS
        PORT (
            clock : in std_logic;
            branchTarget : in std_logic_vector(31 downto 0);
            branch : in std_logic;
            disableAdder : in std_logic;
            instruction : out Instruction;
            PCPlus4 : out std_logic_vector(3 downto 0)
        );
    END COMPONENT;

    --all the input signals with initial values
    signal clock : std_logic := '0';
    signal branchTarget : std_logic_vector(31 downto 0);
    signal branch : std_logic;
    signal disableAdder : std_logic;
    signal instruction : Instruction;
    signal PCPlus4 : std_logic_vector(3 downto 0);

BEGIN
    -- device under test.
    fet: fetchStage PORT MAP(
        clock,
        branchTarget,
        branch,
        disableAdder,
        instruction,
        PCPlus4
    );

    clk_process : process
    BEGIN
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
    end process;

    test_process : process
    BEGIN
        report "Done testing fetch stage." severity NOTE;
        wait;

    END PROCESS;

 
END;