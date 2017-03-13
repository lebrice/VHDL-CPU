LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.INSTRUCTION_TOOLS.all;

ENTITY memStage_tb IS
END memStage_tb;

ARCHITECTURE behaviour OF memStage_tb IS

    constant bit_width : INTEGER := 32;
    constant ram_size : INTEGER := 8192;
    constant clock_period : time := 1 ns;
    
    -- Component under test.
    COMPONENT memStage IS
        PORT (
            clock : in std_logic;
            ALU_result_in : in std_logic_vector(31 downto 0);
            ALU_result_out : out std_logic_vector(31 downto 0);
            instruction_in : in INSTRUCTION;
            instruction_out : out INSTRUCTION;
            branch_taken_in : in  std_logic;
            branch_taken_out : out  std_logic;
            val_b : in std_logic_vector(31 downto 0);
            mem_data : out std_logic_vector(31 downto 0);

            m_addr : out integer range 0 to ram_size-1;
            m_read : out std_logic;
            m_readdata : in std_logic_vector (bit_width-1 downto 0);        
            m_writedata : out std_logic_vector (bit_width-1 downto 0);
            m_write : out std_logic;
            m_waitrequest : in std_logic -- Unused until the Avalon Interface is added.
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

    -- All the input signals with initial values.
    -- Signals for memory component.

    -- Signals for mem_stage component.
    signal ALU_result_in : std_logic_vector(31 downto 0);
    signal ALU_result_out : std_logic_vector(31 downto 0);
    signal instruction_in : INSTRUCTION;
    signal instruction_out : INSTRUCTION;
    signal branch_taken_in : std_logic;
    signal branch_taken_out : std_logic;
    signal val_b : std_logic_vector(31 downto 0);
    signal mem_data : std_logic_vector(31 downto 0);

    -- Shared signals.
    signal clock : std_logic;
    signal mem_writedata : std_logic_vector (bit_width-1 downto 0);
    signal mem_addr : integer range 0 to ram_size-1;
    signal mem_write : std_logic;
    signal mem_read : std_logic;
    signal mem_readdata : std_logic_vector (bit_width-1 downto 0);
    signal mem_waitrequest : std_logic; -- unused until the Avalon Interface is added.

    -- Signals for helping with testing.
    signal test_addr : integer range 0 to ram_size-1;
    signal accessing_memory : std_logic;
    signal test_mem_read : std_logic;

BEGIN

    mem_addr <= test_addr when accessing_memory = '1' else mem_addr;
    mem_read <= test_mem_read when accessing_memory = '1' else mem_read;
    
    -- Memory component which will be linked to the fetchStage under test.
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
    -- Stage under test.
    mem_stage: memStage 
    PORT MAP(
        clock,
        ALU_result_in,
        ALU_result_out,
        instruction_in,
        instruction_out,
        branch_taken_in,
        branch_taken_out,
        val_b,
        mem_data,
        mem_addr,
        mem_read,
        mem_readdata,
        mem_writedata,
        mem_write,
        mem_waitrequest
    );

    -- Clock.
    clk_process : process
    BEGIN
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
    end process;

    -- Testing process.
    test_process : process;
    BEGIN
        -- Store instruction
        ALU_result_in <= x"0000FF00";
        instruction_in <= makeInstruction(SW_OP, 1, 1, 0);
        branch_taken_in <= '0';
        val_b <= x"FEFEFEFE";
        wait for clock_period;
        
        accessing_memory <= '1';
        test_addr <= X"0000FF00";
        test_mem_read <= '1';
        assert mem_read_data = X"FEFEFEFE" report "The wrong value was read from memory!" severity error;
        accessing_memory <= '0';

        -- Load instruction
        ALU_result_in <= x"0000FF00";
        -- instruction_in <= LOAD_WORD;
        instruction_in <= makeInstruction(LW_OP, 1, 1, 0);
        branch_taken_in <= '0';
        wait for clock_period;
        assert mem_data = x"FEFEFEFE" report "mem_data should be FEFEFEFE; Did not correctly load or store!" severity error;

        -- Branch
        instruction_in <= makeInstruction(BEQ_OP, 1, 1, 8);
        branch_taken_in <= '1';
        wait for clock_period;
        assert branch_taken_out = '1' report "branch_taken_out should be 1" severity error;

    end process;

END behaviour ; -- behaviour


