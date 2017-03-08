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
            PC : out integer;
            m_addr : out integer;
            m_read : out std_logic;
            m_readdata : in std_logic_vector (bit_width-1 downto 0);
            m_write : out std_logic;
            m_writedata : out std_logic_vector (bit_width-1 downto 0);
            m_waitrequest : in std_logic -- unused until the Avalon Interface is added.
        );
    END COMPONENT;

    COMPONENT memory IS
        GENERIC(
            ram_size : INTEGER := ram_size;
            bit_width : INTEGER := bit_width;
            mem_delay : time := 0.1 ns;
            clock_period : time := clock_period
        );
        PORT (
            clock: IN STD_LOGIC;
            writedata: IN STD_LOGIC_VECTOR (bit_width-1 DOWNTO 0);
            address: IN INTEGER;
            memwrite: IN STD_LOGIC;
            memread: IN STD_LOGIC;
            readdata: OUT STD_LOGIC_VECTOR (bit_width-1 DOWNTO 0);
            waitrequest: OUT STD_LOGIC
        );
    END COMPONENT;

    --all the input signals with initial values
    signal clock : std_logic;
    signal reset : std_logic;
    signal branch_target : integer := 0;
    signal branch_condition : std_logic := '0';
    signal stall : std_logic;
    signal instruction : Instruction;
    signal PC : integer;

    signal mem_addr : integer;
    signal mem_read : std_logic;
    signal mem_readdata : std_logic_vector (bit_width-1 downto 0);
    signal mem_write : std_logic;
    signal mem_writedata : std_logic_vector (bit_width-1 downto 0);
    signal mem_waitrequest : std_logic; -- unused until the Avalon Interface is added.
BEGIN

    -- memory component which will be linked to the fetchStage under test.
    dut: memory 
    PORT MAP(
        clock,
        mem_writedata,
        mem_addr,
        mem_write,
        mem_read,
        mem_readdata,
        mem_waitrequest
    );
    -- device under test.
    fet: fetchStage PORT MAP(
        clock,
        reset,
        branch_target,
        branch_condition,
        stall,
        instruction,
        PC,

        mem_addr,
        mem_read,
        mem_readdata,
        mem_write,
        mem_writedata,
        mem_waitrequest -- unused until the Avalon Interface is added.
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
        assert PC = 0 report "PC is " & integer'image(PC) & " at the start of testing. (It should probably be 0!)" severity warning;
       
        reset <= '1';
        wait for clock_period;
        assert PC = 0 report "PC Should be 0 whenever reset is asserted (PC is "& integer'image(PC) & ")." severity error;
        reset <= '0';


        wait for clock_period;
        assert PC = 4 report "PC Should be 4 (one cycle after a reset)" severity error;

        branch_target <= 36;
        branch_condition <= '0';
        wait for clock_period;
        assert PC = 8 report "PC Should be 8, the branch should not be taken!" severity error;

        branch_condition <= '1';
        wait for clock_period;
        assert PC = 36 report "PC Should be 36 (the branch target), since branch condition is '1'." severity error;
        branch_condition <= '0';

        reset <= '1';
        wait for clock_period;
        assert PC = 0 report "PC Should be 0 whenever reset is asserted (second time)" severity error;
        reset <= '0';


        wait for clock_period;
        assert PC = 4 report "PC Should be 4 (one cycle after a reset, second time)" severity error;

        stall <= '1';
        wait for clock_period;
        assert PC = 4 report "PC should hold whenever stall is asserted." severity error;
        

        wait for clock_period;
        assert PC = 4 report "PC should hold whenever stall is asserted, even for multiple clock cycles." severity error;
        stall <= '0';        
        wait for clock_period;
        assert PC = 8 report "PC Should start incrementing normally again when stall is de-asserted." severity error;

        mem_addr <= 32;



        report "Done testing fetch stage." severity NOTE;
        wait;
    END PROCESS;

 
END;