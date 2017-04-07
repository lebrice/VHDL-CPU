library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

use work.INSTRUCTION_TOOLS.all;
use work.REGISTERS.all;

entity cpu_tb is
end cpu_tb ; 

architecture processor_test of cpu_tb is
    constant clock_period : time := 1 ns;
    COMPONENT CPU is
        generic(
            ram_size : integer := 8196;
            mem_delay : time := 0.1 ns;
            data_memory_dump_filepath : STRING := "memory.txt";
            instruction_memory_load_filepath : STRING := "program.txt";
            register_file_dump_filepath : STRING := "register_file.txt";
            clock_period : time := 1 ns
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

    signal input_instruction : INSTRUCTION;
    signal override_input_instruction : std_logic := '0';

begin

c1 : CPU PORT MAP (
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
    wait for clock_period;
    report "initialized.";

    for i in 0 to 50 loop
      wait for clock_period;
    end loop;

    wait for 9900 ns;
    report "dumping...";
    dump <= '1'; --dump data
    wait for clock_period;
    dump <= '0';
    wait for clock_period;
    report "Dumped Contents into 'memory.txt' and 'register_file.txt'";
    wait;

end process test_process;

end architecture ;