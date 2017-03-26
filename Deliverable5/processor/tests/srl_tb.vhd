LIBRARY ieee;
	USE ieee.std_logic_1164.all;
	USE ieee.numeric_std.all;
	USE ieee.std_logic_textio.all;

library std;
    use std.textio.all;

use work.INSTRUCTION_TOOLS.all;
use work.REGISTERS.all;

entity srl_tb is
end srl_tb ; 

architecture instruction_test of srl_tb is
    constant OPERATION : string := "srl";

    constant clock_period : time := 1 ns;
    constant data_memory_dump_path : string := "tests/"& OPERATION &"_memory.txt";
    -- not used in this case.
    constant instruction_memory_load_path : string := "tests/"& OPERATION &"_program.txt";
    constant register_file_path : string := "tests/"& OPERATION & "_register_file.txt";
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

    signal override_input_instruction : std_logic := '1';
    signal input_instruction : INSTRUCTION := NO_OP_INSTRUCTION;

    constant test_max_memory_usage : integer := 10;
    type results_array_type is array (0 to test_max_memory_usage) of std_logic_vector(31 downto 0);
    signal expected_results : results_array_type := (others => (others => '0'));
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
    file 	 infile: text;
    variable inline: line;
    variable result : std_logic_vector(31 downto 0);
begin
    report "starting " & OPERATION & " test process";
    initialize <= '1';
    wait for clock_period;
    initialize <= '0';

    -- To test by loading the corresponding program.txt, set to '0'.
    -- When set to '1', input instructions are manually passed with the input_instruction signal. 
    override_input_instruction <= '0';
    
    -- TEST PROGRAM: (should match the corresponding [operation]_program.txt)
    -- ADDI R1 R0 5
    -- srl R2 R1 1
    -- sw r2 4(r0)


    -- EXPECTED RESULTS: (should match the corresponding lines in [operation]_memory.txt)
    expected_results(0) <= std_logic_vector(to_unsigned(0, 32));
    expected_results(1) <= std_logic_vector(to_unsigned(2, 32));
    
    -- put a breakpoint on the wait signal when debugging
    test_loop : for i in 0 to 50 loop
        wait for clock_period;
    end loop ; -- test_loop


        
	
    
    dump <= '1'; --dump data
    wait for clock_period;
    dump <= '0';
    wait for clock_period;


    -- Compare the content of the memory dump with the expected results.
    file_open(infile, data_memory_dump_path, read_mode);
    for i in 0 to test_max_memory_usage loop
        readline(infile, inline);
        read(inline, result);
        assert result = expected_results(i) report "Unexpected result at line " & integer'image(i) & " in file " & data_memory_dump_path severity error;
    end loop;
    file_close(infile);

    report "done testing " & OPERATION & " operation.";
    wait;
    
end process test_process;

end architecture ;