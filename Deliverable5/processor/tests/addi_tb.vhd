library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

use work.INSTRUCTION_TOOLS.all;
use work.REGISTERS.all;

entity addi_tb is
end addi_tb ; 

architecture processor_test of addi_tb is
    constant clock_period : time := 1 ns;
    constant data_memory_dump_path : string := "tests/addi_memory.txt";
    -- not used in this case.
    constant instruction_memory_load_path : string := "tests/program.txt";
    COMPONENT CPU is
        generic(
            ram_size : integer := 8196;
            mem_delay : time := 0.1 ns;
            data_memory_dump_filepath : STRING := "memory.txt";
            instruction_memory_load_filepath : STRING := "program.txt";
            clock_period : time := clock_period
        );
        port (
            clock : in std_logic;
            initialize : in std_logic; -- signals to load Instruciton and Data Memories. Should be held at '1' for at least a few clock cycles.
            dump : in std_logic; -- similar to above but for dump instead of load.
            IF_ID_instruction : out INSTRUCTION; 
            ID_EX_instruction : out INSTRUCTION; 
            EX_MEM_instruction : out INSTRUCTION;
            MEM_WB_instruction : out INSTRUCTION;
            WB_instruction : out INSTRUCTION;
            WB_data : out std_logic_vector(63 downto 0);
            fetch_PC : out integer;
            decode_register_file : out REGISTER_BLOCK;
            ALU_out : out std_logic_vector(63 downto 0);
            input_instruction : in INSTRUCTION;
            override_input_instruction : in std_logic
        );
    end COMPONENT;
    signal dump : std_logic := '0';
    signal clock : std_logic := '0';
    signal initialize : std_logic := '0';


    signal IF_ID_instruction : INSTRUCTION; 
    signal ID_EX_instruction : INSTRUCTION; 
    signal EX_MEM_instruction : INSTRUCTION;
    signal MEM_WB_instruction : INSTRUCTION;
    signal WB_instruction : INSTRUCTION;
    signal WB_data : std_logic_vector(63 downto 0);

    signal PC : integer;

    signal decode_register_file : REGISTER_BLOCK;

    signal ALU_out_copy : std_logic_vector(63 downto 0);

    signal input_instruction : INSTRUCTION := NO_OP_INSTRUCTION;
    signal override_input_instruction : std_logic := '1';

begin

c1 : CPU 
GENERIC MAP (
    data_memory_dump_filepath => data_memory_dump_path
)
PORT MAP (
    clock,
    initialize,
    dump,
    IF_ID_instruction,
    ID_EX_instruction, 
    EX_MEM_instruction,
    MEM_WB_instruction,
    WB_instruction,
    WB_data,
    PC,
    decode_register_file,
    ALU_out_copy,
    input_instruction,
    override_input_instruction
);


clock_process : process
begin
    clock <= '0';
    wait for clock_period/2;
    clock <= '1';
    wait for clock_period/2;
end process ; -- clock_process


test_process : process
begin
    report "starting test process";
    initialize <= '1';
    wait for clock_period;
    initialize <= '0';
    input_instruction <= makeInstruction(ADDI_OP, 0, 1, 15);
    wait for clock_period;

    report "stopped for testing" severity failure;

    wait for 10 * clock_period;
    dump <= '1'; --dump data
    wait for clock_period;
    dump <= '0';
    wait for clock_period;
    wait;
    report "Dumped Contents into 'addi_memory.txt' and 'register_file.txt'";
    
end process test_process;

end architecture ;