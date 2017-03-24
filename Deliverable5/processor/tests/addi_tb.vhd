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
    constant register_file_path : string := "tests/addi_register_file.txt";
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

    signal input_instruction : INSTRUCTION := NO_OP_INSTRUCTION;
    signal override_input_instruction : std_logic := '1';

begin

c1 : CPU 
GENERIC MAP (
    data_memory_dump_filepath => data_memory_dump_path,
    register_file_dump_filepath => register_file_path,
    instruction_memory_load_filepath => instruction_memory_load_path,
    clock_period => clock_period
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
    
    input_instruction <= makeInstruction(ADDI_OP, 0, 1, 15); -- ADDI R1, R0, 15
    wait for clock_period;
    input_instruction <= NO_OP_INSTRUCTION;
    
    wait for clock_period;
    wait for clock_period;
    wait for clock_period;
    wait for clock_period;
    
    assert decode_register_file(1).data = x"0000000F" report "ADDI didn't write the right results back into the register" severity error;
    assert decode_register_file(1).busy = '0' report "Busy bit was still set when it shouldn't be." severity error;

    input_instruction <= makeInstruction(ADDI_OP, 1, 2, 15); -- ADDI R2, R1, 15
    wait for clock_period;
    input_instruction <= NO_OP_INSTRUCTION;

    wait for 5 * clock_period;
    -- the result of R1 + 15 is 30 => x"1E"
    assert decode_register_file(2).data = x"0000001E" report "ADDI didn't write the right results back into the register" severity error;
    assert decode_register_file(2).busy = '0' report "Busy bit was still set when it shouldn't be." severity error;

    input_instruction <= makeInstruction(SW_OP, 0, 1, 0); -- SW R1, 0(R0)
    wait for clock_period;
    input_instruction <= makeInstruction(SW_OP, 0, 2, 4); -- SW R2, 4(R0)
    wait for clock_period;
    input_instruction <= NO_OP_INSTRUCTION;
    
    wait for 10 * clock_period;
    
    dump <= '1'; --dump data
    wait for clock_period;
    dump <= '0';
    wait for clock_period;

    report "done testing ADDI";
    wait;
    
end process test_process;

end architecture ;