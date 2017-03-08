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
            reset : in std_logic;
            branch_target : in integer;
            branch_condition : in std_logic;
            stall : in std_logic;
            instruction : out Instruction;
            PC : out integer
        );
    END COMPONENT;

    --all the input signals with initial values
    signal clock : std_logic := '0';
    signal reset : std_logic := '0';
    signal branch_target : integer := 0;
    signal branch_condition : std_logic := '0';
    signal stall : std_logic;
    signal instruction : Instruction;
    signal PC : integer;

BEGIN
    -- device under test.
    fet: fetchStage PORT MAP(
        clock,
        reset,
        branch_target,
        branch_condition,
        stall,
        instruction
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

        reset <= '1';
        assert PC = 0 report "PC Should be 0 whenever reset is asserted." severity error;
        reset <= '0';


        assert PC = 4 report "PC Should be 4 (one cycle after a reset)" severity error;

        branch_target <= 36;
        branch_condition <= '0';
        assert PC = 8 report "PC Should be 8, the branch should not be taken!" severity error;

        branch_condition <= '1';
        assert PC = 36 report "PC Should be 36 (the branch target), since branch condition is '1'." severity error;
        branch_condition <= '0';

        reset <= '1';
        assert PC = 0 report "PC Should be 0 whenever reset is asserted (second time)" severity error;
        reset <= '0';

        assert PC = 4 report "PC Should be 4 (one cycle after a reset, second time)" severity error;

        stall <= '1';
        assert PC = 4 report "PC should hold whenever stall is asserted." severity error;
        
        assert PC = 4 report "PC should hold whenever stall is asserted, even for multiple clock cycles." severity error;
        stall <= '0';

        assert PC = 8 report "PC Should start incrementing normally again when stall is de-asserted." severity error;
        






        report "Done testing fetch stage." severity NOTE;
        wait;
    END PROCESS;

 
END;