LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.INSTRUCTION_TOOLS.all;
USE work.registers.all;

ENTITY decodeStage_tb IS
END decodeStage_tb;

architecture behaviour of decodeStage_tb is

    constant clock_period : time := 1 ns;

    component decodeStage is
        port (
            clock : in std_logic;

            -- Inputs coming from the IF/ID Register
            PC : in integer;
            instruction_in : in INSTRUCTION;


            -- Instruction and data coming from the Write-Back stage.
            write_back_instruction : in INSTRUCTION;
            write_back_data : in std_logic_vector(63 downto 0);


            -- Outputs to the ID/EX Register
            val_a : out std_logic_vector(31 downto 0);
            val_b : out std_logic_vector(31 downto 0);
            i_sign_extended : out std_logic_vector(31 downto 0);
            PC_out : out integer;
            instruction_out : out INSTRUCTION;

            register_file_out : out REGISTER_BLOCK;
            write_register_file : in std_logic;
            reset_register_file : in std_logic;      

            -- Stall signal out.
            stall_in : std_logic;
            stall_out : out std_logic
            
        );
    end component;

signal clock : std_logic;
signal PC : integer;
signal instruction_in : INSTRUCTION;
signal write_back_instruction : INSTRUCTION;
signal write_back_data : std_logic_vector(63 downto 0);
signal val_a : std_logic_vector(31 downto 0);
signal val_b : std_logic_vector(31 downto 0);
signal i_sign_extended : std_logic_vector(31 downto 0);
signal PC_out : integer;
signal instruction_out : INSTRUCTION;
signal register_file_out : REGISTER_BLOCK;
signal write_register_file : std_logic;
signal reset_register_file : std_logic;

signal stall_in : std_logic := '0';
signal stall_out : std_logic;

signal val_a_int : integer;
signal val_b_int : integer;

signal write_back_data_int : integer;

begin

    dec : decodeStage port map (
        clock,
        PC,
        instruction_in,
        write_back_instruction,
        write_back_data,
        val_a,val_b,
        i_sign_extended,
        PC_out,
        instruction_out,
        register_file_out,
        write_register_file,
        reset_register_file,
        stall_in,
        stall_out
    );


    val_a_int <= to_integer(unsigned(val_a));
    val_b_int <= to_integer(unsigned(val_b));
    write_back_data <= std_logic_vector(to_unsigned(write_back_data_int, 64));

    clk_process : process
    BEGIN
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
    end process;

    test_process : process
    begin
        
        PC <= 0;
        reset_register_file <= '1';
        stall_in <= '1';

        wait for clock_period;

        for I in 0 to NUM_REGISTERS-1 loop
            -- check that each register was properly initialized.
            assert register_file_out(I).data = std_logic_vector(to_unsigned(0, 32)) report "Register wasn't initialized properly!" severity failure;
            assert register_file_out(I).busy = '0' report "Registers did not have their busy bit initialized properly!" severity failure;
        end loop;

        reset_register_file <= '0';
        stall_in <= '0';
        
        wait for clock_period;
        -- instruction_in <= makeInstruction(ALU_OP, 1,2,3,0, ADD_FN); -- ADD R1 R2 R3

        -- Test 1, we're testing the data is written into the register file.
        instruction_in <= NO_OP_INSTRUCTION;
        write_back_instruction <= makeInstruction(ALU_OP, 1,1,1,0, ADD_FN); -- ADD R1 R1 R1
        write_back_data_int <= 10;
        assert register_file_out(1).data = std_logic_vector(to_unsigned(10, 32)) report "Data was not correctly written into the register." severity ERROR;
        assert register_file_out(1).busy = '0' report "The Busy bit was set for no reason!" severity ERROR;

        

        

        wait for clock_period;

        -- assert instruction_in.rd = 3 report "instruciton_in should have rd=3!" severity failure; 
        -- assert PC_out = 0 report "PC isn't output correctly" severity error;
        -- assert val_a_int = 10 report "Value A should be 10, but we have " & integer'image(val_a_int) severity error;
        -- assert val_b_int = 20 report "Value B should be 20, but we have " & integer'image(val_b_int) severity error;
        -- assert register_file_out(3).busy = '1' report "Register R3 should be busy, since the result of the addition is going into it." severity error;
        -- assert stall_out = '0' report "Stall_Out should definitely NOT be '1' right here." severity error;
        -- assert instruction_out.format = R_TYPE report "The output instruction does not have the right format! (Should have R Type)" severity error;
        -- assert instruction_out.instruction_type = ADD report "The output instruction does NOT have the right type (expecting Add)" severity error;
        -- assert instruction_out.rs = 1 report "Instruction RS is wrong! (got " & integer'image(instruction_out.rs) & ", was expecting 1" severity error;
        -- assert instruction_out.rt = 2 report "Instruction RT is wrong! (got " & integer'image(instruction_out.rt) & ", was expecting 2" severity error;
        -- assert instruction_out.rd = 3 report "Instruction RD is wrong! (got " & integer'image(instruction_out.rd) & ", was expecting 3" severity error;
        -- assert instruction_out.shamt = 0 report "Instruction shift amount should be 0." severity error;

        -- wait for clock_period;    

        -- instruction_in <= NO_OP_INSTRUCTION;
        -- assert register_file_out(3).busy = '1' report "Register R3 should still be busy, since we haven't received the Write-Back instruction writing its result." severity error;
        
        -- wait for clock_period;

        -- -- simulate the data coming back from the Write-Back stage, and check that it is written correctly.
        -- write_back_instruction <= makeInstruction(ALU_OP, 1,2,3,0, ADD_FN); -- the "same" instruction comes back from WB
        -- write_back_data_int <= 30; -- result of 10 + 20.

        -- assert register_file_out(3).data = std_logic_vector(to_unsigned(30, 32)) report "The result (30) should have been written back!" severity error;
        -- assert register_file_out(3).busy = '0' report "$R3 should not be busy, since we just wrote the result back in from WB." severity error;

        -- wait for clock_period;

        -- write_back_instruction <= NO_OP_INSTRUCTION;
        -- instruction_in <= makeInstruction(ALU_OP, 10,15,25,0, ADD_FN); -- ADD $R10, $R15, $R25.
        
        -- wait for clock_period;
        -- assert register_file_out(25).busy = '1' report "Last cycle, we started an operation using $R25, it should be busy!" severity error;
        -- -- this instruction would use $R25, but since it's busy, we would expect a STALL_OUT to arise.
        -- instruction_in <= makeInstruction(ALU_OP, 20, 25, 10, 0, ADD_FN); -- ADD $R20, $R25, $R10 
        -- assert stall_out = '1' report "Stall_out should be '1', since there's a data dependency, and the instruction hasn't come back from WB yet." severity error;

        -- wait for clock_period;
        -- -- the instruction came back from the WB stage.
        -- write_back_instruction <= makeInstruction(ALU_OP, 10,15,25,0, ADD_FN); -- ADD $R10, $R15, $R25.
        -- write_back_data_int <= 250;
        -- assert stall_out = '0' report "The Instruction coming back from WB should de-assert Stall_out" severity error;
        -- assert register_file_out(25).busy = '0' report "Register should be marked with 'busy'='0' after the instruction comes back from WB." severity error;
        -- assert register_file_out(25).data = write_back_data(31 downto 0) report "Write-Back data didn't get written out to the register properly!" severity error;

        report "Done testing decode stage." severity NOTE;
        wait;

    end process;


end behaviour;