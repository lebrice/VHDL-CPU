library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;    
	use ieee.std_logic_textio.all;

library std;
    use std.textio.all;

use work.INSTRUCTION_TOOLS.all;
use work.REGISTERS.all;

entity cpu_performance_tb is
end cpu_performance_tb ; 

architecture no_prediction_test of cpu_performance_tb is
    constant clock_period : time := 1 ns;
    constant TEST_NAME : STRING := "NO_PREDICTION";
    constant TEST_FILE_NAME : STRING := "performance_test_program.txt";
    constant RESULTS_FILEPATH : STRING := "./performance_tests/" & TEST_NAME & "_results.txt";
    constant TEST_PROGRAM_FILEPATH : STRING := "./performance_tests/" & TEST_FILE_NAME;
    COMPONENT CPU is
        generic(
        ram_size : integer := 8196;
        mem_delay : time := 0.1 ns;
        data_memory_dump_filepath : STRING := "memory.txt";
        instruction_memory_load_filepath : STRING := "program.txt";
        register_file_dump_filepath : STRING := "register_file.txt";
        clock_period : time := 1 ns;
        predictor_bit_width : integer := 2;
        use_branch_prediction : boolean := false
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
    signal total_time : time;

    procedure write_test_results(total_time : in time) is 
		file     outfile  : text;
		variable outline : line;
	begin
		file_open(outfile, RESULTS_FILEPATH, write_mode);
        write(outline, "Test Name :" & TEST_NAME);
        writeline(outfile, outline);
        write(outline, "Result    :" & time'image(total_time));
        writeline(outfile, outline);
		file_close(outfile);
	end write_test_results;
begin

c1 : CPU GENERIC MAP (
    -- TODO: change this depending on the test case. (Also change the constant TEST_NAME)
    use_branch_prediction => false,
    predictor_bit_width => 2,
    instruction_memory_load_filepath => TEST_PROGRAM_FILEPATH
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
variable exit_register : integer := 30;
variable exit_flag : std_logic_vector(31 downto 0) := (0 => '1', others => '0');
variable start_time, end_time : time;
begin
    report "starting test process";
    initialize <= '1';
    wait for clock_period;
    initialize <= '0';
    wait for clock_period;
    report "initialized.";
    start_time := now;

    for i in 0 to 9990 loop
        wait for clock_period;
        -- check if the program is done (Register 30 contains '1');
        exit when decode_register_file(exit_register).data = exit_flag;
    end loop;

    end_time := now;
    total_time <= end_time - start_time;

    wait for 5 * clock_period;

    report "dumping...";
    dump <= '1'; --dump data
    wait for clock_period;
    dump <= '0';
    wait for clock_period;
    report "Dumped Contents into 'memory.txt' and 'register_file.txt'";

    report "program finished executing in " & time'image(total_time);

    -- Write the test results to a file.
    write_test_results(total_time);

    wait;

end process test_process;

end architecture ;